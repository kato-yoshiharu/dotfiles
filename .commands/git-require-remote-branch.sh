#!/bin/bash
set -e

# 指定したブランチの remote branch (origin/<branch>) が存在するか確認する
# 使い方: git-require-remote-branch.sh <branch>

branch="$1"

if [ -z "$branch" ]; then
  echo "usage: git-require-remote-branch.sh <branch>" >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
  echo "origin/$branch が見つかりません。先に一度 push してください。" >&2
  exit 1
fi
