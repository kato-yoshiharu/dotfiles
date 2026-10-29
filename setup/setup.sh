#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
# 冪等にするため、登録済みのアプリは飛ばす。
register_login_item() {
  local name="$1"
  local hidden="${2:-false}"
  local registered
  registered=$(osascript -e 'tell application "System Events" to get the name of every login item')

  if [[ ", $registered, " != *", $name, "* ]]; then
    osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/$name.app\", hidden:$hidden}"
  fi
}

register_login_item Vicinae
register_login_item AeroSpace
register_login_item "Google Chrome"
register_login_item WezTerm
# Homerow はキーバインドで使うので、起動時にウィンドウを開かない。
register_login_item Homerow true

# スクリーンショットの保存先をホーム直下の ~/Screenshots にする
# 新しい macOS は location-screenshot と location-screenrecording を優先するため、3つとも揃える。
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"
defaults write com.apple.screencapture location-screenshot "$HOME/Screenshots"
defaults write com.apple.screencapture location-screenrecording "$HOME/Screenshots"
killall SystemUIServer
