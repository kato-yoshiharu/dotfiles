return {
  "vuki656/review.nvim",
  cond = not vim.g.vscode,
  cmd = "Review",
  keys = {
    { "<leader>rv", "<cmd>Review<CR>", desc = "レビュー UI を開閉" },
    { "<leader>rs", "<cmd>Review send<CR>", desc = "コメントを agent pane へ送信" },
    { "<leader>rc", "<cmd>Review qc<CR>", desc = "現在行にクイックコメント" },
    -- <cmd> だと範囲が渡らないため、: で '<,'> を自動入力させる
    { "<leader>rc", ":Review qc<CR>", mode = "x", desc = "選択範囲にクイックコメント" },
    { "<leader>rp", "<cmd>Review qp<CR>", desc = "クイックコメントのパネルを開閉" },
  },
  opts = {},
}
