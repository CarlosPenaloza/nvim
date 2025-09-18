-- Bufferline + Lualine (refinado)
-- - Fondo de icono = igual al item (activo/inactivo)
-- - Activo vistoso: barra izquierda + "glow" (sin subrayado)
-- - Inactivos atenuados pero legibles
-- - FG con contraste garantizado
-- - Buffers nuevos al final

local M = {}
local ns = 0

-- ===== Perillas de estilo =====
local GLOW_ACTIVE = 25 -- % de brillo extra al activo (texto/ícono)
local DIM_INACTIVE = -12 -- % de atenuación a inactivos (hazlo menos negativo para más claridad)

-- =============== Utils ===============
local function tohex(n)
	return n and string.format("#%06x", n) or nil
end
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

local function ensure_contrast_fg(bg, fg)
	if not fg or fg == "NONE" or (bg and fg == bg) then
		return pick_fg_for(bg)
	end
	return fg
end

local function safe_set_hl(group, spec)
	pcall(vim.api.nvim_set_hl, ns, group, spec)
end

local function clamp(x, a, b)
	return math.max(a, math.min(b, x))
end
local function brighten(hex, pct) -- ajusta brillo en RGB
	if not hex or hex == "NONE" then
		return hex
	end
	local r = tonumber(hex:sub(2, 3), 16) or 0
	local g = tonumber(hex:sub(4, 5), 16) or 0
	local b = tonumber(hex:sub(6, 7), 16) or 0
	local k = 1 + (pct or 0) / 100
	r = clamp(math.floor(r * k + 0.5), 0, 255)
	g = clamp(math.floor(g * k + 0.5), 0, 255)
	b = clamp(math.floor(b * k + 0.5), 0, 255)
	return string.format("#%02x%02x%02x", r, g, b)
end

-- =============== Paleta fallback (por si faltan grupos) ===============
---@class Palette
---@field active_bg string
---@field active_fg string
---@field inactive_bg string
---@field inactive_fg string
local _palette ---@type Palette|nil

local function compute_palette()
	local st = get_hl("StatusLine", true)
	local nr = get_hl("Normal", true)
	local active_bg = tohex(st.bg) or "#3c3836"
	local inactive_bg = tohex(st.bg) or tohex(nr.bg) or "#2a2a2a"
	local active_fg = ensure_contrast_fg(active_bg, tohex(st.fg) or tohex(nr.fg))
	local inactive_fg = ensure_contrast_fg(inactive_bg, tohex(get_hl("StatusLineNC", true).fg) or tohex(nr.fg))
	_palette = { active_bg = active_bg, active_fg = active_fg, inactive_bg = inactive_bg, inactive_fg = inactive_fg }
	return _palette
end
local function palette()
	return _palette or compute_palette()
end

-- =============== Colores REALES de Bufferline (contrastados) ===============
local function current_bufferline_style()
	local pal = palette()
	local fg_in, bg_in = hl_hex("BufferLineBackground")
	local fg_ac, bg_ac = hl_hex("BufferLineBufferSelected")
	bg_in = bg_in or pal.inactive_bg
	bg_ac = bg_ac or pal.active_bg
	fg_in = ensure_contrast_fg(bg_in, fg_in or pal.inactive_fg)
	fg_ac = ensure_contrast_fg(bg_ac, fg_ac or pal.active_fg)
	return { fg_in = fg_in, bg_in = bg_in, fg_ac = fg_ac, bg_ac = bg_ac }
end

-- =============== Devicons ===============
local function resolve_devicon_fg(color)
	if not color then
		return tohex(get_hl("Normal", true).fg) or "#ffffff"
	end
	if type(color) == "string" and color:sub(1, 1) == "#" then
		return color
	end
	local hl = get_hl(color, true)
	return tohex(hl.fg) or "#ffffff"
end

local function define_devicon_groups(base, color_opt, style, glow_fg)
	local fg_dev = color_opt and resolve_devicon_fg(color_opt) or nil
	local fg_in = ensure_contrast_fg(style.bg_in, fg_dev or style.fg_in)
	local fg_ac = ensure_contrast_fg(style.bg_ac, fg_dev or glow_fg or style.fg_ac)
	safe_set_hl(base, { fg = fg_in, bg = style.bg_in, nocombine = true })
	safe_set_hl(base .. "Selected", { fg = fg_ac, bg = style.bg_ac, bold = true, nocombine = true })
end

local function fix_all_devicon_groups(style, glow_fg)
	local list = vim.fn.getcompletion("BufferLineDevIcon", "highlight") or {}
	for _, name in ipairs(list) do
		local hl = get_hl(name, true)
		local is_sel = name:match("Selected$")
		local bg = is_sel and style.bg_ac or style.bg_in
		local default_fg = is_sel and (glow_fg or style.fg_ac) or style.fg_in
		local fg = ensure_contrast_fg(bg, tohex(hl.fg) or default_fg)
		safe_set_hl(name, { fg = fg, bg = bg, bold = is_sel or false, nocombine = true })
	end
end

-- =============== HLs coherentes (debounced) ===============
local apply_scheduled = false

