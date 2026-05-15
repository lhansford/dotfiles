# Phase 5 Runbook — jdilla cutover

**Before starting:** commit the chezmoi changes so the work is saved if anything goes wrong.

```sh
cd ~/Documents/development/dotfiles
git add home/ .chezmoiroot && git status
git commit -m "Add chezmoi source for Phase 5 cutover"
```

## Step 1 — Sanity-check AUR package names

Several AUR names in the install script are guesses. Check them before the install batch fails on a typo:

```sh
for pkg in crush-bin espanso-wayland junction vicinae zed slack-desktop google-chrome aws-cli-v2 dbeaver granted-bin; do
  echo "=== $pkg ==="
  paru -Ss "^${pkg}\$" 2>&1 | head -2 || echo "NOT FOUND"
done
```

Edit `home/.chezmoiscripts/run_once_before_install-packages.sh.tmpl` to fix any wrong names.

## Step 2 — Preview chezmoi file changes

```sh
chezmoi diff | less
```

Should be ~49 diffs, all symlink → regular file. Bail if anything unexpected.

## Step 3 — Install packages (slow, interactive)

Render the script and run it directly so you can answer paru/sudo prompts cleanly:

```sh
chezmoi execute-template --file \
  ~/Documents/development/dotfiles/home/.chezmoiscripts/run_once_before_install-packages.sh.tmpl \
  > /tmp/install-packages.sh
bash /tmp/install-packages.sh
```

If a package fails: comment it out in the template, fix the name, re-run. AUR builds may take 10–30 minutes total.

## Step 4 — Verify binaries are paru-provided

```sh
for cmd in mise atuin fzf espanso gum codium claude crush; do
  printf "%-10s -> %s\n" "$cmd" "$(command -v "$cmd")"
done
```

You'll still see `/nix/store/...` paths here — that's fine for now, paru installs are in `/usr/bin/`. Both exist; nix wins on PATH order until step 7.

## Step 5 — Apply chezmoi

```sh
chezmoi apply -v
```

`paru -S --needed` will re-run as part of this (it'll see everything already installed and exit quickly). Espanso service will register; vscode extensions will install.

## Step 6 — Test the new shell in a subshell

Don't replace your current shell yet — test in isolation:

```sh
zsh -i -c '
  echo "--- mise:"; mise --version
  echo "--- atuin:"; atuin --version | head -1
  echo "--- fzf:"; command -v fzf
  echo "--- git signing:"; git config --get user.signingKey
  echo "--- gpg.ssh.program:"; git config --get gpg.ssh.program
  echo "--- aliases:"; alias l ls trp fibprod 2>/dev/null
'
```

Expect: all versions print, `gpg.ssh.program` is `/opt/1Password/op-ssh-sign` (not `ssh-keygen` — the fix from earlier), aliases defined.

Try a fresh terminal too — open a new ghostty window and check the prompt loads with the skogen theme.

## Step 7 — Uninstall home-manager

Once the test shell looks good:

```sh
home-manager uninstall
```

This removes `~/.nix-profile`, all HM-managed symlinks (anything still owned by HM is now broken — but everything we care about is already a chezmoi-owned regular file), and the HM systemd user activation.

Reload your current shell so the PATH no longer includes the (now-gone) nix profile:

```sh
exec zsh
```

## Step 8 — Final verification

```sh
echo $PATH | tr ':' '\n' | grep -i nix    # should print nothing
which mise atuin fzf codium               # all from /usr/bin/
git log --oneline -1                      # should still work; signing test:
git commit --allow-empty -m "test: verify signing" && git reset --soft HEAD~1
```

## Rollback

If anything breaks at any step:

- **Shell broken after apply (step 5)**: re-run home-manager switch. Either from `home-manager/` dir: `home-manager switch --flake .#jdilla` (or whatever attribute name your flake uses). HM symlinks reappear, overwriting chezmoi files.
- **Shell broken after uninstall (step 7)**: same recovery — reinstall home-manager via `nix run home-manager/release-25.11 -- switch --flake .#jdilla` or similar.
- **A specific tool missing**: install the missing paru package (`paru -S <name>`) and reload shell.

## After jdilla works, repeat for aphex and kraftwerk

- **aphex**: same process. The chezmoi templates pick up `aphex.pub` automatically via role data. Drop the `nvidia`-role packages if you keep that role for jdilla only (you currently don't).
- **kraftwerk**: short process — only base packages, no graphical/fishbrain/cachyos. The role gating handles this automatically; the install script will skip the big AUR builds.
