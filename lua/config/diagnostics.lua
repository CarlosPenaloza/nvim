-- lua/config/diagnostics.lua

-- (Opcional) Ajuste global de diagnósticos: sin texto inline
vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
})

-- Carga segura de Trouble
local ok, trouble = pcall(require, "trouble")
if not ok then
	vim.notify("trouble.nvim no está disponible", vim.log.levels.WARN)
	return
end

trouble.setup({
	use_diagnostic_signs = true,
	warn_no_results = false, -- ⬅️ no “No results for …”
	position = "right", -- valor por defecto; reforzamos en open()
	width = 50,
	auto_preview = false,
})

-- Estética y resize dentro del panel
vim.api.nvim_create_autocmd("FileType", {
	pattern = "trouble",
	callback = function()
		-- Hereda el tema (cámbialo a Normal si prefieres fondo normal)
		vim.opt_local.winhl = table.concat({
			"Normal:NormalFloat",
			"NormalNC:NormalFloat",
			"SignColumn:SignColumn",
			"LineNr:LineNr",
			"FloatBorder:FloatBorder",
		}, ",")
		-- Resize rápido desde dentro del panel
		local function vres(delta)
			vim.cmd(("vertical resize %s%d"):format(delta > 0 and "+" or "-", math.abs(delta)))
		end
		vim.keymap.set("n", "<A-=>", function()
			vres(6)
		end, { buffer = true, silent = true, desc = "Trouble ancho +6" })
		vim.keymap.set("n", "<A-->", function()
			vres(-6)
		end, { buffer = true, silent = true, desc = "Trouble ancho -6" })
		vim.keymap.set("n", "zl", function()
			vres(4)
		end, { buffer = true, silent = true })
		vim.keymap.set("n", "zh", function()
			vres(-4)
		end, { buffer = true, silent = true })
	end,
})

-- Cierra listas nativas para evitar el panel inferior
local function close_native_lists()
	pcall(vim.cmd, "lclose")
	pcall(vim.cmd, "cclose")
end

-- Abre Trouble del buffer actual forzando derecha
local function open_trouble_buf_right()
	trouble.open({
		mode = "diagnostics",
		filter = { buf = 0 },
		focus = false,
		win = { position = "right", width = 50 },
	})
end

-- Notificación “sin problemas” sólo si veníamos de tener errores
local had_nonzero = {} ---@type table<integer, boolean>
local function notify_clean(bufnr)
	if had_nonzero[bufnr] then
		vim.notify("✅ Sin problemas en este buffer", vim.log.levels.INFO, { title = "Diagnostics" })
	end
	had_nonzero[bufnr] = false
end

-- Debounce de actualizaciones (evita carreras con el LSP)
local last_timer
local function schedule_refresh(bufnr)
	if last_timer then
		last_timer:stop()
		last_timer:close()
	end
	last_timer = (vim.uv or vim.loop).new_timer()
	last_timer:start(60, 0, function()
		vim.schedule(function()
			bufnr = bufnr or 0
			local diags = vim.diagnostic.get(bufnr) or {}
			local count = #diags

			close_native_lists() -- no quickfix/location list

			if count == 0 then
				if trouble.is_open() then
					trouble.close()
				end
				notify_clean(bufnr)
			else
				had_nonzero[bufnr] = true
				open_trouble_buf_right()
			end
		end)
	end)
end

-- Refresca al cambiar diagnósticos y al guardar
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufWritePost" }, {
	callback = function(args)
		schedule_refresh(args.buf)
	end,
})

-- === Mostrar diagnóstico actual en la barra inferior ===
vim.api.nvim_create_autocmd({ "CursorHold" }, {
	callback = function()
		local opts = { focusable = false, border = "none", scope = "cursor" }
		local diags = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
		if #diags > 0 then
			-- Muestra solo el primer diagnóstico bajo el cursor (normalmente 1)
			local msg = diags[1].message:gsub("\n", " ")
			vim.api.nvim_echo({ { " " .. msg, "WarningMsg" } }, false, {})
		else
			-- Limpia el área si no hay mensaje
			vim.cmd("echo ''")
		end
	end,
})

-- Atajos (por si quieres abrir manualmente)
vim.keymap.set("n", "<leader>xx", function()
	trouble.toggle({ mode = "diagnostics" })
end, { desc = "Trouble: Diagnósticos (workspace)" })
vim.keymap.set("n", "<leader>xd", function()
	trouble.toggle({ mode = "diagnostics", filter = { buf = 0 }, focus = false })
end, { desc = "Trouble: Diagnósticos (buffer actual)" })
vim.keymap.set("n", "<leader>xs", function()
	trouble.toggle({ mode = "symbols", focus = false })
end, { desc = "Trouble: Símbolos LSP" })
vim.keymap.set("n", "<leader>xq", function()
	trouble.toggle({ mode = "qflist" })
end, { desc = "Trouble: Quickfix list" })
vim.keymap.set("n", "<leader>xl", function()
	trouble.toggle({ mode = "loclist" })
end, { desc = "Trouble: Location list" })
