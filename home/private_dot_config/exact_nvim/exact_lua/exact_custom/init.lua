-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizeing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- for neovim options
require "custom.core.options"
-- for neovim autocommands. Read `:h lua-guide-autocommand-create`
require "custom.core.autocommands"
-- for personal functions and commands
require "custom.core.utilities"
-- for additional filetypes
require "custom.core.filetypes"