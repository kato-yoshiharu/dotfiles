#!/usr/bin/env bash
# PreToolUse(Bash) フック。git commit / git push / git merge / git rebase / git pull を拒否する。
# ブロックするときだけ stderr に理由を書いて exit 2 で終わる。exit 0 ならコマンドは通る。

set -u

# 行頭の git だけを見る。コマンド全体への部分一致にすると、
# echo や grep が git を文字列として言及しただけで巻き込むため。

# 空白1文字と、トークンを構成する1文字
SP='[[:space:]]'
TOK='[^[:space:]]'

# FOO=bar の前置き
ENV="(${TOK}+=${TOK}*${SP}+)*"
# sudo / command / env 経由
WRAP="((sudo|command|env)${SP}+)*"
# git 本体（絶対パスも）
GIT="(${TOK}*/)?git"
# 値を別トークンで取る長オプション
VAL='(exec-path|git-dir|work-tree|namespace|config-env)'
# サブコマンド前のグローバルオプションを読み飛ばす。-c user.name=x、--git-dir /p、--no-pager
OPTS="(${SP}+(-[cC]${SP}+${TOK}+|--${VAL}${SP}+${TOK}+|-${TOK}+))*"
# 拒否するサブコマンド。末尾の境界で commit-graph などを除く
SUB="${SP}+(commit|push|merge|rebase|pull)(${SP}|\$)"

# ; & | ( ) 改行 を改行に潰し、各コマンドの先頭を行頭に揃えてから照合する。
# クォート内の文字列（pbcopy に渡すコマンド例など）はコマンド区切りではないため、
# 先に単引用符・二重引用符で囲まれた範囲を空にしてから区切り文字を潰す。
jq -r '.tool_input.command // empty' |
  tr ';&|()\n' '\n' |
  grep -qE "^${SP}*$ENV$WRAP$GIT$OPTS$SUB" || exit 0

# PreToolUse では exit 2 がブロックを意味し、stderr がそのまま理由として渡る
echo 'git commit / git push / git merge / git rebase / git pull はブロックされている。' >&2
exit 2
