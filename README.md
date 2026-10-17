# dotfiles

## Setup

```sh
cargo install --force cargo-make
makers init
```

`makers init` は、`install/install.sh` でツールを入れた後に `makers switch` を実行する。

## 設定の配置

ツールの設定と Agent Skills は、nix（home-manager と agent-skills-nix）で宣言管理する。
配置するものは `nix/home.nix` に列挙してあり、次のコマンドで `~/` に反映する。

```sh
makers switch
```

`makers switch` は、実行した worktree を設定の参照先にする。
設定ファイルは worktree の実ファイルを指す symlink になるので、編集は `switch` なしで反映される。
`nix/home.nix` を変えたときだけ、`switch` し直す。

`~/` は1つしかないので、別の worktree で `switch` すると、参照先がその worktree に切り替わる。
その worktree に無い項目は、`~/` から消える。

既存のファイルと衝突して `switch` が拒否されたときは、`makers switch -b bak` のように退避用の拡張子を付けて再実行する。
`-b` が退避するのは実ファイルだけで、既存の symlink は退避しない。
symlink と衝突したときは、その symlink を削除してから再実行する。

## Agent Skills の同期

宛先に nix 管理外のエントリがあると、`agent-skills-nix` が置き換えを拒否する。
拒否されたときだけ、コマンドの前に `AGENT_SKILLS_FORCE=1` を付けて再実行する。

同期は `rsync --delete` で行うため、宣言していないエントリは宛先から消える。
