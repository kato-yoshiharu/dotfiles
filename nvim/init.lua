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

-- プラグインは lua/plugins/*.lua に 1 ファイル 1 プラグインで置く
require("lazy").setup({ import = "plugins" }, {
  change_detection = { notify = false },
})
