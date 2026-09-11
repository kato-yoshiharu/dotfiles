return {
  "sindrets/diffview.nvim",
  cond = not vim.g.vscode,
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
  keys = {
    {
      "<leader>gd",
      function()
        -- diffview のタブが開いていれば閉じる
        if next(require("diffview.lib").views) then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "diffview の差分を開閉",
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "リポジトリの変更履歴" },
    { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "現在のファイルの変更履歴" },
  },
  opts = {
    file_panel = {
      win_config = { width = 40 },
    },
  },
}
