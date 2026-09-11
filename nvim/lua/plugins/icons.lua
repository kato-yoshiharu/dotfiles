-- ファイルタイプ別アイコン（Material Design Icons）
-- snacks の explorer / picker が require("nvim-web-devicons") で参照する
return {
  "DaikyXendo/nvim-material-icon",
  cond = not vim.g.vscode,
  lazy = true,
}
