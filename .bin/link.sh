#!/bin/bash

DOTFILES_PATH="$(pwd)"

ln_files_in_dir() {
  for FILE in $(cd "$1" && ls -A); do
    ln -sfnv "$1/$FILE" "$2/$FILE"
  done
}

# zsh
ln_files_in_dir "$DOTFILES_PATH/config/zsh" "$HOME"

# git
# hooks は core.hooksPath から直接参照するため、ホームには張らない。
for FILE in .gitconfig .mailmap; do
  ln -sfnv "$DOTFILES_PATH/config/git/$FILE" "$HOME/$FILE"
done
# core.excludesFile を指定していないため、git は既定の ~/.config/git/ignore を読む。
mkdir -p "$HOME/.config/git"
ln -sfnv "$DOTFILES_PATH/config/git/.gitignore_global" "$HOME/.config/git/ignore"

# scripts
ln -sfnv "$DOTFILES_PATH/config/scripts" "$HOME/.scripts"

# nvim
mkdir -p "$HOME/.config/nvim"
# rumdl が作る .rumdl_cache などを張らないよう、張るものを列挙する。
for FILE in CLAUDE.md init.lua lazy-lock.json lua; do
  ln -sfnv "$DOTFILES_PATH/config/nvim/$FILE" "$HOME/.config/nvim/$FILE"
done

# wezterm
mkdir -p "$HOME/.config/wezterm"
ln_files_in_dir "$DOTFILES_PATH/config/wezterm" "$HOME/.config/wezterm"

# Claude Code
mkdir -p "$HOME/.claude"
ln -sfnv "$DOTFILES_PATH/config/coding-agents/AGENTS.md" "$HOME/.claude/AGENTS.md"
ln -sfnv "$DOTFILES_PATH/config/claude/keybindings.json" "$HOME/.claude/keybindings.json"
ln -sfnv "$DOTFILES_PATH/config/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfnv "$DOTFILES_PATH/config/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# Claude Code output styles
mkdir -p "$HOME/.claude/output-styles"
ln_files_in_dir "$DOTFILES_PATH/config/claude/output-styles" "$HOME/.claude/output-styles"

# Claude Code と Codex で共有する hooks
mkdir -p "$HOME/.agents/hooks"
ln_files_in_dir "$DOTFILES_PATH/config/coding-agents/hooks" "$HOME/.agents/hooks"

# Codex
mkdir -p "$HOME/.codex"
ln -sfnv "$DOTFILES_PATH/config/coding-agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfnv "$DOTFILES_PATH/config/codex/hooks.json" "$HOME/.codex/hooks.json"

# Codex rules
mkdir -p "$HOME/.codex/rules"
ln_files_in_dir "$DOTFILES_PATH/config/codex/rules" "$HOME/.codex/rules"

# Vicinae
mkdir -p "$HOME/.config/vicinae"
ln_files_in_dir "$DOTFILES_PATH/config/vicinae" "$HOME/.config/vicinae"

# AeroSpace
mkdir -p "$HOME/.config/aerospace"
ln_files_in_dir "$DOTFILES_PATH/config/aerospace" "$HOME/.config/aerospace"

# yazi
mkdir -p "$HOME/.config/yazi"
ln_files_in_dir "$DOTFILES_PATH/config/yazi" "$HOME/.config/yazi"

# Karabiner-Elements
mkdir -p "$HOME/.config/karabiner"
ln_files_in_dir "$DOTFILES_PATH/config/karabiner" "$HOME/.config/karabiner"

# rumdl
mkdir -p "$HOME/.config/rumdl"
ln_files_in_dir "$DOTFILES_PATH/config/rumdl" "$HOME/.config/rumdl"

# Cursor
mkdir -p "$HOME/.cursor"
ln -sfnv "$DOTFILES_PATH/config/cursor/rules" "$HOME/.cursor/rules"

# herdr
# ~/.config/herdr にはログやソケットも置かれるため、config.toml だけを張る。
mkdir -p "$HOME/.config/herdr"
ln -sfnv "$DOTFILES_PATH/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
