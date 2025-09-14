-- lua/config/lualine.lua

-- ===== Helpers =====
local function firstline(cmd)
  local out = vim.fn.systemlist(cmd)
  if vim.v.shell_error == 0 and out and out[1] and #out[1] > 0 then return out[1] end
end

local function git_root() return firstline('git rev-parse --show-toplevel') end

-- Ruta del buffer relativa al root de Git (fallback: relativa a cwd)
local function git_relpath()
  local buf = vim.api.nvim_buf_get_name(0)
  if buf == "" then return "" end
  local root = git_root()
  if root and #root > 0 then
    local rel = vim.fn.fnamemodify(buf, ':.' .. root) -- relativo al root
    if rel ~= buf then return rel end
  end
  return vim.fn.fnamemodify(buf, ':.') -- relativo al cwd
end

-- Solo el directorio (sin el nombre) para winbar izquierda
local function git_rel_dir()
  local p = git_relpath()
  local dir = vim.fn.fnamemodify(p, ':h')
  if dir == '.' then return '' end
  return dir .. '/'
end

-- Diff desde gitsigns
local function diff_source()
  local g = vim.b.gitsigns_status_dict
  if g then return { added = g.added, modified = g.changed, removed = g.removed } end
end

-- Rama actual
local function current_branch()
  local b = firstline("git rev-parse --abbrev-ref HEAD")
  if not b or b == "HEAD" then return "" end
  return b
end

