/**
 * Bash Permissions Extension
 *
 * Intercepts bash tool calls and asks the user for permission before
 * executing commands. Supports three modes:
 *   - "Always Allow" — remembers the command so it won't ask again
 *   - "Allow this time" — allows just this invocation
 *   - "Deny" — blocks the command
 *
 * "Always Allow" decisions are persisted to ~/.pi/agent/bash-permissions.json
 * so they survive across sessions.
 *
 * Command extraction handles:
 *   - Simple commands: `ls -la` → `ls`
 *   - Subcommands: `git commit -m "msg"` → `git commit`
 *   - Pipes: `ls | grep foo` → checks `ls` and `grep` separately
 *   - Command chaining: `make && make test` → checks `make` twice
 *   - Subshells/grouping: `(cd foo && ls)` → checks `cd` and `ls`
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";

// ---- Config ----

const CONFIG_DIR = join(
	process.env.PI_CODING_AGENT_DIR ||
		join(process.env.HOME || "~", ".pi", "agent"),
);
const PERMISSIONS_FILE = join(CONFIG_DIR, "bash-permissions.json");

interface PermissionsConfig {
	/** Commands that are always allowed without prompting */
	alwaysAllowed: string[];
}

function loadConfig(): PermissionsConfig {
	try {
		if (existsSync(PERMISSIONS_FILE)) {
			const raw = readFileSync(PERMISSIONS_FILE, "utf8");
			return JSON.parse(raw) as PermissionsConfig;
		}
	} catch {
		// Corrupt or unreadable — start fresh
	}
	return { alwaysAllowed: [] };
}

function saveConfig(config: PermissionsConfig): void {
	try {
		if (!existsSync(dirname(PERMISSIONS_FILE))) {
			mkdirSync(dirname(PERMISSIONS_FILE), { recursive: true });
		}
		writeFileSync(PERMISSIONS_FILE, JSON.stringify(config, null, 2), "utf8");
	} catch {
		// Best-effort persistence
	}
}

// ---- Command extraction ----

/**
 * Known commands with subcommands — extract the first two words.
 * Add more as needed.
 */
const SUBCOMMAND_COMMANDS = new Set([
	"git",
	"cargo",
	"npm",
	"npx",
	"yarn",
	"pnpm",
	"bun",
	"deno",
	"docker",
	"podman",
	"kubectl",
	"helm",
	"terraform",
	"ansible",
	"pip",
	"conda",
	"brew",
	"apt",
	"dnf",
	"yum",
	"systemctl",
	"journalctl",
	"go",
	"rustup",
	"mise",
	"task",
	"just",
	"make", // make has no subcommands, but keeping for consistency
	"pi",
]);

/**
 * Extract a normalized command key from a single command string.
 * E.g. "git commit -m 'msg'" → "git commit"
 *      "ls -la"              → "ls"
 */
