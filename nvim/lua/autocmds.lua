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

local function is_disposable_empty_buffer(buf)
  -- 名前がない
  return vim.api.nvim_buf_get_name(buf) == ""
      -- terminal・help・quickfix などではない
      and vim.bo[buf].buftype == ""
      -- 中身が空(1行だけで、その行が空文字)
      and vim.api.nvim_buf_line_count(buf) == 1
      and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
      -- どのタブのウィンドウにも表示されていない
      and #vim.fn.win_findbuf(buf) == 0
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = close_empty_group,
  callback = function(args)
    -- ファイルを開いたときだけ対象にする（help・terminal などでは閉じない）
    if vim.bo[args.buf].buftype ~= "" or vim.api.nvim_buf_get_name(args.buf) == "" then
      return
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      -- 今開いたバッファ自身は消さない
      if buf ~= args.buf and is_disposable_empty_buffer(buf) then
        -- 他の autocmd のエラーで残りの掃除が止まらないようにする
        pcall(vim.api.nvim_buf_delete, buf, {})
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
