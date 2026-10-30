# Cursor の公式プラグインをローカルとクラウドに配る

選んだ理由と未確認の事項は [ADR 0005](adr/0005-cursor-skills-cloud-distribution.md) に書く。

## ローカルは Nix で配る

配るプラグインは、`config/cursor/plugins.txt` に書く。
ローカルの Nix とクラウドのスクリプトが、同じファイルを読む。
反映は `make switch`。

## クラウドは install script でコピーする

クラウド用のスクリプトは、dotfiles にコミットせず、gitignore 済みの `_repo/cursor-cloud/` に置く。
理由は ADR 0005 に書く。

スクリプトの役割:

- `cloud-install-plugins.sh`: dotfiles の main の `flake.lock` が固定した版に合わせて、`PLUGINS` で渡されたプラグインのスキルとサブエージェントを、VM の `~/.cursor/` にコピーする
- `env-sync.sh`: Cloud Agents API で、個人の環境を作成または更新する。
  環境の `install` に、`plugins.txt` から作った `PLUGINS` と `cloud-install-plugins.sh` の中身を埋め込む
- `env-repos.txt`: 環境に登録するリポジトリの一覧
- `plugin-versions.sh`: `flake.lock` が固定したプラグインの版を表示する

設定の手順:

1. Cursor の Dashboard で API キーを発行し、`CURSOR_API_KEY` に入れる
2. `env-repos.txt` に、登録するリポジトリを書く
3. `_repo/cursor-cloud/env-sync.sh --dry-run` で、送る内容を確認する
4. `--dry-run` を外して実行する
5. 新しい Cloud Agent を起動し、スキルが一覧に出ることを確認する

注意:

- 環境は登録したリポジトリでだけ使われる。リポジトリを増やすたびに、一覧を直して再実行する
- リポジトリに `.cursor/environment.json` があると、個人の設定は使われない
- Automation は個人の設定を読まない。使わせるスキルは、リポジトリの `.cursor/skills/` にコミットする

## 版を上げるとき

ローカルもクラウドも、`flake.lock` の `plugins-cursor` の版を使う。
`nix flake update plugins-cursor` を行い、main に取り込む。
`_repo/cursor-cloud/plugin-versions.sh` で、固定された版を確認できる。
