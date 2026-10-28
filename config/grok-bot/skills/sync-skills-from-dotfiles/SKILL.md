---
name: sync-skills-from-dotfiles
description: >-
  ユーザーの dotfiles を正本として、そのスキルファイルを Grok Bot のスキルへ取り込む（上書き）。
  trigger phrase: "スキルを同期して", "スキルを取り込み直して", "スキルを dotfiles の最新にして"
---

# dotfiles を正本としてスキルを同期する

正本はユーザーのマシンにある dotfiles: `~/repos/github.com/kato-yoshiharu/dotfiles/config/grok-bot/skills/<スキル名>/SKILL.md`。
Grok Bot 側のスキルは、そのコピーとして扱う。

## 手順

1. `ListMachines` で、ユーザーのマシン（kind が desktop で接続中）の machineId を確認する。接続されていなければ、その旨を報告して止まる。
2. そのマシンで `ls` を使い、上のディレクトリにあるスキル名を一覧する。
3. Grok Bot 側の既存スキルを一覧する。
4. 各スキルの `SKILL.md` を Read で読み、frontmatter の `name` と `description`、本文を取り出す。
   `description` が複数行（`>-` など）のときは、1つの文に連結して扱う。
5. `UpdateSkill` の write で、同じ名前のスキルを上書きする。本文は一字も変えない。
6. dotfiles に無く、Grok Bot 側にだけあるスキルを、手順3の一覧と比べて報告する。
7. 取り込んだスキルの名前と、手順3の一覧と比べた新規か上書きかを報告する。

## ルール

- 内容の修正は dotfiles 側で行う。Grok Bot 側で直したくなったら、直さずに修正案をユーザーに伝える。
- dotfiles の中身を Grok Bot から書き換えるのは、ユーザーが頼んだときだけ。
- Grok Bot 側のスキルは、ユーザーの確認なしに削除しない。
