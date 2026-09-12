-- ファイルパネルから右側（変更後）の差分ウィンドウへ移動する。
-- 素の <C-w>l だと左側（変更前）に入ってしまうため。
local function focus_diff_right()
  local view = require("diffview.lib").get_current_view()
  local layout = view and view.cur_layout
  if not layout then
    return
  end
  local win = layout:get_main_win()
  if win then
    win:focus()
  end
end

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
    keymaps = {
      file_panel = {
        { "n", "<C-l>", focus_diff_right, { desc = "右側の差分ウィンドウへ移動" } },
      },
      file_history_panel = {
        { "n", "<C-l>", focus_diff_right, { desc = "右側の差分ウィンドウへ移動" } },
      },
    },
    file_panel = {
      win_config = { width = 40 },
    },
    hooks = {
      -- 左側（symbol "a"）のバッファだけ常に編集不可にする。
      diff_buf_read = function(bufnr, ctx)
        if ctx.symbol == "a" then
          vim.bo[bufnr].modifiable = false
        end

        -- コミット/インデックス側は "diffview://<絶対パス>/<context>/<相対パス>" という
        -- 仮想バッファ名になり statusline にそのまま出すと読みにくいため、
        -- リポジトリからの相対パス部分だけを抜き出してバッファ変数に持たせておく
        local name = vim.api.nvim_buf_get_name(bufnr)
        local relpath = name:match("^diffview://.-/%x%x%x%x%x%x%x%x%x%x%x/(.+)$")
            or name:match("^diffview://.-/:%d:/(.+)$")
            or name:match("^diffview://.-/%[custom%]/(.+)$")
        if relpath then
          vim.b[bufnr].diffview_relpath = relpath
        end
      end,
    },
  },
}
