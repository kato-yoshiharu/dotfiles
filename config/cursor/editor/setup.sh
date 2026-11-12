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
