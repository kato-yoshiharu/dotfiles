#!/bin/bash
# herdr: session delete 時に自動で stop してから削除する
# .zshrc の herdr 関数から呼ばれる。command herdr で本物のバイナリを実行する。
if [[ "$1" == "session" && "$2" == "delete" ]]; then
  name="$3"
  if [[ -n "$name" ]]; then
    command herdr session stop "$name" >/dev/null 2>&1
  fi
fi
command herdr "$@"
