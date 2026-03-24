#!/usr/bin/env bash
set -euo pipefail

if ! command -v paru >/dev/null 2>&1; then
  echo "paru is not installed. Visit https://github.com/Morganamilo/paru for installation instructions."
  exit 1
fi

echo "Updating package databases..."
paru -Sy

echo "Upgrading packages..."
paru -Su --skipreview

echo "Removing orphaned packages..."
orphans=$(paru -Qdtq 2>/dev/null || true)
if [ -n "$orphans" ]; then
  paru -Rns --noconfirm "$orphans"
  echo "Removed orphaned packages."
else
  echo "No orphaned packages found."
fi

echo "Clearing package cache..."
paru -Scc --noconfirm

if grep -q "LAST_PACKAGE_UPDATE" ~/.shell_timestamps; then
  sed -i "s/LAST_PACKAGE_UPDATE=.*/LAST_PACKAGE_UPDATE=$(date +%s)/" ~/.shell_timestamps
else
  echo "LAST_PACKAGE_UPDATE=$(date +%s)" >> ~/.shell_timestamps
fi

echo "Update complete."
