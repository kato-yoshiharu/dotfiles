# NeoVimのdiff系ハイライトをVSCode Draculaに合わせる

## 背景

dracula.nvimのデフォルトのdiff系ハイライトは、`DiffAdd`が緑のべた塗り背景である一方、`DiffChange`/`DiffDelete`
/`DiffText`は背景色の指定が無く文字色(fg)のみだった。
つまり変更・削除行は背景による強調が一切なく、文字色の違いだけで示されていたため見づらく、逆に`DiffAdd`は緑一色でべた塗りされ、
周囲のコードから浮いて見える強すぎる表示だった。
一方、VSCode版Dracula拡張の実際のdiffエディタは、半透明のgreen/redによる薄い背景色で行全体を強調している。
そのため、VSCode版Dracula拡張の配色に合わせる。

`nvim/lua/plugins/dracula.lua`内の値は一旦すべて仮の白（`#ffffff`）にしてあり、
ここからComputer Use（Codex）でVSCode実機とNeoVimを並べて見比べながら、1色ずつ実際の値を決めていく。

## 実装メモ（2026-09-24更新）

`apply_diff_winhl()`を導入したことで、2ウィンドウ以上のdiff表示では`winhighlight`により
`DiffAdd`/`DiffChange`/`DiffText`/`DiffTextAdd`/`DiffDelete`が常にside別グループ
（`DiffAddRemoved`/`DiffAddAdded`/`DiffAddChanged`など、削除側は`DiffFiller`）へリダイレクトされるようになった。
そのためベース5グループの`set(0, ...)`定義は削除済み。今後はside別グループを基準に確認・調整する。

## TODO

Computer UseでVSCode実機のdiffEditorを開き、NeoVim側と見比べながら進める。

- 追加側（Added）の背景色
  - [x] `DiffAddAdded` bg（`#2c3f2c`、VSCode実機スクリーンショット参考）
  - [x] `DiffChangeAdded` bg（同上）
  - [x] `DiffTextAdded` bg（`#3e6b45`）
- 削除側（Removed）の背景色
  - [x] `DiffAddRemoved` bg（`#4b2632`、VSCode実機スクリーンショット参考）
  - [x] `DiffChangeRemoved` bg（同上）
  - [x] `DiffTextRemoved` bg（`#6b323d`）
- 変更側（Changed）の背景色（3wayコンフリクト時のみ表示。実機のオレンジ色を未確認、要検証）
  - [ ] `DiffAddChanged` bg
  - [ ] `DiffChangeChanged` bg
  - [ ] `DiffTextChanged` bg
- [x] `DiffFiller`（side問わず全ウィンドウ共通のfiller行。`bg = none`で確定）

`diffAdded`/`diffRemoved`/`diffChanged`（`filetype=diff`用）は使う場面が無いと判断し削除済みのため対象外。
