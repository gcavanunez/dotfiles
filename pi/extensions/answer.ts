/**
 * Structured answers for the last assistant response.
 *
 * Inspired by mitsuhiko/agent-stuff's answer extension and Pi's qna example,
 * adapted to the current model registry API and kept intentionally small.
 */

import type { UserMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface ExtractedQuestion {
  question: string;
  context?: string;
}

const EXTRACTION_PROMPT = `Extract every question in the supplied assistant response that needs user input.

Return only JSON in this shape:
{"questions":[{"question":"Question text","context":"Optional essential context"}]}

Keep source order. Be concise. Omit context when it is not needed. Return {"questions":[]} when there are no questions.`;

function parseQuestions(text: string): ExtractedQuestion[] | null {
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)```/i)?.[1];
  const trimmed = text.trim();
  const firstBrace = trimmed.indexOf("{");
  const lastBrace = trimmed.lastIndexOf("}");
  const candidates = [fenced, trimmed, firstBrace >= 0 && lastBrace > firstBrace ? trimmed.slice(firstBrace, lastBrace + 1) : undefined];

  for (const candidate of candidates) {
    if (!candidate) continue;
    try {
      const parsed = JSON.parse(candidate) as { questions?: unknown };
      if (!Array.isArray(parsed.questions)) continue;
      const questions: ExtractedQuestion[] = [];
      let valid = true;
      for (const value of parsed.questions) {
        if (!value || typeof value !== "object") {
          valid = false;
          break;
        }
        const record = value as Record<string, unknown>;
        if (typeof record.question !== "string" || !record.question.trim()) {
          valid = false;
          break;
        }
        if (record.context !== undefined && typeof record.context !== "string") {
          valid = false;
          break;
        }
        questions.push({
          question: record.question.trim(),
          ...(typeof record.context === "string" && record.context.trim() ? { context: record.context.trim() } : {}),
        });
      }
      if (valid) return questions;
    } catch {
      // Try the next representation.
    }
  }

  return null;
}

function lastAssistantText(branch: unknown): string | undefined {
  if (!Array.isArray(branch)) return undefined;
  for (let index = branch.length - 1; index >= 0; index -= 1) {
    const entry = branch[index] as { type?: string; message?: { role?: string; stopReason?: string; content?: unknown[] } };
    if (entry.type !== "message" || entry.message?.role !== "assistant") continue;
    if (entry.message.stopReason !== "stop") return undefined;
    const parts = (entry.message.content ?? [])
      .filter((part): part is { type: "text"; text: string } => {
        return Boolean(part && typeof part === "object" && (part as { type?: string }).type === "text" && typeof (part as { text?: unknown }).text === "string");
      })
      .map((part) => part.text);
    if (parts.length > 0) return parts.join("\n");
    return undefined;
  }
  return undefined;
}

export default function answerExtension(pi: ExtensionAPI): void {
  pi.registerCommand("answer", {
    description: "Answer questions from the last assistant response",
    handler: async (_args, ctx) => {
      if (ctx.mode !== "tui" || !ctx.hasUI) {
        ctx.ui.notify("answer requires interactive mode", "error");
        return;
      }
      if (!ctx.model) {
        ctx.ui.notify("No model selected", "error");
        return;
      }
      if (!ctx.isIdle()) {
        ctx.ui.notify("Wait for the current response before answering questions", "error");
        return;
      }

      const source = lastAssistantText(ctx.sessionManager.getBranch());
      if (!source) {
        ctx.ui.notify("No complete assistant response found", "error");
        return;
      }

      const userMessage: UserMessage = {
        role: "user",
        content: [{ type: "text", text: source }],
        timestamp: Date.now(),
      };
      const response = await ctx.modelRegistry.complete(
        ctx.model,
        { systemPrompt: EXTRACTION_PROMPT, messages: [userMessage] },
      );
      if (response.stopReason !== "stop") {
        ctx.ui.notify(`Question extraction stopped: ${response.stopReason}`, "error");
        return;
      }

      const responseText = response.content
        .filter((part): part is { type: "text"; text: string } => part.type === "text")
        .map((part) => part.text)
        .join("\n");
      const questions = parseQuestions(responseText);
      if (!questions) {
        ctx.ui.notify("Question extraction returned invalid JSON", "error");
        return;
      }
      if (questions.length === 0) {
        ctx.ui.notify("No questions found in the last response", "info");
        return;
      }

      const answered: Array<{ question: string; answer: string }> = [];
      for (let index = 0; index < questions.length; index += 1) {
        const item = questions[index];
        const title = `Question ${index + 1}/${questions.length}: ${item.question}`;
        const answer = await ctx.ui.input(title, item.context ?? "Type your answer");
        if (answer === undefined) {
          ctx.ui.notify("Answering cancelled", "info");
          return;
        }
        answered.push({ question: item.question, answer });
      }

      const content = answered
        .map(({ question, answer }) => `Q: ${question}\nA: ${answer || "No preference"}`)
        .join("\n\n");
      pi.sendMessage(
        {
          customType: "dotfiles-answers",
          content: `I answered your questions:\n\n${content}`,
          display: true,
        },
        { triggerTurn: true },
      );
    },
  });
}
