# AGENTS.md

## Overview

Personal dotfiles repository for managing configuration files across multiple Linux systems. Uses a JSON-driven symlink sync system and is transitioning toward Nix Home Manager for package and config management.

**Owner**: Luke Hansford  
**Primary system**: CachyOS (Arch-based) desktop with niri (Wayland compositor) and Noctalia shell  
**Other systems**: Generic Linux desktop, Linux server, Raspberry Pi

## Repository Structure

```
dotfiles/
├── flake.nix            # Nix dev shell (nixfmt, statix, shfmt, shellcheck)
├── mise.toml            # Task runner config (format, lint tasks)
├── config.json          # Central manifest: maps source files → system destinations
├── scripts/             # Shell scripts for syncing, backups, dependency checks
│   ├── sync.sh          # Main sync script (interactive, uses gum)
│   ├── backup.sh        # Server backup script (restic, mealie, immich, plex)
│   ├── check-required.sh  # Verifies required CLI tools are installed
│   └── update-arch-packages.sh  # Arch/paru package updater
├── home-manager/        # Nix Home Manager config (WIP, on nix-config branch)
│   ├── flake.nix        # Nix flake definition (nixos-unstable, x86_64-linux)
│   └── home.nix         # Home Manager module (packages, programs, services)
├── ghostty/             # Ghostty terminal config + custom "skogen" theme
├── git/                 # Git config and commit template
├── zsh/                 # Zsh config (.zshrc)
├── ohmyzsh/             # Custom oh-my-zsh theme (skogen)
├── niri/                # Niri window manager config (KDL format)
├── noctalia/            # Noctalia shell settings (CachyOS-specific)
├── espanso/             # Text expansion rules (Wayland)
└── keymapper/           # Key remapping config (CapsLock→Hyper, Ctrl↔Alt swap)
```

## Key Commands

### Sync dotfiles to system

```sh
./scripts/sync.sh
```

Interactive script that:
1. Prompts to select a target system (via `gum choose`)
2. Filters `config.json` paths for that system
3. Downloads external sources (e.g., git commit template, zsh theme)
4. Shows a diff of changes (via `diff-so-fancy`)
5. Asks for confirmation, then creates symlinks

**Dependencies**: `gum`, `jq`, `diff-so-fancy`, `curl`

### Check required tools

```sh
./scripts/check-required.sh
```

Verifies: 1Password CLI, atuin, diff-so-fancy, eza, gum, mise, oh-my-zsh, zsh-autosuggestions, zsh.

### Update Arch packages

```sh
./scripts/update-arch-packages.sh
```

Runs `paru -Sy && paru -Su`, removes orphans, clears cache, updates timestamp in `~/.shell_timestamps`.

### Formatting and Linting (mise tasks)

Dev tools (`nixfmt`, `statix`, `shfmt`, `shellcheck`) are provided via a repo-scoped Nix dev shell (`flake.nix`). The mise tasks invoke them through `nix develop --command`.

```sh
mise run format        # Format all files (Nix + shell)
mise run format:nix    # Format Nix files with nixfmt
mise run format:sh     # Format shell scripts with shfmt
mise run lint          # Lint all files (Nix + shell)
mise run lint:nix      # Lint Nix files with statix
mise run lint:sh       # Lint bash scripts with shellcheck
mise run lint:fix      # Auto-fix Nix lint issues with statix
```

**REQUIRED**: After any change to Nix files (`home-manager/*.nix`) or bash shell scripts (`scripts/`), you MUST run `mise run format` and `mise run lint` and ensure both pass before finishing.

### Home Manager (Nix)

```sh
# From the home-manager/ directory:
home-manager switch --flake .
```

The `home-manager/` directory contains a Nix flake that manages packages and program configs declaratively. This is a work-in-progress on the `nix-config` branch and partially duplicates configs from the traditional dotfiles (ghostty, espanso, zsh, etc.).

## How config.json Works

The central `config.json` defines:
- **systems**: Named system types (`linux_desktop`, `linux_server`, `rpi`, `cachyos`)
- **paths**: Array of objects with:
  - `src`: Relative path in this repo
  - `dest`: Absolute destination path (with `~` expansion)
  - `systems`: Which systems this file applies to
  - `external_src` (optional): URL to download the source file from before syncing

