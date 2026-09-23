return {
  "Mofiqul/dracula.nvim",
  cond = not vim.g.vscode,
  -- lazy = false のプラグイン間で先に読み込む
  priority = 1000,
  -- 他のプラグインの描画前に色を確定させるため遅延読み込みしない
  lazy = false,
  config = function()
    require("dracula").setup({
      -- wezterm の背景透過・ぼかしを透かして見せる
      transparent_bg = true,
    })

    local diff_colors = {
      add_bg = "#305444",
      add_text_bg = "#377950",
      delete_bg = "#53333c",
      delete_text_bg = "#7a3a42",
      change_bg = "#383e55",
      change_text_bg = "#454e6d",
      -- visual選択時。Visual(#3E4452)と各side色を混ぜた色
      add_visual_bg = "#374c4b",
      delete_visual_bg = "#493c47",
      change_visual_bg = "#3b4154",
    }

    -- 透過背景でも見やすい明るいグレー
    local comment_bright = "#a4b1cd"

    -- dracula.nvim 標準の背景色（transparent_bg = true でも diffview は不透明にしたいため）
    local normal_bg = "#282a36"

    -- 開いているdiffウィンドウを画面上の位置（左から右）で判定し、
    -- Removed/Added/Changedの役割を割り当ててside別のハイライトを適用する
    local function apply_diff_winhl()
      local diff_wins = vim.tbl_filter(function(win)
        return vim.api.nvim_win_is_valid(win) and vim.wo[win].diff
      end, vim.api.nvim_list_wins())

      if #diff_wins < 2 then
        return
      end

      table.sort(diff_wins, function(left, right)
        local left_pos = vim.api.nvim_win_get_position(left)
        local right_pos = vim.api.nvim_win_get_position(right)

        if left_pos[2] == right_pos[2] then
          return left_pos[1] < right_pos[1]
        end

        return left_pos[2] < right_pos[2]
      end)

      for index, win in ipairs(diff_wins) do
        local side = index == 1 and "Removed" or index == #diff_wins and "Added" or "Changed"

        vim.wo[win].winhighlight = table.concat({
          "Normal:DiffviewNormal",
          "DiffAdd:DiffAdd" .. side,
          "DiffChange:DiffChange" .. side,
          "DiffDelete:DiffFiller",
          "DiffText:DiffText" .. side,
          "DiffTextAdd:DiffText" .. side,
          "Visual:Visual" .. side,
        }, ",")
      end
    end

    local function override_hl()
      local set = vim.api.nvim_set_hl

      set(0, "DiffAddRemoved", { bg = diff_colors.delete_bg })
      set(0, "DiffChangeRemoved", { bg = diff_colors.delete_bg })
      set(0, "DiffTextRemoved", { bg = diff_colors.delete_text_bg })

      set(0, "DiffAddAdded", { bg = diff_colors.add_bg })
      set(0, "DiffChangeAdded", { bg = diff_colors.add_bg })
      set(0, "DiffTextAdded", { bg = diff_colors.add_text_bg })

      set(0, "DiffAddChanged", { bg = diff_colors.change_bg })
      set(0, "DiffChangeChanged", { bg = diff_colors.change_bg })
      set(0, "DiffTextChanged", { bg = diff_colors.change_text_bg })

      set(0, "DiffFiller", { bg = "none" })

      -- diffview/vimdiffのウィンドウはtransparent_bgの対象外にして不透明にする
      set(0, "DiffviewNormal", { bg = normal_bg })

      -- diffウィンドウ内だけ、visual選択でside色が消えないようside別のbgに差し替える
      set(0, "VisualRemoved", { bg = diff_colors.delete_visual_bg })
      set(0, "VisualAdded", { bg = diff_colors.add_visual_bg })
      set(0, "VisualChanged", { bg = diff_colors.change_visual_bg })

      -- デフォルトの Comment は暗すぎて透過背景で見にくいため明るいグレーにする
      set(0, "Comment", { fg = comment_bright, italic = true })

      -- snacks.nvim のフローティングウィンドウ（explorer/picker 等）を透過させる
      set(0, "NormalFloat", { bg = "none" })
      set(0, "SnacksNormal", { bg = "none" })
      set(0, "SnacksNormalNC", { bg = "none" })
      set(0, "SnacksWinBar", { bg = "none" })
      set(0, "SnacksWinBarNC", { bg = "none" })

      -- neogit のコミットメッセージ入力欄で、入力済み文字列の下に引く下線の色（nvim/lua/plugins/neogit.lua から参照）
      set(0, "NeogitCommitInputUnderline", { underline = true, sp = "#bd93f9" })

      -- インデントガイドの縦線・不可視文字（space/tab）を明るくする
      set(0, "SnacksIndent", { fg = "#6272a4" })
      set(0, "Whitespace", { fg = "#6272a4" })

      -- インデントガイドを階層ごとに色分け（レインボー表示、dracula 標準パレット）
      set(0, "SnacksIndent1", { fg = "#bd93f9" })
      set(0, "SnacksIndent2", { fg = "#50fa7b" })
      set(0, "SnacksIndent3", { fg = "#ffb86c" })
      set(0, "SnacksIndent4", { fg = "#ff79c6" })
      set(0, "SnacksIndent5", { fg = "#8be9fd" })
      set(0, "SnacksIndent6", { fg = "#f1fa8c" })
      set(0, "SnacksIndent7", { fg = "#ff5555" })
    end

    -- colorscheme を読み直したときに上書きが巻き戻らないようにする
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "dracula",
      callback = override_hl,
    })

    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "WinNew", "WinClosed", "WinResized" }, {
      pattern = "*",
      callback = function()
        vim.schedule(apply_diff_winhl)
      end,
    })

    -- 'diff' オプションのオン/オフのみを監視する(pattern はオプション名にマッチする)
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "diff",
      callback = function()
        vim.schedule(apply_diff_winhl)
      end,
    })

    vim.cmd("colorscheme dracula")
  end,
}
