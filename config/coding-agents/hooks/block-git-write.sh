#!/usr/bin/env bash
# PreToolUse(Bash) フック。Cursor の beforeShellExecution でも使う（コマンドは .command に入る）。
# git add / git commit / git push / git merge / git rebase / git pull を拒否する。
#
# Cursor は stdout の JSON で判断する。
# failClosed のため、許可時も {"permission":"allow"} を必ず出す。
# 空出力だと Cursor は hook 失敗とみなして全コマンドを止める。
# Claude / Codex は exit 2 と stderr で判断し、stdout の JSON は読まない。
# Codex は PreToolUse の stdout を厳密に読み、
# permission を含む JSON を不正な出力として毎回エラーにする。
# そのため、stdin の hook_event_name が PreToolUse のときは stdout を空にし、
# Cursor のときだけ JSON を出す。
#
# ALLOW_GIT_WRITE=1 のときは何もブロックしない。
# 有効にするリポジトリの .claude/settings.local.json の env に書く。

set -u

deny_msg='git add / git commit / git push / git merge / git rebase / git pull はブロックされている。'

input=$(cat)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)

allow() {
  if [ "$event" != PreToolUse ]; then
    printf '%s\n' '{"permission":"allow"}'
  fi
  exit 0
}

deny() {
  printf '%s\n' "$deny_msg" >&2
  if [ "$event" != PreToolUse ]; then
    printf '%s\n' "{\"permission\":\"deny\",\"user_message\":\"${deny_msg}\",\"agent_message\":\"${deny_msg}\"}"
  fi
  exit 2
}

if [ "${ALLOW_GIT_WRITE:-}" = 1 ]; then
  allow
fi

# 行頭の git だけを見る。コマンド全体への部分一致にすると、
# echo や grep が git を文字列として言及しただけで巻き込むため。
#
# これはうっかり git commit/push を実行してしまう事故を防ぐためのもので、
# 意図的な回避を防ぐセキュリティ境界ではない。
# わざわざ回避しようとしない限り出てこない、次のような書き方は対応範囲外としている:
#   - eval / bash -c / sh -c / source
#   - 変数経由の間接実行
#   - エイリアス・関数定義
#   - \git のようなエスケープ
#   - サブコマンド自体をクォートで細工する（git "push" 等）

# 空白1文字と、トークンを構成する1文字
SP='[[:space:]]'
TOK='[^[:space:]]'

# FOO=bar の前置き
ENV="(${TOK}+=${TOK}*${SP}+)*"
# sudo / command / env / timeout / nohup / nice / setsid 経由。
# いずれも文字列を再解釈せず引数をそのまま実行するだけなので、素通しして問題ない。
# timeout の秒数のような非オプション引数も挟まりうるので、間の引数は種類を問わず読み飛ばす。
WRAP="((sudo|command|env|timeout|nohup|nice|setsid)(${SP}+${TOK}+)*${SP}+)*"
# git 本体（絶対パスも）
GIT="(${TOK}*/)?git"
# 値を別トークンで取る長オプション
VAL='(exec-path|git-dir|work-tree|namespace|config-env)'
# サブコマンド前のグローバルオプションを読み飛ばす。-c user.name=x、--git-dir /p、--no-pager
OPTS="(${SP}+(-[cC]${SP}+${TOK}+|--${VAL}${SP}+${TOK}+|-${TOK}+))*"
# 拒否するサブコマンド。末尾の境界で commit-graph などを除く
SUB="${SP}+(add|commit|push|merge|rebase|pull)(${SP}|\$)"

# '...' "..." の中の git は実行されないので、
# echo '... git commit ...' | pbcopy のような提示用のコマンドを巻き込まないために、
# クォートの中身は先に消す。
# ; & | ( ) 改行 を改行に潰し、各コマンドの先頭を行頭に揃えてから照合する。
# git "push" や git c'ommit' のようにサブコマンド自体をクォートで細工すると
# すり抜けるが、これも対応範囲外。
if printf '%s' "$input" | jq -r '.tool_input.command // .command // empty' |
  perl -0777 -pe 's/\x27[^\x27]*\x27|"(\\.|[^"\\])*"//g' |
  tr ';&|()\n' '\n' |
  grep -qE "^${SP}*$ENV$WRAP$GIT$OPTS$SUB"
then
  deny
fi

allow
