-- LSP（サーバの導入は mason、設定の実体は nvim-lspconfig 同梱のデフォルト設定）
-- 対象言語は treesitter.lua の filetypes に合わせる

local servers = {
  "bashls", -- bash
  "cssls", -- css
  "dockerls", -- dockerfile
  "gopls", -- go
  "html", -- html
  "jsonls", -- json
  "lua_ls", -- lua
  "pyright", -- python
  "rust_analyzer", -- rust
  "taplo", -- toml
  "ts_ls", -- javascript, typescript
  "yamlls", -- yaml
}

return {
  {
    "williamboman/mason.nvim",
    cond = not vim.g.vscode,
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    cond = not vim.g.vscode,
    -- バッファを開いた時点でサーバを起動させたいので遅延読み込みしない
    lazy = false,
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = servers,
      automatic_enable = true,
    },
  },
}
