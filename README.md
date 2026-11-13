# dotfiles

個人用の dotfiles。
zsh・git・Neovim・Claude Code などの設定ファイルに加えて、CLI ツール・GUI アプリ・システム設定までを nix（nix-darwin と home-manager）で宣言管理し、macOS の環境を再現できるようにする。

## 環境変数ファイルで除外対象を指定する

`EXCLUDED_SKILLS` に除外する skill ID をカンマ区切りで指定する。
同じ外部 source に属する skill をすべて除外した場合、その source は取得されない。
`EXCLUDED_PACKAGES` に除外するパッケージ ID をカンマ区切りで指定する。
`EXCLUDED_CASKS` に除外する cask 名をカンマ区切りで指定する。
`make switch` は `_repo/make-switch.env` があれば読み込む。
設定例:

```sh
# _repo/make-switch.env
if [ -z "${EXCLUDED_SKILLS+x}" ]; then
  export EXCLUDED_SKILLS='harness-creator'
fi
if [ -z "${EXCLUDED_PACKAGES+x}" ]; then
  export EXCLUDED_PACKAGES='backlog-md'
fi
if [ -z "${EXCLUDED_CASKS+x}" ]; then
  export EXCLUDED_CASKS='google-chrome'
fi
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
