-- colorful-winsep

return {
  "nvim-zh/colorful-winsep.nvim",
  cond = not vim.g.vscode,
  event = "WinNew",
  config = function(_, opts)
    -- ウィンドウがちょうど 2 つのとき、プラグインは区切り線を半分の長さに縮めて
    -- 矢印記号を添える（indicator_for_2wins）。この「半分にする」処理は
    -- view.lua で position の設定を見ずに走るため、設定では無効化できない。
    -- 判定に使われる count_windows() を上書きして、常に全長で描かせる
    local utils = require("colorful-winsep.utils")
    local count_windows = utils.count_windows
    function utils.count_windows()
      local n = count_windows()
      return n == 2 and 3 or n
    end

    require("colorful-winsep").setup(opts)
  end,
  opts = {
    -- Dracula の purple に合わせる
    highlight = "#bd93f9",
    -- 枠が動くと目が散るので、アニメーションは切る
    animate = { enabled = false },
  },
}
