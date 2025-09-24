-- =============================
--  lua/config/lsp_ts.lua (V3)
-- =============================
-- Setup espec’fico para TypeScript/JavaScript usando VTSLS (recomendado) o tsserver cl‡sico.

-- Intenta cargar vtsls (mejor integraci—n/velocidad que tsserver)
local has_vtsls, _ = pcall(require, 'vtsls')
if has_vtsls then
  -- Registrar config por defecto de vtsls si no lo hizo otro plugin
  pcall(function()
    require('lspconfig.configs').vtsls = require('vtsls').lspconfig
  end)

  vim.lsp.config('vtsls', {
    -- filetypes: vtsls ya incluye ts/tsx/js/jsx; agrega vue si lo usas en modo h’brido
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    -- Evita conflicto con Deno (ajusta si usas deno)
    root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },

    settings = {
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
      },
      typescript = {
        updateImportsOnFileMove = { enabled = 'always' },
        suggest = { completeFunctionCalls = true },
        inlayHints = {
          enumMemberValues = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          parameterNames = { enabled = 'literals' },
          parameterTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          variableTypes = { enabled = false },
        },
        preferences = {
          importModuleSpecifier = 'non-relative',
          quoteStyle = 'auto',
        },
        format = { semicolons = 'insert' },
      },
      javascript = {
        inlayHints = {
          enumMemberValues = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          parameterNames = { enabled = 'literals' },
          parameterTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          variableTypes = { enabled = false },
        },
      },
    },
  })

  vim.lsp.enable('vtsls')
else
  -- Fallback: typescript-language-server (tsserver)
  vim.lsp.config('ts_ls', {
    -- Nota: desde nvim-lspconfig recientes el nombre puede ser 'ts_ls' (alias de tsserver)
    root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
    single_file_support = false,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'literals',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        preferences = {
          includeCompletionsForModuleExports = true,
          includeCompletionsWithClassMemberSnippets = true,
          importModuleSpecifierPreference = 'non-relative',
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'literals',
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
        },
      },
    },
  })

  vim.lsp.enable('ts_ls')
end

-- (Opcional) Comandos helper para organizar imports / actualizar imports
vim.api.nvim_create_user_command('LspOrganizeImports', function()
  if vim.lsp.get_clients({ name = 'vtsls' })[1] then
    vim.cmd('VtsExec organize_imports')
  else
    -- tsserver: usa code action est‡ndar
    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
  end
end, { desc = 'Organize imports (vtsls/tsserver)' })
