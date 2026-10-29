return {
  "jghauser/follow-md-links.nvim",
  ft = "markdown",
  config = function()
    -- ftplugin が normal の <CR> をバッファローカルに割り当てる。
    -- autolist の <CR>（チェックボックスの切り替え）を潰すので外し、リンクは gf で辿る。
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(args)
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(args.buf) then
            return
          end
          pcall(vim.keymap.del, "n", "<CR>", { buffer = args.buf })
          vim.keymap.set("n", "gf", function()
            require("follow-md-links").follow_link()
          end, { buffer = args.buf, desc = "Markdown のリンクを辿る" })
        end)
      end,
    })
  end,
}
