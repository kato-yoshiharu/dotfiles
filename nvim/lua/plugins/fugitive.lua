return {
  "tpope/vim-fugitive",
  -- git 操作は neogit、差分は diffview に一本化した。戻すときはこの行を消す
  enabled = false,
  cond = not vim.g.vscode,
  keys = {
    {
      "<leader>gs",
      function()
        -- status バッファが表示中なら閉じる
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "fugitive" then
            vim.api.nvim_win_close(win, false)
            return
          end
        end
        -- 右に縦分割で出す
        vim.cmd("vertical botright Git")
        vim.api.nvim_win_set_width(0, 40)
      end,
      desc = "fugitive の status を開閉",
    },
    -- index 側が編集可能な左右分割
    {
      "<leader>gv",
      function()
        -- diff 相手の blob が開いていれば閉じる
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.wo[win].diff and vim.b[buf].fugitive_type == "blob" then
            -- blob は読み取り専用なので未保存はありえず、force で確実に閉じる
            vim.api.nvim_win_close(win, true)
            -- blob を閉じても作業ツリー側は diff モードのまま残るので、タブ全体で解除する
            vim.cmd("diffoff!")
            return
          end
        end
        vim.cmd("Gvdiffsplit")
      end,
      desc = "index との差分を左右分割で開閉",
    },
  },
  config = function()
    -- blob（index / HEAD 側）は fugitive の自動リロード対象外なので、自前で読み直す。
    -- blob の中身は fugitive の BufReadCmd が作るので nested が要る。
    -- ただし nested を付けると :edit が BufEnter を呼び戻して自分自身に再帰するため、フラグで再入を止める
    local refreshing = false
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
      group = vim.api.nvim_create_augroup("fugitive_diff_refresh", { clear = true }),
      nested = true,
      callback = function()
        if refreshing then
          return
        end

        -- BufEnter は頻繁に発火するので、diff ビューを開いていなければ何もしない
        local blob_wins = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          -- 作業ツリー側は下の checktime が拾うので blob だけを対象にする
          if vim.b[vim.api.nvim_win_get_buf(win)].fugitive_type == "blob" then
            table.insert(blob_wins, win)
          end
        end
        if #blob_wins == 0 then
          return
        end

        refreshing = true
        local ok, err = pcall(function()
          -- 作業ツリー側は autoread が拾うが、検出は checktime が走ったときだけ。
          -- 自動では走らないので、blob と同じタイミングで明示的に呼ぶ
          vim.cmd("checktime")

          for _, win in ipairs(blob_wins) do
            vim.api.nvim_win_call(win, function()
              vim.cmd("edit")
            end)
          end
          vim.cmd("diffupdate")
        end)
        refreshing = false
        if not ok then
          vim.notify(tostring(err), vim.log.levels.ERROR)
        end
      end,
    })

    -- blob を編集可能にしておくと do / dp が意図しないステージになるので読み取り専用にする
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
      group = vim.api.nvim_create_augroup("fugitive_blob_readonly", { clear = true }),
      callback = function(ev)
        if vim.b[ev.buf].fugitive_type == "blob" then
          vim.bo[ev.buf].modifiable = false
          vim.bo[ev.buf].readonly = true
        end
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fugitive",
      callback = function(ev)
        -- status には fuzzy 絞り込みがないので、行の picker で代替する
        vim.keymap.set("n", "<leader>/", function()
          Snacks.picker.lines()
        end, { buffer = ev.buf, desc = "status の行を fuzzy 検索" })

        -- 中身は fugitive の s と同じ。通常のバッファ（gitsigns）と同じキーで押せるようにする
        vim.keymap.set({ "n", "v" }, "<leader>hs", function()
          vim.fn.feedkeys("s", "mx")
        end, { buffer = ev.buf, desc = "選択行をステージ" })

        -- 選択行（ノーマルモードはカーソル位置）を fugitive の s でステージして git cn
        vim.keymap.set({ "n", "v" }, "<leader>cn", function()
          local git_cn = require("git_cn")
          local cwd = vim.fn.getcwd()
          if not git_cn.index_is_clean(cwd) then
            return
          end
          -- ステージは fugitive 側のキーマップ（s）に任せる。m でそのマッピングを展開する
          vim.fn.feedkeys("s", "mx")
          git_cn.commit(cwd)
        end, { buffer = ev.buf, desc = "選択行をステージして git cn" })
      end,
    })
  end,
}
