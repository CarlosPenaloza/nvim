-- lua/config/format.lua
-- Minimal, robusto y sin auto-on-save. Atajos:
--   Normal: <leader>f  → formatea línea actual
--   Visual: <leader>f  → formatea selección (v / V / Ctrl-v)

-- ────────────────────────────────────────────────────────────────────────
-- Notificaciones
-- ────────────────────────────────────────────────────────────────────────
local function info(msg)
	vim.notify(msg, vim.log.levels.INFO)
end
local function warn(msg)
	vim.notify(msg, vim.log.levels.WARN)
end
local function err(msg)
	vim.notify(msg, vim.log.levels.ERROR)
end

-- ────────────────────────────────────────────────────────────────────────
-- Filetypes por formateador
-- ────────────────────────────────────────────────────────────────────────
local FT_PRETTIER = {
	javascript = true,
	typescript = true,
	javascriptreact = true,
	typescriptreact = true,
	jsx = true,
	tsx = true,
	html = true,
	css = true,
	scss = true,
	less = true,
	json = true,
	jsonc = true,
	markdown = true,
	mdx = true,
	yaml = true,
	yml = true,
	graphql = true,
	astro = true,
	svelte = true,
	vue = true,
}

local function ft_kind()
	local ft = vim.bo.filetype
	if FT_PRETTIER[ft] then
		return "prettier"
	end
	if ft == "lua" then
		return "stylua"
	end
	if ft == "vim" then
		return "vimindent"
	end
	return nil
end

-- ────────────────────────────────────────────────────────────────────────
-- Resolución de ejecutables / comandos
-- ────────────────────────────────────────────────────────────────────────
local function current_dir()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return vim.loop.cwd()
	end
	return vim.fs.dirname(name)
end

local function find_upwards(target, dir)
	local found = vim.fs.find(target, { path = dir, upward = true, type = "file" })
	return (found and found[1]) or nil
end

-- Prettier: local (node_modules) > global; sin npx
local function resolve_prettier()
	local dir = current_dir()
	local local_bin = find_upwards("node_modules/.bin/prettier", dir)
	if local_bin and vim.fn.filereadable(local_bin) == 1 then
		return vim.fn.shellescape(local_bin)
	end
	if vim.fn.executable("prettier") == 1 then
		return "prettier"
	end
	return nil
end

local function prettier_cmdline()
	local bin = resolve_prettier()
	if not bin then
		err(
			"No se encontró Prettier (ni local ni global).\n"
				.. "Instala una de estas opciones:\n"
				.. "  • Local (recomendado): npm i -D prettier\n"
				.. "  • Global: npm i -g prettier"
		)
		return nil
	end
	local fname = vim.api.nvim_buf_get_name(0)
	if fname == "" or fname == nil then
		local ft = (vim.bo.filetype or "txt"):gsub("%s+", "")
		fname = "stdin." .. (ft ~= "" and ft or "txt")
	end
	-- --ignore-unknown evita errores verbosos en tipos raros
	-- --log-level silent suprime mensajes
	return string.format("%s --log-level silent --ignore-unknown --stdin-filepath %s", bin, vim.fn.shellescape(fname))
end

-- StyLua: global; usa stdin y detecta config con --stdin-filepath
local function resolve_stylua()
	if vim.fn.executable("stylua") == 1 then
		return "stylua"
	end
	return nil
end

local function stylua_cmdline()
	local bin = resolve_stylua()
	if not bin then
		err(
			"No se encontró StyLua en PATH. Instálalo, por ejemplo:\n"
				.. "  • cargo install stylua\n"
				.. "  • brew install stylua  (macOS)\n"
				.. "  • scoop install stylua (Windows)"
		)
		return nil
	end
	local fname = vim.api.nvim_buf_get_name(0)
	if fname == "" or fname == nil then
		fname = "stdin.lua"
	end
	-- Lee de stdin con '-' y usa el filepath para buscar stylua.toml
	return string.format("%s --color Never --stdin-filepath %s -", bin, vim.fn.shellescape(fname))
