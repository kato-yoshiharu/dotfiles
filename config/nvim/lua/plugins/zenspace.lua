return {
  "thinca/vim-zenspace",
  cond = not vim.g.vscode,
  lazy = false,
  init = function()
    -- 全角スペースを常に表示する（'list' の設定に関わらず）
    vim.g["zenspace#default_mode"] = "on"
  end,
  config = function()
    -- 全角スペースは文字を持たないため bg で塗って可視化する
    local function apply_highlight()
      local err = vim.api.nvim_get_hl(0, { name = "Error", link = false })
      vim.api.nvim_set_hl(0, "ZenSpace", { bg = err.fg })
    end

    apply_highlight()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("zenspace_highlight", { clear = true }),
      callback = apply_highlight,
    })
  end,
}
