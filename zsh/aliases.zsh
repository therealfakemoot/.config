# shellcheck disable=SC2139
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# utils
alias r='exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias q='exit'

# added verbosity
alias rm='rm -v'
alias mv='mv -iv'
alias ln='ln -v'
alias cp='cp -ipv'

# defaults
alias grep='grep --ignore-case --color'
alias ls='ls -G' # colorize by default
alias ll='ls -GFahl'
alias which='which -a'
alias mkdir='mkdir -pv'
alias pip="pip3"
alias curl="curl -sL"

alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory

# SUFFIX ALIASES
# = default command to act upon the filetype, when is is entered
# ' and " are there to also open quoted things
# without preceding command (analogous to `setopt AUTO_CD` but for files)
alias -s {css,ts,js,yml,json,plist,xml,md}='bat'
alias -s {pdf,png,jpg,jpeg,tiff}="qlmanage -p &> /dev/null"

# open log files in less and scrolled to the bottom
alias -s log="less +G"
