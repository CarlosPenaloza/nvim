-- lua/config/bufferline.lua
-- Bufferline integrado con lualine:
--  - Activo usa fg/bg de lualine_a_<modo>
--  - Inactivo usa lualine_b_normal
--  - Sin diagnósticos (solo ● si hay cambios)
--  - Devicons conservan su color original (solo ajustamos bg)
--  - Reaplica HLs al cambiar colorscheme/modo/ventana con debounce

local M = {}

-- ============================
-- Utils
-- ============================
local ns = 0

local function tohex(n) return n and string.format("#%06x", n) or nil end

local function get_hl(name, follow_links)
  local ok, hl = pcall(vim.api.nvim_get_hl, ns, { name = name, link = follow_links ~= false })
  return ok and hl or {}
end

local function hl_hex(name)
  local hl = get_hl(name, true)
  return tohex(hl.fg), tohex(hl.bg)
end

local function pick_fg_for(bg)
  if not bg or bg == "NONE" then
    local nr = get_hl("Normal", true)
    return tohex(nr.fg) or "#1d2021"
  end
  local r = tonumber(bg:sub(2, 3), 16) or 0
  local g = tonumber(bg:sub(4, 5), 16) or 0
  local b = tonumber(bg:sub(6, 7), 16) or 0
  local luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
  if luma < 128 then
    local nr = get_hl("Normal", true)
    return tohex(nr.fg) or "#fbf1c7"
  else
    return "#1d2021"
  end
end

local function current_mode_group()
  local ok, mode = pcall(require, "lualine.utils.mode")
  if not ok then return "lualine_a_normal" end
  local m = (mode.get_mode and mode.get_mode()) or "NORMAL"
  local map = {
    NORMAL = "normal",
    INSERT = "insert",
    VISUAL = "visual",
    ["V-LINE"] = "visual",
    ["V-BLOCK"] = "visual",
    SELECT = "visual",
    REPLACE = "replace",
    COMMAND = "command",
    TERMINAL = "terminal",
  }
  return "lualine_a_" .. (map[m] or "normal")
end

-- ============================
-- Paleta (con caché)
-- ============================
local _palette ---@type {active_bg:string,active_fg:string,inactive_bg:string,inactive_fg:string} | nil

local function compute_palette()
  -- Activo: lualine_a_<modo>
  local active_fg_lualine, active_bg = hl_hex(current_mode_group())
  if not active_bg then
    local st = get_hl("StatusLine", true)
    active_bg = tohex(st.bg) or "#3c3836"
  end
  local active_fg = active_fg_lualine or pick_fg_for(active_bg)

  -- Inactivo: lualine_b_normal
  local inactive_fg, inactive_bg = hl_hex("lualine_b_normal")
  if not inactive_fg then inactive_fg = "#a89984" end
  if not inactive_bg then inactive_bg = "NONE" end

  _palette = {
    active_bg   = active_bg,
    active_fg   = active_fg,
    inactive_bg = inactive_bg,
    inactive_fg = inactive_fg,
  }
  return _palette
end

local function palette() return _palette or compute_palette() end

-- ============================
-- Devicons
-- ============================
local function resolve_devicon_fg(color)
  if not color then
    local nr = get_hl("Normal", true)
    return tohex(nr.fg) or "#ffffff"
  end
  if type(color) == "string" and color:sub(1, 1) == "#" then
    return color
  end
  local hl = get_hl(color, true)
  return tohex(hl.fg) or "#ffffff"
end

