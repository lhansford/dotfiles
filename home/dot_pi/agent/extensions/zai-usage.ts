import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { basename } from "node:path";
import { visibleWidth } from "@earendil-works/pi-tui";

interface ZaiLimit {
  type: string;
  unit: number;
  number: number;
  percentage: number;
  nextResetTime: number;
}

interface ZaiQuotaResponse {
  code: number;
  success: boolean;
  data?: {
    limits: ZaiLimit[];
    level: string;
  };
}

function formatReset(ms: number): string {
  const diff = ms - Date.now();
  if (diff <= 0) return "now";
  const mins = Math.floor(diff / 60_000);
  if (mins < 60) return `${mins}m`;
  const hours = Math.floor(mins / 60);
  const remMins = mins % 60;
  if (hours < 24) return remMins > 0 ? `${hours}h${remMins}m` : `${hours}h`;
  const days = Math.floor(hours / 24);
  const remHours = hours % 24;
  return remHours > 0 ? `${days}d${remHours}h` : `${days}d`;
}

function bar(theme: any, pct: number, width: number, reset: string): string {
  const filled = Math.round((pct / 100) * width);
  const empty = width - filled;
  const purple = "\x1b[38;2;157;111;255m";
  const resetColor = "\x1b[39m";
  return purple + "█".repeat(filled) + "░".repeat(empty) + resetColor + theme.fg("dim", ` ${pct}% ${reset}`);
}

export default function (pi: ExtensionAPI) {
  let timer: ReturnType<typeof setInterval> | null = null;
  let currentCtx: any = null;
  let footerActive = false;

  // Cached quota data
  let cachedHourly: ZaiLimit | null = null;
  let cachedWeekly: ZaiLimit | null = null;

  async function refresh() {
    if (!currentCtx) return;

    const apiKey = process.env.ZAI_API_KEY;
    if (!apiKey) return;

    const model = currentCtx.model;
    if (!model || model.provider !== "zai") {
      if (footerActive) {
        currentCtx.ui.setFooter(undefined);
        footerActive = false;
      }
      return;
    }

    try {
      const res = await fetch("https://api.z.ai/api/monitor/usage/quota/limit", {
        headers: { Authorization: `Bearer ${apiKey}` },
        signal: AbortSignal.timeout(10_000),
      });
      const body: ZaiQuotaResponse = await res.json();

      if (!body.success || !body.data) return;

      cachedHourly = body.data.limits.find((l) => l.unit === 3) ?? null;
      cachedWeekly = body.data.limits.find((l) => l.unit === 6) ?? null;

      if (!footerActive) {
        footerActive = true;
        currentCtx.ui.setFooter((_tui: any, theme: any, footerData: any) => {
          const unsub = footerData.onBranchChange(() => _tui.requestRender());
          return {
            dispose: unsub,
            invalidate() {},
            render(width: number): string[] {
              const model = currentCtx?.model;
              if (!model || model.provider !== "zai") {
                // Fall back to default footer content
                const branch = footerData.getGitBranch();
                const branchStr = branch ? ` (${branch})` : "";
                const right = theme.fg("dim", `${model?.id || "no-model"}${branchStr}`);
                return [theme.fg("dim", "").padEnd(width) + right];
              }

              // Token stats from session
              let input = 0, output = 0;
              try {
                for (const e of currentCtx.sessionManager.getBranch()) {
                  if (e.type === "message" && e.message.role === "assistant") {
                    const m = e.message as AssistantMessage;
                    input += m.usage?.input ?? 0;
                    output += m.usage?.output ?? 0;
                  }
                }
              } catch { /* ignore */ }
              const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);

              // Left: cwd and git branch
              const cwd = basename(currentCtx?.cwd ?? "");
              const cwdStr = theme.fg("dim", cwd);
              const gitBranch = footerData.getGitBranch();
              const branchStr = gitBranch ? theme.fg("dim", ` (${gitBranch})`) : "";
              const left = cwdStr + branchStr;

              // Right: model + context + tokens + usage bars
              const modelName = theme.fg("dim", model.id);
              let contextStr = "";
              const usage = currentCtx?.getContextUsage?.();
              if (usage) {
                const ctxPct = usage.percent !== null ? `${usage.percent.toFixed(0)}%` : "?";
                const ctxTokens = usage.tokens !== null ? fmt(usage.tokens) : "?";
                const ctxWindow = fmt(usage.contextWindow);
                contextStr = theme.fg("dim", `${ctxTokens}/${ctxWindow} (${ctxPct})`);
              }
              const tokens = theme.fg("dim", `↑${fmt(input)} ↓${fmt(output)}`);
              const sep = theme.fg("dim", "  ");
              let right = modelName + sep + contextStr + sep + tokens;
              if (cachedHourly && cachedWeekly) {
                const hBar = bar(theme, cachedHourly.percentage, 5, formatReset(cachedHourly.nextResetTime));
                const wBar = bar(theme, cachedWeekly.percentage, 5, formatReset(cachedWeekly.nextResetTime));
                right += sep + hBar + "  " + wBar;
              }

              const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
              return [left + pad + right];
            },
          };
        });
      } else {
        // Footer already active, just request re-render with new data
        // The next render call will pick up cachedHourly/cachedWeekly changes
      }
    } catch {
      // silently ignore fetch failures
    }
  }

  pi.on("session_start", async (_event, ctx) => {
    currentCtx = ctx;
    await refresh();
    timer = setInterval(refresh, 120_000);
  });

  pi.on("session_shutdown", async () => {
    if (timer) {
      clearInterval(timer);
      timer = null;
    }
    if (footerActive && currentCtx) {
      currentCtx.ui.setFooter(undefined);
      footerActive = false;
    }
    currentCtx = null;
    cachedHourly = null;
    cachedWeekly = null;
  });

  pi.on("turn_end", async () => {
    await refresh();
  });

  pi.on("model_select", async () => {
    await refresh();
  });
}
