# Grok Bot の Auto-review ルール

このファイルが正本。
反映は、Grok Bot 側の設定画面か、sync-auto-review-rules-from-dotfiles スキルで行う。

## Ask first

- ローカルマシン上で git のコマンドを実行する前に、`~/repos/github.com/kato-yoshiharu/dotfiles/config/coding-agents/hooks/block-git-write.sh` を実行して確認する。
  実行するコマンドを `{"tool_input":{"command":"<コマンド>"}}` の JSON にして、スクリプトの標準入力に渡す。
  終了コードが 2 のときは、そのコマンドを実行せず、ブロックされたことをユーザーに報告する。

## Allow automatically

- （なし）
