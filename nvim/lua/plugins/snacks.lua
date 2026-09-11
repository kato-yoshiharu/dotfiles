-- snacks

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

return {
  "folke/snacks.nvim",
  cond = not vim.g.vscode,
  -- lazy = false のプラグイン間で先に読み込む（描画前に色を確定させる）
  priority = 1000,
  -- 起動直後に explorer を出すので遅延読み込みしない
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- ファイルやディレクトリを指定して起動したときは、そのバッファを邪魔しない
        if vim.fn.argc() > 0 then
          return
        end
        Snacks.explorer()
      end,
    })
  end,
  keys = {
    {
      "<leader>e",
      function()
        -- Snacks.explorer() は開く専用なので、開いていれば閉じる
        local explorer = Snacks.picker.get({ source = "explorer" })[1]
        if explorer then
          explorer:close()
        else
          Snacks.explorer()
        end
      end,
      desc = "ファイラ（snacks）の開閉",
    },
    -- ピッカー
    {
      "<leader>ff",
      function()
        Snacks.picker.smart()
      end,
      desc = "バッファ・最近開いたファイル・全ファイルをまとめて検索",
    },
    {
      "<leader>fF",
      function()
        Snacks.picker.files()
      end,
      desc = "ファイルを検索（ディレクトリ優先のパス順）",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep()
      end,
      desc = "文字列を検索",
    },
    {
      "<leader>fp",
      function()
        Snacks.picker.projects()
      end,
      desc = "プロジェクトを検索（cwd ごと切り替える）",
    },
    {
      "<leader>p",
      function()
        Snacks.picker.commands()
      end,
      desc = "コマンドパレット",
    },
    {
      "<leader>gc",
      function()
        Snacks.picker.git_log()
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
        files = { sort = sort_dirs_first, hidden = true, ignored = true },
        -- ファイラはデフォルトで左に出るので右に寄せる
        explorer = { layout = { layout = { position = "right" } }, hidden = true, ignored = true },
      },
    },
    dashboard = {
      enabled = false,
      autokeys = "1234567890",
      preset = {
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "ファイルを検索",
            action = function()
              Snacks.picker.smart()
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
          {
            icon = " ",
            key = "e",
            desc = "ファイラを開く",
            action = function()
              Snacks.explorer()
            end,
          },
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