function extractCommandKey(cmd: string): string {
	// Remove leading whitespace
	const trimmed = cmd.trimStart();
	if (!trimmed) return "";

	// Skip shell operators at the start
	if (["&", "|", ";", ">", "<", "(", ")"].includes(trimmed[0])) {
		return "";
	}

	// Strip environment variable assignments at the front (e.g. FOO=bar cmd ...)
	const withoutEnv = trimmed.replace(/^[A-Za-z_][A-Za-z0-9_]*=\S*\s*/g, "");

	// Extract the first token (the command name)
	// Handle quoted executables and path-style commands
	const match = withoutEnv.match(/^([^\s'"\\|&;><()!]+)/);
	if (!match) return "";

	let commandName = match[1];

	// Strip path prefix — we only care about the basename
	if (commandName.includes("/")) {
		commandName = commandName.slice(commandName.lastIndexOf("/") + 1);
	}

	// Check if this command has a meaningful subcommand
	if (SUBCOMMAND_COMMANDS.has(commandName)) {
		const rest = withoutEnv.slice(match[0].length).trimStart();
		// Extract the next token as the subcommand
		const subMatch = rest.match(/^([^\s'"\\|&;><()!]+)/);
		if (subMatch) {
			const sub = subMatch[1];
			// Only treat it as a subcommand if it looks like a word (not a flag)
			if (!sub.startsWith("-")) {
				return `${commandName} ${sub}`;
			}
		}
	}

	return commandName;
}

/**
 * Split a compound bash command into individual commands
 * (by pipes, &&, ||, ;) and extract command keys for each.
 */
function extractAllCommandKeys(command: string): string[] {
	// Split on pipe, &&, ||, and semicolon — keeping it simple
	// This regex splits on: | (but not ||), ||, &&, ;
	// We need to be careful: || is "or", single | is pipe
	const parts = command.split(/\s*(?:\|\||&&|;|\|)\s*/);
	const keys: string[] = [];

	for (const part of parts) {
		// Strip leading/trailing whitespace and grouping parens
		const cleaned = part.replace(/^\(+/, "").replace(/\)+$/, "").trim();
		if (!cleaned) continue;

		// Handle cases where the part itself has multiple commands
		// (e.g. from nested grouping)
		const key = extractCommandKey(cleaned);
		if (key) {
			keys.push(key);
		}
	}

	return keys;
}

// ---- Extension ----

export default function (pi: ExtensionAPI) {
	let config = loadConfig();

	// Reload config on session start (in case the file was edited externally)
	pi.on("session_start", async () => {
		config = loadConfig();
	});

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = event.input.command as string;
		if (!command) return undefined;

		const keys = extractAllCommandKeys(command);

		// Find any commands that aren't in the always-allowed list
		const unknown = keys.filter(
			(k) => !config.alwaysAllowed.includes(k),
		);

		if (unknown.length === 0) {
			// All commands already allowed
			return undefined;
		}

		// In non-interactive mode, block by default
		if (!ctx.hasUI) {
			return {
				block: true,
				reason: `Command(s) not in allow list: ${unknown.join(", ")} (no UI for confirmation)`,
			};
		}

		const commandDisplay =
			command.length > 200 ? command.slice(0, 200) + "…" : command;

		// Build the prompt message
		let message = `bash command:\n\n  ${commandDisplay}`;
		if (unknown.length > 0) {
			message += `\n\nNew command(s): ${unknown.join(", ")}`;
		}

		const choice = await ctx.ui.select(`⚠️ Permission Required — ${message}`, [
			"Always Allow",
			"Allow this time",
			"Deny",
		]);

		if (!choice || choice === "Deny") {
			return { block: true, reason: "Denied by user" };
		}

		if (choice === "Always Allow") {
			config.alwaysAllowed.push(...unknown);
			// Deduplicate
			config.alwaysAllowed = [...new Set(config.alwaysAllowed)].sort();
			saveConfig(config);
		}

		// "Allow this time" or "Always Allow" — let it through
		return undefined;
	});

	// Register a command to manage permissions
	pi.registerCommand("bash-permissions", {
		description: "Manage bash command permissions (view/reset always-allowed list)",
		getArgumentCompletions(prefix: string) {
			const items = [
				{ value: "list", label: "list", description: "Show always-allowed commands" },
				{ value: "reset", label: "reset", description: "Clear the always-allowed list" },
			];
			const filtered = items.filter((i) => i.value.startsWith(prefix));
			return filtered.length > 0 ? filtered : null;
		},
		handler: async (args, ctx) => {
			if (args === "reset") {
				config.alwaysAllowed = [];
				saveConfig(config);
				ctx.ui.notify("Cleared all always-allowed commands.", "info");
			} else if (args === "list" || !args) {
				if (config.alwaysAllowed.length === 0) {
					ctx.ui.notify("No commands in the always-allowed list.", "info");
				} else {
					ctx.ui.notify(
						`Always-allowed commands:\n  ${config.alwaysAllowed.join("\n  ")}`,
						"info",
					);
				}
			} else {
				ctx.ui.notify(
					`Unknown argument: ${args}. Use "list" or "reset".`,
					"warning",
				);
			}
		},
	});
}
