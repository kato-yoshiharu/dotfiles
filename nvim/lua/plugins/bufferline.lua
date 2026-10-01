-- 開いているバッファを画面上部にタブのように並べて表示する
return {
  "akinsho/bufferline.nvim",
  cond = not vim.g.vscode,
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<C-Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "次のバッファに移動" },
    { "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "前のバッファに移動" },
    -- :bdelete だとウィンドウの分割まで消えるので、Snacks.bufdelete() を使う。
    {
      "<leader>x",
      function()
        Snacks.bufdelete()
      end,
      desc = "バッファを閉じる",
    },
    { "<leader>X", "<cmd>BufferLineCloseOthers<cr>", desc = "他のバッファを閉じる" },
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
      -- 既定の bdelete! だとマウスで閉じたときも分割が消えるので、
      -- キーマップと同じく Snacks.bufdelete() に揃える。
      close_command = function(n)
        Snacks.bufdelete(n)
      end,
      right_mouse_command = function(n)
        Snacks.bufdelete(n)
      end,
    },
    highlights = {
      background = { italic = false },
      buffer_visible = { italic = false },
      buffer_selected = { italic = false },
    },
  },
}
