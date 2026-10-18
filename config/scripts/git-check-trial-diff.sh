#!/bin/bash
set -e

message="$1"

if [ -z "$message" ]; then
  echo "usage: git ctd <commit message>" >&2
  exit 1
fi

current_branch=$(git branch | grep \* | cut -d ' ' -f2)

sh "$(dirname "$0")/git-require-single-commit-ready.sh" "$current_branch"

# staging の内容と trial ブランチの内容が完全一致するか確認する
staged_tree=$(git write-tree)
trial_tree=$(git rev-parse trial^{tree})

if [ "$staged_tree" != "$trial_tree" ]; then
  echo "staging の内容が trial ブランチと一致しません。" >&2
  git diff trial
  exit 1
fi

git commit -m "$message"

git push -u origin HEAD

git branch -D trial
