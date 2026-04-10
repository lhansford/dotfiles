#!/usr/bin/env bash
set -euo pipefail

if ! command -v home-manager >/dev/null 2>&1; then
	echo "home-manager is not installed"
	exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
	echo "nix is not installed"
	exit 1
fi

FLAKE_DIR="./home-manager"
LOCK_FILE="${FLAKE_DIR}/flake.lock"
hostname=$(hostname)

get_rev() {
	local input="$1"
	jq -r ".nodes.\"${input}\".locked.rev // empty" "${LOCK_FILE}"
}

get_owner_repo() {
	local input="$1"
	local owner repo
	owner=$(jq -r ".nodes.\"${input}\".locked.owner // empty" "${LOCK_FILE}")
	repo=$(jq -r ".nodes.\"${input}\".locked.repo // empty" "${LOCK_FILE}")
	echo "${owner}/${repo}"
}

changelog_url() {
	local input="$1" old_rev="$2" new_rev="$3"
	local owner_repo
	owner_repo=$(get_owner_repo "${input}")
	echo "https://github.com/${owner_repo}/compare/${old_rev:0:12}...${new_rev:0:12}"
}

inputs=$(jq -r '.nodes.root.inputs | keys[]' "${LOCK_FILE}")

declare -A old_revs
for input in ${inputs}; do
	old_revs["${input}"]=$(get_rev "${input}")
done

gum style --foreground="#767676" "Checking for flake input updates..."
echo
nix flake update --flake "${FLAKE_DIR}"
echo

has_changes=false
summary=""

for input in ${inputs}; do
	new_rev=$(get_rev "${input}")
	old_rev="${old_revs[${input}]}"

	if [[ "${old_rev}" != "${new_rev}" ]]; then
		has_changes=true
		owner_repo=$(get_owner_repo "${input}")
		link=$(changelog_url "${input}" "${old_rev}" "${new_rev}")
		summary+="  $(gum style --bold "${input}") (${owner_repo})\n"
		summary+="    ${old_rev:0:12} → ${new_rev:0:12}\n"
		summary+="    $(gum style --foreground='#767676' "${link}")\n\n"
	fi
done

if [[ "${has_changes}" == "false" ]]; then
	gum style --foreground="#4E683E" "All inputs are already up to date."
else
	gum style --bold "The following inputs will be updated:"
	echo
	echo -e "${summary}"

	if ! gum confirm "Apply changes?"; then
		gum style --foreground="#D0883E" "Update cancelled. Restoring lock file..."
		git -C "${FLAKE_DIR}" checkout flake.lock
		exit 0
	fi
fi

echo
gum style --foreground="#767676" "Switching Home Manager config for ${hostname}..."
echo
home-manager switch --flake "${FLAKE_DIR}/.#${hostname}"
echo
gum style --foreground="#767676" "Updating desktop database..." # Needed because we symlink the chrome .desktop file so that Junction can pick up on it (it doesn't look where Nix stores it).
echo
update-desktop-database ~/.local/share/applications
echo

gum style --foreground="#4E683E" --bold "Update complete!"
