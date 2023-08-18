local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local lspkind = require('lspkind')
local types = require("cmp.types")
local str = require("cmp.utils.str")

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
