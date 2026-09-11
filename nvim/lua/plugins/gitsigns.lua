-- 通常のバッファで、行番号の左に git の差分を棒で出し、hunk 単位のステージを行う。
return {
  "lewis6991/gitsigns.nvim",
  cond = not vim.g.vscode,
  -- バッファを開いた時点で差分を出したいので、ファイルを読む前に用意する
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- サイン欄の 2 列は、優先度の高いものから左に詰められる。
    -- 既定の 6 では LSP 診断（10 以上）に左を取られ、診断のある行だけ棒が
    -- 2 列目にずれて縦線が折れるので、診断より高くして常に左端に置く
    sign_priority = 100,
    on_attach = function(buf)
      local gs = require("gitsigns")

      -- ノーマルはカーソル位置の hunk 全体、ビジュアルは選択行だけが対象になる
      vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { buffer = buf, desc = "hunk をステージ" })
      vim.keymap.set("v", "<leader>hs", function()
        -- line(".") がカーソル行、line("v") が選択の開始行
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { buffer = buf, desc = "選択行をステージ" })

      vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { buffer = buf, desc = "hunk をリセット" })
      vim.keymap.set("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { buffer = buf, desc = "選択行をリセット" })
    end,
  },
}
