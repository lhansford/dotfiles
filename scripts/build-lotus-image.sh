#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

require_command() {
	local cmd="$1" hint="$2"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "$cmd is not installed. $hint"
		exit 1
	fi
}

check_dependencies() {
	require_command nix "https://nixos.org/download"
	require_command gum "https://github.com/charmbracelet/gum"
}

check_pubkey() {
	local key_file="$SCRIPT_DIR/keys/luke.pub"
	if [[ ! -f "$key_file" ]]; then
		gum style --foreground="#FF5F56" "Missing $key_file"
		gum style "Drop your SSH public key there before building."
		exit 1
	fi
}

check_wifi() {
	gum confirm "Make sure you have updated nixos/modules/wifi.nix to have the correct password. Make sure to revert it before committing any changes.";
}

binfmt_ready() {
	[[ -e /proc/sys/fs/binfmt_misc/qemu-aarch64 ]]
}

nix_platforms_status() {
	local line
	line=$(grep -E '^[[:space:]]*extra-platforms[[:space:]]*=' /etc/nix/nix.conf 2>/dev/null || true)
	if [[ -z "$line" ]]; then
		echo missing
	elif echo "$line" | grep -qw 'aarch64-linux'; then
		echo present
	else
		echo conflict
	fi
}

ensure_aarch64_emulation() {
	local platforms_status
	platforms_status=$(nix_platforms_status)

	if binfmt_ready && [[ "$platforms_status" == "present" ]]; then
		return 0
	fi

	if [[ "$platforms_status" == "conflict" ]]; then
		gum style --foreground="#FF5F56" "/etc/nix/nix.conf already has an 'extra-platforms' line without aarch64-linux."
		gum style "Edit it manually to include aarch64-linux, then re-run."
		exit 1
	fi

	gum style --bold --foreground="#D0883E" "aarch64 emulation is not configured yet."
	gum style "Building aarch64 images on x86_64 requires one-time setup:"
	if ! binfmt_ready; then
		gum style "  • install qemu-user-static + qemu-user-static-binfmt (via paru)"
		gum style "  • restart systemd-binfmt.service"
	fi
	if [[ "$platforms_status" == "missing" ]]; then
		gum style "  • append 'extra-platforms = aarch64-linux' to /etc/nix/nix.conf"
		gum style "  • restart nix-daemon"
	fi
	gum style --foreground="#767676" "All steps use sudo."
	echo ""

	if ! gum confirm "Run setup now?"; then
		gum style --foreground="#FF5F56" "Aborted — aarch64 emulation required to build the image."
		exit 1
	fi

	if ! binfmt_ready; then
		require_command paru "https://github.com/Morganamilo/paru"
		gum style --bold "Installing qemu binfmt packages..."
		paru -S --needed qemu-user-static qemu-user-static-binfmt
		sudo systemctl restart systemd-binfmt.service
		if ! binfmt_ready; then
			gum style --foreground="#FF5F56" "Installed packages, but /proc/sys/fs/binfmt_misc/qemu-aarch64 still missing."
			exit 1
		fi
	fi

	if [[ "$platforms_status" == "missing" ]]; then
		gum style --bold "Adding extra-platforms to /etc/nix/nix.conf..."
		echo "extra-platforms = aarch64-linux" | sudo tee -a /etc/nix/nix.conf >/dev/null
		sudo systemctl restart nix-daemon
	fi

	gum style --foreground="#4E683E" "✓ aarch64 emulation ready"
	echo ""
}

resolve_image_path() {
	local link="$SCRIPT_DIR/result"
	if [[ ! -L "$link" && ! -d "$link" ]]; then
		return 1
	fi
	find "$link/sd-image" -maxdepth 1 -type f \( -name '*.img' -o -name '*.img.zst' \) 2>/dev/null | head -n1
}

wait_for_ssh() {
	local host="$1"
	local deadline=$(($(date +%s) + 300))
	while (($(date +%s) < deadline)); do
		if ssh -o ConnectTimeout=5 \
			-o StrictHostKeyChecking=accept-new \
			-o BatchMode=yes \
			-o UserKnownHostsFile="$HOME/.ssh/known_hosts" \
			"luke@$host" true 2>/dev/null; then
			return 0
		fi
		sleep 3
	done
	return 1
}

post_flash_setup() {
	echo ""
	if ! gum confirm "Run post-flash setup now (wait for Pi, bootstrap Tailscale)?"; then
		gum style --foreground="#767676" "Skipping. Run the Tailscale bootstrap manually when ready."
		return 0
	fi

	local host
	host=$(gum input --prompt "Pi address: " --value "lotus.local")
	host="${host:-lotus.local}"

	gum style --bold "Waiting for ssh on $host..."
	gum style --foreground="#767676" "Give it up to 5 minutes. First boot expands the root filesystem and reboots once."
	if ! wait_for_ssh "$host"; then
		gum style --foreground="#FF5F56" "Timed out waiting for $host to accept SSH."
		gum style "Check the Pi is powered on and on the same network, then re-run the bootstrap manually:"
		gum style --foreground="#767676" "    ssh -t luke@$host sudo tailscale up --ssh"
		return 1
	fi

	gum style --foreground="#4E683E" "✓ Reachable over SSH."

	if [[ -L "$SCRIPT_DIR/result" ]]; then
		rm "$SCRIPT_DIR/result"
		gum style --foreground="#767676" "Removed ./result symlink — store path will be GC'd on next nix-collect-garbage."
	fi

	echo ""
	gum style --bold "Bootstrapping Tailscale on $host..."
	gum style --foreground="#767676" "Follow the auth URL that appears to add the Pi to your tailnet."
	echo ""
	ssh -t "luke@$host" "sudo tailscale up --ssh"

	echo ""
	gum style --bold --foreground="#4E683E" "✓ Setup complete"
	gum style "Deploy future changes with:  ./scripts/deploy-lotus.sh"
}

main() {
	check_dependencies
	check_pubkey
	check_wifi
	ensure_aarch64_emulation

	gum style --bold "Building lotus SD card image..."
	gum style --foreground="#767676" "aarch64 build via QEMU emulation; the first run will take a while."
	echo ""

	cd "$SCRIPT_DIR"
	nix build ./nixos#sdcard

	local image_path
	image_path=$(resolve_image_path || true)

	echo ""
	gum style --bold --foreground="#4E683E" "✓ Image built"
	if [[ -n "$image_path" ]]; then
		gum style "Image: $image_path"
	else
		gum style --foreground="#D0883E" "Built, but could not locate the .img file under ./result/sd-image/"
	fi

	local image_ref="${image_path:-<image>}"
	local flash_cmd
	if [[ "$image_ref" == *.zst ]]; then
		flash_cmd="zstd -d --stdout $image_ref | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress"
	else
		flash_cmd="sudo dd if=$image_ref of=/dev/sdX bs=4M conv=fsync status=progress"
	fi

	echo ""
	gum style --bold "Next steps:"
	gum style "  1. Plug in the SD card and find its device node:"
	gum style --foreground="#767676" "       lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS"
	gum style --foreground="#D0883E" "     Double-check the device before continuing — dd to the wrong disk is irreversible."
	gum style "  2. Flash the image:"
	gum style --foreground="#767676" "       $flash_cmd"
	gum style "  3. Eject, insert into the Pi, and power on."

	post_flash_setup
}

main
