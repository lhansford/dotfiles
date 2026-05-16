#!/usr/bin/env bash
set -euo pipefail

if ! command -v paru >/dev/null 2>&1; then
	echo "paru is not installed. Visit https://github.com/Morganamilo/paru for installation instructions."
	exit 1
fi

echo "Refreshing CachyOS mirrors..."
if command -v rate-mirrors >/dev/null 2>&1; then
	sudo rate-mirrors cachyos | sudo tee /etc/pacman.d/cachyos-mirrorlist >/dev/null
else
	echo "rate-mirrors not found, skipping CachyOS mirror refresh."
fi

echo "Refreshing Arch mirrors..."
if command -v rate-mirrors >/dev/null 2>&1; then
	sudo rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist >/dev/null
else
	echo "rate-mirrors not found, skipping Arch mirror refresh."
fi

echo "Updating package databases..."
paru -Sy

echo "Upgrading packages..."
paru -Su --skipreview

echo "Removing orphaned packages..."
if paru -Qdtq 2>/dev/null | paru -Rns --noconfirm - 2>/dev/null; then
	echo "Removed orphaned packages."
else
	echo "No orphaned packages found."
fi

echo "Clearing package cache..."
paru -Scc --noconfirm

if grep -q "LAST_PACKAGE_UPDATE" ~/.shell_timestamps; then
	sed -i "s/LAST_PACKAGE_UPDATE=.*/LAST_PACKAGE_UPDATE=$(date +%s)/" ~/.shell_timestamps
else
	echo "LAST_PACKAGE_UPDATE=$(date +%s)" >>~/.shell_timestamps
fi

echo "Update complete."
