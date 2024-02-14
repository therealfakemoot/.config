# Apps
export EDITOR=vim
export PAGER=less

if [ -n $TMUX ]; then
      unset zle_bracketed_paste
fi

export TERM="xterm-256color"
bindkey "^R" history-incremental-search-backward

# Directories
export DOTFILE_FOLDER="$HOME/work/personal/dotfiles/"

# to prevent commit spam on dotfile repo, store data in iCloud instead
# export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"

# defines location of the rest of the zsh config
export ZDOTDIR="$DOTFILE_FOLDER/zsh"

#───────────────────────────────────────────────────────────────────────────────

# vidir availability
export PATH="$DOTFILE_FOLDER/zsh/plugins":$PATH
# Add Python binaries to path
export PATH="$HOME/Library/Python/3.9/bin":$PATH


# NEOVIM: completions for cmp-zsh https://github.com/tamago324/cmp-zsh#configuration
[[ -d $HOME/.zsh/comp ]] && export FPATH="$HOME/.zsh/comp:$FPATH"
