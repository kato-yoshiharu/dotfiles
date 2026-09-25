return {
  "zbirenbaum/copilot.lua",
  cond = not vim.g.vscode,
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      -- 自動トリガーを切って手動リクエストにする（候補は <M-]>/<M-[> でリクエスト）
      auto_trigger = false,
      -- true だと候補非表示時も Tab を横取りしてしまい、autolist などの Tab と競合するため無効化する
      trigger_on_accept = false,
      keymap = {
        accept = "<Tab>",
      },
    },
    filetypes = {
      markdown = true,
    },
  },
}
