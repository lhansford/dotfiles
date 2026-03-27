#!/usr/bin/env bash
set -euo pipefail

if ! command -v home-manager >/dev/null 2>&1; then
	echo "home-manager is not installed"
	exit 1
fi

hostname=$(hostname)

gum style --foreground="#767676" "Switching Home Manager config for ${hostname}..."
echo
home-manager switch --flake "./home-manager/.#${hostname}"
echo

gum style --foreground="#4E683E" --bold "Done!"
