# AGENTS.md

## Overview

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). The `nixos/` directory is a separate NixOS flake for the Lotus Pi kiosk and is **not** managed by chezmoi.

**Owner**: Luke Hansford
**Primary host**: CachyOS (Arch-based) desktop with niri (Wayland compositor) and Noctalia shell
**Other hosts**: CachyOS laptop (aphex), Linux server (kraftwerk), Raspberry Pi NixOS kiosk (lotus)

## Repository Structure

```
dotfiles/
├── .chezmoiroot            # contains "home" — re-roots chezmoi at home/
├── flake.nix               # dev shell (nixfmt, statix, shfmt, shellcheck)
├── mise.toml               # task runner config (format, lint)
├── home/                   # chezmoi source root
│   ├── .chezmoidata.toml   # host → roles map
│   ├── .chezmoiignore      # role-gated path ignores (templated)
│   ├── .chezmoiscripts/    # run_once_ scripts (not deployed to $HOME)
│   ├── dot_zshrc.tmpl
│   ├── dot_gitconfig (under dot_config/git/)
│   ├── dot_config/         # → ~/.config/
│   ├── dot_local/bin/      # bin scripts (executable_ prefix sets mode 755)
│   ├── dot_local/share/    # other user-data files
│   ├── dot_oh-my-zsh/      # oh-my-zsh custom themes
│   ├── private_dot_ssh/    # → ~/.ssh/ (mode 700, files mode 600)
│   └── dot_claude/         # → ~/.claude/
├── nixos/                  # NixOS flake for Lotus Pi (independent)
│   ├── flake.nix           # nixos-25.11 stable + nixos-generators + nixos-hardware
│   ├── hosts/              # per-host modules
│   └── modules/            # reusable modules (common, pi4, kiosk)
├── keys/                   # public SSH keys (read by chezmoi git config + NixOS authorized_keys)
├── ly/                     # system-level ly display manager config (deployed by setup-ly.sh)
└── scripts/                # utility scripts
    ├── backup.sh                 # server backup (restic; runs on kraftwerk)
    ├── update-arch-packages.sh   # paru update wrapper
    ├── update-flatpaks.sh        # flatpak update wrapper
    ├── update-secrets-env.sh     # pull secrets from 1Password into ~/.secrets.env
    ├── setup-ly.sh               # one-time ly display manager setup
    ├── build-lotus-image.sh      # build NixOS SD image for Lotus Pi
    └── deploy-lotus.sh           # nixos-rebuild for Lotus Pi over Tailscale
```

## Key Commands

### chezmoi

```sh
chezmoi diff             # preview pending changes
chezmoi apply            # deploy files + run scripts
chezmoi apply -v         # verbose
chezmoi edit <file>      # open the source file for a managed destination
chezmoi cd               # cd into the source directory
chezmoi data | jq        # inspect template data (hosts, roles, chezmoi vars)
chezmoi execute-template < home/some.tmpl   # dry-render a template
```

The chezmoi source dir is set via `~/.config/chezmoi/chezmoi.toml`:

```toml
sourceDir = "/home/luke/Documents/development/dotfiles"
```

`.chezmoiroot` then re-roots chezmoi at `home/`, so `nixos/`, `keys/`, `scripts/`, `ly/`, and the dev-shell `flake.nix` are invisible to chezmoi.

### Formatting and linting (mise tasks)

Dev tools (`nixfmt`, `statix`, `shfmt`, `shellcheck`) are provided via the root `flake.nix` dev shell. Tasks invoke them through `nix develop --command`.

```sh
mise run format        # Format all files (Nix + shell)
mise run format:nix    # Format Nix files in nixos/
mise run format:sh     # Format shell scripts in scripts/
mise run lint          # Lint all files
mise run lint:nix      # statix on nixos/
mise run lint:sh       # shellcheck on bash scripts in scripts/
mise run lint:fix      # Auto-fix Nix lint issues
```

