return {
  "windwp/nvim-autopairs",
  cond = not vim.g.vscode,
  event = "InsertEnter",
  opts = {
    -- autolist が markdown で <CR> を使うため、競合しないよう <CR> のマップを無効化する
    map_cr = false,
  },
}
