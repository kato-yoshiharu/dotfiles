---
name: add-memo
description: >-
  ユーザーの dotfiles の add-memo スキルを、マシンの Claude Code に実行させて、memos リポジトリにメモを追加・更新する。
  trigger phrase: "メモに追加して", "メモって", "memos に書いて"
---

# Claude Code に add-memo を実行させる

呼び出す add-memo スキルの正本はユーザーのマシンにある dotfiles: `~/repos/github.com/kato-yoshiharu/dotfiles/config/coding-agents/skills/add-memo/SKILL.md`。
メモを書く memos リポジトリは `~/repos/github.com/kato-yoshiharu/memos` のメイン worktree。

## 手順

1. `ListMachines` で、ユーザーのマシン（kind が desktop で接続中）の machineId を確認する。接続されていなければ、その旨を報告して止まる。
2. 書く内容と追加先を、ユーザーに確認する。
   `claude -p` は対話できないので、add-memo スキルが書き出す前に行う確認を、Grok Bot がここで済ませる。
   追加先はユーザーが示したときだけ決める。示さなければ、add-memo スキルに任せる。
3. 手順 1 のマシンで、memos リポジトリのメイン worktree を cwd にして Claude Code を起動する。

   ```sh
   cd ~/repos/github.com/kato-yoshiharu/memos
   HERDR_ENV=1 claude -p --allowedTools "Bash Read Edit Write Glob Grep Skill" <<'EOF'
   add-memo スキルを使って、次をメモに追加する。
   - 書く内容: <書く内容>
   - 追加先: <ファイルパス。ユーザーが示していなければ省く>
   EOF
   ```

4. `herdr agent list` と新しい worktree の `git status`、`git diff` で完了を確認し、新しい worktree の追加先のパスと差分をユーザーに報告する。

## ルール

- Grok Bot はメモを書かない
- メイン worktree には書かない
- add-memo スキルの内容の修正は dotfiles 側で行う。Grok Bot 側で直したくなったら、直さずに修正案をユーザーに伝える。
- `claude` が使えないときは、原因を報告してユーザーに判断を仰ぐ。
  別の方法でメモを書かない
