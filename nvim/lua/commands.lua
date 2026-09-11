vim.api.nvim_create_user_command("Cn", function()
  vim.system({ "git", "cn" }, { cwd = vim.fn.getcwd(), text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 then
        vim.notify("git cn: commit && push しました")
      else
        vim.notify("git cn 失敗:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end, { desc = "git cn を実行" })

vim.api.nvim_create_user_command("Ae", function()
  vim.system({ "git", "ae" }, { cwd = vim.fn.getcwd(), text = true }, function(out)
    vim.schedule(function()
      if out.code == 0 then
        vim.notify("git ae: 実行しました")
      else
        vim.notify("git ae 失敗:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end, { desc = "git ae を実行" })