**REQUIRED**: After any change to Nix files in `nixos/` or bash shell scripts in `scripts/`, run `mise run format` and `mise run lint` and ensure both pass before finishing. Chezmoi templates (`*.tmpl`) are not covered by these tools.

### NixOS (Lotus Pi — `lotus`)

`lotus` is a Raspberry Pi 4 kiosk managed by the `nixos/` flake (pinned to `nixos-25.11`). Home Manager is wired in as a NixOS module, reusing `nixos/home/common.nix` via a minimal per-host file (no graphical environment).

Luke's SSH public key lives at `keys/luke.pub`. Single source of truth, consumed by:

- chezmoi's `home/dot_config/git/config.tmpl` — used as `user.signingkey` for SSH-format commit signing (per-host key file selected via `signing_key_file` in `home/.chezmoidata.toml`)
- `nixos/modules/common.nix` — added to `users.users.luke.openssh.authorizedKeys.keys`

**Wifi PSK** lives at `nixos/secrets/wifi.nix` — gitignored, not committed. First-time setup:

```sh
cp nixos/secrets/wifi.nix.example nixos/secrets/wifi.nix
$EDITOR nixos/secrets/wifi.nix
```

Two wrapper scripts:

```sh
./scripts/build-lotus-image.sh        # first-time provisioning — builds the SD image
./scripts/deploy-lotus.sh             # updates over Tailscale (no SD reflash)
# LOTUS_HOST=luke@lotus.local ./scripts/deploy-lotus.sh    # override target
```

Kiosk URL + screen rotation live in `nixos/hosts/lotus.nix` (`kiosk.url`, `boot.kernelParams`).

## How chezmoi roles work

`home/.chezmoidata.toml` defines per-host role lists:

```toml
[hosts.aphex]
roles = ["base", "graphical", "fishbrain", "cachyos"]
signing_key_file = "aphex.pub"

[hosts.jdilla]
roles = ["base", "graphical", "fishbrain", "cachyos", "nvidia"]
signing_key_file = "jdilla.pub"

[hosts.kraftwerk]
roles = ["base", "server"]
```

Roles:

| Role | Applies to | Brings in |
| --- | --- | --- |
| `base` | every host | zsh, git, mise, atuin, ssh, bottom, bat |
| `graphical` | desktops with a GUI | espanso, vscodium, vicinae, browsers, etc.; ssh 1Password agent |
| `fishbrain` | work hosts | gcloud, granted/`assume`, fibprod/fibstaging aliases |
| `cachyos` | Arch-based CachyOS desktops | niri, noctalia, keymapper, paru-based AUR installs |
| `server` | minimal Linux server (kraftwerk) | base only — no GUI packages |
| `nvidia` | hosts with Nvidia GPU | reserved for driver/env additions; not currently triggering anything |

In templates, query roles via:

```
{{- $host := index .hosts .chezmoi.hostname | default dict -}}
{{- $roles := $host.roles | default list -}}
{{- if has "graphical" $roles }}...{{ end }}
```

Adding a new host: edit `home/.chezmoidata.toml`. Adding a new role: assign it to hosts there, then use `has "rolename" $roles` in templates and `home/.chezmoiignore`.

## chezmoi filename conventions

These prefixes on source filenames map to target behavior:

| Prefix | Effect |
| --- | --- |
| `dot_` | Destination starts with `.` (e.g. `dot_zshrc` → `~/.zshrc`) |
| `private_` | File mode 600 (or dir mode 700) |
| `executable_` | File mode 755 |
| `run_once_` | Script runs once per content hash (good for setup/install) |
| `run_once_before_` | Runs before file deploy |
| `run_once_after_` | Runs after file deploy |
| `.tmpl` (suffix) | File is processed as a Go template before deploy |

`.chezmoiscripts/` is a special directory: contents are scripts that run but don't deploy to `$HOME`.

## Bootstrap scripts

Under `home/.chezmoiscripts/`:

