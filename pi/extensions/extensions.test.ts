import { describe, expect, test } from "bun:test";

import answerExtension from "./answer";
import goalExtension from "./goal";

function extensionHarness() {
  const commands = new Map<string, any>();
  const tools = new Map<string, any>();
  const handlers = new Map<string, Array<(...args: any[]) => any>>();
  const messages: Array<{ message: any; options: any }> = [];
  const entries: Array<{ type: string; data: any }> = [];

  const pi = {
    registerCommand(name: string, command: any) {
      commands.set(name, command);
    },
    registerTool(tool: any) {
      tools.set(tool.name, tool);
    },
    on(event: string, handler: (...args: any[]) => any) {
      const eventHandlers = handlers.get(event) ?? [];
      eventHandlers.push(handler);
      handlers.set(event, eventHandlers);
    },
    sendMessage(message: any, options: any) {
      messages.push({ message, options });
    },
    appendEntry(type: string, data: any) {
      entries.push({ type, data });
    },
    events: {
      emit() {},
    },
  };

  const ctx = {
    mode: "tui",
    hasUI: true,
    model: { provider: "test", id: "test-model" },
    hasPendingMessages: () => false,
    isIdle: () => true,
    sessionManager: {
      getBranch: () => [],
    },
    modelRegistry: {
      complete: async () => ({ stopReason: "stop", content: [] }),
    },
    ui: {
      theme: { fg: (_color: string, value: string) => value },
      setStatus() {},
      notify() {},
      confirm: async () => true,
      input: async () => "",
    },
  };

  return { pi, ctx, commands, tools, handlers, messages, entries };
}

async function emit(harness: ReturnType<typeof extensionHarness>, event: string, payload: any = {}) {
  for (const handler of harness.handlers.get(event) ?? []) {
    await handler(payload, harness.ctx);
  }
}

describe("goal command", () => {
  test("starts explicitly and stops after ten automatic turns", async () => {
    const harness = extensionHarness();
    goalExtension(harness.pi as any);

    await harness.commands.get("goal").handler("finish the migration", harness.ctx);
    expect(harness.messages.filter(({ options }) => options.triggerTurn)).toHaveLength(1);

    for (let turn = 0; turn < 10; turn += 1) {
      await emit(harness, "agent_start");
      await emit(harness, "agent_end", {
        messages: [{ role: "assistant", stopReason: "stop", content: [{ type: "text", text: "progress" }] }],
      });
      await emit(harness, "agent_settled");
    }

    const triggered = harness.messages.filter(({ options }) => options.triggerTurn);
    expect(triggered).toHaveLength(10);
    expect(harness.entries.at(-1)?.data.goal).toMatchObject({
      status: "limited",
      turnsUsed: 10,
      maxTurns: 10,
    });
  });

  test("completion prevents another continuation", async () => {
    const harness = extensionHarness();
    goalExtension(harness.pi as any);

    await harness.commands.get("goal").handler("finish the migration", harness.ctx);
    await emit(harness, "agent_start");
    await harness.tools.get("update_goal").execute("call", { status: "complete" }, undefined, undefined, harness.ctx);
    await emit(harness, "agent_end", {
      messages: [{ role: "assistant", stopReason: "stop", content: [{ type: "text", text: "done" }] }],
    });
    await emit(harness, "agent_settled");

    expect(harness.messages.filter(({ options }) => options.triggerTurn)).toHaveLength(1);
    expect(harness.entries.at(-1)?.data.goal.status).toBe("complete");
  });

  test("completion remains authoritative when the final response errors", async () => {
    const harness = extensionHarness();
    goalExtension(harness.pi as any);

    await harness.commands.get("goal").handler("finish the migration", harness.ctx);
    await emit(harness, "agent_start");
    await harness.tools.get("update_goal").execute("call", { status: "complete" }, undefined, undefined, harness.ctx);
    await emit(harness, "agent_end", {
      messages: [{ role: "assistant", stopReason: "error", content: [] }],
    });
    await emit(harness, "agent_settled");

    expect(harness.entries.at(-1)?.data.goal.status).toBe("complete");
  });
});

describe("answer command", () => {
  test("extracts questions, collects answers, and submits one response", async () => {
    const harness = extensionHarness();
    answerExtension(harness.pi as any);
    harness.ctx.sessionManager.getBranch = () => [
      {
        type: "message",
        message: {
          role: "assistant",
          stopReason: "stop",
          content: [{ type: "text", text: "Which database? Which region?" }],
        },
      },
    ];
    harness.ctx.modelRegistry.complete = async () => ({
      stopReason: "stop",
      content: [
        {
          type: "text",
          text: '```json\n{"questions":[{"question":"Which database?"},{"question":"Which region?","context":"Primary deployment"}]}\n```',
        },
      ],
    });
    const answers = ["PostgreSQL", "eu-west-1"];
    harness.ctx.ui.input = async () => answers.shift() ?? "";

    await harness.commands.get("answer").handler("", harness.ctx);

    expect(harness.messages).toHaveLength(1);
    expect(harness.messages[0].options).toEqual({ triggerTurn: true });
    expect(harness.messages[0].message.content).toContain("Q: Which database?\nA: PostgreSQL");
    expect(harness.messages[0].message.content).toContain("Q: Which region?\nA: eu-west-1");
  });

  test("does not fall back past an incomplete latest response", async () => {
    const harness = extensionHarness();
    answerExtension(harness.pi as any);
    let extractionCalls = 0;
    harness.ctx.sessionManager.getBranch = () => [
      {
        type: "message",
        message: {
          role: "assistant",
          stopReason: "stop",
          content: [{ type: "text", text: "Old question?" }],
        },
      },
      {
        type: "message",
        message: {
          role: "assistant",
          stopReason: "aborted",
          content: [{ type: "text", text: "Interrupted response" }],
        },
      },
    ];
    harness.ctx.modelRegistry.complete = async () => {
      extractionCalls += 1;
      return { stopReason: "stop", content: [] };
    };

    await harness.commands.get("answer").handler("", harness.ctx);

    expect(extractionCalls).toBe(0);
    expect(harness.messages).toHaveLength(0);
  });
});
