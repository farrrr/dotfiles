-- custom/configs/null-ls.lua

local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions
local completion = null_ls.builtins.completion

local sources = {
  -- formatting
  formatting.prettier,
  formatting.stylua,
  formatting.blade_formatter,
  formatting.deno_fmt,
  formatting.eslint,
  formatting.fixjson,
  formatting.jq,
  formatting.nginx_beautifier,
  formatting.phpcsfixer,
  -- code_actions
  code_actions.refactoring.with({
    filetypes = { "typescript", "javascript", "lua", "go", "python", "java", "php", "ruby" }
  }),
  code_actions.xo,
  -- lint
  lint.shellcheck,
  lint.eslint,
  lint.ansiblelint,
  lint.deno_lint,
  lint.dotenv_linter,
  lint.editorconfig_checker,
  lint.gitlint,
  lint.jshint,
  lint.jsonlint,
  lint.markdownlint,
  lint.phpcs,
  lint.phpmd,
  lint.psalm,
  lint.pylint,
  lint.stylelint,
  lint.tsc,
  lint.xo,
  lint.yamllint,
  lint.zsh,
}

null_ls.setup {
   debug = true,
   sources = sources,
}
