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
export PATH="/usr/local/opt/libpq/bin:$PATH"
export PATH="/Users/luke/.bin:$PATH" # ecs-run
export ZSH=$HOME/.oh-my-zsh

export EDITOR='code'
export MISE_LEGACY_VERSION_FILE=1

eval "$(~/.local/bin/mise activate zsh)"
eval "$(mise activate zsh)"

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

alias mount_ciani='sshfs ciani:/mnt/wdhd /Volumes/ciani'
alias backup_dropbox='restic -r /Volumes/Backups/dropbox --verbose backup ~/Dropbox'
alias backup_media='restic -r /Volumes/Backups/media --verbose backup /Volumes/ciani --exclude=Movies --exclude=TV'

if hostname | grep aphex
then
  last_upgrade=$(dnf history | grep upgrade | head -n 1)
  extracted_date=$(echo $last_upgrade | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
  date_timestamp=$(date -d "$extracted_date" +%s)
  week_ago_timestamp=$(date -d '7 days ago' +%s)
  if [ $date_timestamp -lt $week_ago_timestamp ]; then
    echo "Last dnf upgrade was on $extracted_date. Would you like to run it now?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) sudo dnf upgrade; break;;
            No ) break;;
        esac
    done
  fi
fi

if hostname | grep harmonia
then
  if read -q "choice?Press Y/y to backup files: "; then
    backup_dropbox
    restic -r /Volumes/Backups/dropbox forget --keep-last 2
    # TODO: Turn on tailscale
    mount_ciani
    backup_media
    restic -r /Volumes/Backups/media forget --keep-last 2
    umount /Volumes/ciani
  fi
fi

echo "CHEATSHEET"
echo "============================="
echo "gho - Open the github page of the current repo."
