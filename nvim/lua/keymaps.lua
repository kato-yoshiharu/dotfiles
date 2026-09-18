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
end
