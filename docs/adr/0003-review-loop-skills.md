# レビュー・改善ループ skill の設計

evaluator-optimizer パターンの skill を、実装計画用と実装用で2つ作る。

実装計画のレビュー・改善ループ（`plan-review-loop`）と、
実装のレビュー・改善ループ（`impl-review-loop`）を別の skill に分ける。
