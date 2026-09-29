---
name: squash-merge
description: >-
  現在のブランチを、指定したブランチ（未指定なら main）に手元で squash merge する。
  事前にマージ先とのコンフリクトを確認してから、squash merge のコマンドを Claude Code の入力欄に貼り付けて実行できる形で提示する。
---

# 現在のブランチを指定ブランチに squash merge する

## 手順

1. マージ先ブランチを決める。
   - ユーザーがマージ先を明示していればそれを使い、明示がなければ `main` を提示して使う。
2. `git fetch origin <マージ先ブランチ>` でマージ先を最新化する。
3. 現在の状態を、記憶に頼らず毎回コマンドで確認する。
4. コンフリクトの有無を確認する。
   - `git merge-tree $(git merge-base HEAD origin/<マージ先ブランチ>) origin/<マージ先ブランチ> HEAD` を実行する
     （Git 2.38+ 相当のドライラン用法。出力にコンフリクトマーカー（`<<<<<<<` など）が含まれるかで判定する）。
5. コンフリクトがあれば、`git merge-tree` の出力からコンフリクトしているファイルを一覧してユーザーに報告する。
   その場で自動的に解消しない。解消方法（rebase してから squash する、手動で解消するなど）はユーザーに確認する。
6. コンフリクトが無ければ、マージ先ブランチをチェックアウトしている worktree を次のコマンドで確認し、結果に応じた squash merge のコマンドを提示する。
   コミットメッセージは、差分から1行で要約して提案する。
   コピー対象は、先頭の `!` から始まる下記の1行そのものとする。

   <!-- markdownlint-disable MD013 -->
   ```text
   git worktree list --porcelain | awk -v b="refs/heads/<マージ先ブランチ>" '/^worktree /{p=substr($0,10)} $1=="branch" && $2==b{print p}'
   ```

   パスが出力された場合（その worktree で実行する）:

   ```text
   !cd <出力されたパス> && git pull origin <マージ先ブランチ> && git merge --squash <現在のブランチ名> && git commit -m "<コミットメッセージ>" && git push origin <マージ先ブランチ>
   ```

   何も出力されない場合（現在の worktree で checkout して実行し、元のブランチに戻す）:

   ```text
   !git checkout <マージ先ブランチ> && git pull origin <マージ先ブランチ> && git merge --squash <現在のブランチ名> && git commit -m "<コミットメッセージ>" && git push origin <マージ先ブランチ> && git checkout <現在のブランチ名>
   ```
   <!-- markdownlint-enable MD013 -->
7. squash merge 後、現在のブランチ（squash merge 元、および worktree・リモートブランチ）の削除は `cleanup-merged-branch` スキルに従う。

## ルール

- squash merge・push・ブランチ削除・worktree 削除は必ずユーザーの明示的な実行に委ね、Claude 側から代理実行しない
- 状態確認（手順3）は、直前の会話で確認済みでも省略せず毎回実行する
- コンフリクトチェックは必ず squash merge のコマンドを提示するより先に行う
- 実行を要するコマンドは、Claude Code の入力欄に貼り付けて `!` で実行できる1行の形にして提示する
- 提示したコマンドは、先頭の `!` も含めて `pbcopy` でクリップボードにコピーする
