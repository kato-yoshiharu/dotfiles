#!/bin/bash
set -euo pipefail

# clone 直後や worktree 作成直後の作業ディレクトリに、一時ディレクトリと共有設定を用意する。
# 何度実行してもよい。
# 既に実体や別の symlink があるときは上書きせず、警告だけ出す。

repo_root=$(git rev-parse --show-toplevel)

# 先頭の worktree がメインの worktree。
main_worktree=$(git worktree list --porcelain | sed -n '1s/^worktree //p')

# このスクリプトの実体があるリポジトリを dotfiles とみなし、そのメインの worktree を求める。
# ~/.scripts 経由でも、dotfiles の worktree から直接実行しても、同じ場所になる。
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
dotfiles_main=$(git -C "$script_dir" worktree list --porcelain | sed -n '1s/^worktree //p')

warn() {
  echo "警告: $*" >&2
}

# 実ディレクトリを用意する。
ensure_dir() {
  local path="$1"
  if [ -L "$path" ]; then
    warn "$path は symlink になっている。実ディレクトリにしたいので確認すること。"
  elif [ -e "$path" ] && [ ! -d "$path" ]; then
    warn "$path がディレクトリでないファイルとして存在する。"
  elif [ ! -e "$path" ]; then
    mkdir -p "$path"
    echo "作成: $path"
  fi
}

# path に target への symlink を用意する。
ensure_link() {
  local path="$1"
  local target="$2"
  if [ -L "$path" ]; then
    if [ "$(readlink "$path")" != "$target" ]; then
      warn "$path は $(readlink "$path") を指している。$target に向けたいので確認すること。"
    fi
  elif [ -e "$path" ]; then
    warn "$path に実体があるので上書きしない。$target への symlink にしたいので確認すること。"
  else
    ln -s "$target" "$path"
    echo "リンク: $path -> $target"
  fi
}

# _global の実体は dotfiles のメインの worktree に置く。
ensure_dir "$dotfiles_main/_global"
if [ "$repo_root" != "$dotfiles_main" ]; then
  ensure_link "$repo_root/_global" "$dotfiles_main/_global"
fi

# _repo の実体はこのリポジトリのメインの worktree に置く。
ensure_dir "$main_worktree/_repo"
if [ "$repo_root" != "$main_worktree" ]; then
  ensure_link "$repo_root/_repo" "$main_worktree/_repo"
fi

ensure_dir "$repo_root/_local"

# Claude Code の承認済みコマンドなどを、メインの worktree と共有する。
settings_local=".claude/settings.local.json"
if [ "$repo_root" != "$main_worktree" ] && [ -f "$main_worktree/$settings_local" ]; then
  mkdir -p "$repo_root/.claude"
  ensure_link "$repo_root/$settings_local" "$main_worktree/$settings_local"
fi
