# Apps
export EDITOR=vim
export PAGER=less
# export BROWSER="Brave Browser"

if [ -n $TMUX ]; then
      unset zle_bracketed_paste
fi
export TERM="xterm-256color"
bindkey "^R" history-incremental-search-backward

# Directories
# export WD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"
export DOTFILE_FOLDER="$HOME/work/personal/dotfiles/"
# export VAULT_PATH="$HOME/main-vault/"
# export ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/"
# export PASSWORD_STORE_DIR="$HOME/.password-store/" # default value, but still needed for bkp script

# to prevent commit spam on dotfile repo, store data in iCloud instead
# export DATA_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder"

# defines location of the rest of the zsh config
export ZDOTDIR="$DOTFILE_FOLDER/zsh"

#───────────────────────────────────────────────────────────────────────────────

# OpenAI API Key stored outside of public git repo (symlinked file)
# (key is accessed by nvim as well as shell plugins)
# OPENAI_API_KEY=$(tr -d "\n" < "$ICLOUD/Dotfolder/private dotfiles/openai_api_key")
# export OPENAI_API_KEY

# Pass Config
# export PASSWORD_STORE_CLIP_TIME=60
# export PASSWORD_STORE_GENERATED_LENGTH=32
# export PASSWORD_STORE_ENABLE_EXTENSIONS=false
# export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS="[:alnum:]"

# vidir availability
export PATH="$DOTFILE_FOLDER/zsh/plugins":$PATH

# NEOVIM: completions for cmp-zsh https://github.com/tamago324/cmp-zsh#configuration
[[ -d $HOME/.zsh/comp ]] && export FPATH="$HOME/.zsh/comp:$FPATH"

# NEOVIM: so linters managed by mason are available to other apps
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH
