local configs = require("plugins.configs.lspconfig")
local on_attach = configs.on_attach
local capabilities = configs.capabilities

local lspconfig = require "lspconfig"
local servers = {
  "ansiblels",
  "bashls",
  "denols",
  "docker_compose_language_service",
  "dockerls",
  "emmet-ls",
  "eslint",
  "graphql",
  "html",
  "java_language_server",
  "jsonls",
  "lua_ls",
  "phpactor",
  "postgres_lsp",
  "powershell_es",
  "psalm",
  "stylelint_lsp",
  "tsserver",
  "vimls",
  "volar",
  "vuels",
  "yamlls",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

--
-- lspconfig.pyright.setup { blahblah }