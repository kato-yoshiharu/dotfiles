# starship
eval "$(starship init zsh)"

# vimキーバインド
bindkey -v

# mise
eval "$(mise activate zsh)"

# .commands
alias hello-world="sh ~/.commands/hello-world.sh"
alias tmux-start="sh ~/.commands/tmux-start.sh"

# herdr
sh ~/.commands/herdr-start.sh

# direnv
eval "$(direnv hook zsh)"

# local settings (not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

export PATH="$HOME/.local/bin:$PATH"

herdr() {
  sh ~/.commands/herdr.sh "$@"
}

# 外部ターミナルから claude を起動したとき、Cursor 等の他 IDE ロックファイルと
# 競合して自動接続が曖昧になるのを避け、カレントディレクトリ配下を開いている
# Neovim (claudecode.nvim) に確実に接続する
claude() {
  local lock
  lock=$(
    for f in ~/.claude/ide/*.lock(N); do
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
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
# bindkey -v の後に読み込む必要がある
eval "$(fzf --zsh)"
