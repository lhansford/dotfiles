# Bash Permissions Extension

A pi extension that prompts for confirmation before executing bash commands.

## How it works

1. Intercepts every `bash` tool call
2. Extracts command names from the command string (handles pipes, `&&`, `;`, subcommands like `git commit`)
3. Checks each command against an "always allowed" list
4. If any commands are new/unknown, prompts the user **individually for each** with three options:
   - **Always Allow** — adds the command(s) to the allow list and executes
   - **Allow this time** — executes this once without saving
   - **Deny** — blocks the command
5. "Always Allow" decisions persist to `~/.pi/agent/bash-permissions.json`

## Command extraction

The extension extracts a "command key" from each bash command:

| Command | Key |
|---------|-----|
| `ls -la` | `ls` |
| `git commit -m "msg"` | `git commit` |
| `cargo test --all` | `cargo test` |
| `ls \| grep foo` | checks `ls` and `grep` separately |
| `make && make test` | checks `make` (deduplicated) |
| `node -e "const x=1; console.log(x)"` | `node` (semicolons inside quotes are ignored) |

Subcommand-aware commands include: `git`, `cargo`, `npm`, `npx`, `docker`, `kubectl`, `pip`, `brew`, `mise`, and more. See `SUBCOMMAND_COMMANDS` in the source.

## Management command

Use `/bash-permissions` inside pi to manage the allow list:

- `/bash-permissions list` — show all always-allowed commands
- `/bash-permissions reset` — clear the allow list (will prompt for everything again)

## File location

- Extension: `~/.pi/agent/extensions/bash-permissions/index.ts`
- Permissions data: `~/.pi/agent/bash-permissions.json`
