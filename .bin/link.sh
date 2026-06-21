#!/bin/bash

DOTFILES_PATH="$(pwd)"

ln_files_in_dir() {
  for FILE in $(cd "$1" && ls -A); do
    ln -sfnv "$1/$FILE" "$2/$FILE"
  done
}

# zsh
ln_files_in_dir "$DOTFILES_PATH/zsh" "$HOME"

# git
ln_files_in_dir "$DOTFILES_PATH/git" "$HOME"

# .commands
COMMANDS_DIR=".commands"
ln -sfnv "$DOTFILES_PATH/$COMMANDS_DIR" "$HOME/$COMMANDS_DIR"

# nvim
ln -sfnv "$DOTFILES_PATH/nvim/init.vim" "$HOME/.config/nvim/init.vim"

# tmux
ln -sfnv "$DOTFILES_PATH/tmux/.tmux.conf" "$HOME/.tmux.conf"

# VSCode
ln_files_in_dir "$DOTFILES_PATH/vscode" "${HOME}/Library/Application Support/Code/User"

# Claude Code
ln -sfnv "$DOTFILES_PATH/.claude/settings.json" "$HOME/.claude/settings.json"
