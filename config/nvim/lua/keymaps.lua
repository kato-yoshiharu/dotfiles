local map = vim.keymap.set

-- 表示行単位で移動する
map({ "n", "v" }, "j", "gj")
map({ "n", "v" }, "k", "gk")

-- 検索を very nomagic で始める
map({ "n", "v" }, "/", "/\\V")
map({ "n", "v" }, "?", "?\\V")

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "検索ハイライトを消す" })

-- 日本語の句点（。！？.!?）も文区切りとして扱う文単位移動
do
  -- 句点が連続する場合（「!?」など）や直後の空白・改行もまとめて読み飛ばす
  local sentence_end_pat = [[[。！？.!?]\+[ \t\n]*\zs]]

  local function move_sentence(forward)
    local flags = forward and "W" or "bW"
    vim.fn.search(sentence_end_pat, flags)
  end

  map({ "n", "v", "o" }, ")", function()
    move_sentence(true)
  end, { desc = "次の文末（。！？.!?）へ移動" })

  map({ "n", "v", "o" }, "(", function()
    move_sentence(false)
  end, { desc = "前の文末（。！？.!?）へ移動" })
end

-- VSCode の Neovim 拡張ではウィンドウ分割を Neovim 側が管理しないので、素の Neovim のときだけ有効にする
if not vim.g.vscode then
  -- ウィンドウ移動
  map("n", "<C-h>", "<C-w>h")
  map("n", "<C-j>", "<C-w>j")
  map("n", "<C-k>", "<C-w>k")
  map("n", "<C-l>", "<C-w>l")

  -- insert モードの <C-r>{reg} は、レジスタによって挙動が違う。
  -- " や - などはキー入力扱いで、autoindent が各行に上乗せされ、インデントが累積する。
  -- a-z、0-9、+ などは文字どおり入るが、現在行のインデントにそろわない。
  -- どちらの場合も、テキストとしてカーソル位置に挿入し、現在行のインデントにそろえる。
  map("i", "<C-r>", function()
    local reg = vim.fn.getcharstr()
    -- 次のキーが a-z、0-9、"、-、+ などのレジスタ名でなければ（<C-r><C-r>、<C-r>=、<Esc> など）、
    -- <C-r> とそのキーを打ち直して、元の <C-r> に処理させる。
    -- "n" はこのマッピング自体が再び呼ばれないようにするため。
    -- "i" は打ち直すキーを、溜まっているキーの後ろではなく前に入れるため。
    -- マクロ再生中は残りのキーがすでに溜まっているので、後ろに入れると順序が入れ替わって壊れる。
    if not reg:match("^[%w\"%-*+/.:%%#]$") then
      vim.api.nvim_feedkeys(vim.keycode("<C-r>") .. reg, "ni", false)
      return
    end
    local regtype = vim.fn.getregtype(reg)
    local lines = vim.fn.getreg(reg, 1, true)
    -- ブロック単位のレジスタは、インデントをいじらず矩形のまま貼る。
    if regtype:sub(1, 1) == "\22" then
      vim.api.nvim_put(lines, "b", false, true)
      return
    end
    -- 文字単位のレジスタは、行の途中からも行頭からも yank されうるので、1 行目のインデントは当てにならない。
    -- そのため 1 行目は共通インデントの計算から外し、複数行なら先頭の空白を落としてカーソル位置に合わせる。
    local first = regtype == "v" and 2 or 1
    if first == 2 and #lines > 1 then
      lines[1] = lines[1]:gsub("^%s+", "")
    end

    -- 貼る内容の共通インデントを外し、相対的な字下げだけ残す。
    local common
    for i = first, #lines do
      if lines[i]:match("%S") then
        local indent = lines[i]:match("^%s*")
        if not common or #indent < #common then
          common = indent
        end
      end
    end
    common = common or ""

    -- 現在行のインデントを 2 行目以降に足して、今の階層の下にそろえる。
    -- 空白だけの行は空行にする。
    local base = vim.api.nvim_get_current_line():match("^%s*")
    for i = first, #lines do
      local line = lines[i]:sub(#common + 1)
      if not line:match("%S") then
        lines[i] = ""
      elseif i == 1 then
        lines[i] = line
      else
        lines[i] = base .. line
      end
    end
    -- 行単位のレジスタも、下の行ではなくカーソル位置に入れる。
    vim.api.nvim_put(lines, "c", false, true)
  end, { desc = "レジスタを現在行のインデントにそろえてカーソル位置に挿入" })
end
