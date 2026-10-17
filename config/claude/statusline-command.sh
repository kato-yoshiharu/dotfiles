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

# 1行目はここまで。
[ -n "$model$place" ] && printf '\n'

# 2行目にコンテキストの使用率とレート制限を出す。
# 各項目は取れているときだけ、先に出力済みの項目があれば区切りの" | "を挟む。
line2=""
sep() { [ -n "$line2" ] && printf " | "; line2=1; }

# レート制限（5時間枠・週次枠）の使用率。
# 80%以上で黄色、95%以上で赤色にする。
limit() {
  [ -n "$2" ] || return
  sep
  color=32
  [ "$(printf '%.0f' "$2")" -ge 80 ] && color=33
  [ "$(printf '%.0f' "$2")" -ge 95 ] && color=31
  printf "\033[36m%s:\033[0m \033[%sm%.0f%%\033[0m" "$1" "$color" "$2"
}

# 使用率が取れているときだけ黄色で表示する。
if [ -n "$used" ]; then
  sep
  printf "\033[36mTokens:\033[0m \033[33m%.0f%%\033[0m used" "$used"
fi

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
limit "5h" "$five"
limit "7d" "$week"


# 最後の項目が取れていないと終了ステータスが非0になり、
# Claude Code側が出力を捨てて表示されなくなるので、0で終わらせる。
exit 0
