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
  "marksman", -- markdown（脚注の gd / grr に対応）
  "nil_ls", -- nix
  "pyright", -- python
  "rust_analyzer", -- rust
  "taplo", -- toml
  "ts_ls", -- javascript, typescript
  "yamlls", -- yaml
}

local excluded_servers = {}
local excluded_server_set = {}

for server in (vim.env.NVIM_MASON_EXCLUDE or ""):gmatch("[^,%s]+") do
  if not excluded_server_set[server] then
    table.insert(excluded_servers, server)
    excluded_server_set[server] = true
  end
end

servers = vim.tbl_filter(function(server)
  return not excluded_server_set[server]
end, servers)

local automatic_enable = true

if #excluded_servers > 0 then
  automatic_enable = { exclude = excluded_servers }
end

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
      automatic_enable = automatic_enable,
    },
  },
}
