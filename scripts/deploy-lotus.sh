#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_HOST="${LOTUS_HOST:-luke@lotus}"

require_command() {
	local cmd="$1" hint="$2"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "$cmd is not installed. $hint"
		exit 1
	fi
}

check_dependencies() {
	require_command nix "https://nixos.org/download"
	require_command nixos-rebuild "nix profile install nixpkgs#nixos-rebuild"
	require_command gum "https://github.com/charmbracelet/gum"
}

check_wifi() {
	gum confirm "Make sure you have updated nixos/modules/wifi.nix to have the correct password. Make sure to revert it before committing any changes.";
}

main() {
	check_dependencies
	check_wifi

	gum style --bold "Deploying lotus config to $TARGET_HOST..."
	gum style --foreground="#767676" "Builds on this machine, pushes the closure over SSH, activates on the Pi."
	echo ""

	cd "$SCRIPT_DIR"
	nixos-rebuild switch \
		--flake ./nixos#lotus \
		--target-host "$TARGET_HOST" \
		--use-remote-sudo \
		"$@"

	echo ""
	gum style --bold --foreground="#4E683E" "✓ Deploy complete"
}

main "$@"
