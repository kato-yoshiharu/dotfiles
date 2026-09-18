#!/bin/bash
set -e

# これからのコミットで origin との差分がちょうど1コミットになることを保証するための事前チェック
# 使い方: git-require-single-commit-ready.sh <branch>

branch="$1"

if [ -z "$branch" ]; then
  echo "usage: git-require-single-commit-ready.sh <branch>" >&2
  exit 1
fi

sh "$(dirname "$0")/git-require-remote-branch.sh" "$branch"

commit_count=$(git rev-list --count "origin/$branch..$branch")
if [[ $commit_count -ne 0 ]]; then
  echo "origin/$branch との間に未pushのコミットが既に $commit_count 件あります。1コミットにできません。" >&2
  exit 1
fi
