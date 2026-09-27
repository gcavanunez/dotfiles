/**
 * Bounded long-running goals for Pi.
 *
 * Inspired by mitsuhiko/agent-stuff's goal extension, but intentionally
 * smaller: goals start only through /goal and stop after ten agent turns.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATE_TYPE = "dotfiles-goal";
const CONTINUATION_TYPE = "dotfiles-goal-continuation";
const DEFAULT_MAX_TURNS = 10;

type GoalStatus = "active" | "paused" | "blocked" | "limited" | "complete";

interface Goal {
  objective: string;
  status: GoalStatus;
  turnsUsed: number;
  maxTurns: number;
}

interface PersistedState {
  version: 1;
  goal: Goal | null;
}

const UpdateGoalParams = {
  type: "object",
  properties: {
    status: {
      type: "string",
      enum: ["complete", "blocked"],
      description: "Mark the active goal complete or blocked.",
    },
  },
  required: ["status"],
  additionalProperties: false,
} as const;

function continuationPrompt(goal: Goal): string {
  return `Continue working toward this active goal:

<goal>
${goal.objective}
</goal>

This is turn ${goal.turnsUsed + 1} of at most ${goal.maxTurns} in the current segment.
Inspect current state before acting. Make concrete progress and verify it. If the full objective is achieved, call update_goal with status "complete". If progress is impossible without user input or an external change, call update_goal with status "blocked". Do not narrow the objective to claim completion.`;
}

function activeGoalPrompt(goal: Goal): string {
  return `An explicitly activated goal is active: ${goal.objective}

Keep the full objective in scope. If it is achieved, call update_goal with status "complete". If progress requires user input or an external change, call update_goal with status "blocked".`;
}

function statusText(goal: Goal): string {
  return `Goal ${goal.status}: ${goal.objective}\nTurns: ${goal.turnsUsed}/${goal.maxTurns}`;
}

export default function goalExtension(pi: ExtensionAPI): void {
  let goal: Goal | null = null;
  let activeGoalAtTurnStart = false;
  let continuationQueued = false;
  let herdrBlocked = false;
  let lastStopReason: string | undefined;

  function persist(): void {
    pi.appendEntry(STATE_TYPE, {
      version: 1,
      goal: goal ? { ...goal } : null,
    } satisfies PersistedState);
  }

  function setHerdrBlocked(active: boolean): void {
    if (herdrBlocked === active) return;
    herdrBlocked = active;
    pi.events.emit("herdr:blocked", {
      active,
      label: active ? "Goal needs input" : undefined,
    });
  }

  function updateStatus(ctx: ExtensionContext): void {
    if (!ctx.hasUI) return;
    if (!goal) {
      ctx.ui.setStatus("goal", undefined);
      return;
    }

    const color = goal.status === "active" ? "accent" : goal.status === "complete" ? "success" : "warning";
    ctx.ui.setStatus("goal", ctx.ui.theme.fg(color, `Goal ${goal.status} (${goal.turnsUsed}/${goal.maxTurns})`));
  }

  function show(content: string): void {
    pi.sendMessage(
      { customType: "dotfiles-goal-status", content, display: true },
      { triggerTurn: false },
    );
  }

  function queueContinuation(ctx: ExtensionContext): void {
    if (!goal || goal.status !== "active" || continuationQueued || ctx.hasPendingMessages()) return;

    continuationQueued = true;
    pi.sendMessage(
      {
        customType: CONTINUATION_TYPE,
        content: continuationPrompt(goal),
        display: false,
      },
      ctx.isIdle() ? { triggerTurn: true } : { triggerTurn: true, deliverAs: "followUp" },
    );
  }

  function reconstruct(ctx: ExtensionContext): void {
    goal = null;
    activeGoalAtTurnStart = false;
    continuationQueued = false;
    lastStopReason = undefined;
    setHerdrBlocked(false);

    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type !== "custom" || entry.customType !== STATE_TYPE) continue;
      const state = entry.data as Partial<PersistedState> | undefined;
      const candidate = state?.goal;
      if (
        state?.version === 1 &&
        candidate &&
        typeof candidate.objective === "string" &&
        typeof candidate.turnsUsed === "number" &&
        typeof candidate.maxTurns === "number"
      ) {
        goal = { ...candidate };
      } else if (state?.version === 1 && candidate === null) {
        goal = null;
      }
    }

    if (goal?.status === "active") {
      goal.status = "paused";
      persist();
    }
    if (goal?.status === "blocked") {
      const timer = setTimeout(() => {
        if (goal?.status === "blocked") setHerdrBlocked(true);
      }, 0);
      timer.unref?.();
    }
    updateStatus(ctx);
  }

  pi.on("session_start", async (_event, ctx) => reconstruct(ctx));
  pi.on("session_tree", async (_event, ctx) => reconstruct(ctx));

  pi.on("before_agent_start", async (event) => {
    if (!goal || goal.status !== "active") return;
    return {
      systemPrompt: `${event.systemPrompt}\n\n${activeGoalPrompt(goal)}`,
    };
  });

  pi.on("agent_start", async () => {
    continuationQueued = false;
    activeGoalAtTurnStart = goal?.status === "active";
    lastStopReason = undefined;
  });

  pi.on("agent_end", async (event) => {
    if (!activeGoalAtTurnStart) return;
    const lastAssistant = [...event.messages].reverse().find((message) => message.role === "assistant");
    lastStopReason = lastAssistant?.stopReason;
  });

  pi.on("agent_settled", async (_event, ctx) => {
    if (!goal || !activeGoalAtTurnStart) return;
    activeGoalAtTurnStart = false;
    goal.turnsUsed += 1;

    if (goal.status !== "active") {
      persist();
      updateStatus(ctx);
      return;
    }

    if (lastStopReason === "aborted" || lastStopReason === "error") {
      goal.status = "paused";
      persist();
      show(`${statusText(goal)}\nAutomatic continuation stopped after ${lastStopReason}.`);
      updateStatus(ctx);
      return;
    }

    if (goal.turnsUsed >= goal.maxTurns) {
      goal.status = "limited";
      persist();
      show(`${statusText(goal)}\nRun /goal resume to authorize another ${DEFAULT_MAX_TURNS} turns.`);
      updateStatus(ctx);
      return;
    }

    persist();
    updateStatus(ctx);
    queueContinuation(ctx);
  });

  pi.on("context", async (event) => {
    let latestContinuation = -1;
    for (let index = 0; index < event.messages.length; index += 1) {
      const message = event.messages[index] as { customType?: string };
      if (message.customType === CONTINUATION_TYPE) latestContinuation = index;
    }

    return {
      messages: event.messages.filter((message, index) => {
        const custom = message as { customType?: string };
        if (custom.customType === "dotfiles-goal-status") return false;
        if (custom.customType === CONTINUATION_TYPE) {
          return goal?.status === "active" && index === latestContinuation;
        }
        return true;
      }),
    };
  });

  pi.registerCommand("goal", {
    description: "Start or manage a bounded long-running goal",
    handler: async (args, ctx) => {
      const input = args.trim();
      if (!input) {
        show(goal ? statusText(goal) : "No goal is active. Usage: /goal <objective>");
        return;
      }
      if (!ctx.isIdle()) {
        ctx.ui.notify("Wait for the current goal turn to settle before changing it", "error");
        return;
      }

      switch (input.toLowerCase()) {
        case "clear":
          goal = null;
          continuationQueued = false;
          setHerdrBlocked(false);
          persist();
          show("Goal cleared");
          updateStatus(ctx);
          return;
        case "pause":
          if (!goal) {
            show("No goal is active.");
            return;
          }
          goal.status = "paused";
          continuationQueued = false;
          setHerdrBlocked(false);
          persist();
          show(statusText(goal));
          updateStatus(ctx);
          return;
        case "resume":
          if (!goal) {
            show("No goal is available to resume.");
            return;
          }
          goal.status = "active";
          goal.turnsUsed = 0;
          continuationQueued = false;
          setHerdrBlocked(false);
          persist();
          show(statusText(goal));
          updateStatus(ctx);
          queueContinuation(ctx);
          return;
      }

      if (goal && goal.status !== "complete" && ctx.hasUI) {
        const replace = await ctx.ui.confirm("Replace active goal?", input);
        if (!replace) return;
      }

      goal = {
        objective: input,
        status: "active",
        turnsUsed: 0,
        maxTurns: DEFAULT_MAX_TURNS,
      };
      continuationQueued = false;
      setHerdrBlocked(false);
      persist();
      show(statusText(goal));
      updateStatus(ctx);
      queueContinuation(ctx);
    },
  });

  pi.registerTool({
    name: "update_goal",
    label: "Update Goal",
    description: "Mark the explicitly activated goal complete or blocked.",
    parameters: UpdateGoalParams as any,
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!goal || goal.status !== "active") throw new Error("No active goal is available to update.");
      const { status } = params as { status: "complete" | "blocked" };
      goal.status = status;
      continuationQueued = false;
      setHerdrBlocked(status === "blocked");
      persist();
      updateStatus(ctx);
      const result = statusText(goal);
      return {
        content: [{ type: "text", text: result }],
        details: { goal: { ...goal } },
      };
    },
  });
}
