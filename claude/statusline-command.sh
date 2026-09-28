#!/bin/sh
# Claude Code本体がstdin経由でJSONを渡してくるので、
# それをjqで取り出し、色付きの1行として標準出力に返す。
input=$(cat)

# モデル名（例: Sonnet 5）。
model=$(echo "$input" | jq -r '.model.display_name // empty')

# reasoning effort（low/medium/high/xhigh/max）。
# effortパラメータに対応していないモデルでは渡ってこない。
effort=$(echo "$input" | jq -r '.effort.level // empty')

# セッションの場所。
# 手動git worktreeではworktree.nameが空なので、workspace.git_worktreeで補う。
repo=$(echo "$input" | jq -r '.workspace.repo.name // empty')
worktree=$(echo "$input" | jq -r '.worktree.name // empty')
if [ -z "$worktree" ]; then
  worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
fi
dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
if [ -z "$repo" ] && [ -z "$worktree" ] && [ -n "$dir" ]; then
  dirname="${dir##*/}"
fi

# コンテキストウィンドウの使用率。
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# モデル名を紫色で表示する。
# effortが取れているときは、モデル名の後ろに括弧書きで灰色表示する。
if [ -n "$model" ]; then
  printf "\033[35m%s\033[0m" "$model"
  [ -n "$effort" ] && printf " \033[90m(%s)\033[0m" "$effort"
fi

# リポジトリ名を青色で表示する。
# モデル名が既に出力済みなら区切りの" | "を先に挟む。
if [ -n "$repo" ]; then
  [ -n "$model" ] && printf " | "
  printf "\033[34m%s\033[0m" "$repo"
fi

# worktree名を緑色で表示する。
# リポジトリ名の続きであることを示すため、リポジトリ名がある場合は" | "ではなく"/"で繋ぐ。
# リポジトリ名がなくモデル名だけある場合は" | "を先に挟む。
if [ -n "$worktree" ]; then
  if [ -n "$repo" ]; then
    printf "\033[34m/\033[0m"
  elif [ -n "$model" ]; then
    printf " | "
  fi
  printf "\033[32m%s\033[0m" "$worktree"
fi

# リポジトリ名・worktree名がどちらも取れないときは、カレントディレクトリ名を青色でフォールバック表示する。
if [ -z "$repo" ] && [ -z "$worktree" ] && [ -n "$dirname" ]; then
  [ -n "$model" ] && printf " | "
  printf "\033[34m%s\033[0m" "$dirname"
fi

# 使用率が取れているときだけ黄色で表示する。
# それまでに何か出力済みなら区切りの" | "を先に挟む。
if [ -n "$used" ]; then
  { [ -n "$model" ] || [ -n "$repo" ] || [ -n "$worktree" ] || [ -n "$dirname" ]; } && printf " | "
  printf "\033[36mTokens:\033[0m \033[33m%.0f%%\033[0m used" "$used"
fi
