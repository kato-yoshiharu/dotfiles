local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- 設定ファイル変更時に自動リロード
config.automatically_reload_config = true

-- 日本語 IME を有効化
config.use_ime = true

-- 背景透過・ぼかし
config.window_background_opacity = 0.8
config.macos_window_background_blur = 20

-- カラースキーム（wezterm 組み込み）
-- <https://draculatheme.com/wezterm>
config.color_scheme = "Dracula (Official)"

-- Dracula 推奨のタブバー設定
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"

-- フォント
-- 英数字は等幅の Hack Nerd Font Mono
-- 日本語は等幅の Hiragino 丸ゴシック/角ゴシックW3
config.font = wezterm.font_with_fallback({
  "Hack Nerd Font Mono",
  "Hiragino Kaku Gothic ProN",
  "Apple Color Emoji",
})

-- 左 Option を文字合成ではなく ALT として送る。
-- fzf の Alt+C（配下ディレクトリへ移動）などを効かせるために必要。
-- 引き換えに Option+A → å のような合成入力は使えなくなる。
config.send_composed_key_when_left_alt_is_pressed = false

config.keys = {
  -- CMD+Enter を ALT+Enter として送る。受け手（Claude Code）は meta+enter として解釈する。
  {
    key = "Enter",
    mods = "CMD",
    action = wezterm.action.SendKey({ key = "Enter", mods = "ALT" }),
  },
  -- CMD+Z を ALT+Z として送る。受け手（Claude Code）は meta+z として解釈する。
  {
    key = "z",
    mods = "CMD",
    action = wezterm.action.SendKey({ key = "z", mods = "ALT" }),
  },
}

return config
