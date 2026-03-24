#!/usr/bin/env bash
set -euo pipefail

if ! command -v paru >/dev/null 2>&1; then
  echo "paru is not installed. Visit https://github.com/Morganamilo/paru for installation instructions."
  exit 1
fi

packages=(
  # 1password cannot be installed with standalone Nix as it won't integrate with the system (polkit + SSH + browsers)
  1password
  1password-cli
)

echo "Installing packages..."
paru -S --needed --skipreview "${packages[@]}"

echo "Installation complete."
