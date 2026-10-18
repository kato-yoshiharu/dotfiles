-- テスト用の最小の runtimepath を組む。
-- plenary.nvim は lazy のインストール先を使う。
vim.opt.runtimepath:append(vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim"))
vim.opt.runtimepath:append(vim.fn.getcwd() .. "/config/nvim")
