return {
  "iamcco/markdown-preview.nvim",
  cond = not vim.g.vscode,
  ft = { "markdown" },
  cmd = { "MarkdownPreviewToggle" },
  -- mkdp#util#install() は遅延ロード中だと autoload が読めず失敗することがあるため、
  -- npm で直接ビルドする。
  build = "cd app && npm install && git restore yarn.lock && rm -f package-lock.json",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "markdown プレビューを開閉" },
  },
}
