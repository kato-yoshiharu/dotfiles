-- lint（LSP診断とは別に、外部lintツールの結果をdiagnosticsに流し込む）

return {
  {
    -- markdownlint-cli2 などの実行ファイルを mason 経由で入れる
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cond = not vim.g.vscode,
    enabled = false,
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "markdownlint-cli2" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    cond = not vim.g.vscode,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      linters_by_ft = {
        markdown = { "rumdl" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters.cspell.severity = vim.diagnostic.severity.HINT
      -- nvim-lint 同梱の定義は stderr を読むが rumdl は stdout に出す（upstream バグ）
      lint.linters.rumdl.stream = "stdout"
      lint.linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function()
          -- ファイルタイプ別の linters_by_ft に加えて、cspell は全バッファで常に走らせる
          lint.try_lint()
          lint.try_lint("cspell")
        end,
      })
    end,
  },
}
