# zsh 設定の配置方法

zsh の設定は、既存の `.zshrc` と `.zprofile` の中身を変えずに使う。
`programs.zsh` を有効にすると設定を Nix の記述へ書き直すことになるが、
`programs.zsh` の利点である zsh プラグインの宣言管理は、プラグインを使っていないため不要である。
そのため `home.file` で配置する。
