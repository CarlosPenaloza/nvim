-- =====================================================================
--  lua/config/format.lua
-- =====================================================================

-- -------- Helpers básicos --------
local function _has_lsp_method(bufnr, method)
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if c.supports_method and c:supports_method(method) then
			return true
		end
	end
	return false
end

local function _line_len(bufnr, lnum1)
	local line = vim.api.nvim_buf_get_lines(bufnr, lnum1 - 1, lnum1, false)[1] or ""
	return #line
end

local function _mk_range_linewise(bufnr, s_row1, e_row1)
	if e_row1 < s_row1 then
		s_row1, e_row1 = e_row1, s_row1
	end
	return {
		start = { s_row1, 0 }, -- 1-based row, 0-based col
		["end"] = { e_row1, _line_len(bufnr, e_row1) }, -- hasta fin de línea
	}
end

-- Reindenta líneas con indentexpr / Treesitter (sin mover el cursor)
local function _reindent_lines(bufnr, s_row1, e_row1)
	local view = vim.fn.winsaveview()
	vim.api.nvim_buf_call(bufnr, function()
		vim.cmd(string.format("%d,%dnormal! ==", s_row1, e_row1))
	end)
	pcall(vim.fn.winrestview, view)
end

-- -------- Backend: Conform → fallback LSP --------
local function _format_range(bufnr, range)
	local ok_conform, conform = pcall(require, "conform")
	if ok_conform then
		local ok_call, err = pcall(function()
			conform.format({
				bufnr = bufnr,
				timeout_ms = 4000,
				quiet = true,
				lsp_fallback = false,
				range = range,
			}, function(cb_err)
				if cb_err then
					vim.notify("Formato (Conform) falló: " .. tostring(cb_err), vim.log.levels.WARN)
					if _has_lsp_method(bufnr, "textDocument/rangeFormatting") then
						vim.lsp.buf.format({
							bufnr = bufnr,
							async = false,
							timeout_ms = 3000,
							range = {
								start = { line = range.start[1] - 1, character = range.start[2] },
								["end"] = { line = range["end"][1] - 1, character = range["end"][2] },
							},
						})
					end
				end
			end)
		end)
		if ok_call then
			return
		end
		vim.notify("Conform lanzó excepción: " .. tostring(err), vim.log.levels.WARN)
	end

	-- LSP directo si no hay Conform
	if _has_lsp_method(bufnr, "textDocument/rangeFormatting") then
		vim.lsp.buf.format({
			bufnr = bufnr,
			async = false,
			timeout_ms = 3000,
			range = {
				start = { line = range.start[1] - 1, character = range.start[2] },
				["end"] = { line = range["end"][1] - 1, character = range["end"][2] },
			},
		})
	else
		vim.notify("No hay Conform ni LSP con rangeFormatting.", vim.log.levels.INFO)
	end
end

local function _format_full(bufnr)
	local ok_conform, conform = pcall(require, "conform")
	if ok_conform then
		local ok_call, err = pcall(function()
			conform.format({
				bufnr = bufnr,
				timeout_ms = 5000,
				quiet = true,
				lsp_fallback = true,
			})
		end)
		if ok_call then
			return
		end
		vim.notify("Conform lanzó excepción: " .. tostring(err), vim.log.levels.WARN)
	end

	if _has_lsp_method(bufnr, "textDocument/formatting") then
		vim.lsp.buf.format({ bufnr = bufnr, async = false, timeout_ms = 4000 })
	else
		vim.notify("No hay Conform ni LSP con formatting.", vim.log.levels.INFO)
	end
end

-- -------- Treesitter: calcula bloque (todo bajo pcall) --------
local function _ts_block_range_or_nil(bufnr, s_row1, e_row1)
	local ok_ts, _ = pcall(require, "vim.treesitter")
	if not ok_ts or type(vim.treesitter.get_node) ~= "function" then
		return nil
	end

	local mid_row0 = math.floor(((s_row1 - 1) + (e_row1 - 1)) / 2)
	local ok_node, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { mid_row0, 0 } })
	if not ok_node or not node then
		return nil
	end

	local ft = vim.bo[bufnr].filetype
	local preferred = {
		javascript = {
			"if_statement",
			"for_statement",
			"while_statement",
			"switch_statement",
			"function_declaration",
			"method_definition",
			"arrow_function",
			"class_declaration",
			"jsx_element",
			"jsx_fragment",
			"statement_block",
		},
		typescript = {
			"if_statement",
			"for_statement",
			"while_statement",
			"switch_statement",
			"function_declaration",
			"method_definition",
			"arrow_function",
			"class_declaration",
			"statement_block",
		},
		javascriptreact = {
			"if_statement",
			"for_statement",
			"while_statement",
			"switch_statement",
			"function_declaration",
			"method_definition",
			"arrow_function",
			"class_declaration",
			"jsx_element",
			"jsx_fragment",
			"statement_block",
		},
		typescriptreact = {
			"if_statement",
			"for_statement",
			"while_statement",
			"switch_statement",
			"function_declaration",
			"method_definition",
			"arrow_function",
			"class_declaration",
			"jsx_element",
			"jsx_fragment",
			"statement_block",
		},
		html = { "element" },
		css = { "rule_set", "block", "stylesheet" },
		scss = { "rule_set", "block", "stylesheet" },
		_default = { "block", "compound_statement", "statement_block" },
	}
	local target = preferred[ft] or preferred._default

	local function in_list(t, list)
		for _, x in ipairs(list) do
			if t == x then
				return true
			end
		end
		return false
	end

	local cur, chosen = node, nil
	while cur do
		local t = cur:type()
		if in_list(t, target) then
			chosen = cur
			break
		end
		cur = cur:parent()
	end
	if not chosen then
		return nil
	end

	local sr0, _, er0, _ = chosen:range()
	local sr1, er1 = sr0 + 1, er0 + 1
	pcall(
		vim.notify,
		("Formateando bloque: %s  L%d–L%d"):format(chosen:type(), sr1, er1),
		vim.log.levels.INFO,
		{ title = "Format (TS)" }
	)
	return _mk_range_linewise(bufnr, sr1, er1)
end

-- -------- Comandos --------
pcall(vim.api.nvim_del_user_command, "Format")
vim.api.nvim_create_user_command("Format", function()
	_format_full(vim.api.nvim_get_current_buf())
end, { desc = "Formatear buffer completo (Conform→LSP)" })

pcall(vim.api.nvim_del_user_command, "FormatSelection")
vim.api.nvim_create_user_command("FormatSelection", function(args)
	local bufnr = vim.api.nvim_get_current_buf()
	if args.range == 0 then
		vim.notify("Úsalo en Visual o con :'<,'>FormatSelection", vim.log.levels.INFO)
		return
	end
	local s_row1, e_row1 = args.line1, args.line2

	-- 1) Bloque con Treesitter si es posible
	local ts_range = _ts_block_range_or_nil(bufnr, s_row1, e_row1)
	local final_range = ts_range or _mk_range_linewise(bufnr, s_row1, e_row1)

	-- 2) Reindenta primero el rango (clave para indentación correcta)
	_reindent_lines(bufnr, final_range.start[1], final_range["end"][1])

	-- 3) Formatea rango (Conform → LSP)
	_format_range(bufnr, final_range)
end, { desc = "Formatear selección (bloque TS o líneas)", range = true })

-- -------- Keymap Visual --------
-- Usa el rango real :'<,'> para garantizar selección válida.
vim.keymap.set(
	"x",
	"<leader>f",
	[[:<C-U>'<,'>FormatSelection<CR>]],
	{ desc = "Formatear selección (bloque TS + reindent)" }
)
