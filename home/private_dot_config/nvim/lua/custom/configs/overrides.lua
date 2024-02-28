local M = {}

M.treesitter = {
  ensure_installed = {
    -- defaults
    "vim",
    "lua",
    -- web dev
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "graphql",
    "json",
    "jsdoc",
    "json5",
    "scss",
    "tsx",
    "twig",
    "typescript",
    "vue",
    -- shell
    "awk",
    "bash",
    "fish",
    "fsh",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "gpg",
    "http",
    "make",
    -- languages
    "go",
    "java",
    "php",
    "phpdoc",
    "puppet",
    "python",
    "regex",
    "ruby",
    "rust",
    "scala",
    "sql",
    -- others
    "csv",
    "dockerfile",
    "ini",
    "markdown",
    "markdown_inline",
    "ssh_config",
    "toml",
    "yaml"
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- }
  },
}

M.mason = {
  ensure_installed = {
    "ansible-language-server",
    "ansible-lint",
    "awk-language-server",
    "bash-debug-adapter",
    "bash-language-server",
    "beautysh",
    "black",
    "blade-formatter",
    "chrome-debug-adapter",
    "cspell",
    "css-lsp",
    "cssmodules-language-server",
    "deno",
    "docker-compose-language-service",
    "dockerfile-language-server",
    "dot-language-server",
    "editorconfig-checker",
    "emmet-language-server",
    "eslint-lsp",
    "fixjson",
    "gitlint",
    "gitui",
    "go-debug-adapter",
    "graphql-language-service-cli",
    "html-lsp",
    "htmlbeautifier",
    "intelephense",
    "java-debug-adapter",
    "java-language-server",
    "jq",
    "jq-lsp",
    "js-debug-adapter",
    "json-lsp",
    "lua-language-server",
    "luacheck",
    "luaformatter",
    "markdownlint",
    "nginx-language-server",
    "php-cs-fixer",
    "php-debug-adapter",
    "phpactor",
    "phpcbf",
    "phpcs",
    "phpmd",
    "phpstan",
    "pint",
    "powershell-editor-services",
    "prettier",
    "prisma-language-server",
    "psalm",
    "shellcheck",
    "shellharden",
    "shfmt",
    "sqlls",
    "stylelint",
    "stylua",
    "tree-sitter-cli",
    "ts-standard",
    "typescript-language-server",
    "vetur-vls",
    "vim-language-server",
    "vtsls",
    "yaml-language-server",
    "yamlfix",
    "yamlfmt",
    "yamllint",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M