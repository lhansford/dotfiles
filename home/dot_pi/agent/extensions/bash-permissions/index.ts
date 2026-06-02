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

// No hardcoded command list needed — we always try to extract a
// subcommand if the second token looks like a word (not a flag).

/** Token that looks like a subcommand: purely alphabetic-ish word
 *  (letters, digits, hyphens, underscores). Anything containing dots,
 *  slashes, colons, etc. is treated as an argument, not a subcommand. */
const SUBCOMMAND_RE = /^[a-zA-Z][a-zA-Z0-9_-]*$/;

/**
 * Extract a normalized command key from a single command string.
 * Grabs the command name plus ALL subsequent tokens that look like
 * subcommands (alphabetic words, not flags). Stops at the first token
 * that looks like an argument (path, number, flag, etc.).
 *
 * E.g. "git commit -m 'msg'"    → "git commit"
 *      "gh issue list --open"   → "gh issue list"
 *      "ls -la"                 → "ls"
 *      "find . -name foo"       → "find"  (. is not a subcommand)
 *      "npm run build"          → "npm run build"
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

	// Tokenize — simple split on whitespace (doesn't handle quoted strings,
	// but we only need the first few tokens before arguments appear)
	const tokens = withoutEnv.split(/\s+/);
	if (tokens.length === 0) return "";

	// First token is the command — strip path prefix
	let commandName = tokens[0];
	if (commandName.includes("/")) {
		commandName = commandName.slice(commandName.lastIndexOf("/") + 1);
	}

	const parts = [commandName];

	// Walk subsequent tokens: include them as long as they look like
	// subcommands (alphabetic words, not flags, not arguments)
	for (let i = 1; i < tokens.length; i++) {
		const tok = tokens[i];
		// Stop at flags
		if (tok.startsWith("-")) break;
		// Stop at shell operators / redirections
		if (/[|&;><()]/.test(tok)) break;
		// Stop at anything that doesn't look like a subcommand word
		if (!SUBCOMMAND_RE.test(tok)) break;

		parts.push(tok);
	}

	return parts.join(" ");
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
