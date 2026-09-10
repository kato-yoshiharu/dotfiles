return {
  "Mofiqul/dracula.nvim",
  cond = not vim.g.vscode,
  -- lazy = false のプラグイン間で先に読み込む
  priority = 1000,
  -- 他のプラグインの描画前に色を確定させるため遅延読み込みしない
  lazy = false,
  config = function()
    local function diff_hl()
      local set = vim.api.nvim_set_hl
      set(0, "DiffAdd", { bg = "#2f4f38" })
      set(0, "DiffDelete", { bg = "#5a2e3a", fg = "#6272a4" })
      set(0, "DiffChange", { bg = "#2d3b5c" })
      set(0, "DiffText", { bg = "#3f5a8a" })
      set(0, "DiffTextAdd", { bg = "#3f7d55" })

      set(0, "diffAdded", { bg = "#2f4f38", fg = "#50fa7b" })
      set(0, "diffRemoved", { bg = "#5a2e3a" })
      set(0, "diffChanged", { bg = "#2d3b5c", fg = "#ffb86c" })
    end

    -- colorscheme を読み直したときに上書きが巻き戻らないようにする
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "dracula",
      callback = diff_hl,
    })

    vim.cmd("colorscheme dracula")
  end,
}
