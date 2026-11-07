# dotfiles

個人用の dotfiles。
zsh・git・Neovim・Claude Code などの設定ファイルに加えて、CLI ツール・GUI アプリ・システム設定までを nix（nix-darwin と home-manager）で宣言管理し、macOS の環境を再現できるようにする。

## 環境変数で skill を除外して適用する

`EXCLUDED_SKILLS` に除外する skill ID をカンマ区切りで指定する。
同じ外部 source に属する skill をすべて除外した場合、その source は取得されない。

```sh
EXCLUDED_SKILLS=eval-harness,agent-eval,agentic-engineering,harness-creator \
  make switch
```

## 外部 skill の source を更新する

外部 skill の source は `npins/sources.json` で rev と hash を固定している。
更新は次のコマンドで行う。

```sh
nix run nixpkgs#npins -- update
```

source を追加するときは、pin 名を `nix/skills.nix` の `input` に合わせる。

```sh
nix run nixpkgs#npins -- add github <owner> <repo> --name skills-<name> -b main
```
