-- lua/config/lsp.lua
local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

mason.setup()

-- Auto-instalar formatters/linters con Mason
local mti = require("mason-tool-installer")
mti.setup({
  ensure_installed = {
    -- JS/TS
    "prettierd", "prettier", "eslint_d",

    -- Otros que ya usas en conform
    "jq",     -- JSON
    "stylua", -- Lua
    "shfmt",  -- Shell
    "black",  -- Python
    "ruff",   -- Python (para ruff_format)
  },
  auto_update = false,
  run_on_start = true,
})

mason_lspconfig.setup({
  ensure_installed = {
    "eslint",
    "html",
    "cssls",
    "emmet_ls",
    "jsonls",
    "lua_ls",
    "bashls",
    "pyright",
    "marksman",
  },
})

local caps = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = bufnr })
  end

  map("n", "K", vim.lsp.buf.hover)
  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "gy", vim.lsp.buf.type_definition)
  map("n", "]g", vim.diagnostic.goto_next)
  map("n", "[g", vim.diagnostic.goto_prev)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map({ "n", "x" }, "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end)
end

-- Configuración por servidor
lspconfig.eslint.setup({ capabilities = caps, on_attach = on_attach })
lspconfig.html.setup({ capabilities = caps, on_attach = on_attach })
lspconfig.cssls.setup({ capabilities = caps, on_attach = on_attach })
lspconfig.emmet_ls.setup({ capabilities = caps, on_attach = on_attach })
lspconfig.jsonls.setup({ capabilities = caps, on_attach = on_attach })
lspconfig.lua_ls.setup({
  capabilities = caps,
  on_attach = on_attach,
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})
lspconfig.bashls.setup({ capabilities = caps, on_attach = on_attach })
lspconfig.pyright.setup({ capabilities = caps, on_attach = on_attach })
lspconfig.marksman.setup({ capabilities = caps, on_attach = on_attach })

-- Diagnósticos globales
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded" },
  severity_sort = true,
})
