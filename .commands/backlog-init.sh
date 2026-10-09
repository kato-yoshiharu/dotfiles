#!/bin/bash
set -euo pipefail

# カレントの git リポジトリに Backlog.md を導入して、コミットする。
# AGENTS.md への指示ブロック追加と backlog/config.yml 作成は backlog init に任せる。
# AGENTS.md が既にあれば、マーカー間のブロックだけが追加・更新される。

if ! command -v backlog >/dev/null 2>&1; then
  echo "backlog コマンドが見つからない。" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

# 先頭の worktree がメインの worktree。
main_worktree=$(git worktree list --porcelain | sed -n '1s/^worktree //p')

project_name=$(basename "$main_worktree")

# 既に導入済みなら中断する。
if [ -e backlog/config.yml ]; then
  echo "backlog/config.yml が既にある。導入済みとみなして中断する。" >&2
  exit 1
fi

# コミットに無関係な変更を巻き込まないよう、対象ファイルの未コミット変更は許さない。
if [ -n "$(git status --porcelain -- AGENTS.md backlog)" ]; then
  echo "AGENTS.md または backlog/ に未コミットの変更がある。先にコミットか破棄をすること。" >&2
  exit 1
fi

backlog init "$project_name" \
  --defaults \
  --integration-mode cli \
  --agent-instructions agents

git add AGENTS.md backlog/config.yml
git commit -m "chore: add backlog.md" -- AGENTS.md backlog/config.yml
