local MAX_BYTES = 1.5 * 1024 * 1024
local saved = {}
local disabled_options = {
	foldenable = false,
	foldmethod = "manual",
	swapfile = false,
	undofile = false,
	list = false,
	wrap = false,
	colorcolumn = "",
	cursorline = false,
	syntax = "OFF",
}

local function large_on(bufnr)
	if saved[bufnr] then
		return
	end
	local state = { options = {}, clients = {}, diagnostics = vim.diagnostic.is_enabled({ bufnr = bufnr }) }
	saved[bufnr] = state
	vim.b[bufnr].large_file = true
	local ufo = package.loaded["ufo"]
	if ufo and ufo.hasAttached(bufnr) then
		state.ufo = true
		ufo.detach(bufnr)
	end
	vim.api.nvim_buf_call(bufnr, function()
		for name, value in pairs(disabled_options) do
			state.options[name] = vim.api.nvim_get_option_value(name, { scope = "local" })
			vim.api.nvim_set_option_value(name, value, { scope = "local" })
		end
	end)
	pcall(vim.treesitter.stop, bufnr)
	vim.diagnostic.enable(false, { bufnr = bufnr })
	vim.api.nvim_buf_call(bufnr, function()
		local ok, cmp = pcall(require, "cmp")
		if ok then
			state.completion = cmp.get_config().enabled
			cmp.setup.buffer({ enabled = false })
		end
	end)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		table.insert(state.clients, client.id)
		vim.lsp.buf_detach_client(bufnr, client.id)
	end
end

local function large_off(bufnr)
	local state = saved[bufnr]
	if not state then
		return
	end
	vim.b[bufnr].large_file = false
	vim.api.nvim_buf_call(bufnr, function()
		for name, value in pairs(state.options) do
			vim.api.nvim_set_option_value(name, value, { scope = "local" })
		end
	end)
	vim.diagnostic.enable(state.diagnostics, { bufnr = bufnr })
	vim.api.nvim_buf_call(bufnr, function()
		local ok, cmp = pcall(require, "cmp")
		if ok then
			cmp.setup.buffer({ enabled = state.completion })
		end
	end)
	for _, client_id in ipairs(state.clients) do
		if vim.lsp.get_client_by_id(client_id) then
			vim.lsp.buf_attach_client(bufnr, client_id)
		end
	end
	saved[bufnr] = nil
	vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr })
	local ufo = package.loaded["ufo"]
	if state.ufo and ufo then
		ufo.attach(bufnr)
	end
end

local group = vim.api.nvim_create_augroup("config-largefile", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
	group = group,
	callback = function(args)
		local stat = vim.uv.fs_stat(args.file)
		if stat and stat.size > MAX_BYTES then
			large_on(args.buf)
		end
	end,
})
vim.api.nvim_create_autocmd("BufWipeout", {
	group = group,
	callback = function(args)
		saved[args.buf] = nil
	end,
})

vim.api.nvim_create_user_command("LargeFileOn", function()
	large_on(vim.api.nvim_get_current_buf())
end, { desc = "Disable expensive features for this buffer" })
vim.api.nvim_create_user_command("LargeFileOff", function()
	large_off(vim.api.nvim_get_current_buf())
end, { desc = "Restore this buffer's options and LSP clients" })
vim.api.nvim_create_user_command("LargeFileToggle", function()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.b[bufnr].large_file then
		large_off(bufnr)
	else
		large_on(bufnr)
	end
end, { desc = "Toggle large file mode" })
