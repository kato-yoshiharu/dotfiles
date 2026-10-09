# link.sh から home-manager への移行計画

`.bin/link.sh` の symlink 配置を `nix/home.nix` へ段階的に移し、完了時に `link.sh` を廃止する。

## 配置のルール

設定は `mkOutOfStoreSymlink` によるストア外配置にする。

配置の単位のルール:

- ディレクトリ直下のエントリ単位で配置し、`~/.config/nvim` のような配置先のディレクトリ自体は symlink にしない
- 次のものだけは、配置先のディレクトリごと symlink にする
  - 公式がディレクトリ単位の symlink を求めるもの（Karabiner）
  - 配置先にリポジトリ外のファイルが置かれず、ファイルの追加が多いもの（`.commands`）

判断の理由は [ADR 0001](adr/0001-zsh-config-placement.md) と [ADR 0002](adr/0002-config-placement-strategy.md) に記録している。
用語は [GLOSSARY.md](../GLOSSARY.md) に従う。

## 移行の段階

各段階を1コミットにし、段階ごとに実機で動作を確認する。

| 段階 | 対象                                                                    |
| ---- | ----------------------------------------------------------------------- |
| 0    | `makers switch` の定義（`dotfilesDir`、`Makefile.toml`、README）        |
| 1    | git、`.commands`                                                        |
| 2    | zsh                                                                     |
| 3    | tmux、nvim、wezterm、aerospace、yazi、vicinae、rumdl、karabiner、VSCode |
| 4    | Claude Code、Codex                                                      |
| 5    | `link.sh` の削除、`Makefile.toml` と README の更新                      |

- `makers switch` は以降の全段階の手順で使うため、配置を移す前に定義する
- `.commands` は `.gitconfig` のエイリアスと git hooks から呼ばれるため、git と同じ段階にしている
- zsh は失敗すると新しいシェルが設定なしで起動するため、git と分けて原因を切り分けられるようにしている
- Claude Code と Codex は作業中のセッション自身の設定を壊しうるため、後ろ寄せにしている
