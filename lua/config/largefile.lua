-- lua/config/largefile.lua

local MAX_BYTES = 1.5 * 1024 * 1024 -- 1.5 MB

local function is_large(path)
	local stat = vim.loop.fs_stat(path or "")
	return stat and stat.size and stat.size > MAX_BYTES
end

-- === Auto detectar al abrir ===
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(args)
		local fname = args.file
		if fname == "" or not is_large(fname) then
			return
		end

		vim.b.large_file = true

		-- Desactiva cosas costosas
		pcall(vim.cmd, "syntax off")
		vim.opt_local.foldenable = false
		vim.opt_local.foldmethod = "manual"
		vim.opt_local.swapfile = false
		vim.opt_local.undofile = false
		vim.opt_local.list = false
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = ""
		vim.opt_local.cursorline = false
		vim.opt_local.hlsearch = false
		vim.opt_local.incsearch = false

		-- Treesitter
		local ok_ts, _ = pcall(require, "nvim-treesitter.configs")
		if ok_ts then
			vim.treesitter.stop()
		end

		vim.schedule(function()
			vim.notify(
				("Modo archivo grande (> %.1f MB): sintaxis/TS off, folds off, sin swap/undo."):format(
					MAX_BYTES / (1024 * 1024)
				),
				vim.log.levels.INFO
			)
		end)
	end,
})

-- === Funciones manuales ===
local function large_on(bufnr)
	bufnr = bufnr or 0
	vim.b[bufnr].large_file = true

	pcall(vim.cmd, "syntax off")
	vim.opt_local.foldenable = false
	vim.opt_local.foldmethod = "manual"
	vim.opt_local.swapfile = false
	vim.opt_local.undofile = false
	vim.opt_local.list = false
	vim.opt_local.wrap = false
	vim.opt_local.colorcolumn = ""
	vim.opt_local.cursorline = false
	vim.opt_local.hlsearch = false
	vim.opt_local.incsearch = false

	pcall(vim.treesitter.stop)
	vim.diagnostic.disable(bufnr)

	local ok_cmp, cmp = pcall(require, "cmp")
	if ok_cmp then
		cmp.setup.buffer({ enabled = false })
	end

	for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
		pcall(function()
			client.stop()
		end)
	end

	vim.notify("Modo archivo grande: ACTIVADO en este buffer", vim.log.levels.INFO)
end

local function large_off(bufnr)
	bufnr = bufnr or 0
	vim.b[bufnr].large_file = false

	pcall(vim.cmd, "syntax enable")
	vim.opt_local.foldmethod = "expr"
	vim.opt_local.foldenable = false
	vim.opt_local.swapfile = true
	vim.opt_local.undofile = true
	vim.opt_local.list = false
	vim.opt_local.wrap = false
	vim.opt_local.colorcolumn = ""
	vim.opt_local.cursorline = true
	vim.opt_local.hlsearch = true
	vim.opt_local.incsearch = true

	pcall(vim.treesitter.start)
	vim.diagnostic.enable(bufnr)

	local ok_cmp, cmp = pcall(require, "cmp")
	if ok_cmp then
		cmp.setup.buffer({ enabled = true })
	end

	-- Rearranque de LSP
	pcall(vim.cmd, "LspStart")
	pcall(vim.cmd, "LspStart typescript-tools")

	vim.notify("Modo archivo grande: DESACTIVADO en este buffer", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("LargeFileOn", function()
	large_on(0)
end, {})
vim.api.nvim_create_user_command("LargeFileOff", function()
	large_off(0)
end, {})
vim.api.nvim_create_user_command("LargeFileToggle", function()
	if vim.b.large_file then
		large_off(0)
	else
		large_on(0)
	end
end, {})
