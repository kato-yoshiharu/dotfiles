---
name: isolated-change
description: >-
  現在作業中のブランチ・worktree にある未コミットの変更に触れず、それとは無関係な変更を安全に実装する。
  git worktree を新たに切って作業することで、現在の変更を引き継がず隔離する。
  「worktreeを作成して実装して」「今の作業ブランチとは分けて実装して」などと言われたときに使う。
---

# 現在の変更から隔離して実装する

## 手順

1. 対象リポジトリで `git fetch origin main` した上で、
   `git worktree add ../<repo>-worktrees/<branch-name> -b <branch-name> origin/main`
   で新規 worktree を作成する。
   worktree は `<repo>-<name>` のように対象リポジトリと並べてバラバラに作らず、`<repo>-worktrees/` 配下にブランチ名でまとめる。
2. 次の2つの symlink を新規 worktree に張る。
   - `ln -sfnv ~/development/suimenkathemove/memos/_shared <worktree>/_shared`
     個人メモリポジトリの `_shared`へのリンク。全リポジトリ共通で同じ実体を指す。
   - `ln -sfnv <メイン worktree>/_local <worktree>/_local`
     で、対象リポジトリのメイン worktree(最初のチェックアウト、`git worktree list` の1行目)の`_local` に symlink する。
     `_local` はそのリポジトリに閉じたローカルメモで、同一リポジトリの worktree 間でのみ共有する(他のリポジトリの `_local` とは別物)。
     メイン worktree に `_local` が無ければ `mkdir -p <メイン worktree>/_local` で先に作成する。
3. 作成した worktree の中で必要なファイルを作成・編集する。
4. 変更はコミットしない

## ルール

- dotfiles のようにリポジトリ内にリンクスクリプト(`link.sh` 等)がある場合、スクリプト全体を安易に実行しない。
  全体実行すると、今回の変更と無関係な既存のシンボリックリンクまでこの worktree を指すよう書き換わってしまう事故につながる。
  新規追加したファイルだけを個別に `ln -sfnv` でリンクする。
- worktree の配置場所・ブランチ名など、判断が分かれる箇所はユーザーに確認する。

## 完了後の後始末

完了の判断はユーザーが行う。worktree が不要になったとユーザーから伝えられたときに、以下を行う
(`git worktree remove` は取り消しにくい操作のため、Claude 側から完了・削除を持ちかけない)。

- worktree を削除してよいか確認する。
- 削除する前に、動作確認のためにこの worktree を指すよう実環境側(`~/.commands` など)で張り替えた symlink が無いか確認し、
  あればユーザーに伝える。
- ブランチは消さない。
  `git branch -d <branch-name>`(未マージの変更が残るなら `-D`)をユーザーに提示し、実行はユーザーに委ねる。
