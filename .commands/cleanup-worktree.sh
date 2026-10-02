#!/bin/bash
set -euo pipefail

# 現在の worktree と、それに紐づくブランチを、リモートブランチごと削除する
# extract-to-worktree で作った worktree の後片付けに使う

worktree_path=$(git rev-parse --show-toplevel)

# 先頭の worktree がメインの worktree
main_worktree=$(git worktree list --porcelain | sed -n '1s/^worktree //p')

if [ "$worktree_path" = "$main_worktree" ]; then
  echo "メインの worktree では実行できない。削除したい worktree の中で実行すること。" >&2
  exit 1
fi

branch=$(git branch --show-current)

if [ -z "$branch" ]; then
  echo "この worktree はブランチに紐づいていない（detached HEAD）。" >&2
  exit 1
fi

has_remote=false
if [ -n "$(git ls-remote --heads origin "$branch")" ]; then
  has_remote=true
fi

if [ -n "$(git -C "$worktree_path" status --porcelain)" ]; then
  echo "worktree に未コミットの変更があります。中断する: $worktree_path" >&2
  git -C "$worktree_path" status --short >&2
  exit 1
fi

# 削除する worktree の中にいると消せないので、メインの worktree に移る
cd "$main_worktree"

git worktree remove "$worktree_path"

git branch -D "$branch"

if [ "$has_remote" = true ]; then
  git push origin --delete "$branch"
fi
