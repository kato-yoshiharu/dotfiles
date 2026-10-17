# CLAUDE.md（nvim 設定）

## プラグインの無効化

プラグインを使わなくなったときのルール:

- スペックのファイル（`lua/plugins/*.lua`）は削除しない
- `enabled = false` を足して無効にするだけにする
- `lazy-lock.json` のエントリも消さない
