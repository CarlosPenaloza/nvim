-- lua/config/format.lua

-- Carga segura
local ok, conform = pcall(require, "conform")
if not ok then
	vim.notify("conform.nvim no está instalado/cargado", vim.log.levels.ERROR)
	return
end

local util = require("conform.util")

-- ==== Rutas/entorno ====
local home = vim.fn.expand("~")
local prettier_global = home .. "/.prettierrc.json"

-- ==== Configuración base de Conform ====
conform.setup({
	formatters_by_ft = {
		-- JS/TS: solo Prettier para formateo; eslint_d queda para lint
		javascript = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		javascriptreact = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
		json = { "jq" },
		css = { "prettierd", "prettier" },
		html = { "prettierd", "prettier" },
		lua = { "stylua" },
		python = { "ruff_format", "black" },
		sh = { "shfmt" },
		markdown = { "prettierd", "prettier" },
	},
	formatters = {
		-- prettierd: usa tu config global si el repo no trae una
		prettierd = {
			env = { PRETTIERD_DEFAULT_CONFIG = prettier_global },
			cwd = util.root_file({ "package.json", ".prettierrc", ".prettierrc.json", ".git" }),
		},
		-- Prettier CLI: aseguramos detection de parser según filepath
		prettier = {
			prepend_args = { "--stdin-filepath", "$FILENAME" },
		},
	},
	notify_on_error = true,
})

-- ==== Helpers de rango y mensajes ====
local function line_end_col(bufnr, row0)
	local line = vim.api.nvim_buf_get_lines(bufnr, row0, row0 + 1, false)[1] or ""
	return #line
end

local function format_buffer()
	conform.format({ async = true, lsp_fallback = true }, function(err)
		if err then
			vim.notify("✖ Falló formateo del buffer (ver :ConformInfo)", vim.log.levels.ERROR)
		else
			vim.notify("✔ Buffer formateado", vim.log.levels.INFO)
		end
	end)
end

-- Fuerza Prettier CLI para rangos (prettierd no soporta rango)
local function format_line()
	local bufnr = 0
	local row0 = vim.api.nvim_win_get_cursor(0)[1] - 1
	local endc = line_end_col(bufnr, row0)
	conform.format({
		async = true,
		lsp_fallback = true,
		formatters = { "prettier" },
		range = { start = { row0, 0 }, ["end"] = { row0, endc } },
	}, function(err)
		if err then
			vim.notify("✖ Falló formateo de línea (ver :ConformInfo)", vim.log.levels.ERROR)
		else
			vim.notify("✔ Línea formateada", vim.log.levels.INFO)
		end
	end)
end

local function format_selection_by_marks()
	local start_pos = vim.api.nvim_buf_get_mark(0, "<")
	local end_pos = vim.api.nvim_buf_get_mark(0, ">")
	if not start_pos or not end_pos then
		vim.notify("⚠ No hay selección activa", vim.log.levels.WARN)
		return
	end
	local srow, scol = start_pos[1], start_pos[2]
	local erow, ecol = end_pos[1], end_pos[2]
	if (erow < srow) or (erow == srow and ecol < scol) then
		srow, erow = erow, srow
		scol, ecol = ecol, scol
	end
	local endc = line_end_col(0, erow)
	if ecol > endc then
		ecol = endc
	end

	conform.format({
		async = true,
		lsp_fallback = true,
		formatters = { "prettier" },
		range = { start = { srow, scol }, ["end"] = { erow, ecol } },
	}, function(err)
		if err then
			vim.notify("✖ Falló formateo de selección (ver :ConformInfo)", vim.log.levels.ERROR)
		else
			vim.notify("✔ Selección formateada", vim.log.levels.INFO)
		end
	end)
end

local function format_selection_by_range(line1, line2)
	local srow = (line1 - 1)
	local erow = (line2 - 1)
	local ecol = line_end_col(0, erow)
	conform.format({
		async = true,
		lsp_fallback = true,
		formatters = { "prettier" },
		range = { start = { srow, 0 }, ["end"] = { erow, ecol } },
	}, function(err)
		if err then
			vim.notify(
				("✖ Falló formateo del rango %d-%d (ver :ConformInfo)"):format(line1, line2),
				vim.log.levels.ERROR
			)
		else
			vim.notify(("✔ Rango formateado (%d-%d)"):format(line1, line2), vim.log.levels.INFO)
		end
	end)
end

-- ==== Comandos ====
vim.api.nvim_create_user_command("Format", function()
	format_buffer()
end, {})
vim.api.nvim_create_user_command("FormatLine", function()
	format_line()
end, {})
vim.api.nvim_create_user_command("FormatSel", function(opts)
	if opts.count ~= -1 then
		format_selection_by_range(opts.line1, opts.line2)
	else
		format_selection_by_marks()
	end
end, { range = true })

-- Forzar usar Prettier CLI (saltando el daemon) en el buffer actual
vim.api.nvim_create_user_command("FormatPrettier", function()
	conform.format({
		async = true,
		lsp_fallback = true,
		formatters = { "prettier" },
	}, function(err)
		if err then
			vim.notify("✖ Falló con Prettier CLI (ver :ConformInfo)", vim.log.levels.ERROR)
		else
			vim.notify("✔ Formateado con Prettier CLI", vim.log.levels.INFO)
		end
	end)
end, {})

-- Detener/reniciar el daemon de prettierd (por si se “pega”)
local function prettierd_stop(cb)
	vim.system({ "prettierd", "stop" }, { text = true }, function(res)
		if res.code == 0 then
			vim.schedule(function()
				vim.notify("⏹  prettierd detenido", vim.log.levels.INFO)
			end)
		else
			vim.schedule(function()
				vim.notify("⚠ No se pudo detener prettierd", vim.log.levels.WARN)
			end)
		end
		if cb then
			cb()
		end
	end)
end

vim.api.nvim_create_user_command("PrettierdStop", function()
	prettierd_stop()
end, {})

vim.api.nvim_create_user_command("PrettierdRestart", function()
	prettierd_stop(function()
		vim.defer_fn(function()
			vim.notify("🔁 prettierd reiniciado (se iniciará al próximo format)", vim.log.levels.INFO)
		end, 100)
	end)
end, {})

-- ==== Mappings ====
vim.keymap.set("n", "<leader>f", format_line, { desc = "Format current line", silent = true })
vim.keymap.set("x", "<leader>f", format_selection_by_marks, { desc = "Format selection", silent = true })
