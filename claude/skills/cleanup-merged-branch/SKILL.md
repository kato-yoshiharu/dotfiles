---
name: cleanup-merged-branch
description: >-
  マージ済みなどで不要になったブランチを、ローカルブランチ・（pushしていれば）リモートブランチも含めて削除する
  コマンドを、Claude Code の入力欄に貼り付けて実行できる形で提示する。
  worktreeで使われている場合は worktree の削除も合わせて提示する。
  「このブランチを削除して」「worktreeを片付けて」「mainに取り込んだからもういらない」などと言われたときに使う。
---

# 不要になったブランチを片付ける

## 手順

1. 対象ブランチが worktree でチェックアウトされているか確認する（`git worktree list`）。
2. worktree で使われている場合:
   - `git worktree remove` はその worktree の中からは実行できない（削除対象のディレクトリを cwd にしたまま実行するとエラーになる）ため、
     現在のカレントディレクトリが削除対象の worktree 内であれば、先にメインの worktree（リポジトリのルート）へ `cd` するコマンドを含める。
   - Claude Code の入力欄（プロンプト）は1回の送信（Enter）につき1コマンドが単位のため、
     複数のコマンドを確実に一括実行させるには `!` を先頭に付けた1行に `&&` で連結してまとめて提示する。

     <!-- markdownlint-disable MD013 -->
     ```text
     !cd <main-worktree-path> && git worktree remove <worktree-path-relative-to-main-worktree-path> && git branch -D <branch-name>
     ```
     <!-- markdownlint-enable MD013 -->

3. worktree を使っていない場合は `!git branch -D <branch-name>` を入力欄への貼り付け用に提示する。
   マージ方法によっては fast-forward として検出されないことがあるため、`-d` ではなく `-D` を使う。
4. 対象ブランチをリモートに push しているか確認する（`git ls-remote --heads origin <branch-name>` など）。
   push していれば削除するかどうかをユーザーに確認したうえで、次を入力欄への貼り付け用に提示する。

   ```text
   !git push origin --delete <branch-name>
   ```

5. worktree に未コミット・未pushの変更が残っていないか確認する。残っていれば、破棄してよいかをユーザーに確認する。

## ルール

- worktree 削除・ブランチ削除・リモートブランチ削除は必ずユーザーの明示的な実行に委ね、Claude 側から代理実行しない。
- 未コミットの変更が残っている場合は、削除コマンドを提示する前に必ずユーザーに確認する。
- 実行を要するコマンドは、Claude Code の入力欄に貼り付けて `!` で実行できる1行の形にして提示する。
