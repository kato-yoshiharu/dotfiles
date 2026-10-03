# link.sh から home-manager への移行計画

`.bin/link.sh` の symlink 配置を `nix/home.nix` へ段階的に移し、完了時に `link.sh` を廃止する。

## 配置方式の選び方

配置方式を選ぶルール:

- 原則として out-of-store symlink にする
- 次の条件をすべて満たす設定だけをストア経由配置にする
判断の理由は [ADR 0001](adr/0001-zsh-config-placement.md) と [ADR 0002](adr/0002-config-placement-strategy.md) に記録している。
用語は [GLOSSARY.md](../GLOSSARY.md) に従う。

## 移行の段階と配置方式
