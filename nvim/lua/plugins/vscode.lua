-- VS Code の Neovim 拡張で動くときだけ、Git 操作を VS Code 側に委譲する
if not vim.g.vscode then
  return {}
end

local vscode = require("vscode")

vim.keymap.set({ "n", "v" }, "<leader>hs", function()
  vscode.call("git.stageSelectedRanges")
end, { desc = "選択行をステージ (VS Code)" })

vim.keymap.set({ "n", "v" }, "<leader>hr", function()
  vscode.call("git.revertSelectedRanges")
end, { desc = "選択行をリセット (VS Code)" })

return {}
