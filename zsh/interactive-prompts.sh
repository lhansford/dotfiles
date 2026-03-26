if [ -e ~/.shell_timestamps ]; then
	source ~/.shell_timestamps
fi

LAST_HOMEBREW_UPGRADE="${LAST_HOMEBREW_UPGRADE:-0}"
LAST_PACKAGE_UPDATE="${LAST_PACKAGE_UPDATE:-0}"
LAST_BACKUP="${LAST_BACKUP:-0}"

week_ago_timestamp=$(date -d '7 days ago' +%s)

if (hostname | grep -q aphex || hostname | grep -q jdilla) && [ "$TERM_PROGRAM" != "vscode" ]; then
	if [ $LAST_PACKAGE_UPDATE -lt $week_ago_timestamp ]; then
		last_upgrade_date_formatted=$(date -d @$LAST_PACKAGE_UPDATE)
		echo "Last package updates were on $last_upgrade_date_formatted. Would you like to update now?"
		if ([[ -t 1 ]] && gum confirm); then
			~/Documents/development/dotfiles/scripts/update-arch-packages.sh
		fi
		stty sane
	fi
fi

if hostname | grep ciani || hostname | grep isao; then
	date=$(date -r /var/log/apt/history.log)
	date_timestamp=$(date -r /var/log/apt/history.log +%s)
	if [ $date_timestamp -lt $week_ago_timestamp ]; then
		echo "Last apt-get upgrade was on $date. Would you like to run it now?"
		if gum confirm; then
			sudo apt-get update && sudo apt-get upgrade -y
		fi
	fi
fi

if [ $LAST_BACKUP -lt $week_ago_timestamp ]; then
	last_backup_date_formatted=$(date -d @$LAST_BACKUP)

	if ([[ -t 1 ]] && gum confirm "Last backup was on $last_backup_date_formatted. Would you like to run it now?"); then
		ssh kraftwerk -t 'zsh -lic "~/dotfiles/scripts/backup.sh"'

		if grep -q "LAST_BACKUP" ~/.shell_timestamps; then
			sed -i '' "s/LAST_BACKUP=.*/LAST_BACKUP=$(date +%s)/" ~/.shell_timestamps
		else
			echo "LAST_BACKUP=$(date +%s)" >>~/.shell_timestamps
		fi
	fi

	stty sane
fi
