-- Claude Code との IDE 統合（選択範囲/バッファの送信、diff のバッファ内表示・適用）

return {
  "coder/claudecode.nvim",
  cond = not vim.g.vscode,
  -- 外部ターミナルの claude code から WebSocket 経由で接続できるよう、コマンド初回実行を待たずに起動時から IDE 統合サーバーを立ち上げる
  event = "VeryLazy",
  opts = {
    terminal = {
      provider = "none",
    },
  },
  keys = {
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", desc = "現在のバッファを Claude Code に追加" },
    { "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "選択範囲を Claude Code に送る" },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "diff を適用" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "diff を却下" },
  },
}
