return {
  "mistweaverco/kulala.nvim",
  cond = not vim.g.vscode,
  ft = { "http", "rest" },
  opts = {
    global_keymaps = true,
  },
}
