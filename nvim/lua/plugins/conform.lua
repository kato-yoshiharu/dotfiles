-- フォーマッタ（保存時に自動整形する）

return {
  "stevearc/conform.nvim",
  cond = not vim.g.vscode,
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      markdown = { "rumdl" },
    },
    format_on_save = {
      timeout_ms = 2000,
      lsp_format = "fallback",
    },
  },
}
