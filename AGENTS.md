# AGENTS.md

## ドキュメント・コードコメントのルール

Markdown ドキュメントとコードコメントを編集するときのルール。

### 共通のルール

- 文体は常体（だ・である／する）
- 本題に入る前の前置きと、末尾のまとめ直しは書かない

### Markdown ドキュメントのルール

- 見出しは、直前の文に依存しない。
  「壊れる理由」ではなく「1つのモデルにまとめると壊れる」のように、それだけ読んで何の話か分かる形にする
- 箇条書きの直前には「〜のルール:」「〜が向くとき:」のようなリード文（柱書き）を1行置き、何についての列挙かを示す。
- 図（構成図・シーケンス図・フロー図・状態遷移図など）は、アスキーアートではなく Mermaid（```mermaid コードブロック）で記述する。
  ターミナルでの応答に出す図は対象外で、「ターミナルでの応答に出す図はアスキーアートで書く」の節に従う

### コードコメントのルール

- 句点（。）で必ず改行する。読点（、）でもなるべく改行する

## ターミナルでの応答に出す図はアスキーアートで書く

ターミナルでは Mermaid がコードのまま表示されて読みにくい。
そのため、ターミナルに表示する応答（ユーザーへの説明・報告）に出す図は、Mermaid ではなくアスキーアートで書く。

## メモ用ディレクトリは共有範囲で3つに分かれる

各リポジトリ直下の `_global` / `_repo` / `_local` は、グローバル gitignore に入っておりコミットされない。

それぞれの共有範囲:

- `_global`: 全リポジトリ共通。実体は dotfiles のメイン worktree の `_global`。各リポジトリでは symlink にする
- `_repo`: 同一リポジトリの全 worktree で共有する。実体はそのリポジトリのメイン worktree の `_repo`。他の worktree では symlink にする
- `_local`: その worktree だけ。symlink にせず実ディレクトリにする

## 設定を自作する前にプラグインを探す

エディタやツールの挙動を変えたいと言われたとき、いきなり設定ファイルに自作コードを書かない。

対応手順:

- まず既存のプラグイン・拡張を探し、候補を提示する
- 候補は「スター数・最終更新日・アーカイブ済みか」を実際に検索して確認したうえで挙げる。記憶だけで「定番」と言わない
- そのうえで、プラグインを入れるか自作するかをユーザーに選んでもらう

自作を選ぶのが妥当なとき:

- 数行で済む
- 既存プラグインが要件に合わない

## Codex CLI の設定は手動同期する

`.codex/config.toml`（dotfiles のテンプレート）と `~/.codex/config.toml`（実ファイル）は symlink しない方針にしている。
設定を変更したときは、もう一方にも同じ変更を反映する。

## ファイルを書き換える前に最新の状態を読み直す

ユーザーが編集しうるファイルに書き込むとき、手元の記憶を現在の状態だと思い込まない。

- 書き込む直前に、そのファイルを読み直す。`git status` の状態が変わったときや、ユーザーが「修正した」と言ったときも、記憶に頼らず読み直す
- 部分的な変更は、丸ごと置き換える `Write` ではなく `Edit` で行う

## 「調べて」と言われたら必ず検索する

「〜を調べて」と言われたとき、対象が何であっても既知の知識だけで答えない。

対応手順:

- WebSearch・WebFetch や、接続されているMCPの検索ツールなど、使える手段で実際に検索してから回答する
- 検索した情報と記憶の情報が食い違う場合は、検索した情報を優先する

## Backlog.mdのルール

- Backlog.md のタスク名に空白を含めない

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
