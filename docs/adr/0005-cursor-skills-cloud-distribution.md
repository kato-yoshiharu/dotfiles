# Cursor のスキルを、Cloud Agent の install script で配る

公式プラグイン（pstack、thermos など）をクラウドで使うときは、Cursor の個人の環境設定の `install` で、プラグインのスキルとサブエージェントを VM の `~/.cursor/` にコピーする。
ローカルは Nix の `~/.cursor/plugins/local` で入れる。
運用の手順は `docs/cursor-plugins.md` に書く。

## Considered Options 検討した選択肢

2026-10-29 時点で、Cursor にローカルのファイルをクラウドへ自動で同期する公式の手段はない。

### Sync Skills for Cloud Agents

`~/.cursor/skills/` をクラウドに同期する設定。
同期するのは実ディレクトリだけで、Nix が置く symlink は読み飛ばされる（Cursor 側の回答）。
Automation も同期したスキルを読まない。
このため採用しない。

### 各リポジトリの .cursor/skills にコミットする

最も確実だが、リポジトリごとにコピーが増える。
Automation に使わせるスキルだけ、この手段を使う。

### マーケットプレイスでプラグインとして入れる

Team Marketplace の Required は Teams または Enterprise のプランが前提になる。
個人の導入も含め、pstack がクラウドで読み込まれないという報告があり、Cursor のスタッフは既知の問題として追跡している。
このため採用しない。

### 個人の環境設定の install で VM にコピーする

プラグインではなく、スキルとサブエージェントとして直接置く。
各リポジトリにコミットせずに済む。
VM が取るのは、dotfiles（public）の `flake.lock` だけで、認証は要らない。
版は `flake.lock` が固定する `cursor/plugins` のリビジョンにそろえられる。
これを採用する。

gitignore 済みの `_repo/cursor-cloud/` に置き、環境の `install` にスクリプトの中身を埋め込む。
dotfiles にコミットしない理由は2つある。

- コミットしてよいか、内容を確認する手間がかかる
- Cursor が、公式プラグインを個人の Cloud Agent に配る機能を提供し、スクリプトが不要になる可能性がある

## Consequences 決定に伴う影響

- 既存の自作スキルは Claude Code、Codex、個人の環境に依存し、VM では動かないため、配らない
- スクリプトは dotfiles に入らないため、別のマシンでは再作成が要る
- 配るプラグインの一覧は `config/cursor/plugins.txt` の 1 か所で、ローカルとクラウドで共通である。
- 環境は登録したリポジトリでだけ使われる
- リポジトリに `.cursor/environment.json` があると、個人の設定は使われない
- `install` の実行と、スキルとサブエージェントの読み込みは、フォーラムの回答だけが根拠で、実機では未確認である。
  thermos は 2 つのサブエージェントに依存するため、`~/.cursor/agents` が読まれないと動作が欠ける
- symlink を同期できるようになったら、Sync Skills を再検討する