end

-- ────────────────────────────────────────────────────────────────────────
-- Helpers selección / línea
-- ────────────────────────────────────────────────────────────────────────
local function current_line_range()
	local l = vim.api.nvim_win_get_cursor(0)[1]
	return l, l
end

local function visual_or_count_range(opts)
	if opts and opts.range == 2 then
		return opts.line1, opts.line2
	else
		local l1 = vim.fn.getpos("'<")[2]
		local l2 = vim.fn.getpos("'>")[2]
		if not l1 or not l2 then
			return nil, nil
		end
		if l2 < l1 then
			l1, l2 = l2, l1
		end
		return l1, l2
	end
end

local function is_lines_all_empty(l1, l2)
	local lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, false)
	if #lines == 0 then
		return true
	end
	for _, ln in ipairs(lines) do
		if ln ~= "" then
			return false
		end
	end
	return true
end

-- ────────────────────────────────────────────────────────────────────────
-- Aplicadores por backend
-- ────────────────────────────────────────────────────────────────────────
local function apply_prettier(l1, l2)
	local cmd = prettier_cmdline()
	if not cmd then
		return false
	end
	vim.cmd(string.format([[%d,%d! %s]], l1, l2, cmd))
	return true
end

local function apply_stylua(l1, l2)
	local cmd = stylua_cmdline()
	if not cmd then
		return false
	end
	vim.cmd(string.format([[%d,%d! %s]], l1, l2, cmd))
	return true
end

local function apply_vim_indent(l1, l2)
	-- Reindentación nativa por línea (no reemplaza con errores)
	vim.cmd(string.format([[%d,%dnormal! =]], l1, l2))
	return true
end

local function apply_for_range(l1, l2)
	local kind = ft_kind()
	if not kind then
		warn("Formato no aplicado: filetype no soportado (" .. (vim.bo.filetype or "desconocido") .. ")")
		return false
	end
	if is_lines_all_empty(l1, l2) then
		warn("⚠ Selección vacía")
		return false
	end
	if kind == "prettier" then
		return apply_prettier(l1, l2)
	end
	if kind == "stylua" then
		return apply_stylua(l1, l2)
	end
	if kind == "vimindent" then
		return apply_vim_indent(l1, l2)
	end
	return false
end

-- ────────────────────────────────────────────────────────────────────────
-- Acciones públicas
-- ────────────────────────────────────────────────────────────────────────
local function format_line()
	local l1, l2 = current_line_range()
	if apply_for_range(l1, l2) then
		info("✔ Línea formateada")
	end
end

local function format_selection(opts)
	local l1, l2 = visual_or_count_range(opts)
	if not l1 then
		warn("⚠ No hay selección")
		return
	end
	if apply_for_range(l1, l2) then
		info(string.format("✔ Selección formateada (%d-%d)", l1, l2))
	end
end

local function format_buffer()
	local total = vim.api.nvim_buf_line_count(0)
	if total == 1 and (vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or "") == "" then
		warn("⚠ Buffer vacío")
		return
	end
	if apply_for_range(1, total) then
		info("✔ Buffer formateado")
	end
end

-- ────────────────────────────────────────────────────────────────────────
-- Comandos
-- ────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_user_command("FormatLine", function()
	format_line()
end, {})
vim.api.nvim_create_user_command("FormatSel", function(opts)
	format_selection(opts)
end, { range = true })
vim.api.nvim_create_user_command("Format", function()
	format_buffer()
end, {})

-- ────────────────────────────────────────────────────────────────────────
-- Atajos (funciona con v / V / Ctrl-v)
-- ────────────────────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>f", format_line, { desc = "Format current line", silent = true })

pcall(vim.keymap.del, "x", "<leader>f")
vim.keymap.set("x", "<leader>f", [[:<C-u>'<,'>FormatSel<CR>]], { desc = "Format selection", silent = true })
