local lsp = require("lsp-zero")
local mason = require("mason")
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

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
  suggest_lsp_servers = false,
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
  'emmet_ls',
  'eslint',
  'html',
  'jsonls',
  'lua_ls',
  'marksman',
  'quick_lint_js',
  'remark_ls',
  'rust_analyzer',
  'tsserver',
  'vimls',
  'vtsls'
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

cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  },
  formatting = {
    -- changing the order of fields so the icon is the first
    fields = { 'menu', 'abbr', 'kind' },

    -- here is where the change happens
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = 'λ',
        luasnip = '⋗',
        buffer = 'Ω',
        path = '🖫',
        nvim_lua = 'Π',
      }

      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

})
