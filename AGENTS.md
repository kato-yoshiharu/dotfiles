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

## Backlog.mdのルール

- Backlog.md のタスク名に空白を含めない
- Backlog の plan・notes・final summary などの文章は、1行に詰めず Markdown として書く。

<!-- BACKLOG.MD GUIDELINES START -->
<!-- backlog.md-instructions-version: 1.53.0 -->
<CRITICAL_INSTRUCTION>

## Backlog.md Workflow

This project uses Backlog.md for task and project management.

**At the beginning of each conversation in this project, run `backlog instructions overview` before answering or taking action. Re-read it only if you have not read it yet in the current conversation.**

Use the overview to decide whether to search, read, create, or update Backlog tasks.

Before task lifecycle actions, read the matching detailed guide:

- `backlog instructions task-creation` before creating or splitting tasks
- `backlog instructions task-execution` before planning, changing status or assignee, adding a plan or implementation notes, or implementing task work
- `backlog instructions task-finalization` before checking acceptance criteria, writing final summaries, or moving tasks to terminal statuses

Use `backlog <command> --help` before running unfamiliar commands. Help shows options, fields, and examples.

Do not edit Backlog task, draft, document, decision, or milestone markdown files directly. Use the `backlog` CLI so metadata, relationships, and history stay consistent.

</CRITICAL_INSTRUCTION>
<!-- BACKLOG.MD GUIDELINES END -->
