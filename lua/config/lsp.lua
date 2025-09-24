-- =============================
--  lua/config/lsp.lua (V3)
-- =============================
-- Requiere Neovim >= 0.11 y nvim-lspconfig reciente.
-- Migra del viejo `require('lspconfig')[srv].setup{}` a `vim.lsp.config()` + `vim.lsp.enable()`.

-- Protege requerimientos opcionales
local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')

-- 1) Ajustes DIAGNîSTICOS globales
vim.diagnostic.config({
  underline = true,
  virtual_text = { spacing = 2, prefix = '?' },
  signs = true,
  severity_sort = true,
  update_in_insert = false,
})

-- 2) Signos (puedes ajustar a tu paleta)
local signs = { Error = '?', Warn = '?', Hint = '?', Info = '?' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

-- 3) Capacidades por defecto para TODOS los servidores
local default_caps = ok_cmp and cmp_lsp.default_capabilities() or {}
vim.lsp.config('*', {
  capabilities = default_caps,
  inlay_hints = { enabled = true }, -- campo usado por algunos wrappers; real enable abajo en LspAttach
})

-- 4) Keymaps y extras v’a LspAttach (recomendado en v3)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach-keymaps', { clear = true }),
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Inlay hints nativas (Nvim >= 0.10)
    pcall(vim.lsp.inlay_hint.enable, buf, true)

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end

    map('n', 'gd', vim.lsp.buf.definition, 'LSP: Go to definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'LSP: Go to declaration')
    map('n', 'gi', vim.lsp.buf.implementation, 'LSP: Go to implementation')
    map('n', 'gr', vim.lsp.buf.references, 'LSP: References')
    map('n', 'K', vim.lsp.buf.hover, 'LSP: Hover')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'LSP: Rename symbol')
    map('n', '<leader>ca', vim.lsp.buf.code_action, 'LSP: Code action')
    map('n', '<leader>f', function()
      vim.lsp.buf.format({ async = false })
    end, 'LSP: Format')
    map('n', '[d', vim.diagnostic.goto_prev, 'LSP: Prev diagnostic')
    map('n', ']d', vim.diagnostic.goto_next, 'LSP: Next diagnostic')

    -- Desactiva formateo si prefieres un formateador externo
    -- if client and client.name ~= 'lua_ls' then
    --   client.server_capabilities.documentFormattingProvider = false
    --   client.server_capabilities.documentRangeFormattingProvider = false
    -- end
  end,
})

-- 5) Servidores BASE (edita a tu gusto)
-- Nota: `vim.lsp.config()` combina tu config con la de nvim-lspconfig si existe.

-- Lua
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

-- JSON
vim.lsp.config('jsonls', {})

-- CSS
vim.lsp.config('cssls', {})

-- HTML
vim.lsp.config('html', {})

-- Bash
vim.lsp.config('bashls', {})

-- (Opcional) Pyright
vim.lsp.config('pyright', {})

-- 6) Activaci—n autom‡tica segœn filetypes y root_dir
vim.lsp.enable({ 'lua_ls', 'jsonls', 'cssls', 'html', 'bashls', 'pyright' })
