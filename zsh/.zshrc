# Run Niri at login
if [[ -z "$DISPLAY" && "$XDG_VTNR" = "1" ]]; then
  exec dbus-run-session -- startx /usr/bin/niri
fi

if [ -e ~/.env ]
then
  export $(cat ~/.env | xargs)
fi

if [ -e ~/.shell_timestamps ]
then
  source ~/.shell_timestamps
fi

LAST_HOMEBREW_UPGRADE="${LAST_HOMEBREW_UPGRADE:-0}"
LAST_PACKAGE_UPDATE="${LAST_PACKAGE_UPDATE:-0}"
LAST_BACKUP="${LAST_BACKUP:-0}"

if [ -e ~/Dropbox/config/zsh/work/.zshrc ]
then
  source ~/Dropbox/config/zsh/work/.zshrc
fi

export PATH="/home/luke/.local/bin:$PATH"
export PATH="/Users/luke/.cargo/bin:$PATH" # Cargo binaries
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
export PATH="/usr/local/opt/libpq/bin:$PATH" # Postgres
export PATH="/opt/homebrew/opt/libpq/bin:$PATH" # Postgres on Mac
export PATH="/Users/luke/.bin:$PATH" # ecs-run
export PATH="/home/luke/.atuin/bin:$PATH" # atuin on ciani
export PATH="/home/luke/diff-so-fancy:$PATH" # diff-so-fancy on isao
export ZSH=$HOME/.oh-my-zsh
export EDITOR='code'
export MISE_LEGACY_VERSION_FILE=1

export GUM_CONFIRM_PROMPT_FOREGROUND="#D0883E"
export GUM_CONFIRM_PROMPT_BACKGROUND="#2a2a26"
export GUM_CONFIRM_SELECTED_FOREGROUND="#D0D0D2"
export GUM_CONFIRM_SELECTED_BACKGROUND="#4E683E"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="#D0D0D2"
export GUM_CONFIRM_UNSELECTED_BACKGROUND="#767676"

# Check all the needed apps are present
~/Documents/development/dotfiles/scripts/check-required.sh

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


week_ago_timestamp=$(date -d '7 days ago' +%s)

if (hostname | grep -q aphex || hostname | grep -q jdilla) && [ "$TERM_PROGRAM" != "vscode" ]
then
  if [ $LAST_PACKAGE_UPDATE -lt $week_ago_timestamp ]; then
    last_upgrade_date_formatted=$(date -d @$LAST_PACKAGE_UPDATE)
    echo "Last package updates were on $last_upgrade_date_formatted. Would you like to update now?"
    if ([[ -t 1 ]] && gum confirm); then
      ~/Documents/development/dotfiles/scripts/update-arch-packages.sh
    fi
    stty sane
  fi
fi

# Upgrade apt-get
if hostname | grep ciani || hostname | grep isao
then
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
      echo "LAST_BACKUP=$(date +%s)" >> ~/.shell_timestamps
    fi
  fi

  stty sane
fi