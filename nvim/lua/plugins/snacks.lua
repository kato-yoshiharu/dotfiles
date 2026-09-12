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

-- コピー先に同名がある場合、VSCode 風に「〜 copy」「〜 copy 2」…と番号を振って衝突を避ける
local function unique_path(dir, name)
  local to = dir .. "/" .. name
  if not vim.uv.fs_stat(to) then
    return to
  end
  -- 先頭のドットは拡張子とみなさない（.env など）
  local stem, ext = name:match("^(.+)(%.[^.]+)$")
  stem, ext = stem or name, ext or ""
  local base = stem:gsub(" copy%s*%d*$", "")
  for i = 1, math.huge do
    local suffix = i == 1 and " copy" or (" copy " .. i)
    to = dir .. "/" .. base .. suffix .. ext
    if not vim.uv.fs_stat(to) then
      return to
    end
  end
end

-- キーワードで検索できる自作コマンドパレット。
-- text にコマンド名と検索用キーワードをまとめて書き、fn に実行内容を持たせる。
local custom_commands = {
  {
    text = "Copy Relative Path of Active File",
    fn = function()
      local file = vim.api.nvim_buf_get_name(0)
      if file == "" then
        return Snacks.notify.warn("アクティブなファイルがない")
      end
      -- ":." は cwd からの相対パスに変換する modifier（lualine の path = 1 と同じ考え方）
      local relpath = vim.fn.fnamemodify(file, ":.")
      vim.fn.setreg("+", relpath)
      Snacks.notify.info("コピーした: " .. relpath)
    end,
  },
  {
    text = "Copy Current Branch",
    fn = function()
      local cwd = vim.fn.getcwd()
      vim.system({ "git", "branch", "--show-current" }, { text = true, cwd = cwd }, function(result)
        vim.schedule(function()
          local branch = vim.trim(result.stdout or "")
          if result.code ~= 0 or branch == "" then
            return Snacks.notify.warn("ブランチ名を取得できない")
          end
          vim.fn.setreg("+", branch)
          Snacks.notify.info("コピーした: " .. branch)
        end)
      end)
    end,
  },
}

-- 自作コマンドと Ex コマンドをまとめた1つのピッカーとして開く
local function open_command_palette()
  local items = vim.deepcopy(custom_commands)
  -- snacks 標準の "commands" ソースと同じ手順で Ex コマンド一覧を集める
  require("snacks.picker.source.vim").commands()(function(item)
    items[#items + 1] = item
  end)

  Snacks.picker.pick({
    source = "custom_commands",
    items = items,
    format = function(item)
      return { { item.text } }
    end,
    confirm = function(picker, item)
      picker:close()
      if item.fn then
        item.fn()
      elseif item.cmd then
        -- snacks 標準の "cmd" アクションと同じく、コマンドラインに入力した状態にする
        vim.schedule(function()
          vim.api.nvim_input(":")
          vim.schedule(function()
            vim.fn.setcmdline(item.cmd)
          end)
        end)
      end
    end,
  })
end

local function explorer_paste(picker)
  local reg = vim.v.register ~= "" and vim.v.register or "+"
  local files = vim.split(vim.fn.getreg(reg) or "", "\n", { plain = true })
  files = vim.tbl_filter(function(file)
    return file ~= "" and vim.uv.fs_stat(file) ~= nil
  end, files)
  if #files == 0 then
    return Snacks.notify.warn(("`%s` レジスタにファイルがない"):format(reg))
  end

  local dir = picker:dir()
  for _, from in ipairs(files) do
    local name = vim.fn.fnamemodify(from:gsub("/$", ""), ":t")
    Snacks.picker.util.copy_path(from, unique_path(dir, name))
  end

  local Tree = require("snacks.explorer.tree")
  Tree:refresh(dir)
  Tree:open(dir)
  require("snacks.explorer.actions").update(picker, { target = dir })
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
      open_command_palette,
      desc = "コマンドパレット（Ex コマンド + 自作コマンド）",
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
        explorer = {
          layout = { layout = { position = "right" } },
          hidden = true,
          ignored = true,
          -- .git は VSCode 同様に隠す（hidden = true で他のドットファイルは見せたいので、ここだけ個別に除外する）
          exclude = { ".git" },
          actions = { explorer_paste = explorer_paste },
          -- esc で誤って閉じてしまわないようにする（閉じるのは <leader>e に任せる）
          win = {
            input = { keys = { ["<esc>"] = { "", mode = "n" } } },
            list = { keys = { ["<esc>"] = { "", mode = "n" } } },
          },
        },
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
