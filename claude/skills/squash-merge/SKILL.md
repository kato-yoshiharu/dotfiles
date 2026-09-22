---
name: squash-merge
description: >-
  現在のブランチを、指定したブランチ（未指定なら main を候補としてユーザーに確認）に手元で squash merge する。
  事前にマージ先とのコンフリクトを確認してから、squash merge のコマンドを Claude Code の入力欄に貼り付けて実行できる形で提示する。
  「squash mergeしたい」「squash mergeのコマンドを教えて」などと言われたときに使う。
---

# 現在のブランチを指定ブランチに squash merge する

## マージ先ブランチの決定

- ユーザーがマージ先を明示していればそれを使う。
- 明示がなければ `main` を候補として提示し、それでよいかを必ずユーザーに確認する。
  確認なしに `main` を決定・実行しない。
- 以下の手順の `<target-branch>` はこのマージ先ブランチを指す。

## 手順

1. `git fetch origin <target-branch>` でマージ先を最新化する。
2. コンフリクトの有無を、作業ツリーを汚さずに確認する。
   - `git merge-tree $(git merge-base HEAD origin/<target-branch>) origin/<target-branch> HEAD` を実行する
     （Git 2.38+ 相当のドライラン用法。出力にコンフリクトマーカー（`<<<<<<<` など）が含まれるかで判定する）。
3. コンフリクトがあれば、`git merge-tree` の出力からコンフリクトしているファイルを一覧してユーザーに報告する。
   その場で自動的に解消しない。解消方法（rebase してから squash する、手動で解消するなど）はユーザーに確認する。
4. コンフリクトが無ければ、次のコマンドを Claude Code の入力欄（プロンプト）に貼り付けて `!` で実行できる形で提示する。
   実行はユーザーに委ねる（Claude 側から代理実行しない）。
   - 入力欄は1回の送信（Enter）につき1コマンドが単位のため、複数のコマンドを確実に一括実行させるには `!` を先頭に付けた1行に `&&` で連結してまとめる。
   - コミットメッセージは、マージ先ブランチ（`<target-branch>`）と現在のブランチの差分の内容から1行で要約して提案する。
     本文（複数行・箇条書き）は付けない。
   - カレントディレクトリが squash merge 元ブランチの worktree である場合、
     このコマンドは worktree を一時的に `<target-branch>` へチェックアウトするため、
     最後に `git checkout <branch-name>` で元に戻す。
   - `<target-branch>` 自身の worktree で実行する場合は、このチェックアウト戻しは不要。

   <!-- markdownlint-disable MD013 -->
   ```text
   !git checkout <target-branch> && git pull origin <target-branch> && git merge --squash <branch-name> && git commit -m "<squashコミットのメッセージ>" && git push origin <target-branch> && git checkout <branch-name>
   ```
   <!-- markdownlint-enable MD013 -->
5. squash merge 後、現在のブランチ（squash merge 元、および worktree・リモートブランチ）の削除は `cleanup-merged-branch` スキルに従う。

## ルール

- squash merge・push・ブランチ削除・worktree 削除は必ずユーザーの明示的な実行に委ね、Claude 側から代理実行しない。
- コンフリクトチェックは必ず squash merge のコマンドを提示するより先に行う。
- 実行を要するコマンドは、Claude Code の入力欄に貼り付けて `!` で実行できる1行の形にして提示する。
- 提示したコマンドは `pbcopy` でクリップボードにも同時にコピーする（テキスト表示は省略しない）。
