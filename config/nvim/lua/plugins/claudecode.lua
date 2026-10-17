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
  config = function(_, opts)
    require("claudecode").setup(opts)

    -- claude code 側が /clear などで接続を張り直すと、ソケットが ECONNRESET で切れる。
    -- プラグインはこれを ERROR として通知するが、切断処理は正常に行われるので debug に落とす。
    -- 上流 issue: https://github.com/coder/claudecode.nvim/issues/316
    local logger = require("claudecode.logger")
    local original_error = logger.error
    logger.error = function(component, ...)
      for _, part in ipairs({ ... }) do
        if type(part) == "string" and part:find("ECONNRESET", 1, true) then
          return logger.debug(component, ...)
        end
      end
      return original_error(component, ...)
    end
  end,
  keys = {
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", desc = "現在のバッファを Claude Code に追加" },
    { "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "選択範囲を Claude Code に送る" },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "diff を適用" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "diff を却下" },
  },
}
