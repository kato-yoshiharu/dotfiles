return {
  "thinca/vim-zenspace",
  cond = not vim.g.vscode,
  lazy = false,
  init = function()
    -- 全角スペースを常に表示する（'list' の設定に関わらず）
    vim.g["zenspace#default_mode"] = "on"
  end,
  config = function()
    vim.api.nvim_set_hl(0, "ZenSpace", { link = "Error" })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("zenspace_highlight", { clear = true }),
      callback = function()
        vim.api.nvim_set_hl(0, "ZenSpace", { link = "Error" })
      end,
    })
  end,
}
