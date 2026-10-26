#!/bin/bash
set -euo pipefail

# Claude Code と Codex の hooks 設定を、ベースと、Orca など他のツールが書いた分に分けて管理する。
# Orca は、自分の hooks を ~/.claude/settings.json と ~/.codex/hooks.json に直接書き込む。この書き込み先は変更できない。
# そのため、この2つは実ファイルのままにして、実行のたびに他のツールの hooks を、ベースに足して更新する。
# 他のツールの hooks は、実ファイルの hooks から、前回入れたベースの hooks と今のベースの hooks を除いた残りとする。
# Cursor の ~/.cursor/hooks.json も Orca が書くため、Claude と Codex と同じ方式で扱う。
# Cursor CLI の ~/.cursor/cli-config.json は、認証情報や選択中のモデルも含み、CLI が自動で書き換える。
# そのため、このファイルも実ファイルのままにして、ベースに書いたトップレベルのキーだけを置き換える。

repo_root=$(git rev-parse --show-toplevel)
claude_out=${CLAUDE_SETTINGS_OUT:-$HOME/.claude/settings.json}
codex_out=${CODEX_HOOKS_OUT:-$HOME/.codex/hooks.json}
cursor_out=${CURSOR_CLI_CONFIG_OUT:-$HOME/.cursor/cli-config.json}
cursor_hooks_out=${CURSOR_HOOKS_OUT:-$HOME/.cursor/hooks.json}
state_dir=${AGENT_CONFIGS_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/agent-configs}

build() {
  local base=$1 out=$2 state=$3

  mkdir -p "$(dirname "$out")" "$state_dir"

  local existing='{}'
  if [ -s "$out" ]; then
    existing=$(cat "$out")
  fi

  local prev='{}'
  if [ -s "$state" ]; then
    prev=$(cat "$state")
  fi

  local merged
  merged=$(jq --argjson existing "$existing" --argjson prev "$prev" '
    ($existing.hooks // {}) as $old
    | .hooks = (
        (.hooks // {}) as $base_hooks
        | ($base_hooks | keys) + ($old | keys) | unique
        | map(. as $event
            | (($prev[$event] // []) + ($base_hooks[$event] // [])) as $known
            | {
                key: $event,
                value: (
                  ($base_hooks[$event] // [])
                  + (($old[$event] // []) | map(select(. as $group | any($known[]; . == $group) | not)))
                )
              })
        | map(select(.value | length > 0))
        | from_entries
      )
  ' "$base")

  if [ ! -f "$out" ] || [ "$merged" != "$(cat "$out")" ]; then
    printf '%s\n' "$merged" > "$out.tmp"
    mv "$out.tmp" "$out"
    echo "生成した: $out"
  fi

  jq '.hooks // {}' "$base" > "$state"
}

build_cursor() {
  local base=$1 out=$2

  mkdir -p "$(dirname "$out")"

  local existing='{}'
  if [ -s "$out" ]; then
    existing=$(cat "$out")
  fi

  local merged
  merged=$(jq --argjson base "$(cat "$base")" '. + $base' <<< "$existing")

  if [ ! -f "$out" ] || [ "$merged" != "$(cat "$out")" ]; then
    printf '%s\n' "$merged" > "$out.tmp"
    mv "$out.tmp" "$out"
    echo "生成した: $out"
  fi
}

build "$repo_root/config/claude/settings.json" "$claude_out" "$state_dir/claude-base-hooks.json"
build "$repo_root/config/codex/hooks.json" "$codex_out" "$state_dir/codex-base-hooks.json"
build "$repo_root/config/cursor/hooks.json" "$cursor_hooks_out" "$state_dir/cursor-base-hooks.json"
build_cursor "$repo_root/config/cursor/cli-config.json" "$cursor_out"
