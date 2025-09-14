return {
  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim",                  config = true },
  { "williamboman/mason-lspconfig.nvim" },

  -- TypeScript + plugins extra (incluido lit-html global)
  { "pmizio/typescript-tools.nvim",             dependencies = { "nvim-lua/plenary.nvim" } },

  -- Autocompletado
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },

  -- Snippets + iconos
  { "onsails/lspkind.nvim" },

  -- Formateo
  { "stevearc/conform.nvim" },

  -- Plugins LSP
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
}
