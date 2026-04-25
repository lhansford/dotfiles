#!/usr/bin/env zsh
set -euo pipefail

SECRETS_FILE="$HOME/.secrets.env"

require_command() {
	local cmd="$1" url="$2"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "$cmd is not installed. Visit $url for installation instructions."
		exit 1
	fi
}

typeset -a SECRET_KEYS=()
typeset -a SECRET_REFS=()

register() {
	SECRET_KEYS+=("$1")
	SECRET_REFS+=("$2")
}

register TRP_API_TOKEN "op read op://Personal/todoist-random-project/TRP_API_TOKEN"
register TRP_IGNORED_PROJECTS "op read op://Personal/todoist-random-project/TRP_IGNORED_PROJECTS"
register ZAI_API_KEY "op read op://Personal/ZAI_API_KEY/notesPlain"

fetch_secret() {
	local key="$1" ref="$2"
	local value

	if ! value=$(gum spin --title "Fetching $key..." -- zsh -c "$ref" 2>/dev/null); then
		gum style --foreground="#FF5F56" "  ✗ Failed to fetch $key" >&2
		return 1
	fi

	gum style --foreground="#4E683E" "  ✓ $key" >&2
	echo "$value"
}

main() {
	require_command op "https://developer.1password.com/docs/cli"
	require_command gum "https://github.com/charmbracelet/gum"

	gum style --bold "Updating $SECRETS_FILE"
	echo ""

	if ! op account list 2>/dev/null | grep -q .; then
		gum style --foreground="#FF5F56" "Not signed in to 1Password CLI."
		gum style "Run 'eval \$(op signin)' and try again."
		exit 1
	fi

	local tmp_file
	tmp_file=$(mktemp)
	trap "rm -f '$tmp_file'" EXIT

	local failed=0
	for i in {1..${#SECRET_KEYS[@]}}; do
		local key="${SECRET_KEYS[$i]}"
		local ref="${SECRET_REFS[$i]}"

		local value
		if value=$(fetch_secret "$key" "$ref"); then
			echo "export $key=\"${value}\"" >>"$tmp_file"
		else
			failed=1
		fi
	done

	if [[ "$failed" -eq 1 ]]; then
		echo ""
		gum style --foreground="#D0883E" "Some secrets failed to fetch. Aborting."
		exit 1
	fi

	mv "$tmp_file" "$SECRETS_FILE"
	chmod 600 "$SECRETS_FILE"

	echo ""
	gum style --bold --foreground="#4E683E" "Done! Secrets written to $SECRETS_FILE"
}

main
