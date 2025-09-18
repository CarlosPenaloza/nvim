-- lua/config/diagnostics.lua
-- =========================================================
-- Diagnósticos pulidos SIN splits y SIN Trouble:
--  - Flotante bajo el cursor (rápido, con filtro de severidad)
--  - Panel flotante derecho (WORKSPACE) con filtro de texto y orden
--  - Autorefresco robusto al abrir/entrar/adjuntar LSP/etc.
--  - Requiere Neovim 0.10+ (signs en vim.diagnostic.config)
-- =========================================================

-- ===== Config base de diagnósticos + signos modernos =====
local sev = vim.diagnostic.severity

local diag_signs = {
	text = {
		[sev.ERROR] = "",
		[sev.WARN] = "",
		[sev.HINT] = "󰌵",
		[sev.INFO] = "",
	},
	numhl = {
		[sev.ERROR] = "DiagnosticSignError",
		[sev.WARN] = "DiagnosticSignWarn",
		[sev.HINT] = "DiagnosticSignHint",
		[sev.INFO] = "DiagnosticSignInfo",
	},
}

vim.diagnostic.config({
	virtual_text = false, -- flotante por defecto
	signs = diag_signs, -- sin vim.fn.sign_define (deprecado)
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
		focusable = false, -- no roba foco
		header = "",
		prefix = "",
	},
})

-- ===== Augroup único =====
local aug = vim.api.nvim_create_augroup("DiagnosticsPolished", { clear = true })

-- ===== Filtro de severidad (compartido con panel) =====
-- nil => todas; table => {min=..., max=...}
local float_sev_filter = nil

-- :DiagFloatSeverity [all|errwarn|error|warn|info|hint]
local function set_float_severity(mode)
	local m = (mode or "errwarn"):lower()
	local map = {
		all = nil,
		errwarn = { min = sev.ERROR, max = sev.WARN },
		error = { min = sev.ERROR, max = sev.ERROR },
		warn = { min = sev.WARN, max = sev.WARN },
		info = { min = sev.INFO, max = sev.INFO },
		hint = { min = sev.HINT, max = sev.HINT },
	}
	float_sev_filter = map[m]
	vim.notify(
		"DiagFloatSeverity → " .. (m == "all" and "ALL" or m:upper()),
		vim.log.levels.INFO,
		{ title = "Diagnostics" }
	)
	if vim.g.__DiagSide_set_filter then
		pcall(vim.g.__DiagSide_set_filter, float_sev_filter, m)
	end
end

vim.api.nvim_create_user_command("DiagFloatSeverity", function(opts)
	set_float_severity(opts.args ~= "" and opts.args or "errwarn")
end, {
	nargs = "?",
	complete = function()
		return { "all", "errwarn", "error", "warn", "info", "hint" }
	end,
	desc = "Filtra severidad de diagnósticos en el flotante",
})

-- ===== Flotante bajo el cursor (rápido y sin lag) =====
local float_state = {} ---@type table<integer, {winid:integer, lnum:integer}>
local last_float_at = 0
local throttle_ms = 120

local function close_float(bufnr)
	local st = float_state[bufnr]
	if st and st.winid and vim.api.nvim_win_is_valid(st.winid) then
		pcall(vim.api.nvim_win_close, st.winid, true)
	end
	float_state[bufnr] = nil
end

local function show_diag_float()
	local now = (vim.loop.hrtime() or 0) / 1e6
	if now - last_float_at < throttle_ms then
		return
	end
	last_float_at = now

	local bufnr = vim.api.nvim_get_current_buf()
	local pos = vim.api.nvim_win_get_cursor(0)
	local lnum = pos[1] - 1

	local diags = vim.diagnostic.get(bufnr, { lnum = lnum, severity = float_sev_filter })
	if #diags == 0 then
		close_float(bufnr)
		return
	end

	local st = float_state[bufnr]
	if st and st.winid and vim.api.nvim_win_is_valid(st.winid) and st.lnum == lnum then
		return
	end

	close_float(bufnr)

	local maxw = math.floor(vim.o.columns * 0.45)
	local opts = {
		scope = "cursor",
		focusable = false,
		border = "rounded",
		source = "if_many",
		max_width = maxw,
		severity = float_sev_filter,
	}

	local ok, winid = pcall(vim.diagnostic.open_float, bufnr, opts)
	if ok and winid then
		float_state[bufnr] = { winid = winid, lnum = lnum }
		vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufHidden", "BufLeave" }, {
			group = aug,
			buffer = bufnr,
			once = true,
			callback = function()
				close_float(bufnr)
			end,
		})
	end