| Script | When | What |
| --- | --- | --- |
| `run_once_before_install-packages.sh.tmpl` | before file deploy | `paru -S --needed` for the role-gated package list |
| `run_once_after_register-espanso.sh.tmpl` | after file deploy (graphical only) | `espanso service register` |
| `run_once_after_install-vscode-extensions.sh.tmpl` | after file deploy (graphical only) | `codium --install-extension` for each ext |

Re-trigger a `run_once_` script (e.g. after changing the package list):

```sh
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Conventions and Patterns

### Color theme: "Skogen"

Custom palette used across multiple tools:

- **Background**: `#2a2a26`
- **Foreground**: `#D0D0D2`
- **Green/accent**: `#4E683E`
- **Orange/warning**: `#D0883E`
- **Gray/muted**: `#767676`
- **Red/error**: `#FF5F56`

Applied in: Ghostty theme, gum styling, ohmyzsh theme.

### Key remapping (keymapper)

- CapsLock → Hyper key (Ctrl+Meta+Alt+Shift)
- Backslash → Right modifier (arrow key navigation: WASD)
- On Linux: Ctrl ↔ Alt swap (Mac-like keybindings)
- App-specific overrides for Slack, Todoist, Plexamp, Steam, Chrome

### Editor

VSCodium (`codium`) is the primary editor (`EDITOR=codium`). Git uses `codium --wait` for editing. Installed via paru by `run_once_before_install-packages`.

### Git

- Commits signed with SSH key via 1Password (`op-ssh-sign`)
- Custom commit template at `home/dot_config/git/git_commit_template.txt`
- `diff-so-fancy` as pager
- Default branch: `main`
- Pull strategy: merge (not rebase)
- Per-host signing key resolved from `keys/<file>.pub` (file picked via `signing_key_file` in chezmoidata)

### Zsh

- Oh-my-zsh installed via `oh-my-zsh-git` paru package at `/usr/share/oh-my-zsh`
- User customizations under `~/.oh-my-zsh/` (the skogen theme lives there)
- Plugins: aliases, alias-finder, docker-compose, git, z, npm, brew, colorize, dirhistory, history
- atuin for shell history
- mise for runtime version management
- eza aliased over `ls`
- Auto-prompts for package updates (weekly, cachyos hosts only) and backups (weekly, everywhere) on shell startup via `home/dot_config/zsh/interactive-prompts.sh.tmpl`

## Gotchas

1. **chezmoi source layout**: The `.chezmoiroot` file at repo root contains `home`, which means chezmoi treats `home/` as its source. Anything else at the repo root (`nixos/`, `scripts/`, `keys/`, `ly/`, `flake.nix`, etc.) is invisible to chezmoi. Don't move `nixos/` into `home/` — it would get mangled by chezmoi's prefix conventions.
2. **`run_once_` scripts re-run on content change**: Editing the package list in `run_once_before_install-packages.sh.tmpl` causes a re-run on next `apply`. `paru -S --needed` makes that safe.
3. **Manual re-trigger**: To force a `run_once_` script to re-run without changing content, use `chezmoi state delete-bucket --bucket=scriptState` then `chezmoi apply`.
4. **PII in espanso**: `home/dot_config/espanso/match/default.yml` contains personal expansions (emails, phone, address). The whole repo is therefore sensitive.
5. **AUR package names**: A few entries in the install script are best-guesses (`crush-bin`, `vicinae`, `junction`, etc.). If a fresh install fails, `paru -Ss "^<name>\$"` to find the right slug, then update the script.
6. **System-level configs** (e.g. `/etc/ly/config.ini`) live outside `$HOME` so chezmoi can't deploy them. `scripts/setup-ly.sh` handles those by sudo-symlinking from `ly/config.ini`.
7. **1Password integration**: Git signing and some aliases (`trp`) use 1Password CLI (`op`). They'll fail without 1Password configured.
8. **Multi-user nix is still installed** because `nixos/` (the Lotus Pi flake) requires `nix` itself. The user-level `~/.nix-profile` is empty after the chezmoi migration; the stale entry in `$PATH` is harmless (added by `/etc/profile.d/nix.sh`, points at nothing). Don't reintroduce home-manager.
