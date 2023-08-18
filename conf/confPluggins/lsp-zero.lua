local lsp = require("lsp-zero")
local mason = require("mason")

-- format
lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({ buffer = bufnr })
  local opts = { buffer = bufnr }
  vim.keymap.set({ 'n', 'x' }, 'gq', function()
    vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
  end, opts)
end)

lsp.preset({
  name = 'recommended',
  set_lsp_keymaps = true,
  call_servers = 'local',
  manage_nvim_cmp = {
    set_sources = 'recommended',
    set_basic_mappings = true,
    set_extra_mappings = false,
    use_luasnip = true,
    set_format = true,
    documentation_window = true,
  },
  suggest_lsp_servers = true,
  setup_servers_on_start = true,
  float_border = 'none',
  configure_diagnostics = true,
})

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

vim.diagnostic.config({
  virtual_text = true,
})

lsp.ensure_installed({
  'bashls',
  'cssmodules_ls',
  'cssls',
  'cucumber_language_server',
  'custom_elements_ls',
  'emmet_ls',
  'eslint',
  'html',
  'jsonls',
  'lua_ls',
  'marksman',
  'quick_lint_js',
  'rust_analyzer',
  'tsserver',
  'vimls',
  -- 'vtsls'
})

mason.setup()

-- Fix Undefined global 'vim'
lsp.configure("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

lsp.setup()
