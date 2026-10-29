---
name: sync-auto-review-rules-from-dotfiles
description: >-
  ユーザーの dotfiles を正本として、その Auto-review のカスタムルールを Grok Bot へ取り込む。
  ルールの追加・変更・削除も、dotfiles を直してから反映する。
  trigger phrase: "ルールを同期して", "ルールを追加して", "ルールを変更して", "ルールを削除して"
---

# dotfiles を正本として Auto-review のルールを同期する

正本はユーザーのマシンにある dotfiles: `~/repos/github.com/kato-yoshiharu/dotfiles/config/grok-bot/auto-review-rules.md`。
Grok Bot 側のルールは、そのコピーとして扱う。

## 手順

1. `ListMachines` で、ユーザーのマシン（kind が desktop で接続中）の machineId を確認する。接続されていなければ、その旨を報告して止まる。
2. そのマシンで上のファイルを Read で読み、「Ask first」と「Allow automatically」の箇条書きから、ルールを取り出す。
   箇条書き1項目を1ルールとし、続きの行（インデントされた行）は同じルールの本文として連結する。
   「（なし）」の行はルールとして扱わない。
   `ProposeRuleChange` の rule は 1000 文字以内なので、超えるルールは提案せず、ユーザーに短くするよう伝える。
3. 保存済みのルールの一覧は、Grok Bot から直接読めず、add の結果にも返らない。
   そのため、重複判定を前提にしない。
   `ProposeRuleChange`（add）で、1ルールずつ add のカードを出し、1件ずつ答えを待つ。
   すでに保存済みのルールは、ユーザーがカードを取り下げる。
   ユーザーが変更の反映を頼んだときに、dotfiles で文言を変えたルールを反映するには、ユーザーに保存済みの古い文言を聞いてから、update を提案する。
4. `ProposeRuleChange` でカードが出ないとき（チャットから保存できないとき）は、
   設定画面の Auto-review のルール（`grokbot://app/v1/settings?id=auto-review-rules`）に貼る文言をそのまま報告する。
5. 提案したルール、飛ばしたルール、ユーザーが取り下げたルール、貼る文言を報告したルールを、それぞれ報告する。

## ルール

- ルールの追加・変更・削除をユーザーに頼まれたら、先に dotfiles の `auto-review-rules.md` を直す。
  そのあとで上の手順を行い、Grok Bot 側に反映する。
  Grok Bot 側だけを変えない。
- 削除と変更を Grok Bot 側に反映するときは、ユーザーが頼んだ場合に限り、`ProposeRuleChange` の delete または update を提案する。
