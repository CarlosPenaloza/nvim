local M = {}

local namespace = vim.api.nvim_create_namespace("method-complexity")
local group = vim.api.nvim_create_augroup("method-complexity", { clear = true })
local pending = {}

local supported_filetypes = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
}

local function_nodes = {
	arrow_function = true,
	function_declaration = true,
	function_expression = true,
	generator_function = true,
	generator_function_declaration = true,
	method_definition = true,
}

local branch_nodes = {
	catch_clause = true,
	do_statement = true,
	for_in_statement = true,
	for_statement = true,
	if_statement = true,
	switch_case = true,
	ternary_expression = true,
	while_statement = true,
}

local logical_operators = { ["&&"] = true, ["||"] = true, ["??"] = true }

local function limits(options)
	options = options or {}
	return options.limit or tonumber(vim.g.method_complexity_limit) or 10,
		options.margin or tonumber(vim.g.method_complexity_warning_margin) or 2
end

function M.classify(score, options)
	local limit, margin = limits(options)
	if score > limit then
		return "over"
	elseif score >= limit - margin then
		return "near"
	end
	return "good"
end

local function count_branches(node, root, score)
	if node ~= root and function_nodes[node:type()] then
		return
	end

	if branch_nodes[node:type()] then
		score.value = score.value + 1
	end
	if node:type() == "binary_expression" then
		for child in node:iter_children() do
			if logical_operators[child:type()] then
				score.value = score.value + 1
			end
		end
	end
	for child in node:iter_children() do
		count_branches(child, root, score)
	end
end

local function collect_methods(root)
	local methods = {}
	local function visit(node)
		if function_nodes[node:type()] then
			local score = { value = 1 }
			count_branches(node, node, score)
			local row = node:range()
			table.insert(methods, { row = row, score = score.value })
		end
		for child in node:iter_children() do
			visit(child)
		end
	end
	visit(root)
	return methods
end

function M.analyze(source, language)
	local ok, parser = pcall(vim.treesitter.get_string_parser, source, language)
	if not ok then
		return {}
	end
	local parsed, trees = pcall(parser.parse, parser, true)
	if not parsed or not trees or not trees[1] then
		return {}
	end

	return collect_methods(trees[1]:root())
end

local function is_large(buf)
	return vim.b[buf].large_file
		or vim.api.nvim_buf_line_count(buf) > 10000
		or vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) > 500 * 1024
end

local function update(buf)
	pending[buf] = nil
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
	if vim.g.method_complexity_enabled == false or not supported_filetypes[vim.bo[buf].filetype] or is_large(buf) then
		return
	end

	local ok, parser = pcall(vim.treesitter.get_parser, buf)
	if not ok then
		return
	end
	local parsed, trees = pcall(parser.parse, parser, true)
	if not parsed or not trees or not trees[1] then
		return
	end
	local methods = collect_methods(trees[1]:root())
	local labels = {
		good = { "●", "MethodComplexityGood" },
		near = { "▲", "MethodComplexityNear" },
		over = { "✖", "MethodComplexityOver" },
	}
	for _, method in ipairs(methods) do
		local label = labels[M.classify(method.score)]
		vim.api.nvim_buf_set_extmark(buf, namespace, method.row, 0, {
			virt_text = { { (" %s %d"):format(label[1], method.score), label[2] } },
			virt_text_pos = "eol",
			priority = 110,
		})
	end
end

local function schedule_update(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local token = {}
	pending[buf] = token
	vim.defer_fn(function()
		if pending[buf] == token then
			update(buf)
		end
	end, 250)
end

local function apply_highlights()
	vim.api.nvim_set_hl(0, "MethodComplexityGood", { link = "DiagnosticOk" })
	vim.api.nvim_set_hl(0, "MethodComplexityNear", { link = "DiagnosticWarn" })
	vim.api.nvim_set_hl(0, "MethodComplexityOver", { link = "DiagnosticError" })
end

apply_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = apply_highlights,
})

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
	group = group,
	callback = function(args)
		schedule_update(args.buf)
	end,
})
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	group = group,
	callback = function(args)
		schedule_update(args.buf)
	end,
})
vim.api.nvim_create_autocmd("BufWipeout", {
	group = group,
	callback = function(args)
		pending[args.buf] = nil
	end,
})

vim.g.method_complexity_enabled = vim.g.method_complexity_enabled ~= false
vim.api.nvim_create_user_command("ComplexityToggle", function()
	vim.g.method_complexity_enabled = not vim.g.method_complexity_enabled
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			schedule_update(buf)
		end
	end
end, { desc = "Toggle method complexity indicators" })

return M