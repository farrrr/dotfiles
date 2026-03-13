-- 針對 Markdown 檔案關閉拼字檢查與診斷訊息
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("disable_md_spell_diag", { clear = true }),
  pattern = { "markdown" },
  callback = function(args)
    vim.opt_local.spell = false
    vim.diagnostic.enable(false, { bufnr = args.buf })
  end,
})
