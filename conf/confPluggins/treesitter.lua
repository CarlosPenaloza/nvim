require 'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "comment",
    "css",
    "dockerfile",
    "gitignore",
    "html",
    "http",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "meson",
    "python",
    "regex",
    "scss",
    "tsx",
    "typescript",
    "vim",
  },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  },
  rainbow = {
    enable = true,
    -- list of languages you want to disable the plugin for
    disable = {},
    -- Which query to use for finding delimiters
    query = 'rainbow-parens',
    -- Highlight the entire buffer all at once
    strategy = require('ts-rainbow').strategy.global,
  }
}
