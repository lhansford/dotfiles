#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

if ! command -v gum >/dev/null 2>&1; then
  echo "gum is not installed. Visit https://github.com/charmbracelet/gum for installation instructions."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed. Visit https://jqlang.github.io/jq/download for installation instructions."
  exit 1
fi

if ! command -v diff-so-fancy >/dev/null 2>&1; then
  echo "diff-so-fancy is not installed. Visit https://github.com/so-fancy/diff-so-fancy for installation instructions."
  exit 1
fi

resolve_path() {
  echo "${1/#\~/$HOME}"
}

system_keys=($(jq -r '.systems | keys[]' "$CONFIG_FILE"))
system_labels=()
typeset -A label_to_key
for key in "${system_keys[@]}"; do
  label=$(jq -r ".systems[\"$key\"]" "$CONFIG_FILE")
  system_labels+=("$label")
  label_to_key[$label]="$key"
done

selected_label=$(gum choose --header "Select your OS:" "${system_labels[@]}")
selected_system="${label_to_key[$selected_label]}"

if [[ -z "$selected_system" ]]; then
  echo "No system selected."
  exit 1
fi

# Read all filtered paths once into parallel arrays
filtered_json=$(jq -r \
  --arg sys "$selected_system" \
  '[.paths[] | select(.systems | index($sys))] | .[] | "\(.src)\t\(.dest)\t\(.external_src // "")"' \
  "$CONFIG_FILE")

path_srcs=()
path_dests=()
path_externals=()

while IFS=$'\t' read -r src dest external; do
  path_srcs+=("$(resolve_path "$SCRIPT_DIR/${src#./}")")
  path_dests+=("$(resolve_path "$dest")")
  path_externals+=("$external")
done <<< "$filtered_json"

has_error=false

gum style --bold "Syncing external files..."

for i in {1..${#path_srcs[@]}}; do
  [[ -z "${path_externals[$i]}" ]] && continue

  if ! gum spin --title "Downloading $(basename "${path_srcs[$i]}")..." -- \
    curl -sfLo "${path_srcs[$i]}" "${path_externals[$i]}"; then
    gum style --foreground="#FF5F56" "Failed to download ${path_externals[$i]}"
    has_error=true
    break
  fi
done

diff_output=""
if [[ "$has_error" == false ]]; then
  gum style --bold "Creating diff..."
  echo ""

  for i in {1..${#path_srcs[@]}}; do
    src="${path_srcs[$i]}"
    dest="${path_dests[$i]}"

    if [[ -e "$dest" ]]; then
      file_diff=$(diff -Nu "$dest" "$src" | diff-so-fancy 2>/dev/null || true)
      if [[ -n "$file_diff" ]]; then
        echo "$file_diff"
        diff_output+="$file_diff"
      fi
    else
      gum style --foreground="#D0883E" "New file: $dest → $src"
      diff_output+="new"
    fi
  done
fi

if [[ -z "$diff_output" ]]; then
  gum style --bold --foreground="#4E683E" "No changes found. You're up to date!"
elif [[ "$has_error" == false ]]; then
  echo ""
  if gum confirm "Apply changes?"; then
    gum style --bold "Symlinking files..."

    for i in {1..${#path_srcs[@]}}; do
      src="${path_srcs[$i]}"
      dest="${path_dests[$i]}"

      dest_dir="$(dirname "$dest")"
      if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
        gum style --foreground="#767676" "Created directory: $dest_dir"
      fi

      ln -sf "$src" "$dest"
      gum style --foreground="#4E683E" "✓ $(basename "$src") → $dest"
    done

    gum style --bold --foreground="#4E683E" "Done!"
  fi
fi

if [[ "$has_error" == true ]]; then
  exit 1
fi
