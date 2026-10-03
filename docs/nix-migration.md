# link.sh から home-manager への移行計画

`.bin/link.sh` の symlink 配置を `nix/home.nix` へ段階的に移し、完了時に `link.sh` を廃止する。

## 配置方式の選び方

配置方式を選ぶルール:

- 原則としてストア外配置にする
- 次の条件をすべて満たす設定だけをストア経由配置にする
  - ツールが書き換えないと確認できている
  - 編集頻度が低い
- ディレクトリ直下のエントリ単位で配置し、`~/.config/nvim` のような配置先のディレクトリ自体は symlink にしない
- 次のものだけは、配置先のディレクトリごと symlink にする
  - 公式がディレクトリ単位の symlink を求めるもの（Karabiner）
  - 配置先にリポジトリ外のファイルが置かれず、ファイルの追加が多いもの（`.commands`）

判断の理由は [ADR 0001](adr/0001-zsh-config-placement.md) と [ADR 0002](adr/0002-config-placement-strategy.md) に記録している。
用語は [GLOSSARY.md](../GLOSSARY.md) に従う。

## 移行の段階と配置方式

各段階を1コミットにし、段階ごとに実機で動作を確認する。

| 段階 | 対象                                                              | 配置方式       |
| ---- | ----------------------------------------------------------------- | -------------- |
| 1    | git、`.commands`                                                  | ストア外配置   |
| 2    | zsh                                                               | ストア外配置   |
| 3    | tmux                                                              | ストア経由配置 |
| 4    | nvim、wezterm、aerospace、yazi、vicinae、rumdl、karabiner、VSCode | ストア外配置   |
| 5    | Claude Code、Codex                                                | ストア外配置   |
| 6    | `link.sh` の削除、`Makefile.toml` と README の更新                | なし           |

