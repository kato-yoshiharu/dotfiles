-- 今のタブに、このファイルの描画ウィンドウがあれば閉じ、なければ縦分割で開く。
-- md-render は描画バッファに「<元のファイル名> [render]」という名前を付けるため、
-- その名前で対応するウィンドウを探す。
local function toggle_split()
  -- 描画ウィンドウの中で押したときは、そのウィンドウを閉じる。
  -- フローティングの描画ウィンドウでは何もしない。
  if vim.b.md_render then
    if vim.api.nvim_win_get_config(0).relative == "" then
      vim.api.nvim_win_close(0, false)
    end
    return
  end
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
    -- md-render は描画幅を既定で80桁に抑えるため、縦分割で2等分された幅(区切り線の1桁を除く)を渡す。
    -- 描画ウィンドウには行番号などの列がないため、元のウィンドウの textoff は引かない。
    local max_width = math.floor((vim.api.nvim_win_get_width(0) - 1) / 2)
    require("md-render").preview.split({ mods = { vertical = true }, max_width = max_width })
  end
end

-- フローティングウィンドウは画面幅の8割が上限なので、
-- そこから枠とインデントの分を引いた幅で描画する。
local function show_float()
  require("md-render").preview.show({ max_width = math.floor(vim.o.columns * 0.8) - 4 })
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
    { "<leader>mf", show_float, desc = "markdown をフローティングでレンダリング" },
    { "<leader>ms", toggle_split, desc = "markdown の縦分割レンダリングを開閉" },
  },
}
