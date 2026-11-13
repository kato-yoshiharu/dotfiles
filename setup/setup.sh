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

# VS Code と Cursor の User 設定を、このリポジトリのファイルへの symlink として配置する。
bash "$DOTFILES_DIR/config/cursor/editor/setup.sh"
# VS Code と Cursor に、一覧にある拡張機能をインストールする。
bash "$DOTFILES_DIR/config/cursor/editor/install.sh"

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

# macOS の外観をダークモードにする
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

# 無操作でもディスプレイの電源を切らない
sudo pmset -a displaysleep 0

# 電源アダプタ接続中は Mac を自動スリープさせない
sudo pmset -c sleep 0

# macOS の設定を defaults write で適用する
# 意図と、反映に必要な操作は docs/mac-settings.md に書く。
# defaults write は誤ったキーでも成功するため、
# 読み戻しで分かるのは、値が書けたことだけ。
# 効いているかの確認は、docs/mac-settings.md の手順で行う。
set_default() {
  local domain="$1" key="$2" type="$3" value="$4"
  local expected="$value"
  case "$type:$value" in
    bool:true) expected=1 ;;
    bool:false) expected=0 ;;
  esac

  defaults write "$domain" "$key" "-$type" "$value"

  local actual
  actual=$(defaults read "$domain" "$key" 2>/dev/null)
  if [ "$actual" != "$expected" ]; then
    echo "WARN: $domain $key が $expected にならなかった（読み戻した値: ${actual:-なし}）" >&2
  fi
}

# トラックパッドのカーソル速度を 3 にする
set_default -g com.apple.trackpad.scaling float 3

# キーリピートを速くする
set_default -g KeyRepeat int 2
set_default -g InitialKeyRepeat int 15

# 長押しでアクセント文字の選択を出さず、キーリピートさせる
set_default -g ApplePressAndHoldEnabled bool false

# インターフェースの視差効果を減らす
set_default com.apple.universalaccess reduceMotion bool true

# Dock を使わないときは隠す
set_default com.apple.dock autohide bool true
# アイコンの大きさを 64 にする
set_default com.apple.dock tilesize int 64

# Finder の下部にステータスバーを出す
set_default com.apple.finder ShowStatusBar bool true
# Finder の既定の表示をリストにする
set_default com.apple.finder FXPreferredViewStyle string Nlsv

# エラー音が鳴るとき、画面も点滅させる
set_default -g com.apple.sound.beep.flash int 1

# 日本語入力のライブ変換を使わない
set_default com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey int 0
# Windows 風のキー操作を使う
set_default com.apple.inputmethod.Kotoeri JIMPrefWindowsModeKey int 1

# トラックパッドで 3 本指を上にスワイプしたときの挙動を、Mission Control にする
# 内蔵トラックパッドと Bluetooth トラックパッドで、ドメインが分かれている
set_default com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture int 2
set_default com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture int 2

# Dock と Finder を再起動して、設定を反映する
killall Dock
killall Finder
