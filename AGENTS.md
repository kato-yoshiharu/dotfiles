# AGENTS.md

## Codex CLI の設定は手動同期する

`config/codex/config.toml`（dotfiles のテンプレート）と `~/.codex/config.toml`（実ファイル）は symlink しない方針にしている。
設定を変更したときは、もう一方にも同じ変更を反映する。

## エージェントの設定ファイルは、ベースを直して `make agent-configs` で反映する

次の実ファイルは Orca や CLI 自身が書き換えるため、直接直さない。

| 実ファイル                  | ベース                          |
| --------------------------- | ------------------------------- |
| `~/.claude/settings.json`   | `config/claude/settings.json`   |
| `~/.codex/hooks.json`       | `config/codex/hooks.json`       |
| `~/.cursor/cli-config.json` | `config/cursor/cli-config.json` |

運用のルール:

- 設定の変更は、実ファイルではなくベースに書く
- Cursor のベースには、管理したいトップレベルのキーだけを書く。反映時はそのキーだけが置き換わり、認証情報やキャッシュなど他のキーは実ファイルの値が残る
- ベースを直した後は `make agent-configs` を実行する

## 新しい coding agent を導入するときは、チェックリストを読む

新しい coding agent の設定を揃えるときは、`docs/new-agent-checklist.md` を読んで、その項目に沿って進める。
