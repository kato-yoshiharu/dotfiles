-- 外部プロセス（Claude Code など）がファイルを書き換えたとき、
-- フォーカス移動を待たずに反映させる
local checktime_group = vim.api.nvim_create_augroup("Checktime", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = checktime_group,
  callback = function()
    -- コマンドライン入力中に呼ぶとプロンプトが崩れるので避ける
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- 起動直後の空の [No Name] バッファは、ファイルを開いたあとに不要になるので閉じる。
local close_empty_group = vim.api.nvim_create_augroup("CloseEmptyBuffer", { clear = true })

local function is_empty_unnamed_buffer(buf)
  -- 名前がない
  return vim.api.nvim_buf_get_name(buf) == ""
      -- terminal・help・quickfix などではない
      and vim.bo[buf].buftype == ""
      -- 中身が空(1行だけで、その行が空文字)
      and vim.api.nvim_buf_line_count(buf) == 1
      and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
end

-- そのウィンドウが、タブに残っている唯一の通常ウィンドウかどうか。
-- picker などのフローティングウィンドウは数えない。
local function is_only_window_in_tab(win)
  local normal_wins = vim.tbl_filter(function(w)
    return vim.api.nvim_win_get_config(w).relative == ""
  end, vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(win)))
  return #normal_wins == 1
end

local function close_empty_buffer(buf, current_tab)
  -- neogit の kind = "tab" のようにタブを増やす操作で残った、空バッファだけのタブを閉じる。
  -- 現在のタブと、最後の1タブは閉じない。
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    local tab = vim.api.nvim_win_get_tabpage(win)
    if tab ~= current_tab and #vim.api.nvim_list_tabpages() > 1 and is_only_window_in_tab(win) then
      pcall(vim.cmd, "tabclose " .. vim.api.nvim_tabpage_get_number(tab))
    end
  end

  -- 分割ウィンドウなどでまだ表示されているバッファは残す
  if #vim.fn.win_findbuf(buf) == 0 then
    pcall(vim.api.nvim_buf_delete, buf, {})
  end
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = close_empty_group,
  callback = function(args)
    -- ファイルを開いたときだけ対象にする（help・terminal などでは閉じない）
    if vim.bo[args.buf].buftype ~= "" or vim.api.nvim_buf_get_name(args.buf) == "" then
      return
    end

    local current_tab = vim.api.nvim_get_current_tabpage()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      -- 今開いたバッファ自身は消さない
      if buf ~= args.buf and is_empty_unnamed_buffer(buf) then
        close_empty_buffer(buf, current_tab)
      end
    end
  end,
})

local group = vim.api.nvim_create_augroup("ReloadConfig", { clear = true })

-- lua/ 配下は dotfiles へのシンボリックリンクなので、
-- ~/.config/nvim/lua と dotfiles 側の実体パス、どちらで開いても同じ扱いにする
local lua_root = vim.uv.fs_realpath(vim.fn.stdpath("config") .. "/lua")

-- lua/ 配下の *.lua を保存したら、モジュールキャッシュを捨てて読み直す
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.lua",
  callback = function(args)
    if not lua_root then
      return
    end

    local path = vim.uv.fs_realpath(args.file)
    if not path or not vim.startswith(path, lua_root .. "/") then
      return
    end

    -- lua_root からの相対パスをモジュール名にする: plugins/lsp.lua -> plugins.lsp
    local name = path:sub(#lua_root + 2):gsub("%.lua$", ""):gsub("/", ".")

    package.loaded[name] = nil
    local ok, mod = pcall(require, name)
    if not ok then
      vim.notify(mod, vim.log.levels.ERROR)
      return
    end

    -- plugins/ 配下は lazy.nvim へ渡すスペックを return するだけで、
    -- require し直しても opts は再適用されない。素直に再起動を促す
    if vim.startswith(name, "plugins.") then
      vim.notify(name .. ": 反映には再起動が必要", vim.log.levels.WARN)
      return
    end

    vim.notify("reloaded: " .. name)
  end,
})
