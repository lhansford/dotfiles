# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). The `nixos/` directory is a separate NixOS flake for the Lotus Pi kiosk.

## Layout

| Path | Purpose |
| --- | --- |
| `home/` | chezmoi source — files deployed to `$HOME` |
| `nixos/` | NixOS flake for the Lotus Pi kiosk (untouched by chezmoi) |
| `keys/` | Public SSH keys, used by both chezmoi (git signing) and `nixos/` (authorized_keys) |
| `ly/` | System-level config for the `ly` display manager (deployed by `scripts/setup-ly.sh`) |
| `scripts/` | Utility scripts: backups, NixOS Pi deploy, package updates |
| `flake.nix` | Dev shell with `nixfmt`, `statix`, `shfmt`, `shellcheck` |
| `mise.toml` | Task runner config (format, lint) |

## Initial setup on a new machine

```sh
# 1. Install chezmoi (CachyOS / Arch)
paru -S chezmoi

# 2. Point chezmoi at this repo
mkdir -p ~/.config/chezmoi
printf 'sourceDir = "%s"\n' "$HOME/Documents/development/dotfiles" > ~/.config/chezmoi/chezmoi.toml

# 3. Verify the host is in the role map
chezmoi data | jq '.hosts."'$(hostname)'"'

# 4. Apply — runs the package install script, deploys files, registers services
chezmoi apply
```

## Hosts and roles

Per-host role assignments live in `home/.chezmoidata.toml`. Templates query roles via:

```
{{ $h := index .hosts .chezmoi.hostname }}
{{ if has "graphical" $h.roles }}...{{ end }}
```

| Host | Roles |
| --- | --- |
| `aphex` | `base graphical fishbrain cachyos` |
| `jdilla` | `base graphical fishbrain cachyos nvidia` |
| `kraftwerk` | `base server` |

Add a new host by editing `home/.chezmoidata.toml`.

## Common tasks

```sh
chezmoi diff        # preview changes
chezmoi apply       # deploy / re-apply
chezmoi edit <file> # edit a managed file (opens the source)
chezmoi cd          # cd into the source directory
```

## Lotus Pi kiosk (NixOS)

See [`nixos/`](./nixos) — separate flake, deployed via `scripts/build-lotus-image.sh` and `scripts/deploy-lotus.sh`. Not managed by chezmoi.
