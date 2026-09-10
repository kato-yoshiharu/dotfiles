-- 起動画面（dashboard）とピッカー（picker）

-- 各階層でディレクトリを先、ファイルを後にしてパスを比較する。
-- 絞り込みを入力しているときは、あいまい検索のスコア順を優先する。
local function sort_dirs_first(a, b)
  if a.score ~= b.score then
    return a.score > b.score
  end
  local ap = vim.split(a.file or "", "/", { plain = true })
  local bp = vim.split(b.file or "", "/", { plain = true })
  for i = 1, math.min(#ap, #bp) do
    -- その階層でディレクトリ（まだ下に続く）か、ファイル（最後の要素）か
    local a_is_dir, b_is_dir = i < #ap, i < #bp
    if a_is_dir ~= b_is_dir then
      return a_is_dir
    end
    if ap[i] ~= bp[i] then
      return ap[i] < bp[i]
    end
  end
  return #ap < #bp
end

-- ダッシュボードでは snacks 既定の中央レイアウトに任せ、それ以外は右上に出す
local function layout_override()
  if vim.bo.filetype == "snacks_dashboard" then
    return
  end
  -- row = 1 が上端、col = -1 が右端
  local layout = vim.deepcopy(require("snacks.picker.config.layouts").default.layout)
  layout.row = 1
  layout.col = -1
  layout.min_width = nil
  layout.width = 0.25
  -- 最大値にする0を指定すると下端が見切れるので。
  layout.height = 0.9
  layout.backdrop = false
  return { layout = layout }
end

return {
  "folke/snacks.nvim",
  cond = not vim.g.vscode,
  -- lazy = false のプラグイン間で先に読み込む（描画前に色を確定させる）
  priority = 1000,
  -- 起動画面なので遅延読み込みしない
  lazy = false,
  keys = {
    -- oil は <leader>e / -。こちらはドロワー型のツリーとして使い分ける
    {
      "<leader>E",
      function()
        -- Snacks.explorer() は開く専用なので、開いていれば閉じる
        local explorer = Snacks.picker.get({ source = "explorer" })[1]
        if explorer then
          explorer:close()
        else
          Snacks.explorer({ layout = layout_override() })
        end
      end,
      desc = "ファイラ（snacks）の開閉",
    },
    -- ピッカー
    {
      "<leader>ff",
      function()
        Snacks.picker.files({ layout = layout_override() })
      end,
      desc = "ファイルを検索",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep({ layout = layout_override() })
      end,
      desc = "文字列を検索",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers({ layout = layout_override() })
      end,
      desc = "バッファを検索",
    },
    {
      "<leader>fh",
      function()
        Snacks.picker.help({ layout = layout_override() })
      end,
      desc = "ヘルプを検索",
    },
    {
      "<leader>fp",
      function()
        Snacks.picker.projects({ layout = layout_override() })
      end,
      desc = "プロジェクトを検索（cwd ごと切り替える）",
    },
    {
      "<leader>gc",
      function()
        Snacks.picker.git_log({ layout = layout_override() })
      end,
      desc = "git のコミット履歴",
    },
  },
  opts = {
    picker = {
      enabled = true,
      -- 絞り込みが空のときも並べ替える（既定では走査順のまま）
      matcher = { sort_empty = true },
      sources = {
        -- ファイル一覧を走査順ではなく、ディレクトリ優先のパス順で並べる
        files = { sort = sort_dirs_first },
      },
    },
    dashboard = {
      enabled = true,
      -- キーを指定していない項目に a, b, c... と自動で割り当てる
      autokeys = "abcdefghijklmnopqrstuvwxyz",
      preset = {
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "ファイルを検索",
            action = function()
              Snacks.picker.files()
            end,
          },
          {
            icon = " ",
            key = "g",
            desc = "文字列を検索",
            action = function()
              Snacks.picker.grep()
            end,
          },
          { icon = " ", key = "e", desc = "ファイラを開く", action = "<cmd>Oil<CR>" },
          { icon = " ", key = "n", desc = "新規ファイル", action = "<cmd>ene | startinsert<CR>" },
          { icon = " ", key = "q", desc = "終了", action = "<cmd>qa<CR>" },
        },
      },
      sections = {
        { section = "header" },
        { icon = " ", title = "最近のファイル", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "プロジェクト", section = "projects", indent = 2, padding = 1 },
        { icon = " ", title = "キーマップ", section = "keys", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
  },
}
