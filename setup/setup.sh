#!/bin/bash

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# GUI アプリ
brew bundle --file "$DOTFILES_DIR/setup/Brewfile"

# mise
# 入れるランタイムは config/mise/config.toml に書いてある。
mise install

# cspell: link the shared personal dictionary as global config
# グローバル辞書は cspell-global worktree の cspell.json だけを編集する運用にしている。
# そのため、リンク先は常にこの worktree に固定する。
# worktree の置き場は、メインのクローンの隣の <クローン名>-worktrees にする。
MAIN_CLONE_DIR="$(cd "$(git -C "$DOTFILES_DIR" rev-parse --git-common-dir)/.." && pwd)"
CSPELL_GLOBAL_DIR="$MAIN_CLONE_DIR-worktrees/cspell-global"
CSPELL_GLOBAL_JSON="$CSPELL_GLOBAL_DIR/cspell.json"

# worktree がなければ作成する。
# ブランチが既にあれば -b なしで、なければ origin/main から作る。
if [ ! -d "$CSPELL_GLOBAL_DIR" ]; then
  if git -C "$DOTFILES_DIR" show-ref --verify --quiet refs/heads/cspell-global; then
    git -C "$DOTFILES_DIR" worktree add "$CSPELL_GLOBAL_DIR" cspell-global
  else
    git -C "$DOTFILES_DIR" worktree add "$CSPELL_GLOBAL_DIR" -b cspell-global origin/main
  fi
fi

# 別の dotfiles の cspell.json へのリンクが残っていれば外す（冪等にするため）。
cspell link list | awk -F' *\\| *' '{print $4}' | grep '/dotfiles.*/cspell\.json$' | while read -r linked; do
  if [ "$linked" != "$CSPELL_GLOBAL_JSON" ]; then
    cspell link remove "$linked"
  fi
done

cspell link add "$CSPELL_GLOBAL_JSON"

# login items: macOS起動時に自動起動させるアプリ
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Vicinae.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/AeroSpace.app", hidden:false}'
