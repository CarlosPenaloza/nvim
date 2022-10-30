use {
  'nvim-treesitter/nvim-treesitter',
  run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "comment",
    "css",
    "dockerfile",
    "gitignore",
    "hjson",
    "html",
    "http",
    "javascript",
    "json",
    "json5",
    "lua",
    "markdown",
    "markdown_inline",
    "php",
    "python",
    "regex",
    "scss",
    "sql",
    "slint",
    "tsx",
    "typescript",
    "vim",
    "vue"
  },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = false,
    disable = {""},
    additional_vim_regex_highlighting = false,
  },
}
