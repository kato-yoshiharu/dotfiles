#!/bin/bash
set -e

# ステージ済みの変更があると、意図しない差分まで commit されるので中断する
if ! git diff --cached --quiet; then
  echo "There are staged changes." >&2
  exit 1
fi

UNTRACKED_FILES=$(git ls-files --others --exclude-standard)

if [ -z "$UNTRACKED_FILES" ]; then
  echo "No untracked files found."
  exit 0
fi

MY_TMPDIR=$(mktemp -d)

restore_files() {
  while IFS= read -r FILE; do
    TMPFILE="$MY_TMPDIR/$(echo "$FILE" | sha256sum | cut -c1-8)_$(basename "$FILE")"
    [ -f "$TMPFILE" ] && cp "$TMPFILE" "$FILE"
  done <<< "$UNTRACKED_FILES"
  rm -rf "$MY_TMPDIR"
}

trap restore_files EXIT

while IFS= read -r FILE; do
  TMPFILE="$MY_TMPDIR/$(echo "$FILE" | sha256sum | cut -c1-8)_$(basename "$FILE")"
  cp "$FILE" "$TMPFILE"
  true > "$FILE"
  git add "$FILE"
done <<< "$UNTRACKED_FILES"

git commit -m "add empty files"

git push
