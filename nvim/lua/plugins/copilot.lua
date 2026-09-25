return {
  "zbirenbaum/copilot.lua",
  cond = not vim.g.vscode,
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = "<Tab>",
      },
    },
    filetypes = {
      markdown = true,
    },
  },
}
