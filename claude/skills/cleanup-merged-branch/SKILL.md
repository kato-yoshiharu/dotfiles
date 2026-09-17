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
   このスキルは、削除対象ブランチの worktree の中から呼ばれるとは限らない（squash merge 後に
   main 側から呼ばれるなど、無関係な場所から呼ばれることもある）。
   `git worktree list` の出力から対象ブランチに対応する worktree のパスを機械的に特定する。
   カレントディレクトリとの位置関係を前提にしない。
2. worktree で使われている場合:
   - `git worktree remove` はその worktree の中からは実行できない（削除対象のディレクトリを cwd にしたまま実行するとエラーになる）ため、
     カレントディレクトリが削除対象の worktree 内であれば、先にリポジトリのルート（`git worktree list`
     の1行目に出る、`.git` を直接持つディレクトリ）へ `cd` するコマンドを含める。
     カレントディレクトリが削除対象の worktree の外（main 側から呼ばれた場合など）であれば、
     `cd` は不要で `git worktree remove` から始める。
   - Claude Code の入力欄（プロンプト）は1回の送信（Enter）につき1コマンドが単位のため、
     複数のコマンドを確実に一括実行させるには `!` を先頭に付けた1行に `&&` で連結してまとめて提示する。
   - カレントディレクトリが削除対象の worktree 内の場合:

     <!-- markdownlint-disable MD013 -->
     ```text
     !cd <repo-root-path> && git worktree remove <worktree-path-relative-to-repo-root> && git branch -D <branch-name>
     ```
     <!-- markdownlint-enable MD013 -->

   - カレントディレクトリが削除対象の worktree の外の場合:

     ```text
     !git worktree remove <worktree-path> && git branch -D <branch-name>
     ```

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
- 提示したコマンドは `pbcopy` でクリップボードにも同時にコピーする（テキスト表示は省略しない）。
