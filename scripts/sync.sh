#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

require_command() {
	local cmd="$1" url="$2"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "$cmd is not installed. Visit $url for installation instructions."
		exit 1
	fi
}

check_dependencies() {
	require_command gum "https://github.com/charmbracelet/gum"
	require_command jq "https://jqlang.github.io/jq/download"
	require_command delta "https://github.com/dandavison/delta"
}

check_nix_dependencies() {
	require_command nix "paru -S nix"
	# TODO: If not set up, also run following
	#
	# nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
	# nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	# nix-channel --update
	#
	# nix run github:nix-community/home-manager -- switch --flake ./home-manager/
}

resolve_path() {
	echo "${1/#\~/$HOME}"
}

resolve_src() {
	resolve_path "$SCRIPT_DIR/${1#./}"
}

detect_system() {
	local hostname=$(hostname)
	DETECTED_SYSTEM=$(jq -r --arg h "$hostname" '.hostnames[$h] // ""' "$CONFIG_FILE")

	if [[ -z "$DETECTED_SYSTEM" ]]; then
		gum style --foreground="#FF5F56" "Unknown hostname: $hostname"
		gum style "Add an entry to the \"hostnames\" object in config.json:"
		gum style --foreground="#D0883E" "  \"$hostname\": \"<system_key>\""
		exit 1
	fi

	local label=$(jq -r --arg s "$DETECTED_SYSTEM" '.systems[$s]' "$CONFIG_FILE")
	gum style --foreground="#4E683E" "Detected system: $label ($hostname)"
}

load_paths() {
	local system="$1"

	jq -r \
		--arg sys "$system" \
		'[.paths[] | select(.systems | index($sys))] | .[] | "\(.src)\t\(.dest)\t\(.external_src // "")"' \
		"$CONFIG_FILE"
}

parse_paths() {
	local filtered_json="$1"

	path_srcs=()
	path_dests=()
	path_externals=()

	while IFS=$'\t' read -r src dest external; do
		path_srcs+=("$(resolve_src "$src")")
		path_dests+=("$(resolve_path "$dest")")
		path_externals+=("$external")
	done <<<"$filtered_json"
}

download_externals() {
	gum style --bold "Syncing external files..."

	for i in {1..${#path_srcs[@]}}; do
		[[ -z "${path_externals[$i]}" ]] && continue

		if ! gum spin --title "Downloading $(basename "${path_srcs[$i]}")..." -- \
			curl -sfLo "${path_srcs[$i]}" "${path_externals[$i]}"; then
			gum style --foreground="#FF5F56" "Failed to download ${path_externals[$i]}"
			return 1
		fi
	done
}

compute_diff() {
	local diff_output=""

	gum style --bold "Creating diff..."
	echo ""

	for i in {1..${#path_srcs[@]}}; do
		local src="${path_srcs[$i]}"
		local dest="${path_dests[$i]}"

		if [[ -e "$dest" ]]; then
			local file_diff=$(diff -Nu "$dest" "$src" | delta 2>/dev/null || true)
			if [[ -n "$file_diff" ]]; then
				echo "$file_diff"
				diff_output+="$file_diff"
			fi
		else
			gum style --foreground="#D0883E" "New file: $dest → $src"
			diff_output+="new"
		fi
	done

	echo "$diff_output"
}

apply_symlinks() {
	gum style --bold "Symlinking files..."

	for i in {1..${#path_srcs[@]}}; do
		local src="${path_srcs[$i]}"
		local dest="${path_dests[$i]}"
		local dest_dir="$(dirname "$dest")"

		if [[ ! -d "$dest_dir" ]]; then
			mkdir -p "$dest_dir"
			gum style --foreground="#767676" "Created directory: $dest_dir"
		fi

		ln -sf "$src" "$dest"
		gum style --foreground="#4E683E" "✓ $(basename "$src") → $dest"
	done

	gum style --bold --foreground="#4E683E" "Done!"
}

main() {
	check_dependencies
	detect_system

	local selected_system="$DETECTED_SYSTEM"
	local filtered_json=$(load_paths "$selected_system")
	parse_paths "$filtered_json"

	# if ! download_externals; then
	# 	exit 1
	# fi

	if [[ "$selected_system" == "cachyosWithNix" ]]; then
		gum style --bold "Updating secrets..."
		"$SCRIPT_DIR/scripts/update-secrets-env.sh"

		check_nix_dependencies

		gum style --bold "Checking for system updates..."
		paru -Sy
		local updates=$(paru -Qu 2>/dev/null || true)

		if [[ -n "$updates" ]]; then
			gum style --bold "Available package updates:"
			echo "$updates"
			echo ""

			if gum confirm "Apply system update?"; then
				gum style --bold "Updating system packages..."
				"$SCRIPT_DIR/scripts/update-arch-packages.sh"
			fi
		else
			gum style --foreground="#4E683E" "System packages are up to date."
		fi

		gum style --bold "Installing Arch packages..."
		"$SCRIPT_DIR/scripts/install-arch-packages.sh"
		gum style --bold "Updating Flatpaks..."
		"$SCRIPT_DIR/scripts/update-flatpaks.sh"
		gum style --bold "Updating Nix..."
		"$SCRIPT_DIR/scripts/update-home-manager.sh"
	if ! groups | grep -qw input; then
		gum style --foreground="#D0883E" "Adding user to 'input' group (needed for espanso)..."
		sudo usermod -aG input "$USER"
		gum style --foreground="#D0883E" "A reboot is required for this to take effect."
	fi

	gum style --bold "Setting up ly display manager..."
	"$SCRIPT_DIR/scripts/setup-ly.sh"
	fi

	# local diff_output=$(compute_diff)

	# echo "test"
	# echo $diff_output

	# if [[ -z "$diff_output" ]]; then
	# 	gum style --bold --foreground="#4E683E" "No changes found. You're up to date!"
	# 	return
	# fi

	# echo ""
	# if gum confirm "Apply changes?"; then
	# 	apply_symlinks
	# fi
	gum style --bold --foreground="#4E683E" "Sync complete!"
}

main
