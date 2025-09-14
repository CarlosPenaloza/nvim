-- lua/config/lsp_ts.lua
local caps = require("cmp_nvim_lsp").default_capabilities()

-- Opción A: typescript-tools.nvim (recomendada)
local ok, ts = pcall(require, "typescript-tools")
if ok then
  ts.setup({
    capabilities = caps,
    on_attach = function(_, bufnr)
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
    end,
-- ✅ así SÍ con typescript-tools:
settings = {
  tsserver_plugins = {
    "typescript-lit-html-plugin",
    -- si usas otros: "@styled/typescript-styled-plugin", etc.
  },
  tsserver_path = vim.fn.exepath("tsserver"), -- opcional
}
  })
  return
end

-- Opción B: fallback con lspconfig
local lspconfig = require("lspconfig")
lspconfig.tsserver.setup({
  capabilities = caps,
  init_options = {
    plugins = { { name = "typescript-lit-html-plugin" } },
    hostInfo = "neovim",
  },
})
