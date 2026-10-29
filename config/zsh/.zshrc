# starship
eval "$(starship init zsh)"

# vimキーバインド
bindkey -v

# mise
eval "$(mise activate zsh)"

# scripts
alias cleanup-worktree="bash ~/.scripts/cleanup-worktree.sh"
alias squash-commits="bash ~/.scripts/squash-commits.sh"

# local settings (not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

export PATH="$HOME/.local/bin:$PATH"

herdr() {
  sh ~/.scripts/herdr.sh "$@"
}

# Cursor Agent の起動前に画面を消し、打ったコマンドの行を残さない。
# 対象は引数なしの `cursor` と `cursor agent` で、出力が端末のときだけ消す。
cursor() {
  if [[ -t 1 && ( $# -eq 0 || $1 == agent ) ]]; then
    clear
  fi
  command cursor "$@"
}

# 外部ターミナルから claude を起動したとき、Cursor 等の他 IDE ロックファイルと
# 競合して自動接続が曖昧になるのを避け、カレントディレクトリ配下を開いている
# Neovim (claudecode.nvim) に確実に接続する
claude() {
  # (N) 修飾子は実行環境によって効かないため、null_glob オプションで代用する
  setopt local_options null_glob
  local lock
  lock=$(
    for f in ~/.claude/ide/*.lock; do
      jq -e --arg cwd "$PWD" \
        'select(.ideName == "Neovim") | select(.workspaceFolders | any(. as $w | $cwd | startswith($w)))' \
        "$f" >/dev/null 2>&1 && echo "$f"
    done | head -n1
  )

  if [[ -n "$lock" ]]; then
    local port
    port=$(basename "$lock" .lock)
    CLAUDE_CODE_SSE_PORT="$port" ENABLE_IDE_INTEGRATION=true command claude "$@"
  else
    command claude "$@"
  fi
}

# zoxide の初期設定
eval "$(zoxide init zsh)"

# fzf の探索コマンドを fd に差し替える
export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
# bindkey -v の後に読み込む必要がある
eval "$(fzf --zsh)"

# Claude Code・Codex の Ctrl+G（外部エディタ起動）で Neovim を開く
export VISUAL=nvim
export EDITOR=nvim

# git merge でマージコミットのメッセージ編集エディタを開かない(--no-edit を既定にする)。
# 明示的に --edit を付ければ開ける
export GIT_MERGE_AUTOEDIT=no

# ghq のリポジトリ配置先
export GHQ_ROOT="$HOME/repos"

# ghq で管理しているリポジトリを fzf で選んで cd する
ghq-fzf-cd() {
  local repo
  repo=$(ghq list -p | fzf --prompt="ghq> ")
  [[ -n "$repo" ]] && cd "$repo"
}
bindkey -s '^g' 'ghq-fzf-cd\n'
