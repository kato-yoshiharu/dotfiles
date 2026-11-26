#!/bin/bash
# Cursor と VSCode の User 設定を、このディレクトリのファイルへの symlink として張る。

set -euo pipefail

src_dir="$(cd "$(dirname "$0")" && pwd)"
user_dirs=(
  "$HOME/Library/Application Support/Cursor/User"
  "$HOME/Library/Application Support/Code/User"
)

link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak"
  fi
  ln -sfn "$src" "$dest"
}

for user_dir in "${user_dirs[@]}"; do
  mkdir -p "$user_dir"
  link "$src_dir/settings.json" "$user_dir/settings.json"
  link "$src_dir/keybindings.json" "$user_dir/keybindings.json"
done

# チャットの送信を Cmd+Enter、改行を Enter にする。
# この設定は settings.json ではなく state.vscdb にだけ保存される。
# Cursor の起動中に書くと、終了時に値が上書きされて戻る。
state_db="$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb"
if [ -f "$state_db" ]; then
  if pgrep -x Cursor >/dev/null; then
    echo "Cursor が起動中のため、チャットの Cmd+Enter 送信設定をスキップした。終了して再実行する。" >&2
  else
    sqlite3 "$state_db" "update ItemTable set value = json_set(value, '\$.chatSubmitOnCmdEnter', json('true')) where key = 'src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser';"
  fi
fi
