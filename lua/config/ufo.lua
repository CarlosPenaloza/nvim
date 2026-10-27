local ufo = require("ufo")
local web_filetypes = {
	javascript = true,
	typescript = true,
	javascriptreact = true,
	typescriptreact = true,
}

local function web_folds(bufnr)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if ok then
		parser:parse(true)
	end
	return ufo.getFolds(bufnr, "treesitter")
end

ufo.setup({
	open_fold_hl_timeout = 150,
	provider_selector = function(bufnr, filetype, buftype)
		if buftype ~= "" or not vim.api.nvim_buf_is_loaded(bufnr) or vim.b[bufnr].large_file then
			return ""
		end
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		local bytes = vim.api.nvim_buf_get_offset(bufnr, line_count)
		if bytes > 1.5 * 1024 * 1024 then
			return ""
		end
		if bytes > 200 * 1024 or line_count > 10000 then
			return { "indent" }
		end
		if web_filetypes[filetype] then
			return { web_folds, "indent" }
		end
		return { "treesitter", "indent" }
	end,
	fold_virt_text_handler = function(chunks, first_line, last_line, width, truncate)
		if width <= 0 then
			return {}
		end
		local suffix = ("  [%d lineas]"):format(last_line - first_line)
		local suffix_width = vim.fn.strdisplaywidth(suffix)
		if suffix_width >= width then
			return { { truncate(suffix, width), "UfoFoldedEllipsis" } }
		end
		local result, used = {}, 0
		local available = width - suffix_width
		for _, chunk in ipairs(chunks) do
			if used >= available then
				break
			end
			local text = chunk[1]
			if vim.fn.strdisplaywidth(text) > available - used then
				text = truncate(text, available - used)
			end
			table.insert(result, { text, chunk[2] })
			used = used + vim.fn.strdisplaywidth(text)
		end
		table.insert(result, { suffix, "UfoFoldedEllipsis" })
		return result
	end,
	preview = {
		win_config = { border = "rounded", winblend = 0, maxheight = 15 },
		mappings = { scrollU = "<C-u>", scrollD = "<C-d>", close = "q", switch = "<Tab>", trace = "<CR>" },
	},
})

vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Folds: abrir todos" })
vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Folds: cerrar todos" })
vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "Folds: abrir salvo grupos configurados" })
vim.keymap.set("n", "zm", ufo.closeFoldsWith, { desc = "Folds: cerrar hasta nivel indicado (cuenta)" })
vim.keymap.set("n", "zp", function()
	if not ufo.peekFoldedLinesUnderCursor() then
		vim.lsp.buf.hover()
	end
end, { desc = "Folds: vista previa o informacion LSP" })
