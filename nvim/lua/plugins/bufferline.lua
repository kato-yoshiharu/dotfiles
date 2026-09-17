-- 開いているバッファを画面上部にタブのように並べて表示する
return {
  "akinsho/bufferline.nvim",
  cond = not vim.g.vscode,
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>bn", "<cmd>BufferLineCycleNext<cr>", desc = "次のバッファに移動" },
    { "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", desc = "前のバッファに移動" },
    { "<leader>bd", "<cmd>bdelete<cr>", desc = "バッファを閉じる" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "他のバッファを全て閉じる" },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- 画面上部（tabline）は lualine のタブページ一覧に譲り、
    -- bufferline のバッファ一覧は winbar 側に表示する
    vim.o.winbar = "%!v:lua.nvim_bufferline()"
  end,
  opts = {
    options = {
      mode = "buffers",
      -- tabline はもう bufferline が使わないので、バッファ数に応じて showtabline を書き換えないようにする
      auto_toggle_bufferline = false,
      diagnostics = "nvim_lsp",
    },
    highlights = {
      background = { italic = false },
      buffer_visible = { italic = false },
      buffer_selected = { italic = false },
    },
  },
}
