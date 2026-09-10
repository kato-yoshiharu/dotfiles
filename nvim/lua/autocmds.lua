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
    local ok, err = pcall(require, name)
    if ok then
      vim.notify("reloaded: " .. name)
    else
      vim.notify(err, vim.log.levels.ERROR)
    end
  end,
})
