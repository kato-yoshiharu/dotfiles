local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- カラースキーム（wezterm 組み込み）
-- <https://draculatheme.com/wezterm>
config.color_scheme = "Dracula (Official)"

-- Dracula 推奨のタブバー設定
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"

config.keys = {
  -- CMD+Enter を ALT+Enter として送る。受け手（Claude Code）は meta+enter として解釈する。
  {
    key = "Enter",
    mods = "CMD",
    action = wezterm.action.SendKey({ key = "Enter", mods = "ALT" }),
  },
}

return config
