-- フォーマッタ（保存時に自動整形する）

return {
  "stevearc/conform.nvim",
  cond = not vim.g.vscode,
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      markdown = { "markdownlint-cli2" },
    },
    formatters = {
      ["markdownlint-cli2"] = {
        -- lint.lua の mason-tool-installer が入れたものを使う
        command = "markdownlint-cli2",
        args = { "--fix", "$FILENAME" },
        stdin = false,
      },
    },
    format_on_save = {
      timeout_ms = 2000,
      lsp_format = "fallback",
    },
  },
}
