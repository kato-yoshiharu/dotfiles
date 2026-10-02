---
name: extract-to-worktree
description: >-
  指定された内容、または git の現在の変更を、新しい git worktree に切り出し、別セッションに実装を委譲する。
  trigger phrase: "この変更を別worktreeに切り出して", "別worktreeでこの作業を行いたい", "切り出して", "分けて"
argument-hint: "[切り出す実装内容(省略時は現在の変更)]"
---

# 別 worktree に切り出して実装を委譲する

## 前提

このスキルは herdr 配下(`echo $HERDR_ENV` が `1`)での利用を前提とする。
配下でない場合はこのスキルを使わずユーザーに確認する。

## 切り出す対象の決め方

切り出す対象を、次の順で決める。

1. 引数で実装内容が与えられていれば、それを切り出す。
2. 引数が無ければ、`git status` / `git diff` で現在の変更を特定し、それを切り出す。
3. 現在の変更が複数の文脈にまたがるときは、`AskUserQuestion` でどれを切り出すかをユーザーに聞く。

## 手順

1. 対象リポジトリで `git fetch origin main` した上で、
   `herdr worktree create --cwd <メイン worktree> --branch <branch-name> --base origin/main --path ../<repo>-worktrees/<branch-name> --label <branch-name>`
   で worktree の作成と herdr workspace の起動を一度に行う。
   `--cwd` はメイン worktree(`git worktree list` の1行目)のパスにする(リンク worktree だと `linked_worktree_source` エラーになる)。
   レスポンスの `.result.workspace` / `.result.tab` / `.result.root_pane` に、後で委譲に使う workspace・pane の情報が含まれる。
2. 次の3つを新規 worktree に用意する。
   - `ln -sfnv ~/development/suimenkathemove/dotfiles/_global <worktree>/_global`
   - `ln -sfnv <メイン worktree>/_repo <worktree>/_repo`
   - `mkdir -p <worktree>/_local`
3. 手順1で作成済みの workspace の `root_pane.pane_id` を左ペインとして使い、そこで Neovim を起動する。
   その右に新規ペインを分割し、そちらで Claude Code セッションを起動して実装作業を委譲する
   (「herdr でペインを分割してセッションを委譲する」を参照)。

### herdr でペインを分割してセッションを委譲する

引き継ぎメッセージの組み立て方は `delegate-to-sub-session` スキルに従うが、完了報告を委譲元に返す部分は使わない。

```bash
# <left_pane_id> は手順1の `herdr worktree create` レスポンスの .result.root_pane.pane_id
# 先に右へ新規ペインを分割し、左ペインのサイズを確定させる
herdr pane split --pane <left_pane_id> --direction right --cwd <worktree>
# 上記レスポンスの .result.pane.pane_id が <right_pane_id>

# サイズ確定後に Neovim を起動する
herdr pane run <left_pane_id> nvim

cat > <scratchpad-dir>/handoff.txt <<'HANDOFF_EOF'
<delegate-to-sub-session のテンプレートに沿った引き継ぎ内容>
HANDOFF_EOF
herdr agent start "<branch-name>" --kind claude --pane <right_pane_id>
herdr agent wait "<branch-name>" --until idle --timeout 30000
herdr agent prompt "<branch-name>" "$(cat <scratchpad-dir>/handoff.txt)"
herdr agent send-keys "<branch-name>" alt+enter
herdr agent wait "<branch-name>" --until working --until blocked --timeout 10000
```

- Neovim を起動してから split すると、起動中のリサイズで画面描画が崩れる(ステータスラインが重複するなど)ため、必ず split を先に行う。
- `<branch-name>` は herdr 上のラベル・エージェント名にもなるので、`[a-z][a-z0-9_-]{0,31}` に収まる短い名前にする。
- `herdr agent start` が失敗する場合は `herdr agent list` / `herdr pane list` で該当 workspace のペインを再確認する。
- `herdr agent start` の `--` 経由での初回メッセージ渡しは失敗することがある(`invalid_agent_argument`)ため、
  `agent start` でペインを起動してから `agent prompt` でメッセージを送る2段階に分ける。
- `agent start` 直後はまだ Claude Code の入力欄が受付可能になっていないことがあり、
  そのまま `agent prompt` すると入力はされるが送信(Enter)されない事故が起きる。
  `agent wait --until idle` で入力受付可能になるのを待ってから送信する。
- `~/.claude/keybindings.json` で Enter を改行・`meta+enter`(端末からは `alt+enter`)を送信に再割り当てしている場合、
  `agent prompt` だけでは送信されないため `send-keys ... alt+enter` で明示的に送信する。

## ルール

- 実装作業は自分自身では行わず、必ず委譲先の Claude Code セッションに行わせる。

## 完了後の後始末

完了の判断はユーザーが行う。worktree が不要になったとユーザーから伝えられたら、対象の worktree 内で `cleanup-worktree` コマンドを実行するよう案内する。
