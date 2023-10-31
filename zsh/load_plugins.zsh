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

# Magic enter
source "$DOTFILE_FOLDER/zsh/plugins/magic_enter.zsh"

# Starship
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
[[ "$TERM" == "Warp" ]] && export STARSHIP_CONFIG=~/.config/starship/starship-warp.toml
