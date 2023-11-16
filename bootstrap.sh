#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164,SC1071

set -e -u -o pipefail
setopt INTERACTIVE_COMMENTS

DOTFILE_FOLDER="$HOME/work/personal/dotfiles/"

#-------------------------------------------------------------------------------
# SYMLINKS

# zsh (ZDOTDIR set in .zshenv for the remaining config)
[[ -e ~/.zshenv ]] && rm -fv ~/.zshenv
ln -sf "$DOTFILE_FOLDER/zsh/.zshenv" ~

[[ -e ~/.wezterm.lua ]] && rm -fv ~/.wezterm.lua
ln -sf "$DOTFILE_FOLDER/wezterm/wezterm.lua" ~

[[ -e ~/.gitconfig ]] && rm -fv ~/.gitconfig
ln -sf "$DOTFILE_FOLDER/git/config" ~

[[ -e ~/.vimrc ]] && rm -fv ~/.vimrc
ln -sf "$DOTFILE_FOLDER/vim/vimrc" ~

[[ -e ~/.config/starship/starship.toml ]] && rm -fv ~/.config/starship/starship.toml
ln -sf "$DOTFILE_FOLDER/starship/starship.toml" ~

[[ -e ~/.tmux.conf ]] && rm -fv ~/.tmux.conf
ln -sf "$DOTFILE_FOLDER/tmux/tmux.conf" ~
