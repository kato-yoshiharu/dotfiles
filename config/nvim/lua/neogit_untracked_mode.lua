-- Untracked files のファイルのパーミッションが 644 以外のとき、「644 -> 755」のように status に出す。
local M = {}

local DEFAULT_PERMISSION = "644"

-- path のパーミッション(0o777 でマスクした値)を 3 桁の 8 進数の文字列で返す。
-- 取得できないとき(ディレクトリ・symlink・消えたファイル)は nil
local function permission(path)
  local stat = vim.uv.fs_lstat(path)
  if not stat or stat.type ~= "file" then
    return nil
  end
  return ("%03o"):format(bit.band(stat.mode, tonumber("777", 8)))
end

function M.setup()
  local ui = require("neogit.buffers.status.ui")
  local original_status = ui.Status

  ui.Status = function(state, ...)
    for _, item in ipairs(state.untracked.items or {}) do
      local perm = item.absolute_path and permission(item.absolute_path)
      if perm then
        item.file_mode = { head = DEFAULT_PERMISSION, index = perm, worktree = perm }
      end
    end
    return original_status(state, ...)
  end
end

return M
