local lsp = require("lsp-zero")
local mason = require("mason")
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local lspkind = require('lspkind')
local types = require("cmp.types")
local str = require("cmp.utils.str")

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end


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

-- cmp.setup
local window = {
  completion = cmp.config.window.bordered(),
  documentation = cmp.config.window.bordered(),
}

local formatting = {
  fields = {
    cmp.ItemField.Kind,
    cmp.ItemField.Abbr,
    cmp.ItemField.Menu,
  },
  format = lspkind.cmp_format({
    with_text = false,
    before = function(entry, vim_item)
      -- Get the full snippet (and only keep first line)
      local word = entry:get_insert_text()
      if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
        word = vim.lsp.util.parse_snippet(word)
      end
      word = str.oneline(word)

      -- concatenates the string
      local max = 50
      if string.len(word) >= max then
        local before = string.sub(word, 1, math.floor((max - 3) / 2))
        word = before .. "..."
      end

      if
          entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet
          and string.sub(vim_item.abbr, -1, -1) == "~"
      then
        word = word .. "~"
      end
      vim_item.abbr = word

      return vim_item
    end,
  }),
}

local mapping = {
  ['<CR>'] = cmp.mapping.confirm({ select = true }),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<Tab>'] = cmp_action.tab_complete(),
  ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
  ['<C-u>'] = cmp.mapping.scroll_docs(-4),
  ['<C-d>'] = cmp.mapping.scroll_docs(4),
  ['<C-f>'] = cmp_action.luasnip_jump_forward(),
  ['<C-b>'] = cmp_action.luasnip_jump_backward(),
}

local snippet = {
  expand = function(args)
    require("luasnip").lsp_expand(args.body)
  end,
}

-- setup
cmp.setup({
  window = window,
  formatting = formatting,
  mapping = mapping,
  snippet = snippet
})

-- servers configuration

