local opt = vim.opt

-- 検索時に大文字小文字を区別しない
opt.ignorecase = true
-- ただし検索語に大文字が含まれる場合は区別する
opt.smartcase = true
-- ヤンク・削除を OS のクリップボードと共有する
opt.clipboard = "unnamed"

if not vim.g.vscode then
  -- 行番号を表示する
  opt.number = true
  -- 行番号をカーソル行からの相対値で表示する
  opt.relativenumber = true
  -- サイン欄を常に表示して本文の横ずれを防ぐ
  -- git の差分の帯と LSP 診断のマークを並べるので、2 列分確保する
  opt.signcolumn = "yes:2"
  -- カーソル行をハイライトする
  opt.cursorline = true
  -- :vsplit で新しいウィンドウを右に開く
  opt.splitright = true
  -- :split で新しいウィンドウを下に開く
  opt.splitbelow = true
  -- カーソルの上下に最低 5 行の余白を残してスクロールする
  opt.scrolloff = 5
  -- Tab キーでタブ文字ではなくスペースを挿入する
  opt.expandtab = true
  -- 自動インデント 1 段分の幅
  opt.shiftwidth = 2
  -- タブ文字の表示幅
  opt.tabstop = 2
  -- undo 履歴をファイルに保存して、再起動後も元に戻せるようにする
  opt.undofile = true
end
