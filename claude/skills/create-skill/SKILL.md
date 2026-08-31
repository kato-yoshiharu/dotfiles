---
name: create-skill
description: >-
  dotfiles で管理している個人スキル（~/development/suimenkathemove/dotfiles/claude/skills）を新規作成・更新する。
  「このスキルを作って」「スキル化して」「今の手順をスキルにして」などと言われたときに使う。
---

# 個人スキルを作成する

対象ディレクトリ: `~/development/suimenkathemove/dotfiles/claude/skills/<name>/SKILL.md`

`~/.claude/skills/<name>` からシンボリックリンクを張ることで、全プロジェクトで有効になる。
`claude/skills-installed/` は外部から入れたスキルなので、そこには置かない。

## 手順

1. **スキル化する価値があるか確認する。**
   一度きりの作業はスキルにしない。
   繰り返し使う手順で、かつ毎回同じ判断を口頭で説明している場合が対象。
## フォーマット

テンプレートは `~/development/suimenkathemove/dotfiles/claude/skills/TEMPLATE.md` を参照する。

## 本文の書き方

- 日本語の地の文。技術用語・コマンドは原語のまま。
