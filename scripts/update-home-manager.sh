#!/usr/bin/env bash
set -euo pipefail

if ! command -v home-manager >/dev/null 2>&1; then
	echo "home-manager is not installed"
	exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
	echo "nix is not installed"
	exit 1
fi

FLAKE_DIR="./home-manager"
hostname=$(hostname)

gum style --foreground="#767676" "Updating flake inputs..."
echo
nix flake update --flake "${FLAKE_DIR}"
echo

gum style --foreground="#767676" "Switching Home Manager config for ${hostname}..."
echo
home-manager switch --flake "${FLAKE_DIR}/.#${hostname}"
echo

gum style --foreground="#4E683E" --bold "Update complete!"
