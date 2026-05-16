#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if ! command -v gum >/dev/null 2>&1; then
	echo "gum is not installed. Visit https://github.com/charmbracelet/gum for installation instructions."
	exit 1
fi

# No-op if ly is already the active display manager on tty2
if systemctl is-active --quiet "ly@tty2.service" 2>/dev/null; then
	gum style --foreground="#4E683E" "ly@tty2.service is already running. Nothing to do."
	exit 0
fi

# Find the currently enabled display manager
current_dm=""
if [[ -L /etc/systemd/system/display-manager.service ]]; then
	current_dm="$(basename "$(readlink -f /etc/systemd/system/display-manager.service)")"
fi

# Also check for any ly instances on other TTYs
current_ly=""
for unit in /etc/systemd/system/multi-user.target.wants/ly@*.service; do
	if [[ -e "$unit" ]]; then
		current_ly="$(basename "$unit")"
		break
	fi
done

gum style --bold "Display manager setup"
echo ""

if [[ -n "$current_dm" ]]; then
	gum style "Current display manager: $current_dm" --foreground="#D0883E"
fi
if [[ -n "$current_ly" && "$current_ly" != "ly@tty2.service" ]]; then
	gum style "Found ly on different TTY: $current_ly" --foreground="#D0883E"
fi

echo ""
gum style "This will:"
if [[ -n "$current_dm" ]]; then
	gum style --foreground="#FF5F56" "  • Disable $current_dm"
fi
if [[ -n "$current_ly" && "$current_ly" != "ly@tty2.service" ]]; then
	gum style --foreground="#FF5F56" "  • Disable $current_ly"
fi
gum style --foreground="#4E683E" "  • Enable ly@tty2.service"
gum style --foreground="#4E683E" "  • Symlink ly/config.ini → /etc/ly/config.ini"
echo ""

if ! gum confirm "Proceed with display manager switch?"; then
	gum style --foreground="#767676" "Aborted."
	exit 0
fi

if [[ -n "$current_dm" ]]; then
	gum style "Disabling $current_dm..."
	sudo systemctl disable "$current_dm"
fi

if [[ -n "$current_ly" && "$current_ly" != "ly@tty2.service" ]]; then
	gum style "Disabling $current_ly..."
	sudo systemctl disable "$current_ly"
fi

gum style "Symlinking ly config..."
sudo ln -sf "$REPO_DIR/ly/config.ini" /etc/ly/config.ini

gum style "Enabling ly@tty2.service..."
sudo systemctl enable "ly@tty2.service"

gum style --bold --foreground="#4E683E" "ly@tty2.service enabled. It will start on next boot."
