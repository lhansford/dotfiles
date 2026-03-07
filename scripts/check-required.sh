#!/usr/bin/env bash
set -euo pipefail

if ! command -v gum >/dev/null 2>&1; then
  echo "gum is not installed. Visit https://github.com/charmbracelet/gum for installation instructions."
  exit 1
fi

check() {
  local name="$1"
  local install_hint="$2"

  if ! eval "$3" >/dev/null 2>&1; then
    gum style --foreground="#FF5F56" --bold "✗ $name"
    gum style --foreground="#767676" "  $install_hint"
    echo ""
  fi
}

check "1Password CLI" \
  "paru -S 1password-cli" \
  "command -v op"

check "atuin" \
  "Visit https://atuin.sh/" \
  "command -v atuin"

check "diff-so-fancy" \
  "brew install diff-so-fancy  OR  paru -S diff-so-fancy" \
  "command -v diff-so-fancy"

check "eza" \
  "brew install eza  OR  paru -S eza" \
  "command -v eza"

check "gum" \
  "brew install gum  OR  paru -S gum" \
  "command -v gum"

check "mise" \
  "Visit https://mise.jdx.dev/" \
  "command -v mise"

check "oh-my-zsh" \
  "Visit https://ohmyz.sh/#install" \
  "test -d \"\${ZSH:-\$HOME/.oh-my-zsh}\""

check "zsh-autosuggestions" \
  "git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" \
  "test -d \"\${ZSH_CUSTOM:-\${ZSH:-\$HOME/.oh-my-zsh}/custom}/plugins/zsh-autosuggestions\""

check "zsh" \
  "Visit https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH" \
  "command -v zsh"