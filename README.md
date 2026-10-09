# dotfiles

## Setup

```sh
cargo install --force cargo-make
makers init
```

### Agent Skills

Agent Skills は nix（home-manager と agent-skills-nix）で宣言管理する。
`makers init` の後に、次のコマンドで `~/.claude/skills` と `~/.agents/skills` へ同期する。
初回は flakes が無効なので、環境変数で有効にする。
`--extra-experimental-features` は home-manager 内部の nix に引き継がれないので、`NIX_CONFIG` で指定する。

```sh
NIX_CONFIG='experimental-features = nix-command flakes' nix run home-manager -- switch --flake .#katouyoshiharu
```

初回の `switch` で `~/.config/nix/nix.conf` が置かれるため、2回目以降は次のコマンドでよい。

```sh
nix run home-manager -- switch --flake .#katouyoshiharu
```

宛先に nix 管理外のエントリがあると、`agent-skills-nix` が置き換えを拒否する。
拒否されたときだけ、コマンドの前に `AGENT_SKILLS_FORCE=1` を付けて再実行する。

同期は `rsync --delete` で行うため、宣言していないエントリは宛先から消える。