end

-- Mostrar en normal & insert (si usas CursorHoldI)
vim.api.nvim_create_autocmd({ "CursorHold" }, {
	group = aug,
	callback = show_diag_float,
})

-- ===== Panel flotante derecho (WORKSPACE) con filtro y orden =====
do
	local Side = {
		enabled = false,
		filter = nil, -- nil=todo; o {min=sev.ERROR,max=sev.WARN}
		query = "", -- texto a filtrar (insensible a mayúsculas)
		sort_mode = "sev_file", -- "sev_file" | "file_sev"
		width = 42,
		heightF = 0.55,
		mincols = 100,
		ns = vim.api.nvim_create_namespace("DiagSideFloat"),
		bufnr = nil,
		winid = nil,
		idxmap = nil, -- línea -> item (para <CR>)
		cursor = 3, -- posición del cursor en el panel
	}

	-- Exponer setters para sincronizar desde comandos globales
	local function diagside_set_filter(tbl, _label)
		Side.filter = tbl
		if Side.enabled then
			vim.schedule(function()
				vim.cmd("redraw")
			end)
		end
	end
	vim.g.__DiagSide_set_filter = function(tbl, label)
		diagside_set_filter(tbl, label)
	end

	local function side_close()
		if Side.winid and vim.api.nvim_win_is_valid(Side.winid) then
			pcall(vim.api.nvim_win_close, Side.winid, true)
		end
		Side.winid = nil
		if Side.bufnr and vim.api.nvim_buf_is_valid(Side.bufnr) then
			vim.api.nvim_buf_clear_namespace(Side.bufnr, Side.ns, 0, -1)
		end
		Side.idxmap = nil
	end

	local function ensure_buf()
		if Side.bufnr and vim.api.nvim_buf_is_valid(Side.bufnr) then
			return
		end
		Side.bufnr = vim.api.nvim_create_buf(false, true) -- scratch
		vim.bo[Side.bufnr].filetype = "diaglist"
		vim.bo[Side.bufnr].bufhidden = "wipe"
		vim.bo[Side.bufnr].modifiable = false

		local function nmap(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = Side.bufnr, silent = true, desc = desc })
		end
		nmap("q", function()
			Side.enabled = false
			side_close()
		end, "Cerrar panel")
		nmap("<Esc>", function()
			Side.enabled = false
			side_close()
		end, "Cerrar panel")
		nmap("<CR>", function()
			if not (Side.winid and vim.api.nvim_win_is_valid(Side.winid)) then
				return
			end
			local l = vim.api.nvim_win_get_cursor(Side.winid)[1]
			if Side.idxmap and Side.idxmap[l] then
				local it = Side.idxmap[l]
				Side.enabled = false
				side_close()
				vim.api.nvim_set_current_buf(it.bufnr)
				vim.api.nvim_win_set_cursor(0, { it.lnum + 1, it.col or 0 })
				vim.cmd("normal! zz")
			end
		end, "Ir al diagnóstico")

		-- Navegación del panel
		nmap("j", function()
			local last = vim.api.nvim_buf_line_count(Side.bufnr)
			Side.cursor = math.min(last, (Side.cursor or 3) + 1)
			pcall(vim.api.nvim_win_set_cursor, Side.winid, { Side.cursor, 0 })
		end, "Bajar")
		nmap("k", function()
			Side.cursor = math.max(3, (Side.cursor or 3) - 1)
			pcall(vim.api.nvim_win_set_cursor, Side.winid, { Side.cursor, 0 })
		end, "Subir")
		nmap("<Tab>", function()
			local last = vim.api.nvim_buf_line_count(Side.bufnr)
			Side.cursor = ((Side.cursor or 3) >= last) and 3 or (Side.cursor + 1)
			pcall(vim.api.nvim_win_set_cursor, Side.winid, { Side.cursor, 0 })
		end, "Siguiente item")
		nmap("<S-Tab>", function()
			local last = vim.api.nvim_buf_line_count(Side.bufnr)
			Side.cursor = ((Side.cursor or 3) <= 3) and last or (Side.cursor - 1)
			pcall(vim.api.nvim_win_set_cursor, Side.winid, { Side.cursor, 0 })
		end, "Item previo")

		-- Comandos rápidos dentro del panel:
		-- /  -> pedir filtro de texto
		nmap("/", function()
			if not (Side.winid and vim.api.nvim_win_is_valid(Side.winid)) then
				return
			end
			local ok, input = pcall(vim.fn.input, "Filtrar texto (/): ", Side.query or "")
			if ok then
				Side.query = tostring(input or ""):lower()
				vim.cmd("redraw")
			end
		end, "Filtrar texto")
		-- o  -> alternar orden
		nmap("o", function()
			Side.sort_mode = (Side.sort_mode == "sev_file") and "file_sev" or "sev_file"
			vim.cmd("redraw")
		end, "Alternar orden")
		-- + / - ancho
		nmap("<A-=>", function()
			Side.width = math.min(vim.o.columns - 10, Side.width + 6)
			vim.cmd("redraw")
		end, "Ancho +6")
		nmap("<A-->", function()
			Side.width = math.max(20, Side.width - 6)
			vim.cmd("redraw")
		end, "Ancho -6")
	end

	local function ensure_win()
		if Side.winid and vim.api.nvim_win_is_valid(Side.winid) then
			return
		end
		ensure_buf()
		local cols, lines = vim.o.columns, vim.o.lines
		local height = math.max(8, math.floor(lines * Side.heightF))
		local row = math.floor((lines - height) / 2) - 1
		if row < 0 then
			row = 0
		end
		local col = cols - Side.width - 1
		Side.winid = vim.api.nvim_open_win(Side.bufnr, false, {
			relative = "editor",
			row = row,
			col = math.max(0, col),
			width = math.min(Side.width, cols - 2),
			height = height,
			border = "rounded",
			noautocmd = true,
			focusable = true,
			style = "minimal",
		})
		local wo = vim.wo[Side.winid]
		wo.winhl = "Normal:NormalFloat,FloatBorder:FloatBorder,SignColumn:SignColumn"
		wo.wrap = false
		wo.number = false
		wo.relativenumber = false
		wo.cursorline = true
	end

	local function hl_for_sev(s)
		if s == sev.ERROR then
			return "DiagnosticError"
		elseif s == sev.WARN then
			return "DiagnosticWarn"
		elseif s == sev.INFO then
			return "DiagnosticInfo"
		else
			return "DiagnosticHint"
		end
	end

	local function fmt_loc(it)
		local fn = (it.filename or ""):match("[^/\\]+$") or ""
		if fn == "" then
			fn = "[buf]"
		end
		return string.format("%s:%d:%d", fn, (it.lnum or 0) + 1, (it.col or 0) + 1)
	end

	-- ==== WORKSPACE: recolecta de todos los buffers loaded ====
	local function collect_workspace_diags()
		local list = {}
		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(b) then
				local name = vim.api.nvim_buf_get_name(b)
				for _, d in ipairs(vim.diagnostic.get(b, { severity = Side.filter })) do
					local msg = (d.message or ""):gsub("%s+", " ")
					local lower = msg:lower()
					if
						Side.query == ""
						or lower:find(Side.query, 1, true)
						or (name:lower():find(Side.query, 1, true))
					then
						list[#list + 1] = {
							bufnr = b,
							filename = name,
							lnum = d.lnum or 0,
							col = d.col or 0,
							sev = d.severity,
							msg = msg,
						}
					end
				end
			end
		end
		-- Orden
		table.sort(list, function(a, b)
			if Side.sort_mode == "sev_file" then
				if a.sev ~= b.sev then
					return a.sev < b.sev
				end
				if a.filename ~= b.filename then
					return a.filename < b.filename
				end
			else -- file_sev
				if a.filename ~= b.filename then
					return a.filename < b.filename
				end
				if a.sev ~= b.sev then
					return a.sev < b.sev
				end
			end
			if a.lnum ~= b.lnum then
				return a.lnum < b.lnum
			end
			return a.col < b.col
		end)
		return list
	end

	local function render_side()
		if not Side.enabled then
			return
		end
		if vim.o.columns < Side.mincols then
			side_close()
			return
		end

		local items = collect_workspace_diags()
		if #items == 0 then
			side_close()
			return
		end

		ensure_win()
		vim.bo[Side.bufnr].modifiable = true
		vim.api.nvim_buf_set_lines(Side.bufnr, 0, -1, false, {})
		Side.idxmap = {}

		local counts = { err = 0, warn = 0, info = 0, hint = 0 }
		for _, it in ipairs(items) do
			if it.sev == sev.ERROR then
				counts.err = counts.err + 1
			elseif it.sev == sev.WARN then
				counts.warn = counts.warn + 1
			elseif it.sev == sev.INFO then
				counts.info = counts.info + 1
			else
				counts.hint = counts.hint + 1
			end
		end

		local header = string.format(
			' Workspace Diagnostics  E:%d  W:%d  I:%d  H:%d  | filter:"%s"  | order:%s',
			counts.err,
			counts.warn,
			counts.info,
			counts.hint,
			Side.query ~= "" and Side.query or "—",
			(Side.sort_mode == "sev_file") and "sev→file" or "file→sev"
		)
		local lines = { header, string.rep("─", math.max(20, math.min(Side.width - 2, #header))) }

		local icon = { [sev.ERROR] = "", [sev.WARN] = "", [sev.INFO] = "", [sev.HINT] = "󰌵" }
		for _, it in ipairs(items) do
			local msg = it.msg
			local room = Side.width - 12
			if room > 8 and #msg > room then
				msg = msg:sub(1, room) .. "…"
			end
			local line = string.format("%s  %s  %s", icon[it.sev] or "•", fmt_loc(it), msg)
			table.insert(lines, line)
		end

		vim.api.nvim_buf_set_lines(Side.bufnr, 0, -1, false, lines)
		vim.api.nvim_buf_clear_namespace(Side.bufnr, Side.ns, 0, -1)
		for i = 3, #lines do
			local it = items[i - 2]
			Side.idxmap[i] = it
			vim.api.nvim_buf_add_highlight(Side.bufnr, Side.ns, hl_for_sev(it.sev), i - 1, 0, -1)
		end
		vim.api.nvim_buf_add_highlight(Side.bufnr, Side.ns, "Title", 0, 0, -1)
		vim.bo[Side.bufnr].modifiable = false

		-- Mantener cursor visible
		local last = #lines
		if not Side.cursor or Side.cursor < 3 or Side.cursor > last then
			Side.cursor = 3
		end
		pcall(vim.api.nvim_win_set_cursor, Side.winid, { Side.cursor, 0 })
	end

	-- Debounce de actualizaciones y eventos robustos
	local uv = vim.uv or vim.loop
	local side_timer
	local function side_schedule()
		if not Side.enabled then
			return
		end
		if side_timer then
			side_timer:stop()
			side_timer:close()
		end
		side_timer = uv.new_timer()
		side_timer:start(
			80,
			0,
			vim.schedule_wrap(function()
				render_side()
			end)
		)
	end

	vim.api.nvim_create_autocmd({
		"VimEnter",
		"BufReadPost",
		"BufNewFile",
		"BufEnter",
		"BufWritePost",
		"BufWinEnter",
		"LspAttach",
		"LspDetach",
		"DiagnosticChanged",
		"VimResized",
		"BufDelete",
		"BufWipeout",
	}, {
		group = aug,
		callback = side_schedule,
	})

	-- Comandos del panel
	vim.api.nvim_create_user_command("DiagSide", function(opts)
		local arg = (opts.args or ""):lower()
		if arg == "on" then
			Side.enabled = true
		elseif arg == "off" then
			Side.enabled = false
			side_close()
			return
		else
			Side.enabled = not Side.enabled
			if not Side.enabled then
				side_close()
				return
			end
		end
		render_side()
	end, { nargs = "?", desc = "Alterna panel flotante de diagnósticos (workspace)" })

	vim.api.nvim_create_user_command("DiagSideSeverity", function(opts)
		local m = (opts.args or "all"):lower()
		local map = {
			all = nil,
			errwarn = { min = sev.ERROR, max = sev.WARN },
			error = { min = sev.ERROR, max = sev.ERROR },
			warn = { min = sev.WARN, max = sev.WARN },
			info = { min = sev.INFO, max = sev.INFO },
			hint = { min = sev.HINT, max = sev.HINT },
		}
		Side.filter = map[m]
		if Side.enabled then
			render_side()
		end
		vim.notify("DiagSideSeverity → " .. m:upper(), vim.log.levels.INFO, { title = "Diagnostics" })
	end, {
		nargs = "?",
		complete = function()
			return { "all", "errwarn", "error", "warn", "info", "hint" }
		end,
		desc = "Filtra severidad en panel flotante (workspace)",
	})

	vim.api.nvim_create_user_command("DiagSideFilter", function(opts)
		Side.query = (opts.args or ""):lower()
		if Side.enabled then
			render_side()
		end
		vim.notify(
			'DiagSideFilter → "' .. (Side.query ~= "" and Side.query or "—") .. '"',
			vim.log.levels.INFO,
			{ title = "Diagnostics" }
		)
	end, { nargs = "?", desc = "Filtrar por texto (mensaje/archivo) en panel flotante" })

	vim.api.nvim_create_user_command("DiagSideOrder", function()
		Side.sort_mode = (Side.sort_mode == "sev_file") and "file_sev" or "sev_file"
		if Side.enabled then
			render_side()
		end
		vim.notify(
			"DiagSideOrder → " .. ((Side.sort_mode == "sev_file") and "sev→file" or "file→sev"),
			vim.log.levels.INFO,
			{ title = "Diagnostics" }
		)
	end, { desc = "Alternar orden del panel (sev→file | file→sev)" })

	-- Helpers para atajos globales
	_G.__DiagSide_toggle = function()
		vim.cmd("DiagSide")
	end
	_G.__DiagSide_filter = function()
		vim.cmd("DiagSideFilter")
	end
	_G.__DiagSide_order = function()
		vim.cmd("DiagSideOrder")
	end
end

-- ===== Comandos misceláneos =====
vim.api.nvim_create_user_command("DiagToggleVT", function()
	local cfg = vim.diagnostic.config()
	local new = not (cfg.virtual_text == true or type(cfg.virtual_text) == "table")
	vim.diagnostic.config({
		virtual_text = new and { spacing = 2, prefix = "●" } or false,
	})
	vim.notify("Virtual Text: " .. (new and "ON" or "OFF"), vim.log.levels.INFO, { title = "Diagnostics" })
end, { desc = "Alterna virtual text de diagnósticos" })

-- =========================================================
--  ATAJOS GLOBALES (al final del archivo)
-- =========================================================
-- Flotante manual (con foco)
vim.keymap.set("n", "<leader>mf", function()
	vim.diagnostic.open_float(0, {
		scope = "cursor",
		border = "rounded",
		focusable = true,
		source = "if_many",
		severity = float_sev_filter,
	})
end, { desc = "Mostrar diagnóstico flotante (manual)" })

-- Toggle severidad del flotante: ALL ↔ ERR/WARN
vim.keymap.set("n", "<leader>me", function()
	local cfg = (float_sev_filter == nil) and "errwarn" or "all"
	vim.cmd("DiagFloatSeverity " .. cfg)
end, { desc = "Toggle float: All ↔ Error/Warn" })

-- Navegación entre diagnósticos
-- nativos: ]d / [d (todos)
vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = sev.ERROR, float = false })
end, { desc = "Siguiente ERROR" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = sev.ERROR, float = false })
end, { desc = "Anterior ERROR" })
vim.keymap.set("n", "]E", function()
	vim.diagnostic.goto_next({ severity = { min = sev.ERROR, max = sev.WARN }, float = false })
end, { desc = "Siguiente Error/Warn" })
vim.keymap.set("n", "[E", function()
	vim.diagnostic.goto_prev({ severity = { min = sev.ERROR, max = sev.WARN }, float = false })
end, { desc = "Anterior Error/Warn" })

-- Panel flotante (workspace)
vim.keymap.set("n", "<leader>xp", function()
	_G.__DiagSide_toggle()
end, { desc = "Toggle panel flotante de diagnósticos (workspace)" })
-- Filtro de texto del panel (invoca input)
vim.keymap.set("n", "<leader>xf", function()
	local ok, input = pcall(vim.fn.input, "DiagSide filter: ", "")
	if ok then
		vim.cmd("DiagSideFilter " .. input)
		if vim.fn.mode() ~= "n" then
			vim.cmd("stopinsert")
		end
	end
end, { desc = "Panel: filtrar por texto" })
-- Limpiar filtro rápidamente
vim.keymap.set("n", "<leader>xF", function()
	vim.cmd("DiagSideFilter")
end, { desc = "Panel: limpiar filtro" })
-- Alternar orden (sev→file | file→sev)
vim.keymap.set("n", "<leader>xo", function()
	_G.__DiagSide_order()
end, { desc = "Panel: alternar orden" })
