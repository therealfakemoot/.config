# shellcheck disable=SC2086,SC2164

function bindEverywhere () {
	bindkey -M emacs "$1" $2
	bindkey -M viins "$1" $2
	bindkey -M vicmd "$1" $2
}

bindEverywhere "^A" beginning-of-line
bindEverywhere "^E" end-of-line
bindEverywhere "^K" kill-line
bindEverywhere "^U" kill-whole-line
bindEverywhere "^P" copy-location
bindEverywhere "^B" copy-buffer
bindEverywhere "^L" open-location # remapped to cmd+l via karabiner
bindEverywhere '…' insert-last-word # …=alt+.

# [f]orward to $EDITOR
autoload edit-command-line
zle -N edit-command-line
bindEverywhere '^F' edit-command-line
