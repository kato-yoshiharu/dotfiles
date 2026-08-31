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
2. **既存のスキル（組み込み、インストール済み、自作）に近いものがあるか確認する。**
   インストール済みは `~/development/suimenkathemove/dotfiles/claude/skills-installed/`、
   自作は `~/development/suimenkathemove/dotfiles/claude/skills/`。
   description を読み、近そうなものがあればそのファイルを全文読む。
   重なるなら、新規作成するか既存スキルに節を足すかをユーザーに確認する。
3. 書き出す前に、次の2点をユーザーに確認する。
## フォーマット

テンプレートは `~/development/suimenkathemove/dotfiles/claude/skills/TEMPLATE.md` を参照する。

## 本文の書き方

- 日本語の地の文。技術用語・コマンドは原語のまま。
