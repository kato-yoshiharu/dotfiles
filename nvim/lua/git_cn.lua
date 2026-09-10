-- 選択行だけをステージして `git cn`（commit -m "confirmed" && push）するための共通処理
local M = {}

local function git(cwd, args)
  return vim.system(vim.list_extend({ "git" }, args), { cwd = cwd, text = true }):wait()
end

-- 既にステージ済みの変更があると、意図しない差分まで commit されるので中断する
function M.index_is_clean(cwd)
  local out = git(cwd, { "diff", "--cached", "--quiet" })
  if out.code == 0 then
    return true
  end
  vim.notify("git cn: ステージ済みの変更があります。", vim.log.levels.ERROR)
  return false
end

-- ステージ処理は非同期なので、index に載るのを待ってから commit する
function M.commit(cwd)
  -- 呼び出し元の stage（fugitive の s）は非同期で、
  -- 呼び出しが返った時点では index に反映されていない。
  -- 完了通知を受け取る手段がないため、ステージ済み変更が現れるまでポーリングで待つ。
  local tries = 0
  local function run()
    if git(cwd, { "diff", "--cached", "--quiet" }).code == 0 then
      tries = tries + 1
      -- 100ms x 20 = 約2秒。hunk の stage は通常数十msで終わるため、
      -- これを超えるのは stage 失敗か対象なしとみなして打ち切る
      if tries > 20 then
        vim.notify("git cn: ステージされた変更がありません", vim.log.levels.WARN)
        return
      end
      vim.defer_fn(run, 100)
      return
    end
    vim.system({ "git", "cn" }, { cwd = cwd, text = true }, function(out)
      vim.schedule(function()
        if out.code == 0 then
          vim.notify("git cn: commit && push しました")
        else
          vim.notify("git cn 失敗:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
        end
      end)
    end)
  end
  run()
end

return M
