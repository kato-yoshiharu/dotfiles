#!/bin/bash
set -e

current_branch=$(git branch | grep \* | cut -d ' ' -f2)

sh "$(dirname "$0")/git-require-remote-branch.sh" "$current_branch"

UNTRACKED_FILES=$(git ls-files --others --exclude-standard)

if [ -z "$UNTRACKED_FILES" ]; then
  echo "No untracked files found."
  exit 0
fi

MY_TMPDIR=$(mktemp -d)

restore_files() {
  while IFS= read -r FILE; do
    TMPFILE="$MY_TMPDIR/$(echo "$FILE" | shasum -a 256 | cut -c1-8)_$(basename "$FILE")"
    [ -f "$TMPFILE" ] && cp "$TMPFILE" "$FILE"
  done <<< "$UNTRACKED_FILES"
  rm -rf "$MY_TMPDIR"
}

trap restore_files EXIT

while IFS= read -r FILE; do
  TMPFILE="$MY_TMPDIR/$(echo "$FILE" | shasum -a 256 | cut -c1-8)_$(basename "$FILE")"
  cp "$FILE" "$TMPFILE"
  true > "$FILE"
  git add "$FILE"
done <<< "$UNTRACKED_FILES"

UNTRACKED_FILES_ARR=()
while IFS= read -r FILE; do
  UNTRACKED_FILES_ARR+=("$FILE")
done <<< "$UNTRACKED_FILES"

git commit -m "add empty files" -- "${UNTRACKED_FILES_ARR[@]}"

git push -u origin HEAD
