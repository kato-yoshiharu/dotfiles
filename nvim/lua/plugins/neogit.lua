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
        -- status バッファが今のタブで表示中なら閉じる。
        -- 別タブで開いている場合は neogit.open() を呼ぶと(kind="tab"のため)重複して新しいタブが作られ、
        -- self.buffer の参照先と実際に見ている画面がズレてキー入力が効かなくなるため、
        -- 単にそのタブへ移動するだけにする
        local current_tab = vim.api.nvim_get_current_tabpage()
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NeogitStatus" then
              if tab == current_tab then
                neogit.close()
              else
                vim.api.nvim_set_current_tabpage(tab)
                vim.api.nvim_set_current_win(win)
              end
              return
            end
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
    graph_style = "unicode",
    integrations = {
      diffview = true,
      snacks = true,
    },
    treesitter_diff_highlight = true,
    disable_line_numbers = false,
    disable_hint = true,
    mappings = {
      status = {
        ["]c"] = "GoToNextHunkHeader",
        ["[c"] = "GoToPreviousHunkHeader",
      },
    },
  },
  config = function(_, opts)
    require("neogit").setup(opts)

    -- status バッファが別タブで開いている状態からもう一度 status を開くと、
    -- neogit の Buffer:is_visible() がカレントタブしか見ないため既存インスタンスが再構築され、
    -- その過程で古いキーマップが self.buffer == nil のまま発火してクラッシュする
    -- (n_goto_file, n_down など発火するアクションはその時々で変わる)。
    -- アクション個別ではなく status.actions 全体に対して汎用的にガードをかける
    do
      local actions = require("neogit.buffers.status.actions")

      for name, action_fn in pairs(actions) do
        if type(action_fn) == "function" then
          actions[name] = function(self, ...)
            local fn = action_fn(self, ...)
            if type(fn) ~= "function" then
              return fn
            end

            return function(...)
              if not self.buffer then
                return
              end
              return fn(...)
            end
          end
        end
      end
    end

    -- COMMIT_EDITMSG バッファを開くと誤って他の行を編集してしまう不安があるため、
    -- ブランチ名入力と同じ一行入力欄でメッセージを受け取ってコミットする
    local function commit_with_input()
      local a = require("neogit.lib.async")
      local git = require("neogit.lib.git")
      local notification = require("neogit.lib.notification")

      a.void(function()
        if not git.status.anything_staged() then
          notification.warn("No changes staged.")
          return
        end

        -- neogit.lib.input 経由の vim.ui.input だとコミットメッセージの内容の境界をわかりやすくするための下線が引けないため、
        -- Snacks.input を直接呼んでいる(下線の色は dracula.lua の NeogitCommitInputUnderline を参照)
        local msg = a.wrap(function(opts, on_confirm)
          Snacks.input(opts, on_confirm)
        end, 2)({
          prompt = "Commit message",
          win = { width = 20 },
          highlight = function(text)
            return { { 0, #text, "NeogitCommitInputUnderline" } }
          end,
        })
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

    -- cherry-pick popup の範囲選択(commit select)ではなく、checkout と同じ
    -- ブランチ名の fuzzy 検索でブランチを選び、そのブランチにしかないコミットを
    -- --no-commit で取り込む(git cherry-pick a..b --no-commit 相当)
    do
      local Builder = require("neogit.lib.popup.builder")
      local original_build = Builder.build

      local function apply_from_branch(popup)
        local git = require("neogit.lib.git")
        local notification = require("neogit.lib.notification")
        local FuzzyFinderBuffer = require("neogit.buffers.fuzzy_finder")

        local branch = FuzzyFinderBuffer.new(git.refs.list_branches())
            :open_async({ prompt_prefix = "Apply from branch" })
        if not branch then
          return
        end

        -- git log HEAD..branch 相当(パッチ内容の重複判定はせず、単純なレンジで取得)
        local commits =
            git.cli["rev-list"].args("--reverse", ("HEAD..%s"):format(branch)).call({ hidden = true }).stdout

        if #commits == 0 then
          notification.warn("No commits to apply")
          return
        end

        git.cherry_pick.apply(commits, popup:get_arguments())
        notification.info(("Applied %d commit(s) from %q"):format(#commits, branch))
      end

      function Builder:build()
        -- cherry-pick 中断中は "Apply" action が無いので、そちらには追加しない
        if self.state.name == "NeogitCherryPickPopup" and self.state.keys["a"] then
          self:action("b", "Apply from branch (--no-commit)", apply_from_branch)
        end

        return original_build(self)
      end
    end

    -- stage/unstageするとファイルがセクションをまたいで移動し、neogitはカーソル位置を
    -- 復元できず先頭行に戻してしまう。押す前の行番号を覚えておき、再描画後に同じ行へ戻す
    local last_status_line
    vim.api.nvim_create_autocmd("User", {
      pattern = "NeogitStatusRefreshed",
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "NeogitStatus" then
            local line = math.min(last_status_line or 1, vim.api.nvim_buf_line_count(buf))
            vim.api.nvim_win_set_cursor(win, { line, 0 })
          end
        end
      end,
    })

    -- branch popup の delete(D) は fuzzy finder で Tab により複数マークしても先頭の1つしか
    -- 削除しないため、マークしたブランチをすべて受け取り、ローカルは git branch -d、
    -- リモート(origin/xxx)は git push origin --delete xxx で1つずつ削除する
    do
      local branch_actions = require("neogit.popups.branch.actions")

      function branch_actions.delete_branch(popup)
        local git = require("neogit.lib.git")
        local input = require("neogit.lib.input")
        local notification = require("neogit.lib.notification")
        local event = require("neogit.lib.event")
        local util = require("neogit.lib.util")
        local FuzzyFinderBuffer = require("neogit.buffers.fuzzy_finder")

        local options = util.deduplicate(util.merge({ popup.state.env.ref_name }, git.refs.list_branches()))
        local selected = FuzzyFinderBuffer.new(options)
            :open_async({ prompt_prefix = "Delete branch", refocus_status = false, allow_multi = true })
        if not selected or #selected == 0 then
          return
        end

        local message = #selected == 1 and ("Delete branch '%s'?"):format(selected[1])
            or ("Delete %d branches? (%s)"):format(#selected, table.concat(selected, ", "))
        if not input.get_permission(message) then
          return
        end

        local current = git.branch.current()
        for _, name in ipairs(selected) do
          local remote, branch_name = git.branch.parse_remote_branch(name)
          if remote and remote ~= "." and branch_name then
            local result = git.cli.push.remote(remote).delete.to(branch_name).call({ await = true })
            if result:success() then
              notification.info(("Deleted remote branch '%s/%s'"):format(remote, branch_name))
              event.send("BranchDelete", { branch_name = branch_name })
            else
              notification.error(("Failed to delete '%s/%s'\n%s"):format(
                remote, branch_name, table.concat(result.stderr, "\n")))
            end
          elseif branch_name == current then
            -- チェックアウト中のブランチは消せないのでスキップする
            notification.warn(("Skipped '%s': currently checked out"):format(branch_name))
          elseif branch_name then
            -- 未マージのコミットがあれば、強制削除してよいか git.branch.delete が確認する
            if git.branch.delete(branch_name) then
              notification.info(("Deleted branch '%s'"):format(branch_name))
              event.send("BranchDelete", { branch_name = branch_name })
            else
              notification.error(("Failed to delete branch '%s'"):format(branch_name))
            end
          end
        end
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NeogitStatus",
      callback = function(ev)
        -- status には fuzzy 絞り込みがないので、行の picker で代替する
        vim.keymap.set("n", "<leader>/", function()
          Snacks.picker.lines()
        end, { buffer = ev.buf, desc = "status の行を fuzzy 検索" })

        -- gitsigns（通常のバッファ）と同じキーで押せるように、neogit標準の s / x に委譲する。
        -- discard は確認ダイアログを伴う非同期処理なので、"x"フラグ(即時実行)だと
        -- ダイアログの応答待ちとかみ合わないことがあるため、次のtickに回す
        vim.keymap.set("v", "<leader>hs", function()
          vim.schedule(function()
            vim.fn.feedkeys("s", "m")
          end)
        end, { buffer = ev.buf, desc = "選択行をステージ" })

        vim.keymap.set("v", "<leader>hr", function()
          vim.schedule(function()
            vim.fn.feedkeys("x", "m")
          end)
        end, { buffer = ev.buf, desc = "選択行をリセット(discard)" })

        -- visual選択でのstage/unstageは選択範囲がまとめて消えるため、カーソル行ではなく
        -- 選択範囲の一番上の行を覚えておく(そこに後続の項目が繰り上がってくる)
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = ev.buf,
          callback = function()
            local mode = vim.fn.mode()
            if mode == "v" or mode == "V" or mode == "\22" then
              last_status_line = math.min(vim.fn.line("."), vim.fn.line("v"))
            else
              last_status_line = vim.api.nvim_win_get_cursor(0)[1]
            end
          end,
        })

        -- 画面幅を超える行を折り返す
        -- FileType 発火時点ではまだウィンドウに表示されていないことがあるため一tick遅らせる
        vim.schedule(function()
          for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
            vim.wo[win].wrap = true
          end
        end)
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
