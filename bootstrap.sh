#!/usr/bin/env zsh
# shellcheck disable=SC2034,SC2164,SC1071

set -e -u -o pipefail
setopt INTERACTIVE_COMMENTS

DOTFILE_FOLDER="$HOME/work/personal/dotfiles/"

#-------------------------------------------------------------------------------
# SYMLINKS

# zsh (ZDOTDIR set in .zshenv for the remaining config)
[[ -e ~/.zshenv ]] && rm -fv ~/.zshenv
ln -sfv "$DOTFILE_FOLDER/zsh/.zshenv" ~/.zshenv

[[ -e ~/.wezterm.lua ]] && rm -fv ~/.wezterm.lua
ln -sfv "$DOTFILE_FOLDER/wezterm/wezterm.lua" ~/.wezterm.lua

[[ -e ~/.gitconfig ]] && rm -fv ~/.gitconfig
ln -sfv "$DOTFILE_FOLDER/git/config" ~/.gitconfig

[[ -e ~/.vimrc ]] && rm -fv ~/.vimrc
ln -sfv "$DOTFILE_FOLDER/vim/vimrc" ~/.vimrc

[[ -e ~/.config/starship/starship.toml ]] && rm -fv ~/.config/starship/starship.toml
ln -sfv "$DOTFILE_FOLDER/starship/starship.toml" ~

[[ -e ~/.tmux.conf ]] && rm -fv ~/.tmux.conf
ln -sfv "$DOTFILE_FOLDER/tmux/tmux.conf" ~/.tmux.conf

[[ -e ~/.config/fd/ignore ]] && rm -fv ~/.config/fd/ignore
ln -sfv "$DOTFILE_FOLDER/fd" ~/.config/fd/ignore
