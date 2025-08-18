if [ -e ~/.shell_timestamps ]
then
  source ~/.shell_timestamps
fi
LAST_HOMEBREW_UPGRADE="${LAST_HOMEBREW_UPGRADE:-0}"
LAST_BACKUP="${LAST_BACKUP:-0}"

if [ -e ~/Dropbox/config/zsh/work/.zshrc ]
then
  source ~/Dropbox/config/zsh/work/.zshrc
fi

if hostname | grep ciani
then
  export TERM=xterm-256color
fi

export PATH="/home/luke/.local/bin:$PATH"
export PATH="/Users/luke/.cargo/bin:$PATH" # Cargo binaries
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
export PATH="/usr/local/opt/libpq/bin:$PATH" # Postgres
export PATH="/opt/homebrew/opt/libpq/bin:$PATH" # Postgres on Mac
export PATH="/Users/luke/.bin:$PATH" # ecs-run
export PATH="/home/luke/.atuin/bin:$PATH" # atuin on ciani
export ZSH=$HOME/.oh-my-zsh
export EDITOR='code'
export MISE_LEGACY_VERSION_FILE=1

export GUM_CONFIRM_PROMPT_FOREGROUND="#D0883E"
export GUM_CONFIRM_PROMPT_BACKGROUND="#2a2a26"
export GUM_CONFIRM_SELECTED_FOREGROUND="#D0D0D2"
export GUM_CONFIRM_SELECTED_BACKGROUND="#4E683E"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="#D0D0D2"
export GUM_CONFIRM_UNSELECTED_BACKGROUND="#767676"

if [ -x "$(command -v mise)" ];then
  eval "$(mise activate zsh)"
else
  eval "$(~/.local/bin/mise activate zsh)"
fi


ZSH_THEME="skogen"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(aliases alias-finder docker-compose git z npm brew colorize dirhistory history zsh-autosuggestions)

zstyle ':omz:update' frequency 7 # This will check for updates every 7 days
zstyle ':omz:plugins:alias-finder' autoload yes

source $ZSH/oh-my-zsh.sh

# Atuin - needs to be loaded after zsh-autosuggestions
eval "$(atuin init zsh)"
. "$HOME/.atuin/bin/env"

# Perm
export PERM_PEOPLE_DIR="$HOME/Obsidian/Personal/people"

# todoist-random-project
alias trp='op run -- todoist-random-project'
export TRP_API_TOKEN=op://Personal/todoist-random-project/TRP_API_TOKEN
export TRP_IGNORED_PROJECTS=op://Personal/todoist-random-project/TRP_IGNORED_PROJECTS

# git aliases
alias gcfp='git commit -a --amend --no-edit --no-verify && git push --force-with-lease'
alias gcnv='git commit -a --no-verify'
# Open github homepage of a repository
alias gho='open "https://github.com/$(git config --get remote.origin.url | cut -d ":" -f 2  | cut -d "." -f 1)"'

# eza
alias ls='eza'
alias l='eza -la --group-directories-first'

alias mount_ciani='sshfs ciani:/mnt/wdhd /Volumes/ciani'
alias backup_dropbox='restic -r /Volumes/Backups/dropbox --verbose backup ~/Dropbox'
alias backup_media='restic -r /Volumes/Backups/media --verbose backup --ignore-inode /Volumes/ciani --exclude=Movies --exclude=TV'

if hostname | grep aphex && [ "$TERM_PROGRAM" != "vscode" ]
then
  last_upgrade=$(dnf history list | grep upgrade | head -n 1)
  extracted_date=$(echo $last_upgrade | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
  date_timestamp=$(date -d "$extracted_date" +%s)
  week_ago_timestamp=$(date -d '7 days ago' +%s)
  if [ $date_timestamp -lt $week_ago_timestamp ]; then
    echo "Last dnf upgrade was on $extracted_date. Would you like to run it now?"
    if gum confirm; then
      sudo dnf upgrade
    fi
  fi
fi

if hostname | grep harmonia && [ "$TERM_PROGRAM" != "vscode" ]
then
  week_ago_timestamp=$(date -v -7d +%s)
  if [ $LAST_HOMEBREW_UPGRADE -lt $week_ago_timestamp ]; then
    last_upgrade_date_formatted=$(date -r $LAST_HOMEBREW_UPGRADE)
    if gum confirm "Last \`brew upgrade\` was on $last_upgrade_date_formatted. Would you like to run it now?"; then
      brew upgrade
      if grep -q "LAST_HOMEBREW_UPGRADE" ~/.shell_timestamps; then
        sed -i '' "s/LAST_HOMEBREW_UPGRADE=.*/LAST_HOMEBREW_UPGRADE=$(date +%s)/" ~/.shell_timestamps
      else
        echo "LAST_HOMEBREW_UPGRADE=$(date +%s)" >> ~/.shell_timestamps
      fi
    fi
  fi

  if [ $LAST_BACKUP -lt $week_ago_timestamp ]; then
    last_backup_date_formatted=$(date -r $LAST_BACKUP)
    if gum confirm "Last backup was on $last_backup_date_formatted. Would you like to run it now?"; then
      if ! command -v restic >/dev/null 2>&1; then
        echo "restic is not installed. Visit https://restic.readthedocs.io/en/stable/020_installation.html for installation instructions."
        return 1
      fi

      if ! command -v sshfs >/dev/null 2>&1; then
        echo "sshfs is not installed. Visit https://macfuse.github.io/ and https://github.com/libfuse/sshfs for installation instructions."
        return 1
      fi

      backup_dropbox
      restic -r /Volumes/Backups/dropbox forget --keep-last 2

      echo "\nMounting ciani..."
      mount_ciani

      if [ -z "$( ls -A '/Volumes/ciani' )" ];
      then
        echo "/Volumes/ciani failed to mount. Check that Tailscale is running."
      else
        echo "Mounted ciani. Backing up media..."
        backup_media
        restic -r /Volumes/Backups/media forget --keep-last 2
        umount /Volumes/ciani
        echo "Unmounted ciani."
        if grep -q "LAST_BACKUP" ~/.shell_timestamps; then
          sed -i '' "s/LAST_BACKUP=.*/LAST_BACKUP=$(date +%s)/" ~/.shell_timestamps
        else
          echo "LAST_BACKUP=$(date +%s)" >> ~/.shell_timestamps
        fi
      fi
    fi
  fi
fi
