-- lua/plugins/ui-productivity.lua
return {
  -- 1) which-key: guía de atajos
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = { enabled = false } }, -- pon true si usas :set spell
      win = { border = "rounded" },
      show_help = true,
      show_keys = true,
    },
  },

  -- 2) trouble: panel de diagnósticos/refs/quickfix
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" }, -- v2: TroubleToggle; v3: Trouble (nuevo subcomando)
    opts = {
      use_diagnostic_signs = true, -- usa signos de lsp/coc si existen
    },
  },

  -- 3) todo-comments: resalta y lista TODO/FIXME/NOTE
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        TODO  = { icon = "", color = "info" },
        FIX   = { icon = "", color = "error", alt = { "FIXME", "BUG" } },
        HACK  = { icon = "", color = "warning" },
        NOTE  = { icon = "", color = "hint", alt = { "INFO" } },
      },
      highlight = { multiline = false },
      search = { command = "rg", args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" } },
    },
  },
}
