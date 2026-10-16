-- neogit の status は rename を無着色の「旧名 -> 新名」で出すため、再描画のたびに差分を計算して色を付ける。
-- 差分は2段階で求める。
-- 1. パスを / で区切ったセグメント(ディレクトリ名・ファイル名)を1行ずつ並べて、セグメント単位で diff する。
-- 2. セグメントが変更されたものについては、そのセグメントの中を文字単位でさらに diff する。
-- diff は Neovim 組み込みの vim.diff(xdiff)を使うため、セグメントが途中で増減しても、増減したセグメントだけに色が付く。
-- 旧名側は NeogitRenameOld(削除色)、新名側は NeogitRenameNew(追加色)
local M = {}

-- text を分けた要素ごとの { 開始, 終了, 文字列 }(開始・終了は line 内の 0 始まりのバイト位置)を返す。
-- base は text の先頭のバイト位置
local function split_items(text, base, sep)
  local items = {}
  local from = base
  if sep then
    -- 1. 区切り文字 sep で分ける(セグメント単位)
    for part in (text .. sep):gmatch("([^" .. sep .. "]*)" .. sep) do
      table.insert(items, { from, from + #part, part })
      from = from + #part + #sep
    end
  else
    -- 2. 1文字ずつに分ける(文字単位)
    for _, c in ipairs(vim.fn.split(text, [[\zs]])) do
      table.insert(items, { from, from + #c, c })
      from = from + #c
    end
  end
  return items
end

-- 2つの要素の列を diff して、変更範囲(vim.diff の indices 形式)を返す
local function diff_items(a, b)
  local function join(items)
    local texts = {}
    for _, item in ipairs(items) do
      table.insert(texts, item[3])
    end
    return table.concat(texts, "\n") .. "\n"
  end
  return vim.diff(join(a), join(b), { result_type = "indices" })
end

-- items の start から count 個分のバイト範囲を ranges に足す
local function add_range(ranges, items, start, count)
  if count > 0 then
    table.insert(ranges, { items[start][1], items[start + count - 1][2] })
  end
end

-- 旧名と新名の、色を付けるバイト範囲を { 旧名側, 新名側 } で返す
local function rename_ranges(old_name, new_name)
  local old_segments = split_items(old_name, 0, "/")
  local new_segments = split_items(new_name, 0, "/")
  local old_ranges, new_ranges = {}, {}
  for _, h in ipairs(diff_items(old_segments, new_segments)) do
    local old_start, old_count, new_start, new_count = h[1], h[2], h[3], h[4]
    if old_count == new_count and old_count > 0 then
      -- セグメントが同数ずつ変わっているときは、対応するセグメント同士を文字単位で diff する
      for k = 0, old_count - 1 do
        local o, n = old_segments[old_start + k], new_segments[new_start + k]
        local old_chars = split_items(o[3], o[1])
        local new_chars = split_items(n[3], n[1])
        for _, c in ipairs(diff_items(old_chars, new_chars)) do
          add_range(old_ranges, old_chars, c[1], c[2])
          add_range(new_ranges, new_chars, c[3], c[4])
        end
      end
    else
      add_range(old_ranges, old_segments, old_start, old_count)
      add_range(new_ranges, new_segments, new_start, new_count)
    end
  end
  return old_ranges, new_ranges
end

M.rename_ranges = rename_ranges

function M.setup()
  local Ui = require("neogit.lib.ui")
  local original_update = Ui.update
  local ns = vim.api.nvim_create_namespace("neogit-rename-diff")

  vim.api.nvim_set_hl(0, "NeogitRenameOld", { link = "DiffDelete", default = true })
  vim.api.nvim_set_hl(0, "NeogitRenameNew", { link = "DiffAdd", default = true })

  local function mark(buf, row, col, ranges, group)
    for _, r in ipairs(ranges) do
      vim.api.nvim_buf_set_extmark(buf, ns, row, col + r[1], {
        end_col = col + r[2],
        hl_group = group,
        priority = 200,
      })
    end
  end

  local function highlight_renames(ui)
    local buf = ui.buf.handle
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for _, section in ipairs(ui.item_index or {}) do
      for _, item in ipairs(section.items or {}) do
        if item.original_name and item.first then
          local row = item.first - 1
          local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
          local pair = item.original_name .. " -> " .. item.name
          local col = line:find(pair, 1, true)
          if col then
            local old_ranges, new_ranges = rename_ranges(item.original_name, item.name)
            mark(buf, row, col - 1, old_ranges, "NeogitRenameOld")
            mark(buf, row, col - 1 + #item.original_name + #" -> ", new_ranges, "NeogitRenameNew")
          end
        end
      end
    end
  end

  function Ui:update(...)
    local result = original_update(self, ...)
    if self.buf and self.item_index then
      highlight_renames(self)
    end
    return result
  end
end

return M