-- ============================
-- Aplicar HLs coherentes (debounced)
-- ============================
local apply_scheduled = false
local function apply_bufferline_hl()
  local pal = palette()

  -- Inactivos = lualine_b_normal
  local inactive_groups = {
    "BufferLineBackground",
    "BufferLineBuffer",
    "BufferLineBufferVisible",
    "BufferLineDuplicate",
    "BufferLineDuplicateVisible",
    "BufferLineModified",
    "BufferLineSeparator",
    "BufferLineSeparatorVisible",
    "BufferLineCloseButton",
    "BufferLineCloseButtonVisible",
  }
  for _, grp in ipairs(inactive_groups) do
    vim.api.nvim_set_hl(ns, grp, { fg = pal.inactive_fg, bg = pal.inactive_bg })
  end

  -- Activo: cualquier grupo *Selected
  local all = vim.fn.getcompletion("BufferLine", "highlight") or {}
  for _, name in ipairs(all) do
    if name:match("Selected$") then
      vim.api.nvim_set_hl(ns, name, { fg = pal.active_fg, bg = pal.active_bg, bold = true })
    end
  end

  -- Fill basado en StatusLine
  local st = get_hl("StatusLine", true)
  vim.api.nvim_set_hl(ns, "BufferLineFill", {
    fg = tohex(st.fg) or pal.inactive_fg,
    bg = tohex(st.bg) or pal.inactive_bg,
  })
end

local function schedule_apply()
  if apply_scheduled then return end
  apply_scheduled = true
  vim.defer_fn(function()
    compute_palette()      -- recalc por si cambió modo/tema
    apply_bufferline_hl()  -- aplicar
    apply_scheduled = false
  end, 30) -- debounce corto
end

-- ============================
-- Setup
-- ============================
function M.setup()
  local ok_buf, bufferline = pcall(require, "bufferline")
  if not ok_buf then return end

  bufferline.setup({
    options = {
      mode = "buffers",
      numbers = "none",
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      middle_mouse_command = "bdelete! %d",

      indicator = { style = "icon", icon = "▎" },
      buffer_close_icon = "",
      modified_icon = "●", -- marca de modificado
      close_icon = "",

      diagnostics = false, -- sin diagnósticos en bufferline

      offsets = {
        {
          filetype = "oil",
          text = function()
            return "   " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end,
          text_align = "left",
          separator = true,
        },
      },

      color_icons = true, -- devicons manejan fg; nosotros ajustamos bg
      show_buffer_icons = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      show_tab_indicators = true,
      persist_buffer_sort = true,

      separator_style = "thin",
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      hover = { enabled = true, delay = 120, reveal = { "close" } },

      max_name_length = 22,
      max_prefix_length = 15,
      truncate_names = true,
      sort_by = "insert_after_current",

      -- Iconos: devolvemos el icono y registramos HL una sola vez por estado
      get_element_icon = function(element)
        local ok_dev, devicons = pcall(require, "nvim-web-devicons")
        local icon, color = "", nil
        if ok_dev then
          icon, color = devicons.get_icon_by_filetype(element.filetype or "", { default = true })
          icon = icon or ""
        end
        local fg = resolve_devicon_fg(color)
        local ft = (element.filetype or ""):gsub("%W", "")
        local hl_name = ft ~= "" and ("BufferLineDevIcon" .. ft) or "BufferLineDevIconDefault"

        local pal = palette()
        -- Solo definimos (o redefinimos) cuando cambie el estado seleccionado,
        -- el debounce externo ya re-aplica al cambiar modo/tema.
        if element.selected then
          vim.api.nvim_set_hl(ns, hl_name, { fg = fg, bg = pal.active_bg, bold = true })
        else
          vim.api.nvim_set_hl(ns, hl_name, { fg = fg, bg = pal.inactive_bg })
        end

        return icon
      end,
    },
  })

  -- Pintado inicial
  schedule_apply()

  -- Reaplicar cuando cambie tema, modo o foco (con debounce)
  vim.api.nvim_create_autocmd({ "ColorScheme", "ModeChanged", "BufEnter", "WinEnter" }, {
    callback = schedule_apply,
    desc = "Bufferline: reaplicar highlights desde lualine",
  })
end

-- Ejecutar si este archivo se requiere directamente
pcall(M.setup)

return M
