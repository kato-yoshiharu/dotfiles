vim.api.nvim_create_user_command("Cc", function()
  vim.system({ "git", "cc" }, { cwd = vim.fn.getcwd(), text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 then
        vim.notify("git cc: commit && push しました")
      else
        vim.notify("git cc 失敗:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end, { desc = "git cc を実行" })

vim.api.nvim_create_user_command("Cfa", function()
  vim.system({ "git", "cfa" }, { cwd = vim.fn.getcwd(), text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 then
        vim.notify("git cfa: 実行しました")
      else
        vim.notify("git cfa 失敗:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end, { desc = "git cfa を実行" })

vim.api.nvim_create_user_command("Ptb", function()
  vim.system({ "git", "ptb" }, { cwd = vim.fn.getcwd(), text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 then
        vim.notify("git ptb: 実行しました")
      else
        vim.notify("git ptb 失敗:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end, { desc = "git ptb を実行" })

vim.api.nvim_create_user_command("Cfr", function()
  vim.system({ "git", "cfr" }, { cwd = vim.fn.getcwd(), text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 then
        vim.notify("git cfr: 実行しました")
      else
        vim.notify("git cfr 失敗:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end, { desc = "git cfr を実行" })
