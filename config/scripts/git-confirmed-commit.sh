#!/bin/bash
set -e

current_branch=$(git branch | grep \* | cut -d ' ' -f2)

sh "$(dirname "$0")/git-require-remote-branch.sh" "$current_branch"

git commit -m "confirmed"
git push -u origin HEAD
