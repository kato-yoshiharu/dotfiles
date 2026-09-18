---
name: isolated-change
description: >-
  現在作業中のブランチ・worktree にある未コミットの変更に触れず、それとは無関係な変更を安全に実装する。
  git worktree を新たに切って作業することで、現在の変更を引き継がず隔離する。
  「worktreeを作成して実装して」「今の作業ブランチとは分けて実装して」などと言われたときに使う。
---

# 現在の変更から隔離して実装する

## 前提

このスキルは herdr 配下(`echo $HERDR_ENV` が `1`)での利用を前提とする。
配下でない場合は、このスキルを使わずユーザーに確認する。

## 手順

1. 対象リポジトリで `git fetch origin main` した上で、
   `herdr worktree create --cwd <メイン worktree> --branch <branch-name> --base origin/main --path ../<repo>-worktrees/<branch-name> --label <branch-name>`
   で worktree の作成と herdr workspace の起動を一度に行う。
   `--cwd` はメイン worktree(`git worktree list` の1行目)のパスにする(リンク worktree だと `linked_worktree_source` エラーになる)。
   worktree は `<repo>-<name>` のように対象リポジトリと並べてバラバラに作らず、`<repo>-worktrees/` 配下にブランチ名でまとめる。
   レスポンスの `.result.workspace` / `.result.tab` / `.result.root_pane` に、後で委譲に使う workspace・pane の情報が含まれる。
2. 次の2つの symlink を新規 worktree に張る。
   - `ln -sfnv ~/development/suimenkathemove/memos/_shared <worktree>/_shared`
     個人メモリポジトリの `_shared`へのリンク。全リポジトリ共通で同じ実体を指す。
   - `ln -sfnv <メイン worktree>/_local <worktree>/_local`
     で、対象リポジトリのメイン worktree(最初のチェックアウト、`git worktree list` の1行目)の`_local` に symlink する。
     `_local` はそのリポジトリに閉じたローカルメモで、同一リポジトリの worktree 間でのみ共有する(他のリポジトリの `_local` とは別物)。
     メイン worktree に `_local` が無ければ `mkdir -p <メイン worktree>/_local` で先に作成する。
3. 手順1で作成済みの workspace の `root_pane.pane_id` を使って Claude Code セッションを起動し、実装作業を委譲する
   (「herdr でセッションを委譲する」を参照)。

### herdr でセッションを委譲する

引き継ぎメッセージの組み立て方は `delegate-to-sub-session` スキルに従うが、完了報告を委譲元(自分)に返す部分は使わない。
委譲先セッションを起動するペインの用意方法も異なる(ペイン分割ではなく、手順1で `herdr worktree create` が作成済みの workspace のペインを使う)。

```bash
cat > <スクラッチパッド>/handoff.txt <<'HANDOFF_EOF'
<delegate-to-sub-session のテンプレートに沿った引き継ぎ内容>
HANDOFF_EOF
# <pane_id> は手順1の `herdr worktree create` レスポンスの .result.root_pane.pane_id
herdr agent start "<branch-name>" --kind claude --pane <pane_id> -- "$(cat <スクラッチパッド>/handoff.txt)"
```

- `<branch-name>` は herdr 上のラベル・エージェント名にもなるので、`[a-z][a-z0-9_-]{0,31}` に収まる短い名前にする。
- `herdr agent start` が失敗する場合は `herdr agent list` / `herdr pane list` で該当 workspace のペインを再確認する
  (shell起動直後の環境によっては claude が自動起動しており pane_id がずれることがある)。

## ルール

- dotfiles のようにリポジトリ内にリンクスクリプト(`link.sh` 等)がある場合、スクリプト全体を安易に実行しない。
  全体実行すると、今回の変更と無関係な既存のシンボリックリンクまでこの worktree を指すよう書き換わってしまう事故につながる。
  新規追加したファイルだけを個別に `ln -sfnv` でリンクする。
- worktree の配置場所・ブランチ名など、判断が分かれる箇所はユーザーに確認する。
- 実装作業は自分自身では行わず、必ず委譲先の Claude Code セッションに行わせる。

## 完了後の後始末

完了の判断はユーザーが行う。worktree が不要になったとユーザーから伝えられたら、`cleanup-merged-branch` スキルに任せる
