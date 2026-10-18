#!/bin/bash
set -euo pipefail

# 現在のブランチのコミットを、分岐元から HEAD まで1つにまとめる
# 分岐元は main（xxx-trial というブランチ名のときは xxx）
# コミットメッセージは confirmed 固定
# push はしない

message="confirmed"

branch=$(git branch --show-current)

if [ -z "$branch" ]; then
  echo "ブランチに紐づいていない（detached HEAD）。中断する。" >&2
  exit 1
fi

base="main"
case "$branch" in
  ?*-trial) base="${branch%-trial}" ;;
esac

if ! git rev-parse --verify --quiet "refs/heads/$base" >/dev/null; then
  echo "分岐元のブランチ $base が存在しない。中断する。" >&2
  exit 1
fi

if [ "$branch" = "$base" ]; then
  echo "$base 自身は対象外。まとめたいブランチの中で実行すること。" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "未コミットの変更があります。中断する。" >&2
  git status --short >&2
  exit 1
fi

merge_base=$(git merge-base "$base" HEAD)
commit_count=$(git rev-list --count "$merge_base..HEAD")

if [ "$commit_count" -le 1 ]; then
  echo "$base からのコミットが $commit_count 個なので、まとめる必要はない。"
  exit 0
fi

echo "まとめる対象のコミット（$commit_count 個）:"
git log --oneline "$merge_base..HEAD"

git reset --soft "$merge_base"
git commit -m "$message"

# push 済みのブランチは、履歴が書き換わるので通常の push は弾かれる
if [ -n "$(git ls-remote --heads origin "$branch")" ]; then
  echo
  echo "リモートに $branch がある。反映するには次を実行すること:"
  echo "  git push --force-with-lease origin $branch"
fi
