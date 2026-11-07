vim.g.mapleader = " "

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("options")
require("keymaps")
require("autocmds")
require("commands")

-- NVIM_PLUGIN_EXCLUDE にリポジトリ（zbirenbaum/copilot.lua など）をカンマ区切りで指定すると、
-- そのプラグインを無効にする。
-- LSP サーバだけを除外するときは NVIM_MASON_EXCLUDE を使う。
local spec = { { import = "plugins" } }
for name in (vim.env.NVIM_PLUGIN_EXCLUDE or ""):gmatch("[^,%s]+") do
  table.insert(spec, { name, enabled = false })
end

-- プラグインは lua/plugins/*.lua に 1 ファイル 1 プラグインで置く
require("lazy").setup(spec, {
  change_detection = { notify = false },
})
