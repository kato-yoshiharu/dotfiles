return {
  "dawsers/floaterm.nvim",
  cond = not vim.g.vscode,
  keys = {
    {
      "<leader>tt",
      function()
        -- floaterm.toggle() は1つもターミナルを作成していないと何もしないため、
        -- その場合は新規作成にフォールバックする
        local terminal = require("floaterm")
        local has_terminal = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == "terminal" then
            has_terminal = true
            break
          end
        end
        if has_terminal then
          terminal.toggle()
        else
          terminal.open()
        end
      end,
      mode = { "n", "t" },
      desc = "フローティングターミナルの開閉",
    },
    {
      "<leader>tl",
      function()
        require("floaterm").pick()
      end,
      mode = { "n", "t" },
      desc = "フローティングターミナルの一覧から選択",
    },
    {
      "<leader>tf",
      function()
        require("floaterm").open()
      end,
      mode = { "n", "t" },
      desc = "フローティングターミナルを新規作成",
    },
    {
      "<leader>tn",
      function()
        require("floaterm").next()
      end,
      mode = { "n", "t" },
      desc = "次のフローティングターミナル",
    },
    {
      "<leader>tp",
      function()
        require("floaterm").prev()
      end,
      mode = { "n", "t" },
      desc = "前のフローティングターミナル",
    },
  },
  config = function()
    require("floaterm").setup()
  end,
}
