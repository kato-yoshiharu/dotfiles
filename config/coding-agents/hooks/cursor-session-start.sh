#!/usr/bin/env bash
# Cursor の sessionStart hook。共通の AGENTS.md を additional_context として返す。
# Cursor CLI はユーザー単位の AGENTS.md を読まないため、hook で注入する。
# 読み込めないときは何も返さず、セッションを止めない。

set -u

src="$HOME/.claude/AGENTS.md"

cat > /dev/null

if [ -r "$src" ]; then
  jq -Rs '{additional_context: .}' "$src"
else
  echo '{}'
fi
