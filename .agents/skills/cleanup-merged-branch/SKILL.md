---
name: cleanup-merged-branch
description: >-
  マージ済みなどで不要になったブランチを、ローカルブランチ・（pushしていれば）リモートブランチも含めて削除するコマンドを、
  Claude Code の入力欄に貼り付けて実行できる形で提示する。
  worktree で使われている場合は worktree の削除も合わせて提示する。
---

# 不要になったブランチを片付ける

## 手順

### 1. 削除対象の特定

- リモートブランチを削除するか
  対象ブランチがリモートに push されているか確認する（`git ls-remote --heads origin <branch-name>` など）。
- worktree を削除するか
  `git worktree list` の出力（各行 `<path> <sha> [<branch>]` の形式）から `[<branch-name>]` を含む行を探し、そのパスを対応する worktree のパスとする。
- スキル呼び出し時の引数に `すべて`, `全て`, `all` が含まれており、かつ worktree が存在する場合は、
  worktree を削除対象に含める。

### 2. 削除コマンドの提示

ローカルブランチ・（pushしていれば）リモートブランチ・（削除対象に含めていれば）worktree を、
一括削除する1個のコマンドを提示する。
コマンドは次の要素を、該当するものだけ `&&` で順につないで組み立てる。

1. worktree が削除対象の場合のみ: `cd <repo-root-path> && git worktree remove <worktree-path-relative-to-repo-root>`
2. 常に: `git branch -D <branch-name>`
3. リモートに push 済みの場合のみ: `git push origin --delete <branch-name>`

## ルール

- ブランチ削除・リモートブランチ削除・worktree 削除は必ずユーザーの明示的な実行に委ね、Claude Code 側から実行しない。
- 実行を要するコマンドは、Claude Code の入力欄に貼り付けて `!` で実行できる1行の形にして提示する。
- 提示したコマンドは `pbcopy` でクリップボードにもコピーする。
- 未コミットの変更が残っている場合は、削除コマンドを提示する前に必ずユーザーに確認する。
