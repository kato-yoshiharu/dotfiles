# レビュー・改善ループ skill の設計

## Context 背景

evaluator-optimizer パターン（生成役と評価役を分け、評価のフィードバックで改善を繰り返す）を、
実装計画のレビューと、実装のレビューに使う skill にしたい[^memo][^building-effective-agents]。

ただし、LLM によるレビュー・改善ループでは、よくある失敗がある。

## Decision 設計で決めたこと

### 工程の分け方

実装計画のレビュー・改善ループ（`plan-review-loop`）と、
実装のレビュー・改善ループ（`impl-review-loop`）を別の skill に分ける。
## References 参考にした資料

設計の出発点にした資料:

- [memos リポジトリの memos/coding-agent/evaluator-optimizer.md](https://github.com/kato-yoshiharu/memos/blob/f9680b571e39956249a08ea26cb9d29a25c1280e/memos/coding-agent/evaluator-optimizer.md)
  - 生成役と評価役を分け、終了条件と評価の出力形式を必ず決める
- [AIに丸投げしないで理解するためのAI開発手法（Zenn）](https://zenn.dev/avaintelligence/articles/dont-outsource-understanding-to-ai)
  - 第4節: Codex による実装計画レビューループ。過剰な指摘を人間が仕分けないとループが終わらない
  - 第5節: 実装計画が固まったら新しいセッションで実装する

公式の資料:

設計を参考にした skill:

