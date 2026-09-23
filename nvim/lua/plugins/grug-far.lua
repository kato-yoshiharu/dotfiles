-- 検索結果をバッファとして編集し、一括置換を適用する
return {
  "MagicDuck/grug-far.nvim",
  cond = not vim.g.vscode,
  cmd = { "GrugFar" },
  keys = {
    {
      "<leader>sr",
      "<cmd>GrugFar<CR>",
      desc = "検索・一括置換（grug-far）を開く",
    },
  },
  opts = {},
}
