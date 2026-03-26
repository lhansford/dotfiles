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
	require_command diff-so-fancy "https://github.com/so-fancy/diff-so-fancy"
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

select_system() {
	local system_keys=($(jq -r '.systems | keys[]' "$CONFIG_FILE"))
	local system_labels=()
	typeset -A label_to_key

	for key in "${system_keys[@]}"; do
		local label=$(jq -r ".systems[\"$key\"]" "$CONFIG_FILE")
		system_labels+=("$label")
		label_to_key[$label]="$key"
	done

	local selected_label=$(gum choose --header "Select your OS:" "${system_labels[@]}")
	local selected="${label_to_key[$selected_label]}"

	if [[ -z "$selected" ]]; then
		echo "No system selected."
		exit 1
	fi

	echo "$selected"
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
			local file_diff=$(diff -Nu "$dest" "$src" | diff-so-fancy 2>/dev/null || true)
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

	local selected_system=$(select_system)
	local filtered_json=$(load_paths "$selected_system")
	parse_paths "$filtered_json"

	if ! download_externals; then
		exit 1
	fi

	if [[ "$selected_system" == "cachyosWithNix" ]]; then
		check_nix_dependencies
		gum style --bold "Installing Arch packages..."
		"$SCRIPT_DIR/scripts/install-arch-packages.sh"
	fi

	local diff_output=$(compute_diff)

	if [[ -z "$diff_output" ]]; then
		gum style --bold --foreground="#4E683E" "No changes found. You're up to date!"
		return
	fi

	echo ""
	if gum confirm "Apply changes?"; then
		apply_symlinks
	fi
}

main
