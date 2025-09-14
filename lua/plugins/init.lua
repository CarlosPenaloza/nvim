return {
  -- ── Temas ───────────────────────────────
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, lazy = true },
  { "morhetz/gruvbox", priority = 1000, lazy = true },

  -- ── Iconos ──────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Explorador (Oil) ────────────────────
  {
    "stevearc/oil.nvim",
    lazy = false,                  -- carga al inicio
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
      { "<leader>e", "<cmd>Oil<cr>", desc = "Oil" },
    },
  },
  { "refractalize/oil-git-status.nvim", lazy = true },

  -- ── Navegación tmux ─────────────────────
  { "christoomey/vim-tmux-navigator", event = "VeryLazy" },

  -- ── mini.nvim ───────────────────────────
  { "echasnovski/mini.nvim", version = false, event = "VeryLazy" },

  -- ── Git ─────────────────────────────────
  { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" } },

  -- ── Treesitter ──────────────────────────
  { "nvim-treesitter/nvim-treesitter", event = { "BufReadPre", "BufNewFile" }, build = ":TSUpdate" },
  { "HiPhish/rainbow-delimiters.nvim", event = "VeryLazy" },

  -- ── lspkind (CoC) ───────────────────────
  { "onsails/lspkind.nvim", event = "VeryLazy" },

  -- ── Barras ──────────────────────────────
  { "akinsho/bufferline.nvim", event = "VeryLazy", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim", event = "VeryLazy" },

  -- ── Autocompletado (CoC) ─────────────────
  { "neoclide/coc.nvim", branch = "release", event = "VimEnter" },

  -- ── Telescope ───────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
}
