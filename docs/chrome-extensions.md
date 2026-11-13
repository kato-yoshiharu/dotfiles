# Chrome 拡張機能の管理

## 拡張は extensions.txt に書いて External Extensions で入れる

`config/chrome/extensions.txt` に、1行に拡張 ID を書き、`#` 以降に名前を書く。
`nix/home.nix` が、ID ごとに `~/Library/Application Support/Google/Chrome/External Extensions/<ID>.json` を配置する。

MDM 管理外の Mac では `ExtensionInstallForcelist` が効かないため、この方式を使う。

## 追加と削除の手順

追加するとき:

1. `extensions.txt` に ID を足す
2. `make switch-home` を実行する
3. Chrome を再起動し、有効化の承認を出す

削除するときは、`extensions.txt` から消したうえで、`chrome://extensions` で手動で削除する。
