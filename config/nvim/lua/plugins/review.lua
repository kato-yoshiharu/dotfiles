return {
  "vuki656/review.nvim",
  cond = not vim.g.vscode,
  cmd = "Review",
  keys = {
    { "<leader>rv", "<cmd>Review<CR>", desc = "レビュー UI を開閉" },
    {
      "<leader>rs",
      function()
        -- 空のまま送ると空の本文が貼り付けられるため、件数を確認してから送る。
        local review_count = #require("review.state").get_all_comments()
        local quick_count = #require("review.quick_comments.state").get_all_flat()
        if review_count == 0 and quick_count == 0 then
          vim.notify("送信するコメントがない", vim.log.levels.WARN)
          return
        end
        -- 送信済みのコメントを残すと、次の送信で重複するため消す。
        -- 公開 API の clear_comments は確認ダイアログが出るため、review.nvim の内部モジュールを直接呼んでいる。
        local function clear_review()
          local state = require("review.state")
          state.clear_all_comments()
          if state.state.is_open then
            if state.state.current_file then
              require("review.ui.diff_view").render()
            end
            local list = require("review.ui.layout").get_comment_list()
            if list and vim.api.nvim_win_is_valid(list.winid) then
              require("review.ui.comment_list").refresh()
            end
          end
          require("review.core.persistence").save({ force_empty = true })
        end
        local function send_quick()
          if quick_count > 0 then
            require("review").quick_send(nil, { clear = true })
          end
        end
        if review_count == 0 then
          send_quick()
          return
        end
        -- herdr ではピッカーが非同期で開くため、2つ目はレビューの送信完了後に送る。
        local export = require("review.export.markdown")
        export.send_to_default(export.generate(), review_count, nil, false, function(ok)
          if ok then
            clear_review()
            send_quick()
          end
        end)
      end,
      desc = "レビューとクイックコメントを agent pane へ送信",
    },
    { "<leader>rc", "<cmd>Review qc<CR>", desc = "現在行にクイックコメント" },
    -- <cmd> だと範囲が渡らないため、: で '<,'> を自動入力させる
    { "<leader>rc", ":Review qc<CR>", mode = "x", desc = "選択範囲にクイックコメント" },
    { "<leader>rp", "<cmd>Review qp<CR>", desc = "クイックコメントのパネルを開閉" },
  },
  opts = {},
}