local function apply_bufferline_hl()
	local style = current_bufferline_style()

	-- Glow del activo y dim de inactivos (ajustables)
	local glow_fg = brighten(style.fg_ac, GLOW_ACTIVE)
	local dim_fg = brighten(style.fg_in, DIM_INACTIVE)
	local dim_fg_visible = brighten(style.fg_in, math.floor(DIM_INACTIVE / 2)) -- un poco más claro

	-- Inactivos
	safe_set_hl("BufferLineBackground", { fg = dim_fg, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineBuffer", { fg = dim_fg, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineDuplicate", { fg = dim_fg, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineModified", { fg = dim_fg, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineSeparator", { fg = style.bg_in, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineCloseButton", { fg = dim_fg, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineTab", { fg = dim_fg, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineGroupSeparator", { fg = dim_fg, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineGroupLabel", { fg = dim_fg, bg = style.bg_in, nocombine = true })

	-- Visibles (ventana no activa pero buffer visible) ligeramente más claros
	safe_set_hl("BufferLineBufferVisible", { fg = dim_fg_visible, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineDuplicateVisible", { fg = dim_fg_visible, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineModifiedVisible", { fg = dim_fg_visible, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineSeparatorVisible", { fg = style.bg_in, bg = style.bg_in, nocombine = true })
	safe_set_hl("BufferLineCloseButtonVisible", { fg = dim_fg_visible, bg = style.bg_in, nocombine = true })

	-- Activo (glow + negritas)
	local all = vim.fn.getcompletion("BufferLine", "highlight") or {}
	for _, name in ipairs(all) do
		if name:match("Selected$") then
			safe_set_hl(name, { fg = glow_fg, bg = style.bg_ac, bold = true, nocombine = true })
		end
	end
	-- Indicador del activo (barra gruesa a la izquierda) y separador
	safe_set_hl("BufferLineIndicatorSelected", { fg = glow_fg, bg = style.bg_ac, nocombine = true })
	safe_set_hl("BufferLineSeparatorSelected", { fg = style.bg_ac, bg = style.bg_ac, nocombine = true })

	-- Fill coherente con StatusLine
	local st = get_hl("StatusLine", true)
	local fill_fg = ensure_contrast_fg(style.bg_in, tohex(st.fg))
	safe_set_hl("BufferLineFill", { fg = fill_fg, bg = style.bg_in, nocombine = true })

	-- Alinear devicons al nuevo glow/dim
	fix_all_devicon_groups(style, glow_fg)
end

local function schedule_apply()
	if apply_scheduled then
		return
	end
	apply_scheduled = true
	vim.defer_fn(function()
		compute_palette()
		apply_bufferline_hl()
		apply_scheduled = false
	end, 40)
end

-- =============== Setup ===============
function M.setup()
	local ok_buf, bufferline = pcall(require, "bufferline")
	if not ok_buf then
		return
	end

	bufferline.setup({
		options = {
			mode = "buffers",
			numbers = "none",

			close_command = function(n)
				pcall(vim.cmd, "bdelete! " .. n)
			end,
			right_mouse_command = function(n)
				pcall(vim.cmd, "bdelete! " .. n)
			end,
			middle_mouse_command = function(n)
				pcall(vim.cmd, "bdelete! " .. n)
			end,

			-- Barra gruesa a la izquierda (sin subrayado)
			indicator = { style = "icon", icon = "█" },

			buffer_close_icon = "",
			modified_icon = "●",
			close_icon = "",
			diagnostics = false,

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

			color_icons = true,
			show_buffer_icons = true,
			show_buffer_close_icons = false,
			show_close_icon = false,
			show_tab_indicators = true,
			persist_buffer_sort = true,

			separator_style = "slant", -- un poco más vistoso
			enforce_regular_tabs = false,
			always_show_bufferline = true,
			hover = { enabled = true, delay = 120, reveal = { "close" } },

			max_name_length = 22,
			max_prefix_length = 15,
			truncate_names = true,

			-- SIEMPRE al final
			insert_at_end = true,
			sort_by = "id",

			-- Devicons con fondo idéntico y glow en el activo
			get_element_icon = function(element)
				local ok_dev, devicons = pcall(require, "nvim-web-devicons")
				local icon, color = "", nil
				if ok_dev then
					icon, color = devicons.get_icon_by_filetype(element.filetype or "", { default = true })
					icon = icon or ""
				end

				local style = current_bufferline_style()
				local glow_fg = brighten(style.fg_ac, GLOW_ACTIVE)
				local ft = (element.filetype or ""):gsub("%W", "")
				local base = ft ~= "" and ("BufferLineDevIcon" .. ft) or "BufferLineDevIconDefault"

				define_devicon_groups(base, color, style, glow_fg)
				local hl_name = element.selected and (base .. "Selected") or base
				return icon, hl_name
			end,
		},
	})

	schedule_apply()
	vim.api.nvim_create_autocmd(
		{ "ColorScheme", "ModeChanged", "BufEnter", "WinEnter", "UIEnter" },
		{ callback = schedule_apply, desc = "Bufferline: reaplicar highlights/devicons (glow + bar)" }
	)
end

pcall(M.setup)
return M
