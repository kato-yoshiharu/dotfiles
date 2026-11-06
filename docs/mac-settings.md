# macOS の設定

設定の意図は、このファイルに書く。
設定を書き込むコマンドは、`setup/setup.sh` に置く。コマンドは、動作確認したものだけを置く。
`defaults write` は存在しないキーでも成功するため、書けたことは効いていることの証拠にならない。
効いているかは、macOS 更新後に「更新後に意図が効いているかを確認する」の手順で確かめる。

## 設定と意図

カーソルとキーボード:

- トラックパッドのカーソルを速く動かす
  - キー: `-g com.apple.trackpad.scaling`
  - 値: 3
  - 反映に必要な操作: ログアウトか再起動
- 連打の間隔を短くする
  - キー: `-g KeyRepeat`
  - 値: 2
  - 反映に必要な操作: ログアウトか再起動
- 押してから連打が始まるまでを短くする
  - キー: `-g InitialKeyRepeat`
  - 値: 15
  - 反映に必要な操作: ログアウトか再起動
- 長押しでアクセント選択を出さず、キーリピートさせる
  - キー: `-g ApplePressAndHoldEnabled`
  - 値: false
  - 反映に必要な操作: アプリの再起動
- 3 本指で上にスワイプしたら Mission Control を開く
  - キー: `com.apple.AppleMultitouchTrackpad` と `com.apple.driver.AppleBluetoothMultitouch.trackpad` の `TrackpadThreeFingerVertSwipeGesture`
  - 値: 2
  - 反映に必要な操作: ログアウトか再起動

Dock:

- 使わないときは隠す
  - キー: `com.apple.dock autohide`
  - 値: true
  - 反映に必要な操作: `killall Dock`
- アイコンの大きさを 64 にする
  - キー: `com.apple.dock tilesize`
  - 値: 64
  - 反映に必要な操作: `killall Dock`

Finder:

- 下部にステータスバーを出す
  - キー: `com.apple.finder ShowStatusBar`
  - 値: true
  - 反映に必要な操作: `killall Finder`
- 既定の表示をリストにする
  - キー: `com.apple.finder FXPreferredViewStyle`
  - 値: `Nlsv`
  - 反映に必要な操作: `killall Finder`

アラート:

- エラー音が鳴るとき、画面も点滅させる
  - キー: `-g com.apple.sound.beep.flash`
  - 値: 1
  - 反映に必要な操作: なし

日本語入力（macOS 標準の入力方法）:

- ライブ変換を使わない
  - キー: `com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey`
  - 値: 0
  - 反映に必要な操作: 入力メソッドの再起動かログアウト
- Windows 風のキー操作を使う
  - キー: `com.apple.inputmethod.Kotoeri JIMPrefWindowsModeKey`
  - 値: 1
  - 反映に必要な操作: 入力メソッドの再起動かログアウト

スクリーンショット:

- 保存先をホーム直下の `~/Screenshots` にする
  - キー: `com.apple.screencapture` の `location`、`location-screenshot`、`location-screenrecording`
  - 値: `~/Screenshots`
  - 反映に必要な操作: `killall SystemUIServer`

外観:

- ダークモードを使う
  - コマンド: `osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'`
  - 値: true
  - 反映に必要な操作: なし

ディスプレイ:

- 無操作でもディスプレイの電源を切らない
  - コマンド: `sudo pmset -a displaysleep 0`
  - 値: 0
  - 反映に必要な操作: なし

## 設定を足すときの手順

キーを推測せず、GUI の変更を `defaults read` の差分で特定する。

手順:

1. `defaults read > before.txt` を取る
2. System Settings などで、設定を 1 つだけ変える
3. `defaults read > after.txt` を取り、`diff before.txt after.txt` で差分を見る
4. 時刻やバッテリー情報などのノイズを除き、変わったキーと値を特定する
5. 動作確認した設定コマンドを `setup/setup.sh` に意図コメント付きで書き、このファイルの「設定と意図」にも書く。`defaults write` を使う場合は `set_default` で書く

## 更新後に意図が効いているかを確認する

`set_default` の読み戻しは、値が書けたことしか保証しない。
意図が効いているかは、設定の画面と実際の挙動で確かめる。

確認の手順:

1. 「設定と意図」の各キーを `defaults read` で読み、値が記載と一致するか確かめる
2. System Settings の対応する画面で、意図どおりの状態になっているか確かめる
3. 実際の挙動で確かめる。例: Dock が自動で隠れる
4. 効いていない設定は、`defaults read` を前後で取る差分の手順で、新しいキーを特定する
5. キーを直したら、`setup/setup.sh` とこのファイルの「設定と意図」を揃えて直す

読み戻しが一致しても、画面や挙動が意図と違えば、キーが廃止されたか名前が変わったと疑う。