-- ===== Colores auto con el tema =====
local function get_hl(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and hl or {}
end

local function hex(n) return n and string.format("#%06x", n) or nil end

local function pick_primary_bg()
  local sel = get_hl('PmenuSel'); if sel.bg then return hex(sel.bg) end
  local tab = get_hl('TabLineSel'); if tab.bg then return hex(tab.bg) end
  local cur = get_hl('CursorLine'); if cur.bg then return hex(cur.bg) end
  local st  = get_hl('StatusLine'); if st.bg  then return hex(st.bg)  end
  local nr  = get_hl('Normal');     if nr.bg  then return hex(nr.bg)  end
  return "#3c3836" -- fallback (gruvbox-friendly)
end

local function pick_fg_for(bg)
  local function luma(c)
    local r = tonumber(c:sub(2, 3), 16)
    local g = tonumber(c:sub(4, 5), 16)
    local b = tonumber(c:sub(6, 7), 16)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
  end
  local nr = get_hl('Normal')
  local dark  = "#1d2021"
  local light = (nr.fg and hex(nr.fg)) or "#fbf1c7"
  return (luma(bg) < 128) and light or dark
end

-- === Color dinámico por modo (igual que el "mode" de lualine) ===
local function hl_hex(name)
  local h = get_hl(name)
  local fg = h.fg and string.format("#%06x", h.fg) or nil
  local bg = h.bg and string.format("#%06x", h.bg) or nil
  return fg, bg
end

local function current_mode_group()
  -- Devuelve el grupo que usa lualine para la sección A según el modo
  local mode = require('lualine.utils.mode').get_mode()
  local map = {
    NORMAL = 'normal',
    INSERT = 'insert',
    VISUAL = 'visual',
    ['V-LINE'] = 'visual',
    ['V-BLOCK'] = 'visual',
    SELECT = 'visual',
    REPLACE = 'replace',
    COMMAND = 'command',
    TERMINAL = 'terminal',
  }
  return 'lualine_a_' .. (map[mode] or 'normal')
end

local function filename_color_by_mode()
  local grp = current_mode_group()
  local fg, bg = hl_hex(grp)
  if not bg then bg = pick_primary_bg() end
  if not fg then fg = pick_fg_for(bg) end
  return { fg = fg, bg = bg, gui = 'bold' }
end

local function color_directory()
  local d = get_hl('Directory');   if d.fg then return { fg = hex(d.fg) } end
  local id = get_hl('Identifier'); if id.fg then return { fg = hex(id.fg) } end
  return {}
end

-- ===== Condiciones por filetype =====
local function is_oil() return vim.bo.filetype == 'oil' end
local function not_oil() return not is_oil() end

-- ===== BIG FILE badge =====
local function big_file_text()
  local buf = vim.api.nvim_get_current_buf()
  if _G.BigFile and _G.BigFile.state and _G.BigFile.state[buf] then
    return ' BIG FILE'
  end
  return ''
end

-- Badge BIG FILE coloreado por modo (bg por modo, fg de advertencia si existe)
local function big_file_color_by_mode()
  local col = filename_color_by_mode()
  local dw = get_hl('DiagnosticWarn')
  local wm = get_hl('WarningMsg')
  if dw.fg then
    col.fg = hex(dw.fg)
  elseif wm.fg then
    col.fg = hex(wm.fg)
  end
  col.gui = (col.gui and (col.gui .. ',bold')) or 'bold'
  return col
end

-- ===== Setup Lualine =====
require('lualine').setup({
  options = {
    theme                = 'auto',
    globalstatus         = true,
    component_separators = { left = '|', right = '|' },
    section_separators   = { left = '', right = '' },
    disabled_filetypes   = {
      statusline = { 'alpha', 'dashboard', 'starter' },
      winbar     = {},
    },
    always_divide_middle = false,
    refresh              = { statusline = 200, tabline = 200, winbar = 200 },
  },

  -- ===== Statusline =====
  sections = {
    lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
    lualine_b = {
      { current_branch, icon = '', color = { gui = 'bold' } },
    },
    lualine_c = {
      { big_file_text, color = big_file_color_by_mode, padding = { left = 1, right = 1 } },
    },
    lualine_x = {
      { 'diagnostics', sources = { 'coc' }, sections = { 'error', 'warn', 'info', 'hint' }, update_in_insert = false },
      { 'diff', source = diff_source, symbols = { added = '+', modified = '~', removed = '-' }, colored = true },
    },
    lualine_y = { 'encoding', { 'filetype', icon_only = true }, 'progress' },
    lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
  },

  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },

  -- ===== Winbar =====
  winbar = {
    lualine_b = {
      { function() return ' ' end, cond = is_oil, padding = { left = 0, right = 0 } },
      { 'filetype', icon_only = true, color = color_directory, padding = { left = 1, right = 0 }, separator = '', cond = not_oil },
      { git_rel_dir, color = color_directory, padding = { left = 1, right = 1 }, cond = not_oil },
    },
    lualine_c = {
      { function() return '' end, cond = is_oil, padding = 0 },
      {
        'filename',
        path = 0,
        file_status = true,
        newfile_status = true,
        symbols = { modified = ' ●', readonly = ' ', unnamed = '[No Name]', newfile = '[New]' },
        color = filename_color_by_mode,
        padding = { left = 0, right = 1 },
        separator = '',
        cond = not_oil,
      },
      { big_file_text, color = big_file_color_by_mode, padding = { left = 1, right = 0 }, separator = '', cond = not_oil },
    },
    lualine_a = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },

  inactive_winbar = {
    lualine_b = {
      { function() return ' ' end, cond = is_oil, padding = { left = 0, right = 0 } },
      { 'filetype', icon_only = true, color = color_directory, padding = { left = 1, right = 0 }, separator = '', cond = not_oil },
      { git_rel_dir, color = color_directory, padding = { left = 1, right = 1 }, cond = not_oil },
    },
    lualine_c = {
      { function() return '' end, cond = is_oil, padding = 0 },
      {
        'filename',
        path = 0,
        file_status = true,
        newfile_status = true,
        symbols = { modified = ' ●', readonly = ' ', unnamed = '[No Name]', newfile = '[New]' },
        color = filename_color_by_mode,
        padding = { left = 0, right = 1 },
        separator = '',
        cond = not_oil,
      },
      { big_file_text, color = big_file_color_by_mode, padding = { left = 1, right = 0 }, separator = '', cond = not_oil },
    },
  },

  tabline = {},
  extensions = { 'oil', 'quickfix' },
})

-- ⚠️ IMPORTANTE:
--   vim.opt.splitkeep = "screen"
--   vim.opt.cmdheight = 0
--   vim.opt.showmode = false
--   vim.opt.shortmess:append("F")
--   vim.opt.shortmess:append("Ic")
--   -- Si usas noice.nvim, configura mensajes flotantes para no mover el layout.
