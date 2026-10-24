# Homebrew 本体を nix で管理しない

cask・tap・Mac App Store アプリは、nix-darwin の `homebrew` モジュールで宣言管理する。
Homebrew 本体は nix-darwin では入らないため、`make install-brew` で導入し、更新は `brew update` で行う。
本体まで nix で管理できる nix-homebrew は、採用しない。

## Considered Options 検討した選択肢

### nix-homebrew

Homebrew 本体の導入と、tap の宣言・固定ができる。
cask の宣言は含まず、nix-darwin の `homebrew` モジュールと組み合わせて使う。
2026-10-24 時点で、次の2つの問題があるため採用しない。

- Homebrew の版が `flake.nix` の `brew-src` で固定される。
  main は 7.0.4 を指しており、7.0.10 への更新 PR（#195）は未マージである。
  導入すると Homebrew が古い版に下がり、更新も `brew update` ではなく `nix flake update` 経由になる。
- `masApps` が失敗する。
  nix-homebrew の `brew` ラッパー経由だと、`brew bundle` が `mas` を見つけられない（issue #189、#149）。
  修正 PR（#194）は未マージである。

## Consequences 決定に伴う影響

- Homebrew 本体の導入だけが、nix の宣言の外に残る。
  `install-brew` は導入済みならスキップするため、実害は小さい。
- 次の条件が揃ったら、nix-homebrew を再検討する。
  - PR #194 と #195 がマージされ、`masApps` が動き、Homebrew の版が最新に近い。
