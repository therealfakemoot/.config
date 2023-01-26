# shellcheck disable=SC1090,SC1091,SC2292

# TODO: This is a huge blanket import. It'd be nice to trim this down?
zmodload zsh/complist

# activate completions, also needed for ZSH auto suggestions & completions
# must be loaded before plugins
autoload compinit -Uz +X && compinit

# Fix for Intel Mac, https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-629539004
if [[ $(uname -p) == "i386" ]]; then
	compaudit | xargs chmod g-w
fi

# INFO zoxide loading in terminal-utils, cause needs to be loaded with configuration
# parameters

# INFO `brew --prefix` ensures the right path is inserted on M1 as well as  non-M1 macs

# BUG autosuggesstions do not work for obsidian-terminal yet
# source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# has to be loaded *after* zsh syntax highlighting
# source "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Magic enter
source "$DOTFILE_FOLDER/zsh/plugins/magic_enter.zsh"

# Starship
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
[[ "$TERM" == "Warp" ]] && export STARSHIP_CONFIG=~/.config/starship/starship-warp.toml
