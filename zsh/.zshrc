source ~/Dropbox/config/zsh/work/.zshrc

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

echo "CHEATSHEET"
echo "============================="
echo "gho - Open the github page of the current repo."
