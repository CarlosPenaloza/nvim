local M = {}
local web_filetypes = {
	javascript = true,
	typescript = true,
	javascriptreact = true,
	typescriptreact = true,
}

function M.filetypes()
	local filetype = vim.bo.filetype
	local result = vim.split(filetype, ".", { plain = true })
	if not web_filetypes[filetype] then
		return result
	end
	local ok, node = pcall(vim.treesitter.get_node, { ignore_injections = true })
	if not ok then
		return result
	end
	while node do
		if node:type() == "template_substitution" then
			return result
		end
		if node:type() == "template_string" then
			local parent = node:parent()
			if parent and parent:type() == "call_expression" then
				local tag = parent:field("function")[1]
				if tag and vim.treesitter.get_node_text(tag, 0) == "html" then
					table.insert(result, 1, "html")
				end
			end
			return result
		end
		node = node:parent()
	end
	return result
end

return M
