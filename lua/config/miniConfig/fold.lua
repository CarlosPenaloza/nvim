-- =============================
--  lua/config/fold.lua
-- =============================

-- Fallback si no hay Treesitter cargado
if not pcall(require, "nvim-treesitter") then
	vim.o.foldmethod = "indent"
end

-- Protege carga de mini.fold
local ok, fold = pcall(require, "mini.fold")
if not ok then
	return
end

fold.setup({
	text = function(section, _, line_count, first_line)
		local icon = ""
		local line = first_line:gsub("^%s+", ""):gsub("%s+$", "")
		if #line > 80 then
			line = line:sub(1, 77) .. "…"
		end
		return string.format(" %s %s  · %d líneas ", icon, line, line_count)
	end,
	mappings = {
		close = "zc",
		open = "zo",
		toggle = "za",
		open_all = "zR",
		close_all = "zM",
	},
})

-- Opcional: desactivar mini.fold en archivos muy grandes
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(args)
		local bufnr = args.buf
		if _G.BigFile and _G.BigFile.state and _G.BigFile.state[bufnr] then
			vim.b.minifold_disable = true
			vim.o.foldmethod = "manual"
		end
	end,
})
