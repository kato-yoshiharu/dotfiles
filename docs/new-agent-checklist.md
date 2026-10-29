# 新しい coding agent の導入チェックリスト

新しい coding agent を入れるときに、設定を揃える項目。
各項目は、公式ドキュメントを実際に検索して、対応の有無を確認してから書く。
対応していない機能は無理に移植せず、「移植しなかった項目」に記録する。

## 設定ファイルの書き換え主体を先に確認する

実ファイルを agent 本体や Orca が書き換えるなら、symlink にせずベースを置く。

確認すること:

- 実ファイルを agent 本体が書き換えるか（認証情報、キャッシュ、trust 状態など）
- Orca が hooks を直接書き込むか

書き換えられるときの対応:

- `config/<agent>/` にベースを置き、`config/scripts/build-agent-configs.sh` に反映処理を足す
- 反映処理は、hooks が主なら `build`、設定ファイル全体なら `build_cursor` の方式に合わせる
- 手動同期にする場合は AGENTS.md に理由と運用を書く

## 禁止コマンドを deny に入れる

Claude の `permissions.deny` と Codex の `rules/destructive.rules` に合わせて、禁止コマンドを入れる。

## git 書き込みを止める hook を入れる

`block-git-write.sh` を呼ぶ hook を入れる。

## 共通 AGENTS.md を置く

`config/coding-agents/AGENTS.md` を、その agent のグローバル指示の置き場所に置く。

置き場所がないときの対応:

- Cursor CLI は、次のファイルを読まない（実機で確認した）。
  - `~/.cursor/AGENTS.md`
  - `~/.claude/AGENTS.md`
  - `~/.codex/AGENTS.md`
  - `~/.cursor/rules`
- アプリの User Rules は、ファイルではなくアカウントに紐づく
- 代わりに `sessionStart` hook の `additional_context` で注入する。
  `config/coding-agents/hooks/cursor-session-start.sh` が `~/.claude/AGENTS.md` を返す
- 注入の確認は、`~` の外のディレクトリで `cursor-agent -p` を実行し、AGENTS.md の内容を質問して行う

## スキルの読み込み先を確認する

- 読み込み先のディレクトリ。`~/.agents/skills` と `~/.claude/skills` を読む agent は、追加の設定がいらない
- 読まないなら、`nix/home.nix` の `skills.targets` に足す

### skill がファイルではなくアプリ内に保存される agent

Grok Bot は、skill を `~/.grok/skills` のようなパスではなく、アプリ内（クラウド側）の Private skills ライブラリに保存する。

運用のルール:

- skill の原本は `config/grok-bot/skills/<name>/SKILL.md` に置く。nix や Makefile では配備しない
- Auto-review のカスタムルールの正本は `config/grok-bot/auto-review-rules.md` に置く
- ルールの同期手順は `config/grok-bot/skills/sync-auto-review-rules-from-dotfiles/SKILL.md` に書く
- Grok Bot へは、チャットで SKILL.md の本文を渡し、「この内容を skill として保存して」と依頼して取り込む。
  公式 docs に、ファイルの import や upload の手段はない
- 原本を直したら、アプリ内の skill も手動で更新する

## 見た目と操作の設定を入れる

任意の項目。対応する設定があるときだけ入れる。

- vim モード
- ステータスライン
- 通知
- コミットと PR への attribution の無効化

## 移植しなかった項目

### Cursor CLI

- ステータスラインの内容: `display.showStatusLineRunningTime` で経過時間を出すだけで、Claude のようにコマンドで内容を作る設定はない
- 推論の強さ、環境変数: 対応する設定がドキュメントにない
