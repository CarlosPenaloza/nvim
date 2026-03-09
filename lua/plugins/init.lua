return {
  -- ── Temas ───────────────────────────────
  { "catppuccin/nvim",             name = "catppuccin", priority = 0, lazy = true },
  { "morhetz/gruvbox",             priority = 1000,     lazy = false },

  -- ── Iconos ──────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Explorador (Oil) ────────────────────
  {
    "stevearc/oil.nvim",
    lazy = false, -- carga al inicio
    priority = 100,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "refractalize/oil-git-status.nvim",
    },
    config = function()
      pcall(require, "config.oil") -- ⬅️ aquí delegamos tu configuración modular
    end,
    keys = {
      { "-", "<cmd>Oil --float<cr>", desc = "Oil (float)" },
    },
  },
  { "refractalize/oil-git-status.nvim", lazy = true },

  -- ── Navegación tmux ─────────────────────
  { "christoomey/vim-tmux-navigator",   event = "VeryLazy" },

  -- ── mini.nvim ───────────────────────────
  { "echasnovski/mini.nvim",            version = false,                       event = "VeryLazy" },

  -- ── Git ─────────────────────────────────
  { "lewis6991/gitsigns.nvim",          event = { "BufReadPre", "BufNewFile" } },

  -- ── Treesitter ──────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    version = "*", -- 👈 mejor usar la última release estable
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- ── Barras ──────────────────────────────
  { "akinsho/bufferline.nvim",   event = "VeryLazy", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim", event = "VeryLazy" },

  -- ── Telescope ───────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim
          .fn.executable("make") == 1
    end
  },

  -- ── Utilidad ───────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("config.which-key")
    end,
  },

  -- 2) trouble (solo declaración, config en config/diagnostics.lua)
  {
    "folke/trouble.nvim",
    branch = "main",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" }, -- lazy por comando
  },

  -- 3) todo-comments
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("config.todo-comments") -- 👈 todo aquí (opts + keymaps)
    end,
  },

  -- LSP
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason.nvim",
    config = true,
    event = "VeryLazy"
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy"
  },

  -- TypeScript + plugins extra (incluido lit-html global)
  { "pmizio/typescript-tools.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

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
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy"
  },

  -- Conversion Mayusculas, Snake Case, Kebbab Case
  {
    "gregorias/coop.nvim",
  },
  {
    "gregorias/coerce.nvim",
    tag = 'v4.1.0',
    config = true,
  },

  -- Fold
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async"
    }
  }
}
