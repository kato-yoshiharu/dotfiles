-- ファイラ（ディレクトリを普通のバッファとして編集する）
return {
  "stevearc/oil.nvim",
  -- ファイラは snacks.explorer に一本化した。戻すときはこの行を消す
  enabled = false,
  cond = not vim.g.vscode,
  cmd = { "Oil" },
  dependencies = {
    "DaikyXendo/nvim-material-icon",
    -- oil のバッファに git の状態を表示する
    "refractalize/oil-git-status.nvim",
  },
  keys = {
    {
      "<leader>e",
      function()
        -- oil のバッファなら元のバッファへ戻す
        if vim.bo.filetype == "oil" then
          require("oil").close()
        else
          require("oil").open()
        end
      end,
      desc = "ファイラ（oil）の開閉",
    },
    { "-", "<cmd>Oil<CR>", desc = "ファイラ（oil）を開く" },
    {
      "<C-n>",
      function()
        require("oil").toggle_float()
      end,
      desc = "ファイラ（oil）をフロートで開閉",
    },
  },
  init = function()
    -- nvim にディレクトリや oil:// を渡して起動したときは、その場で oil を読み込む。
    local path = vim.fn.expand("%:p")
    local is_dir = vim.fn.isdirectory(path) == 1
    local is_oil_path = vim.iter({ "oil://", "oil-ssh://", "oil-trash://" }):any(function(prefix)
      return string.find(path, prefix, 1, true) ~= nil
    end)
    if is_dir or is_oil_path then
      require("oil")
    end

    -- oil でのリネームを LSP に伝える
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilActionsPost",
      callback = function(event)
        if event.data.actions.type == "move" then
          Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
        end
      end,
    })
  end,
  opts = {
    -- 削除はゴミ箱に送る
    delete_to_trash = true,
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return vim.tbl_contains({ ".DS_Store" }, name)
      end,
    },
    win_options = {
      -- oil-git-status の表示幅を確保する
      signcolumn = "yes:2",
    },
  },
  config = function(_, opts)
    require("oil").setup(opts)
    require("oil-git-status").setup()
  end,
}
