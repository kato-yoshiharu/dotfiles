local rename_ranges = require("neogit_rename_diff").rename_ranges

-- ranges の各範囲(0 始まりのバイト位置)を text から切り出した文字列の列にする
local function slices(text, ranges)
  local result = {}
  for _, r in ipairs(ranges) do
    table.insert(result, text:sub(r[1] + 1, r[2]))
  end
  return result
end

local cases = {
  {
    name = "同じ名前なら、どちら側も塗られない",
    old = "foo/bar.md",
    new = "foo/bar.md",
    old_painted = {},
    new_painted = {},
  },
  {
    name = "セグメントの中で文字が増えたとき、新名側だけが塗られる",
    old = "foo/bar/baz.md",
    new = "foo/barr/baz.md",
    old_painted = {},
    new_painted = { "r" },
  },
  {
    name = "セグメントの中で文字が減ったとき、旧名側だけが塗られる",
    old = "foo/barr/baz.md",
    new = "foo/bar/baz.md",
    old_painted = { "r" },
    new_painted = {},
  },
  {
    name = "セグメントが増えたとき、増えたセグメントだけが新名側で塗られる",
    old = "foo/baz.md",
    new = "foo/bar/baz.md",
    old_painted = {},
    new_painted = { "bar" },
  },
  {
    name = "セグメントが減ったとき、減ったセグメントだけが旧名側で塗られる",
    old = "foo/bar/baz.md",
    new = "foo/baz.md",
    old_painted = { "bar" },
    new_painted = {},
  },
  {
    name = "セグメントが別のものに変わったとき、そのセグメントが塗られる",
    old = "foo/baz.md",
    new = "bar/baz.md",
    old_painted = { "foo" },
    new_painted = { "bar" },
  },
  {
    name = "セグメントが別のセグメントに置き換わって増えたとき、置き換わったセグメントが塗られる",
    old = "foo/baz.md",
    new = "bar/bar/baz.md",
    old_painted = { "foo" },
    new_painted = { "bar/bar" },
  },
  {
    name = "セグメントが別のセグメントに置き換わって減ったとき、置き換わったセグメントが塗られる",
    old = "bar/bar/baz.md",
    new = "foo/baz.md",
    old_painted = { "bar/bar" },
    new_painted = { "foo" },
  },
  {
    name = "変更が複数箇所にあっても、2つ目以降の範囲の位置がずれない",
    old = "foo/bar/baz.md",
    new = "fooo/bar/baz.txt",
    old_painted = { "md" },
    new_painted = { "o", "txt" },
  },
  {
    name = "マルチバイト文字でも、範囲がバイト位置でずれない",
    old = "foo/あい.md",
    new = "foo/あう.md",
    old_painted = { "い" },
    new_painted = { "う" },
  },
}

describe("rename_ranges", function()
  for _, c in ipairs(cases) do
    it(c.name, function()
      local old_ranges, new_ranges = rename_ranges(c.old, c.new)
      assert.are.same(c.old_painted, slices(c.old, old_ranges))
      assert.are.same(c.new_painted, slices(c.new, new_ranges))
    end)
  end
end)
