#!/usr/bin/env bash
set -euo pipefail

if ! command -v flatpak >/dev/null 2>&1; then
	echo "flatpak is not installed. Visit https://flatpak.org/setup/ for installation instructions."
	exit 1
fi

FLATPAKS=(
	# There is a nix package for this, but running Nix standalone the graphics libraries drift over time and it stops working.
	"re.sonny.Junction"
)

echo "Checking Flathub remote..."
if ! flatpak remotes | grep -q flathub; then
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

echo "Installing missing Flatpaks..."
for app in "${FLATPAKS[@]}"; do
	if ! flatpak info "$app" >/dev/null 2>&1; then
		echo "Installing $app..."
		flatpak install -y flathub "$app"
	else
		echo "$app is already installed."
	fi
done

echo "Updating all Flatpaks..."
flatpak update -y

echo "Flatpak update complete."
