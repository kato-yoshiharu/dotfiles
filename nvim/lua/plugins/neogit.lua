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

    -- COMMIT_EDITMSG バッファを開くと誤って他の行を編集してしまう不安があるため、
    -- ブランチ名入力と同じ一行入力欄でメッセージを受け取ってコミットする
    local function commit_with_input()
      local a = require("neogit.lib.async")
      local git = require("neogit.lib.git")
      local input = require("neogit.lib.input")
      local notification = require("neogit.lib.notification")

      a.void(function()
        if not git.status.anything_staged() then
          notification.warn("No changes staged.")
          return
        end

        local msg = input.get_user_input("Commit message", { strip_spaces = true })
        if not msg or msg == "" then
          return
        end

        local result = git.cli.commit.message(msg).call({ await = true })
        if result:success() then
          notification.info("Committed")
          git.repo:dispatch_refresh()
        else
          notification.error(table.concat(result.stderr, "\n"))
        end
      end)()
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NeogitStatus",
      callback = function(ev)
        -- status には fuzzy 絞り込みがないので、行の picker で代替する
        vim.keymap.set("n", "<leader>/", function()
          Snacks.picker.lines()
        end, { buffer = ev.buf, desc = "status の行を fuzzy 検索" })
      end,
    })

    -- popup は種類を問わず filetype が "NeogitPopup" 共通なので、
    -- バッファ名(popup 名)で commit popup だけを判別して c を上書きする
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NeogitPopup",
      callback = function(ev)
        -- バッファ名は cwd を前置した絶対パスに解決されるため末尾一致で判定する
        if vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":t") ~= "NeogitCommitPopup" then
          return
        end

        -- neogit は FileType 設定後に自前のキーマップ(c など)を設定するため、
        -- それより後に上書きする必要があり vim.schedule で1ティック遅らせる
        vim.schedule(function()
          vim.keymap.set("n", "c", function()
            local winnr = vim.fn.bufwinnr(ev.buf)
            if winnr ~= -1 then
              vim.api.nvim_win_close(vim.fn.win_getid(winnr), true)
            end
            commit_with_input()
          end, { buffer = ev.buf, desc = "git commit(一行入力欄でメッセージ入力)" })
        end)
      end,
    })
  end,
}
