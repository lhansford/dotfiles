#!/usr/bin/env bash
set -euo pipefail

if ! command -v paru >/dev/null 2>&1; then
	echo "paru is not installed. Visit https://github.com/Morganamilo/paru for installation instructions."
	exit 1
fi

packages=(
	# Needed for todoist-appimage to work
	qt5-wayland
	qt6-wayland

	# 1password cannot be installed with standalone Nix as it won't integrate with the system (polkit + SSH + browsers)
	1password
	1password-cli

	# Docker Desktop isn't supported by Standalone Nix.
	docker-desktop

	# There is a nix plexamp package but I get errors running it on jdilla.
	plexamp-appimage

	# Nix package didn't work. It's possible because I didn't have QT set up properly though, so it might be worth investigating again.
	todoist-appimage

	# Not supported by home-manager and better to run via pacman
	steam
)

echo "Updating package databases..."
paru -Sy

echo "Installing packages..."
paru -S --needed --skipreview "${packages[@]}"

echo "Installation complete."
