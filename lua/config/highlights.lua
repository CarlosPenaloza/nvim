local function apply()
	local links = {
		["@function"] = "Function",
		["@function.method"] = "Function",
		["@property"] = "Special",
		["@variable.member"] = "@property",
		["@variable.parameter"] = "Identifier",
		["@variable.builtin.this"] = "Normal",
		["@tag"] = "Type",
		["@tag.attribute"] = "Identifier",
		["@tag.attribute.lit.event"] = "@function",
		["@tag.attribute.lit.property"] = "@property",
		["@tag.attribute.lit.boolean"] = "@boolean",
		["@comment.documentation"] = "Comment",
		["@lsp.type.function"] = "@function",
		["@lsp.type.method"] = "@function.method",
		["@lsp.type.parameter"] = "@variable.parameter",
		["@lsp.type.property"] = "@property",
	}
	for name, target in pairs(links) do
		vim.api.nvim_set_hl(0, name, { link = target })
	end
	for _, name in ipairs({ "variable", "string", "comment" }) do
		vim.api.nvim_set_hl(0, "@lsp.type." .. name, {})
	end
	if vim.g.colors_name == "gruvbox" then
		vim.api.nvim_set_hl(0, "Comment", {
			fg = vim.o.background == "dark" and "#a89984" or "#665c54",
			italic = true,
		})
	end
	for _, severity in ipairs({ "Error", "Warn", "Info", "Hint" }) do
		local color = vim.api.nvim_get_hl(0, { name = "Diagnostic" .. severity, link = false }).fg
		vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. severity, { fg = color })
		vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. severity, { sp = color, undercurl = true })
	end
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("config-code-highlights", { clear = true }),
	callback = apply,
})

if vim.g.colors_name then
	apply()
end

return { apply = apply }
