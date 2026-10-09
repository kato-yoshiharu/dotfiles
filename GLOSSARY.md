# dotfiles

個人の設定ファイルを管理するリポジトリ。
設定ファイルは home-manager でホームディレクトリに配置する。

**配置**:
設定ファイルをホームディレクトリ下の所定の場所に置くこと。

**ストア経由配置**:
設定ファイルを Nix ストアにコピーし、ホームからストアへ symlink を張る配置。
編集内容は `switch` するまで反映されない。

**ストア外配置**:
ホームから、`makers switch` を実行した worktree 内のファイルへ直接 symlink を張る配置。
編集は `switch` なしで反映される。
_Avoid_: out-of-store symlink

**メイン worktree**:
dotfiles リポジトリのクローン本体（`~/development/suimenkathemove/dotfiles`）。
通常はここで `makers switch` し、ストア外配置の参照先にする。
