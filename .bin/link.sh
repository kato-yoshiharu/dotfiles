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
mkdir -p "$HOME/.config/nvim"
ln_files_in_dir "$DOTFILES_PATH/nvim" "$HOME/.config/nvim"

# wezterm
mkdir -p "$HOME/.config/wezterm"
ln_files_in_dir "$DOTFILES_PATH/wezterm" "$HOME/.config/wezterm"

# tmux
ln -sfnv "$DOTFILES_PATH/tmux/.tmux.conf" "$HOME/.tmux.conf"

# VSCode
ln_files_in_dir "$DOTFILES_PATH/vscode" "${HOME}/Library/Application Support/Code/User"

# Claude Code
ln -sfnv "$DOTFILES_PATH/.claude/settings.json" "$HOME/.claude/settings.json"

# Claude Code skills
mkdir -p "$HOME/.claude/skills"
ln_files_in_dir "$DOTFILES_PATH/claude/skills" "$HOME/.claude/skills"
if [ -d "$DOTFILES_PATH/claude/skills-installed" ]; then
  ln_files_in_dir "$DOTFILES_PATH/claude/skills-installed" "$HOME/.claude/skills"
fi

# Claude Code output styles
mkdir -p "$HOME/.claude/output-styles"
ln_files_in_dir "$DOTFILES_PATH/claude/output-styles" "$HOME/.claude/output-styles"

# Claude Code hooks
mkdir -p "$HOME/.claude/hooks"
ln_files_in_dir "$DOTFILES_PATH/claude/hooks" "$HOME/.claude/hooks"

# bin
mkdir -p "$HOME/bin"
ln_files_in_dir "$DOTFILES_PATH/bin" "$HOME/bin"

# Vicinae
mkdir -p "$HOME/.config/vicinae"
ln_files_in_dir "$DOTFILES_PATH/vicinae" "$HOME/.config/vicinae"

# AeroSpace
mkdir -p "$HOME/.config/aerospace"
ln_files_in_dir "$DOTFILES_PATH/aerospace" "$HOME/.config/aerospace"

# yazi
mkdir -p "$HOME/.config/yazi"
ln_files_in_dir "$DOTFILES_PATH/yazi" "$HOME/.config/yazi"
