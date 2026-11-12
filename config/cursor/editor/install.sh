#!/bin/bash
# PATH 上の cursor は Cursor CLI（agent）で --install-extension を持たないため、
# アプリ同梱の cursor を使う。
# Cursor では入れられない拡張があるため、失敗しても次の拡張へ進む。

set -u

dir="$(cd "$(dirname "$0")" && pwd)"
clis=(
  code
  /Applications/Cursor.app/Contents/Resources/app/bin/cursor
)

for cli in "${clis[@]}"; do
  command -v "$cli" >/dev/null || continue
  while read -r extension; do
    "$cli" --install-extension "$extension" || echo "skip: $cli $extension" >&2
  done <"$dir/extensions.txt"
done
