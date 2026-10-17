-- コミットグラフの表示
return {
  "isakbm/gitgraph.nvim",
  cond = not vim.g.vscode,
  dependencies = { "sindrets/diffview.nvim" },
  keys = {
    {
      "<leader>gg",
      function()
        -- 既存のウィンドウを差し替えると、neogit/diffview のレイアウト管理と衝突して
        -- 分割が増殖することがあるため、干渉しないよう専用タブで開閉する
        for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "gitgraph" then
              vim.api.nvim_set_current_tabpage(tabpage)
              vim.cmd("tabclose")
              return
            end
          end
        end
        vim.cmd("tabnew")
        require("gitgraph").draw({}, { all = true, max_count = 5000 })
      end,
      desc = "git のコミットグラフを開閉",
    },
  },
  opts = {
    hooks = {
      -- 選択したコミットを diffview で開く
      on_select_commit = function(commit)
        vim.cmd({ cmd = "DiffviewOpen", args = { commit.hash .. "^!" } })
      end,
      on_select_range_commit = function(from, to)
        -- 選択方向によって新旧が逆転することがあるため、時系列順に並べ替えてから range を組み立てる
        local older, newer = from, to
        if from.timestamp and to.timestamp and from.timestamp > to.timestamp then
          older, newer = to, from
        end
        vim.cmd({ cmd = "DiffviewOpen", args = { older.hash .. "~1.." .. newer.hash } })
      end,
    },
  },
}
