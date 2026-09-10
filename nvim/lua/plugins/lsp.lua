-- LSP（サーバの導入は mason、設定の実体は nvim-lspconfig の lsp/ ディレクトリ）

return {
  {
    "williamboman/mason.nvim",
    cond = not vim.g.vscode,
    cmd = "Mason",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    cond = not vim.g.vscode,
    -- バッファを開いた時点でサーバを起動させたいので遅延読み込みしない
    lazy = false,
    -- TODO: config
  },
}
