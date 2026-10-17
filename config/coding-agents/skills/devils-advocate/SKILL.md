---
name: devils-advocate
description: >-
  devils-advocate サブエージェントを確実に呼び出してレビューさせる。
  trigger phrase: "$devils-advocate", "devils-advocateを使って", "devil's advocateを使って"
argument-hint: "[レビュー対象]"
---

# devils-advocate サブエージェントを呼び出す

## 手順

1. レビュー対象を特定する。
   提示されていないときだけ、何をレビューするかユーザーに確認する。
2. 「サブエージェントへ渡す依頼文の内容」に従って、依頼文を組み立てる。
3. 専用サブエージェントを必ず起動する。
   - Claude Code: Agent ツールを `subagent_type: devils-advocate` で呼び出す。
   - Codex: `~/.claude/agents/alirezarezvani/devils-advocate.md` を全文読む。
     `spawn_agent` で、タスク名を `devils_advocate` として起動する。
     指示には、読んだ定義の全文と手順2の依頼文を含める。
4. 起動したら、完了を待たずに次の操作へ進む。
   結果が届いたら、ユーザーへ返す。

### サブエージェントへ渡す依頼文の内容

ルート自身の評価や懸念は入れない。

<!-- TODO -->

## ルール

- ルートエージェント自身がレビューしない。
  必ず専用サブエージェントを使う。

<!--
TODO: 開発用の devil's advocate サブエージェントを自作する。
現在の呼び出し先は、経営判断向けの alirezarezvani 版である。
自作したら、手順3の呼び出し先を差し替える。
-->
