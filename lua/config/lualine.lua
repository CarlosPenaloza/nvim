-- lua/config/lualine.lua

require("lualine").setup({
  options = {
    theme = "gruvbox",
    globalstatus = true,

    -- Powerline look
    component_separators = { left = "│", right = "│" },
    section_separators = { left = "", right = "" },

    disabled_filetypes = {
      statusline = { "alpha", "dashboard" },
    },
  },

  sections = {
    -- 🟢 MODO
    lualine_a = {
      { "mode", separator = { left = "" }, right_padding = 2 },
    },

    -- 🌿 RAMA (truncado inteligente)
    lualine_b = {
      -- {
      --   "branch",
      --   icon = "",
      --   fmt = function(branch)
      --     local parts = vim.split(branch, "/")
      --     if #parts > 2 then
      --       return parts[1] .. "/…/" .. parts[#parts]
      --     end
      --     if #branch > 25 then
      --       return branch:sub(1, 25) .. "…"
      --     end
      --     return branch
      --   end,
      -- },
    },

    -- 📄 ARCHIVO
    lualine_c = {
      {
        "filename",
        path = 1,
        symbols = {
          modified = " ●",
          readonly = " ",
          unnamed = "[No Name]",
        },
      },
    },

    -- ⚙️ LSP + ⚠️ DIAGNÓSTICOS + 📄 FILETYPE
    lualine_x = {
      -- LSP STATUS
      {
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if not clients or #clients == 0 then
            return "No LSP"
          end
          return "LSP"
        end,
        icon = "",
      },

      -- DIAGNÓSTICOS (con íconos)
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = {
          error = " ",
          warn  = " ",
          info  = " ",
          hint  = " ",
        },
      },

      -- FILETYPE (solo icono)
      {
        "filetype",
        icon_only = true,
      },
    },

    lualine_y = {
      { "progress" },
    },

    -- 📍 POSICIÓN
    lualine_z = {
      { "location", separator = { right = "" }, left_padding = 2 },
    },
  },

  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },

  -- 🪟 WINBAR → rama completa (sin truncar)
  winbar = {
    lualine_c = {
      {
        "branch",
        icon = "",
        cond = function()
          return vim.bo.buftype == ""
        end,
      },
    },
  },

  inactive_winbar = {
    lualine_c = {
      {
        "branch",
        icon = "",
        cond = function()
          return vim.bo.buftype == ""
        end,
      },
    },
  },
})

vim.o.winbar = "%{%v:lua.require'lualine'.statusline()%}"
