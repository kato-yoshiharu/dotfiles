-- 今のタブに、このファイルの描画ウィンドウがあれば閉じ、なければ縦分割で開く。
-- md-render は描画バッファに「<元のファイル名> [render]」という名前を付けるため、
-- その名前で対応するウィンドウを探す。
local function toggle_split()
  local render_name = vim.api.nvim_buf_get_name(0) .. " [render]"
  local found = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.b[buf].md_render and vim.api.nvim_buf_get_name(buf) == render_name then
      vim.api.nvim_win_close(win, false)
      found = true
    end
  end
  if not found then
    require("md-render").preview.split({ mods = { vertical = true } })
  end
end

return {
  "delphinus/md-render.nvim",
  cond = not vim.g.vscode,
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    -- 日本語を文節単位で折り返す。
    { "delphinus/budoux.lua", version = "*" },
  },
  cmd = { "MdRender" },
  keys = {
    { "<leader>mf", "<Plug>(md-render-preview)", ft = "markdown", desc = "markdown をフローティングでレンダリング" },
    { "<leader>ms", toggle_split, ft = "markdown", desc = "markdown の縦分割レンダリングを開閉" },
  },
}
