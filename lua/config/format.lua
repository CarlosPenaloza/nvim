local M = {}

function M.selection(first_line, last_line, first_column, last_column)
	local bufnr = vim.api.nvim_get_current_buf()
	local conform = require("conform")
	local original = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local offsets = { 0 }
	for _, line in ipairs(original) do
		table.insert(offsets, offsets[#offsets] + #line + 1)
	end
	local lower = offsets[first_line] + (first_column or 0)
	local upper = last_column and offsets[last_line] + last_column or offsets[last_line + 1]
	local formatters = conform.resolve_formatters(conform.list_formatters_for_buffer(bufnr), bufnr, false)
	if #formatters == 0 then
		vim.notify("Formato: no hay formateador disponible; consulta :ConformInfo", vim.log.levels.WARN)
		return
	end
	local range = {
		start = { first_line, first_column or 0 },
		["end"] = { last_line, last_column or #original[last_line] },
	}
	local err, formatted = require("conform.runner").format_lines_sync(bufnr, formatters, 5000, range, original, {
		exclusive = false,
		dry_run = false,
		undojoin = false,
	})
	if err or not formatted then
		vim.notify("Formato: " .. tostring(err and err.message or "no hay formateador disponible"), vim.log.levels.WARN)
		return
	end
	local hunks = vim.diff(table.concat(original, "\n") .. "\n", table.concat(formatted, "\n") .. "\n", {
		result_type = "indices",
		algorithm = "minimal",
	})
	local text = table.concat(original, "\n") .. "\n"
	local skipped = false
	for index = #hunks, 1, -1 do
		local hunk = hunks[index]
		local old_chunk = table.concat(vim.list_slice(original, hunk[1], hunk[1] + hunk[2] - 1), "\n")
		local new_chunk = table.concat(vim.list_slice(formatted, hunk[3], hunk[3] + hunk[4] - 1), "\n")
		old_chunk = hunk[2] > 0 and old_chunk .. "\n" or ""
		new_chunk = hunk[4] > 0 and new_chunk .. "\n" or ""
		local prefix, suffix = 0, 0
		while prefix < math.min(#old_chunk, #new_chunk) and old_chunk:byte(prefix + 1) == new_chunk:byte(prefix + 1) do
			prefix = prefix + 1
		end
		while
			suffix < math.min(#old_chunk, #new_chunk) - prefix
			and old_chunk:byte(#old_chunk - suffix) == new_chunk:byte(#new_chunk - suffix)
		do
			suffix = suffix + 1
		end
		local start = offsets[hunk[2] == 0 and hunk[1] + 1 or hunk[1]] + prefix
		local finish = start + #old_chunk - prefix - suffix
		if start >= lower and finish <= upper then
			text = text:sub(1, start) .. new_chunk:sub(prefix + 1, #new_chunk - suffix) .. text:sub(finish + 1)
		elseif finish > lower and start < upper then
			skipped = true
		end
	end
	local result = vim.split(text:sub(1, -2), "\n", { plain = true })
	if not vim.deep_equal(original, result) then
		local prefix, suffix = 0, 0
		while prefix < math.min(#original, #result) and original[prefix + 1] == result[prefix + 1] do
			prefix = prefix + 1
		end
		while
			suffix < math.min(#original, #result) - prefix
			and original[#original - suffix] == result[#result - suffix]
		do
			suffix = suffix + 1
		end
		local view = vim.fn.winsaveview()
		vim.api.nvim_buf_set_lines(
			bufnr,
			prefix,
			#original - suffix,
			false,
			vim.list_slice(result, prefix + 1, #result - suffix)
		)
		vim.fn.winrestview(view)
	end
	if skipped then
		vim.notify(
			"Formato: se omitieron cambios que salen de la seleccion; amplia la seleccion si es necesario.",
			vim.log.levels.INFO
		)
	end
end

vim.api.nvim_create_user_command("Format", function()
	require("conform").format({ async = false, timeout_ms = 5000, lsp_format = "fallback" })
end, { desc = "Formatear archivo completo" })

vim.api.nvim_create_user_command("FormatSelection", function(args)
	if args.range == 0 then
		vim.notify("Selecciona codigo o usa :inicio,fin FormatSelection", vim.log.levels.INFO)
		return
	end
	M.selection(args.line1, args.line2)
end, { range = true, desc = "Formatear solo las lineas seleccionadas" })

vim.keymap.set("n", "<leader>F", "<cmd>Format<cr>", { desc = "Formatear archivo completo" })
vim.keymap.set("x", "<leader>f", function()
	local mode = vim.fn.mode()
	if mode == "\22" then
		vim.notify("Formato: usa seleccion de lineas o caracteres, no bloque rectangular.", vim.log.levels.INFO)
		return
	end
	local anchor, cursor = vim.fn.getpos("v"), vim.fn.getpos(".")
	if anchor[2] > cursor[2] or (anchor[2] == cursor[2] and anchor[3] > cursor[3]) then
		anchor, cursor = cursor, anchor
	end
	local first_column, last_column
	if mode ~= "V" then
		first_column = anchor[3] - 1
		local line = vim.api.nvim_buf_get_lines(0, cursor[2] - 1, cursor[2], false)[1]
		last_column = cursor[3] - 1
		if vim.o.selection ~= "exclusive" then
			last_column = math.min(#line, last_column + #vim.fn.strcharpart(line:sub(last_column + 1), 0, 1))
		end
	end
	vim.cmd("normal! \27")
	M.selection(anchor[2], cursor[2], first_column, last_column)
end, { desc = "Formatear solo la seleccion" })

return M
