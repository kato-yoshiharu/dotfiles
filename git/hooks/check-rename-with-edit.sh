#!/bin/sh
# rename と内容変更を同じコミットに混ぜない
# 類似度が 100% 未満の rename（R50〜R99）が staged に含まれていたら拒否する

EDITED=$(git -c core.quotepath=false diff --cached -M --name-status --diff-filter=R |
  awk -F '\t' '$1 != "R100" { print "  " $2 " -> " $3 " (" $1 ")" }')

if [ -n "$EDITED" ]; then
  echo "エラー: rename と内容変更が同じコミットに含まれています。" >&2
  echo "rename だけのコミットと、内容変更のコミットに分けてください。" >&2
  echo "$EDITED" >&2
  exit 1
fi
