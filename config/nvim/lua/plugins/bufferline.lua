-- ピン留めしたバッファは、一度目の操作では、確認してピン留めを外すだけにする。
-- 閉じるのはピン留めを外したあとの二度目の操作。
-- Snacks.bufdelete() はピン留めを考慮しないので、ここで止める。
local function close_buffer(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local groups = require("bufferline.groups")
  if groups._is_pinned({ id = buf }) then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    if vim.fn.confirm(name .. " のピン留めを外しますか？", "&Yes\n&No", 2) == 1 then
      groups.remove_element("pinned", { id = buf })
      require("bufferline.ui").refresh()
    end
    return
  end
  Snacks.bufdelete(buf)
end

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
        close_buffer()
      end,
      desc = "バッファを閉じる",
    },
    { "<leader>X", "<cmd>BufferLineCloseOthers<cr>", desc = "他のバッファを閉じる" },
    -- ピン留めしたバッファは BufferLineCloseOthers などの一括クローズ対象から外れる。
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "バッファのピン留めを切り替える" },
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
      -- キーマップと同じく close_buffer() に揃える。
      close_command = close_buffer,
      right_mouse_command = close_buffer,
    },
    highlights = {
      background = { italic = false },
      buffer_visible = { italic = false },
      buffer_selected = { italic = false },
    },
  },
}
