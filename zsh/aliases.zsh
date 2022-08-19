# shellcheck disable=SC2139
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# configurations
alias .star='open $STARSHIP_CONFIG'

# beautify JSON in the terminal (yq = better jq)
# e.g.: curl -s "https://api.corona-zahlen.org/germany" | yq -p=yaml -o=json
alias jq='yq -p=yaml -o=json'

# z & cd
alias zz='z -' # back
alias .="open ."
alias ..="z .."
alias ...="z ../.."
alias ....="z ../../.."
alias v='cd "$VAULT_PATH"' # Obsidian Vault

# utils
alias q='exit'
alias notify="osascript -e 'display notification \"\" with title \"Terminal Process finished.\" subtitle \"\" sound name \"\"'"
alias t="alacritty-theme-switch"

# colorize by default
alias grep='grep --color'
alias ls='ls -G'

# Safety nets
alias rm='rm -vi' # -I only asks when more then 3 files are being deleted
alias mv='mv -vi'
alias ln='ln -v'
alias cp='cp -v'

# defaults
alias which='which -a'
alias mkdir='mkdir -p'
alias pip="pip3"
alias curl="curl -s"

# exa
alias ll='command exa --all --long --git --icons --group-directories-first --sort=modified'
alias tre='command exa --tree -L1 --icons'
alias tree='command exa --tree -L2 --icons'
alias treee='command exa --tree -L3 --icons'
alias treeee='command exa --tree -L4 --icons'
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory

# Suffix Aliases
# = default command to act upon the filetype, when is is entered
# without preceding command (analogous to `setopt AUTO_CD` but for files)
alias -s {css,ts,js,yml,json,plist,xml,md}='bat'
# alias -s {pdf,png,jpg,jpeg}="qlmanage -p &> /dev/null"
alias -s {pdf,png,jpg,jpeg}="open"

# open log files in less and scrolled to the bottom
alias -s log="less +G"
