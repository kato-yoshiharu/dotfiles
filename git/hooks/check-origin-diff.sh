#!/bin/sh
# Check if current branch has unpushed commits compared to origin

BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
if [ -z "$BRANCH" ]; then
  exit 0
fi

# trial ブランチはローカルのみで使う(originにpushしない)想定のため対象外にする
if [ "$BRANCH" = "trial" ]; then
  exit 0
fi

# Check if origin exists
if ! git remote get-url origin > /dev/null 2>&1; then
  exit 0
fi

# Fetch origin (silently); skip check if fetch fails (e.g. no network)
# if ! git fetch origin "$BRANCH" --quiet 2>/dev/null; then
#   exit 0
# fi

# Check if origin/<branch> exists
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
if ! "$SCRIPT_DIR/../../.commands/git-require-remote-branch.sh" "$BRANCH"; then
  exit 1
fi

UNPUSHED=$(git rev-list HEAD ^"origin/$BRANCH" --count 2>/dev/null)
if [ "$UNPUSHED" -gt 0 ]; then
  echo "Error: $UNPUSHED unpushed commit(s) exist on '$BRANCH'." >&2
  echo "Push before committing: git push origin $BRANCH" >&2
  exit 1
fi
