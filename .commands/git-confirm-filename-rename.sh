#!/bin/bash
set -e

# stagedなrename(ファイル名の変更)のみを対象にする
RENAMES=$(git diff --cached -M --name-status --diff-filter=R)

if [ -z "$RENAMES" ]; then
  echo "No staged renames found." >&2
  exit 0
fi

current_branch=$(git branch | grep \* | cut -d ' ' -f2)

sh "$(dirname "$0")/git-require-remote-branch.sh" "$current_branch"

MY_TMPDIR=$(mktemp -d)
echo "退避先: $MY_TMPDIR (強制終了時はここから手動で復旧してください)"

NEW_PATHS=()
OLD_PATHS=()

restore_files() {
  for NEW in "${NEW_PATHS[@]}"; do
    TMPFILE="$MY_TMPDIR/$(echo "$NEW" | shasum -a 256 | cut -c1-8)_$(basename "$NEW")"
    [ -f "$TMPFILE" ] && cp "$TMPFILE" "$NEW"
  done
  rm -rf "$MY_TMPDIR"
}

trap restore_files EXIT

while IFS=$'\t' read -r STATUS OLD NEW; do
  NEW_PATHS+=("$NEW")
  OLD_PATHS+=("$OLD")

  TMPFILE="$MY_TMPDIR/$(echo "$NEW" | shasum -a 256 | cut -c1-8)_$(basename "$NEW")"
  cp "$NEW" "$TMPFILE"

  # 中身は変えず、ファイル名だけを変えた「純粋なrename」にするため、
  # 新しいパスの中身を旧パス(HEAD時点)の内容に戻す
  git show "HEAD:$OLD" > "$NEW"
  git add "$NEW"
done <<< "$RENAMES"

git commit -m "confirm filename" -- "${OLD_PATHS[@]}" "${NEW_PATHS[@]}"

git push -u origin HEAD
