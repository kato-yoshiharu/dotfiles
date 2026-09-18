#!/bin/bash
set -e

current_branch=$(git branch | grep \* | cut -d ' ' -f2)

case "$current_branch" in
  *-trial)
    echo "現在のブランチ ($current_branch) には既に -trial が含まれています。" >&2
    exit 1
    ;;
esac

sh "$(dirname "$0")/git-require-remote-branch.sh" "$current_branch"

trial_branch="${current_branch}-trial"

git checkout -b "$trial_branch"
git push -u origin HEAD
