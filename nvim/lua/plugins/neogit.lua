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
        -- log view(status で la など)が開いていれば先に閉じる。
        -- 閉じるとウィンドウ・タブの一覧が変わるため、先に対象を集めてから閉じる
        local log_wins = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NeogitLogView" then
            table.insert(log_wins, win)
          end
        end
        local closed_log = #log_wins > 0
        for _, win in ipairs(log_wins) do
          if vim.api.nvim_win_is_valid(win) then
            local tab = vim.api.nvim_win_get_tabpage(win)
            -- タブ内で最後のウィンドウなら :close は失敗するため、タブごと閉じる
            if #vim.api.nvim_tabpage_list_wins(tab) == 1 then
              vim.cmd("tabclose " .. vim.api.nvim_tabpage_get_number(tab))
            else
              vim.api.nvim_win_close(win, true)
            end
          end
        end

        if closed_log then
          -- log を閉じたら status も一緒に閉じる
          neogit.close()
          return
        end

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
    graph_style = "ascii",
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

    -- neogit は list を off にするため、空白(listchars)が表示されない。
    -- 差分の本文だけ表示するには自前の描画が要るので、対応しない。

    -- log popup の色付け(c)は初期 off なので、初回のみ既定で on にする(手動 off 後は上書きしない)
    do
      local state = require("neogit.lib.state")
      if state.get({ "NeogitLogPopup", "color" }, nil) == nil then
        state.set({ "NeogitLogPopup", "color" }, true)
      end
    end

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
          -- git.repo:dispatch_refresh() は git の内部状態を更新するだけで、
          -- status バッファの再描画までは行わない(self:dispatch_refresh() を呼ぶ必要がある)ため、
          -- staged changes がコミット後も画面から消えないままになっていた
          require("neogit.buffers.status").instance():dispatch_refresh(nil, "commit_with_input")
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

    -- Staged changes セクションを常に一番上に表示したい。
    -- config には表示順を変える設定がないため、生成後のツリーの中から該当セクションを探して並び替える。
    do
      local status_ui = require("neogit.buffers.status.ui")
      local original_status = status_ui.Status

      local section_order = { staged = 1, untracked = 2, unstaged = 3 }

      status_ui.Status = function(state, config)
        local result = original_status(state, config)

        local list = result[1]
        if list and list.children then
          local entries = {}
          local min_idx
          for i, child in ipairs(list.children) do
            local section = child.options and child.options.section
            if section_order[section] then
              table.insert(entries, { idx = i, section = section, child = child })
              min_idx = min_idx and math.min(min_idx, i) or i
            end
          end

          if #entries > 1 then
            -- 並び替え後の順序を決める
            table.sort(entries, function(a, b)
              return section_order[a.section] < section_order[b.section]
            end)

            -- 元の位置を後ろから消してから、最小位置に並び替え後の順序で詰め直す
            local original_indices = {}
            for _, entry in ipairs(entries) do
              table.insert(original_indices, entry.idx)
            end
            table.sort(original_indices, function(a, b) return a > b end)
            for _, idx in ipairs(original_indices) do
              table.remove(list.children, idx)
            end

            for offset, entry in ipairs(entries) do
              table.insert(list.children, min_idx + offset - 1, entry.child)
            end
          end
        end

        return result
      end
    end

    -- neogitのWatcherは.gitディレクトリの変更をrecursiveオプション無しで監視しているため、
    -- refs/heads/<branch> や logs/HEAD のような1階層下のファイル変更(=git commit/pushなど、
    -- neogitを経由しない外部コマンドでの操作)を検知できず、statusバッファが再描画されない。
    -- recursive = true を渡して外部コマンドでの変更も拾えるようにする
    do
      local Watcher = require("neogit.watcher")
      local config = require("neogit.config")

      function Watcher:start()
        if not config.values.filewatcher.enabled then
          return self
        end

        if self.running then
          return self
        end

        self.running = true
        self.fs_event_handler:start(self.git_dir, { recursive = true }, self:fs_event_callback())
        return self
      end

      -- buffer:redraw() だとカーソル位置が保存・復元されず先頭行に飛ぶため、
      -- 保存・復元込みの dispatch_refresh() を使う(無ければ従来どおり redraw())
      function Watcher:dispatch_refresh()
        for _, buffer in pairs(self.buffers) do
          if buffer.dispatch_refresh then
            buffer:dispatch_refresh(nil, "watcher")
          else
            buffer:redraw()
          end
        end
      end
    end

    -- Staged changes 内の各ファイルの差分(hunk)を、status を開いたときに展開済みにする。
    -- neogit には差分の初期展開を変える設定がないため、
    -- 再描画のたびにツリーから staged のファイル項目を探して on_open(差分の遅延ロードと展開)を呼ぶ。
    -- staged のファイルが多いと、1ファイルの展開ごとに git diff --cached と --shortstat の2プロセスを直列に走らせ、
    -- 差分の読み込みごとに再描画も走るため、status 画面が固まる。
    -- そのため、staged のファイル数が上限を超えているときは自動展開しない(上限値は仮置き)
    do
      local MAX_AUTO_EXPAND_STAGED = 20
      local expanded_staged_ids = {}

      vim.api.nvim_create_autocmd("User", {
        pattern = "NeogitStatusRefreshed",
        callback = function()
          local status = require("neogit.buffers.status").instance()
          if not (status and status.buffer) then
            return
          end
          local ui = status.buffer.ui

          local staged_count = #require("neogit.lib.git").repo.state.staged.items
          if staged_count > MAX_AUTO_EXPAND_STAGED then
            return
          end

          local present = {}
          local function walk(node)
            local options = node.options or {}
            local id = options.id
            if type(id) == "string" and vim.startswith(id, "staged--") then
              present[id] = true
              if options.on_open and not expanded_staged_ids[id] then
                expanded_staged_ids[id] = true
                options.on_open(node, ui)
              end
            end
            for _, child in ipairs(node.children or {}) do
              walk(child)
            end
          end
          walk(ui.layout)

          for id in pairs(expanded_staged_ids) do
            if not present[id] then
              expanded_staged_ids[id] = nil
            end
          end
        end,
      })
    end

    -- neogit は各 hunk の位置(hunk.first / hunk.last)を、差分を読み込んだ時点の絶対行番号で一度だけ記録し、
    -- 再描画しても更新しない(ファイル項目の位置 item.first / item.last は再描画のたびに更新される)。
    -- そのため、上にある Staged changes の差分が後から展開されて行が増えると、
    -- その下にある展開済みファイルの hunk の位置が古いまま残り、
    -- visual 選択での stage(item_hunks)が選択とは別の行を patch にしてしまう。
    -- 再描画のたびに、描画後のファイル項目の位置から hunk の位置を数え直す
    -- (数え方は neogit の load_diff と同じ)
    do
      local Ui = require("neogit.lib.ui")
      local original_update = Ui.update

      local function sync_hunk_positions(node)
        local options = node.options or {}
        local item = options.item
        -- on_open が nil になっていれば、差分は読み込み済み(load_diff が nil にする)
        if item and item.diff and item.diff.hunks and options.on_open == nil and node.position then
          local row = node.position.row_start + 1
          for _, hunk in ipairs(item.diff.hunks) do
            hunk.first = row
            hunk.last = row + hunk.length
            row = hunk.last + 1
          end
        end
        for _, child in ipairs(node.children or {}) do
          sync_hunk_positions(child)
        end
      end

      function Ui:update(...)
        local result = original_update(self, ...)
        if self.layout then
          sync_hunk_positions(self.layout)
        end
        return result
      end
    end

    -- rename の差分への色付け
    require("neogit_rename_diff").setup()

    -- Untracked files のファイルのモード表示
    require("neogit_untracked_mode").setup()

    -- stage/unstageするとファイルがセクションをまたいで移動し、neogitはカーソル位置を
    -- 復元できず先頭行に戻してしまう。
    -- 単純に行番号を覚えておくと、Staged changesセクションが上に現れたとき(や差分が展開されたとき)に
    -- その行数分だけカーソルがずれる。
    -- そのため、押す前のカーソルが属するセクションと、その見出しからの相対行数を覚えておき、
    -- 再描画後は同じセクションの見出しを探して、そこからの相対位置へ戻す。
    -- セクションが消えた場合(最後の1件をstageしたときなど)は、行番号で戻す。
    -- セクションの名前と範囲は neogit が持っている(ui.item_index)ので、見出しの文言には頼らず、それを使う
    local function status_sections()
      local status = require("neogit.buffers.status").instance()
      if status and status.buffer then
        return status.buffer.ui.item_index
      end
      return {}
    end

    -- lnum が属するセクションの名前と、その見出し行を返す
    local function find_section_at(lnum)
      for _, section in ipairs(status_sections()) do
        if section.first and section.first <= lnum and lnum <= section.last then
          return section.name, section.first
        end
      end
    end

    local function find_section_header(name)
      for _, section in ipairs(status_sections()) do
        if section.first and section.name == name then
          return section.first
        end
      end
    end

    -- 再描画の前に覚えておく、カーソルの位置。
    -- CursorMoved で常時記録すると、neogit が再描画中に動かしたカーソル位置で上書きされてしまう。
    -- そのため、位置が動く操作(stage など)を実行する直前と、status から離れる瞬間(commit など)だけを記録する
    local last_status_cursor
    local SNAPSHOT_TTL_MS = 1500

    local function restore_status_cursor()
      if not last_status_cursor then
        return
      end
      -- time が nil の間は、status から離れていて期限切れにしない(戻ってきたときに時刻が入る)
      if last_status_cursor.time and vim.uv.now() - last_status_cursor.time > SNAPSHOT_TTL_MS then
        last_status_cursor = nil
        return
      end
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "NeogitStatus" then
          local count = vim.api.nvim_buf_line_count(buf)
          local line = last_status_cursor.line
          if last_status_cursor.section then
            local header_line = find_section_header(last_status_cursor.section)
            if header_line then
              line = header_line + last_status_cursor.offset
            end
            -- 末尾の項目をstageしたあとは相対位置がセクションの外(空行)にはみ出す。
            -- 空行でsを押すとセクション全体が対象になってしまうため、直前の項目まで戻す
            while line > 1 and line <= count and vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1] == "" do
              line = line - 1
            end
          end
          vim.api.nvim_win_set_cursor(win, { math.max(1, math.min(line, count)), 0 })
        end
      end
    end

    -- Staged changes の差分は非同期で展開されるため、再描画の直後に復元しても、
    -- その後に行が増えてカーソルが別の行に乗ってしまい、意図しない行をstageしてしまう。
    -- 差分の読み込みが終わるたびにも復元し直す
    vim.api.nvim_create_autocmd("User", {
      pattern = { "NeogitStatusRefreshed", "NeogitDiffLoaded" },
      callback = restore_status_cursor,
    })

    local function snapshot_status_cursor()
      local line
      local mode = vim.fn.mode()
      if mode == "v" or mode == "V" or mode == "\22" then
        -- visual選択でのstage/unstageは選択範囲がまとめて消えるため、
        -- 選択範囲の一番上の行を基準にする(そこに後続の項目が繰り上がってくる)
        line = math.min(vim.fn.line("."), vim.fn.line("v"))
      else
        line = vim.api.nvim_win_get_cursor(0)[1]
      end
      local section, header_line = find_section_at(line)
      last_status_cursor = {
        line = line,
        section = section,
        offset = header_line and (line - header_line) or 0,
        time = vim.uv.now(),
      }
    end

    -- commit のように、popup やエディタへ移ってから戻ってくる操作では、
    -- 押したキーの位置を記録できず、再描画で先頭行に戻ってしまう。
    -- そのため、status から離れる瞬間の位置も記録しておき、
    -- 戻ってきてから SNAPSHOT_TTL_MS の間に起きた再描画で復元する
    vim.api.nvim_create_autocmd("WinLeave", {
      callback = function()
        if vim.bo.filetype == "NeogitStatus" then
          snapshot_status_cursor()
          last_status_cursor.time = nil
        end
      end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if vim.bo.filetype == "NeogitStatus" and last_status_cursor and not last_status_cursor.time then
          last_status_cursor.time = vim.uv.now()
        end
      end,
    })

    -- status を閉じたあとも記録が残っていると、次に開いたときの最初の再描画で、閉じる前の位置へ寄せようとしてしまう。
    -- そのため、status のバッファが消えるときに記録を捨てる
    -- (status は kind="tab" で開くため、commit エディタなどへ移っても、バッファは消えない)
    vim.api.nvim_create_autocmd("BufWipeout", {
      callback = function(args)
        if vim.bo[args.buf].filetype == "NeogitStatus" then
          last_status_cursor = nil
        end
      end,
    })

    -- ファイルや差分が動いて、カーソルの位置がずれる action を、
    -- 実行する直前(押した瞬間)の位置を記録してから呼ぶ。
    do
      local actions = require("neogit.buffers.status.actions")
      local names = {
        -- ファイルが staged と unstaged の間を動く
        "n_stage",
        "v_stage",
        "n_unstage",
        "v_unstage",
        "n_stage_all",
        "n_stage_unstaged",
        "n_unstage_staged",
        -- 変更の内容を捨てる
        "n_discard",
        "v_discard",
        "n_reverse",
        "v_reverse",
        -- ファイルの扱いを変える
        "n_untrack",
        "v_untrack",
        "n_rename",
      }
      for _, name in ipairs(names) do
        local action_fn = actions[name]
        if action_fn then
          actions[name] = function(self, ...)
            local fn = action_fn(self, ...)
            if type(fn) ~= "function" then
              return fn
            end
            return function(...)
              snapshot_status_cursor()
              return fn(...)
            end
          end
        end
      end
    end

    -- push などの実行中に出るコンソール(NeogitConsole)では、<esc> がプロセスの停止(process:stop())に
    -- 割り当てられているため、画面を閉じるつもりで押すと push が中断されて "Failed to push to ..." になる。
    -- <esc> はプロセスを止めずにコンソールを隠すだけにする(中断したいときは <c-c> を使う)
    do
      local ProcessBuffer = require("neogit.buffers.process")
      local original_open = ProcessBuffer.open

      function ProcessBuffer:open()
        local result = original_open(self)
        if self.buffer then
          vim.keymap.set("n", "<esc>", function()
            self:hide()
          end, { buffer = self.buffer.handle, nowait = true, desc = "コンソールを隠す(プロセスは止めない)" })
        end
        return result
      end
    end

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

    -- <leader>hs が送る s だけ、エラーにせず neogit 標準のステージに渡すためのフラグ。
    -- 渡したら false に戻す。
    -- 素の s は、押し間違いを防ぐためエラーにする。
    local allow_visual_s = false
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
          allow_visual_s = true
          vim.schedule(function()
            vim.fn.feedkeys("s", "m")
          end)
        end, { buffer = ev.buf, desc = "選択行をステージ" })

        vim.keymap.set("v", "<leader>hr", function()
          vim.schedule(function()
            vim.fn.feedkeys("x", "m")
          end)
        end, { buffer = ev.buf, desc = "選択行をリセット(discard)" })

        -- neogit は FileType 設定後に自前のキーマップを設定するため、
        -- それより後に上書きする必要があり vim.schedule で1ティック遅らせる。
        -- <leader>hs 経由のときは、上書き前の neogit 標準の s に委譲する
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(ev.buf) then
            return
          end
          local original = vim.fn.maparg("s", "v", false, true)
          vim.keymap.set("v", "s", function()
            if allow_visual_s then
              allow_visual_s = false
              if original.callback then
                return original.callback()
              end
              return
            end
            vim.notify("行選択中の s は使えない。<leader>hs を使う", vim.log.levels.ERROR)
          end, { buffer = ev.buf, nowait = true, desc = "行選択中の s はエラー" })
        end)

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
            local popup = require("neogit.lib.popup").instance
            if popup then
              popup:close()
            end
            commit_with_input()
          end, { buffer = ev.buf, desc = "git commit(一行入力欄でメッセージ入力)" })
        end)
      end,
    })
  end,
}
