---
name: add-devlog
description: >-
  memos_private（~/development/suimenkathemove/memos_private）の devlog に、今日やったことを書き込む。
  trigger phrase: "devlogを書いて", "今日やったことを記録して"
argument-hint: "[日付・期間。省略時は今日]"
---

# devlog に今日やったことを書き込む

対象repo: `~/development/suimenkathemove/memos_private/devlog`

- ファイルパスは `2026/01/2026-01-01.md` のように `<年>/<月>/<YYYY-MM-DD>.md` とする。
- テンプレートは `devlog/TEMPLATE.md`。

## 手順

1. 対象日を決める。引数がなければ今日。
   解釈に迷う指定はユーザーに聞く。
   対象になる日付は、手順 4 の確認で示す。
2. 対象日ごとに、ファイルが既にあるか確認する。
   あれば全文読み直し、「今日やったこと」に追記する。なければ `TEMPLATE.md` をコピーして作る。
3. 書く内容を、自分の commit ログから集める。
   集め方は「commit ログの集め方」の節に従う。
   - commit は、テーマごとに1項目にまとめる。
     粒度は直近のファイルに合わせる。
   - 作業の記録がない日はファイルを作らない。
   - ログから分からない作業があれば、ユーザーに聞く。

## commit ログの集め方

ローカルの commit を `git log` で取得する。

取得の方針:

- `~/development/` 配下のすべてのリポジトリで `git log` を実行する。
- worktree は本体と ref を共有するので、本体を `--all` で見れば足りる。

```sh
find ~/development -maxdepth 4 -type d -name .git |
  while read -r g; do
    r=$(dirname "$g")
    git -C "$r" log --all --author="$(git config user.name)" \
      --since="<開始日> 00:00" --until="<終了日の翌日> 00:00" \
      --format="$(basename "$r") %H %ad %s" --date=iso
  done
```
