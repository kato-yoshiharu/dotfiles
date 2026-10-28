---
name: extract-to-worktree
description: >-
  ユーザーの Mac の Claude Code に、extract-to-worktree スキルを実行させて、新しい worktree に作業を切り出す。
  trigger phrase: "worktreeを作成して", "切り出して"
---

# Claude Code に extract-to-worktree を実行させる

## 手順

1. 次の 2 つを決める。決められないものは、ユーザーに確認する。
   - リポジトリ: `~/repos/github.com/<owner>/<repo>` のメイン worktree
   - 切り出す内容: ユーザーが示した情報だけにする。推測で足さない
2. `ListMachines` で、ユーザーの Mac の machineId を確認する。
3. その Mac で、リポジトリのメイン worktree を cwd にして Claude Code を起動する。
   Mac のシェルは herdr の外なので、`HERDR_ENV=1` を付ける。

   ```sh
   HERDR_ENV=1 claude -p --allowedTools "Bash Read Edit Write Glob Grep Skill" <<'EOF'
   extract-to-worktree スキルを使って、次を切り出す。
   - 内容: <切り出す内容>
   EOF
   ```

4. `herdr agent list` と worktree の `git status` で完了を確認し、worktree のパスと `git status` をユーザーに報告する。

## ルール

- Grok Bot は実装しない
- herdr か `claude` が使えないときは、原因を報告してユーザーに判断を仰ぐ。
  別の方法で worktree を作らない
