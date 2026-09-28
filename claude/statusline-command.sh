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
# ブランチ名は入力JSONに含まれないので、カレントディレクトリでgitに問い合わせる。
repo=$(echo "$input" | jq -r '.workspace.repo.name // empty')
dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
branch=""
if [ -n "$dir" ]; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
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
# リポジトリ名が取れないときは、カレントディレクトリ名で代用する。
# モデル名が既に出力済みなら区切りの" | "を先に挟む。
place="${repo:-$dirname}"
if [ -n "$place" ]; then
  [ -n "$model" ] && printf " | "
  printf "\033[34m%s\033[0m" "$place"
fi

# ブランチ名を緑色で表示する。
# リポジトリ名の続きであることを示すため、"/"で繋ぐ。
if [ -n "$branch" ]; then
  [ -n "$place" ] && printf "\033[34m/\033[0m"
  printf "\033[32m%s\033[0m" "$branch"
fi

# 使用率が取れているときだけ黄色で表示する。
# それまでに何か出力済みなら区切りの" | "を先に挟む。
if [ -n "$used" ]; then
  { [ -n "$model" ] || [ -n "$place" ]; } && printf " | "
  printf "\033[36mTokens:\033[0m \033[33m%.0f%%\033[0m used" "$used"
fi
