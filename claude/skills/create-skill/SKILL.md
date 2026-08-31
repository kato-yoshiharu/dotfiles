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
   ただしインストール済みスキルは**絶対に編集しない**。
3. 書き出す前に、次の2点をユーザーに確認する。
   - **何を書くか**: 手順・ルールの要点を箇条書きで示す。
   - **スキル名**: 小文字ケバブケース。
   「おまかせ」と言われたらそのまま進めてよい。
4. `~/development/suimenkathemove/dotfiles/claude/skills/<name>/SKILL.md` を書く。
   `~/development/suimenkathemove/dotfiles/claude/skills/TEMPLATE.md` をひな形にする。
5. `npx markdownlint-cli2 '<書いたファイル>'` で lint を通す。
6. シンボリックリンクを張る。

   ```sh
   ln -s ~/development/suimenkathemove/dotfiles/claude/skills/<name> ~/.claude/skills/<name>
   ```

## フォーマット

テンプレートは `~/development/suimenkathemove/dotfiles/claude/skills/TEMPLATE.md` を参照する。

## description の書き方

- ユーザーが実際に打ちそうなフレーズを含める（`「メモに追加して」「メモって」` のように）。

## 本文の書き方

- 日本語の地の文。技術用語・コマンドは原語のまま。
- 手順は番号付き、守るべき制約は「ルール」節に箇条書きで分ける。
- 判断が分かれる箇所は「迷ったらユーザーに確認する」と書く。

## やらないこと

- 汎用的で当たり前の手順（「テストを書く」など）をスキルにしない。