When adding a new config file:
1. Place the file in the appropriate directory in this repo
2. Add an entry to `config.json` with `src`, `dest`, and applicable `systems`
3. Run `sync.sh` to create the symlink

## Shell Scripts

- All scripts use `#!/usr/bin/env zsh` (sync.sh, backup.sh) or `#!/usr/bin/env bash` (check-required.sh, update-arch-packages.sh)
- Scripts use `set -euo pipefail` for strict error handling
- Interactive prompts use [gum](https://github.com/charmbracelet/gum) (charmbracelet)
- Color scheme in gum follows the skogen theme palette (greens, oranges, grays)

## Conventions and Patterns

### Color Theme: "Skogen"

A custom color theme used across multiple tools:
- **Background**: `#2a2a26`
- **Foreground**: `#D0D0D2`
- **Green/accent**: `#4E683E`
- **Orange/warning**: `#D0883E`
- **Gray/muted**: `#767676`
- **Red/error**: `#FF5F56`

Applied in: Ghostty theme, gum styling (in .zshrc and sync.sh), ohmyzsh theme.

### System-Specific Configs

Configs are targeted to specific systems via the `systems` array in `config.json`:
- `cachyos`: Primary desktop — gets niri, noctalia, keymapper, ghostty, espanso, git, zsh
- `linux_desktop`: Generic Linux desktop — similar to cachyos but without niri/noctalia
- `linux_server` / `rpi`: Minimal — git and zsh only

### Key Remapping (keymapper)

- CapsLock → Hyper key (Ctrl+Meta+Alt+Shift)
- Backslash → Right modifier (arrow key navigation: WASD)
- On Linux: Ctrl ↔ Alt swap (Mac-like keybindings)
- App-specific overrides for Slack, Todoist, Plexamp, Steam, Chrome

### Editor

VS Code / VSCodium is the primary editor (`EDITOR='code'`). Git uses `code --wait` for editing.

### Git

- Commits signed with SSH key via 1Password (`op-ssh-sign`)
- Custom commit template from external repo
- `diff-so-fancy` as pager
- Default branch: `main`
- Pull strategy: merge (not rebase)

### Zsh Configuration

- Oh-my-zsh with skogen theme
- Plugins: aliases, alias-finder, docker-compose, git, z, npm, brew, colorize, dirhistory, history, zsh-autosuggestions
- Atuin for shell history (loaded after zsh-autosuggestions)
- mise for runtime version management
- eza aliased over `ls`
- Auto-prompts for package updates (weekly) and backups (weekly) on shell startup

## Gotchas

1. **Symlink sync behavior**: Since `sync.sh` creates symlinks, editing the destination file edits the repo file directly. Pulling git changes updates the symlinked files immediately — the sync script is mainly needed for initial setup or adding new files.

2. **Dual config systems**: The `home-manager/` Nix config and the traditional dotfiles overlap (ghostty, espanso, zsh, etc.). The Nix config is a work-in-progress on the `nix-config` branch. When editing configs, check which system is authoritative for the target machine.

3. **External sources**: Some files (`git_commit_template.txt`, `skogen.zsh-theme`) are downloaded from external URLs during sync. The local copies may be overwritten by `sync.sh`.

4. **Shell scripts require zsh**: `sync.sh` and `backup.sh` use zsh-specific features (e.g., `typeset -A` for associative arrays, 1-based array indexing). Don't convert to bash without adjusting array handling.

5. **backup.sh is server-specific**: It's designed to run on a specific home server (`kraftwerk`) with docker, restic, and specific mount points. Not portable.

6. **gum dependency**: Many scripts and the zsh startup rely on `gum` for interactive prompts. If gum is missing, `check-required.sh` will report it but won't block shell startup.

7. **Nix dev shell**: The root `flake.nix` provides dev tools only — it is separate from `home-manager/flake.nix` which manages Home Manager. Run `nix develop` from the repo root to get `nixfmt`, `statix`, `shfmt`, and `shellcheck` in your shell.

8. **shellcheck scope**: `lint:sh` only lints bash scripts (detected by `#!/usr/bin/env bash` shebang). The zsh scripts (`sync.sh`, `backup.sh`) are excluded because shellcheck does not support zsh.

9. **1Password integration**: Git signing and some aliases (`trp`) use 1Password CLI (`op`). These will fail without 1Password configured.
