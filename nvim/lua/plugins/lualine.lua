-- ステータスライン本体。ファイル名は git の状態（untracked/ignored/unmerged も含む）で色を変える。

-- Dracula 公式パレット（VSCode テーマ dracula/visual-studio-code の src/dracula.yml と同じ値）
local dracula = {
  comment = "#6272a4",
  cyan = "#8be9fd",
  green = "#50fa7b",
  orange = "#ffb86c",
  red = "#ff5555",
}

-- VSCode の gitDecoration.* に合わせる。
-- Dracula が定義しているのは modified / deleted / untracked / ignored / conflicting の 5 つだけなので、
-- 残り（added, renamed, copied, type changed）は意味の近いものに寄せる。
local git_colors = {
  ["?"] = dracula.green,   -- untracked
  ["!"] = dracula.comment, -- ignored
  ["U"] = dracula.orange,  -- unmerged（コンフリクト中）= conflicting
  ["A"] = dracula.green,   -- added（Dracula 未定義。untracked に合わせる）
  ["D"] = dracula.red,     -- deleted
  ["M"] = dracula.cyan,    -- modified
  ["R"] = dracula.cyan,    -- renamed（Dracula 未定義。VSCode は copied と同じキー）
  ["C"] = dracula.cyan,    -- copied（同上）
  ["T"] = dracula.cyan,    -- type changed（VSCode に対応キーなし。modified に合わせる）
}

-- git の呼び出しは非同期なので、結果はバッファ変数に貯めて描画時はそれを読む
local function update(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
    return
  end
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" or vim.fn.filereadable(file) ~= 1 then
    return
  end

  vim.system(
    { "git", "status", "--porcelain", "--ignored", "--", file },
    { text = true, cwd = vim.fs.dirname(file) },
    function(result)
      -- git 管理下でなければ色を付けない
      local color = nil
      if result.code == 0 then
        local line = vim.split(result.stdout, "\n")[1] or ""
        if line ~= "" then
          local index, worktree = line:sub(1, 1), line:sub(2, 2)
          -- 作業ツリー側を優先し、無ければインデックス側の状態で色を決める
          color = git_colors[worktree] or git_colors[index]
        end
      end

      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].statusline_git_color ~= color then
          vim.b[buf].statusline_git_color = color
          vim.cmd("redrawstatus!")
        end
      end)
    end
  )
end

return {
  "nvim-lualine/lualine.nvim",
  cond = not vim.g.vscode,
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local group = vim.api.nvim_create_augroup("lualine_git_filename", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
      group = group,
      callback = function(ev)
        update(ev.buf)
      end,
    })

    require("lualine").setup({
      options = {
        theme = "dracula",
      },
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1, -- cwd からの相対パス
            color = function()
              local color = vim.b[vim.api.nvim_get_current_buf()].statusline_git_color
              return color and { fg = color } or nil
            end,
          },
        },
      },
    })

    update(vim.api.nvim_get_current_buf())
  end,
}
