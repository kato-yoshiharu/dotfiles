-- magit 風の git 操作画面（ステータス表示とコミット・rebase などの操作をまとめて行う）
return {
  "NeogitOrg/neogit",
  cond = not vim.g.vscode,
  cmd = { "Neogit" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- 差分の表示は diffview に任せる
    "sindrets/diffview.nvim",
  },
  keys = {
    {
      "<leader>gs",
      function()
        local neogit = require("neogit")
        -- status バッファが表示中なら閉じる
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NeogitStatus" then
            neogit.close()
            return
          end
        end
        neogit.open()
      end,
      desc = "neogit の status を開閉",
    },
    {
      "<leader>gC",
      function()
        require("neogit").open({ "commit" })
      end,
      desc = "neogit のコミットメニュー",
    },
  },
  opts = {
    -- ステータスは専用タブで開き、元のウィンドウ配置を壊さない
    kind = "tab",
    graph_style = "unicode",
    integrations = {
      diffview = true,
      snacks = true,
    },
  },
  config = function(_, opts)
    require("neogit").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NeogitStatus",
      callback = function(ev)
        -- status には fuzzy 絞り込みがないので、行の picker で代替する
        vim.keymap.set("n", "<leader>/", function()
          Snacks.picker.lines()
        end, { buffer = ev.buf, desc = "status の行を fuzzy 検索" })
      end,
    })
  end,
}
