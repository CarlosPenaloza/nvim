local root_markers = {
	{ "package-lock.json", "pnpm-lock.yaml", "yarn.lock", "bun.lock", "bun.lockb" },
	{ "tsconfig.json", "jsconfig.json", "package.json" },
	".git",
}

vim.lsp.config("vtsls", {
	filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	root_markers = root_markers,
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, root_markers)
		local deno = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })
		if root and (not deno or #deno < #root) then
			on_dir(root)
		end
	end,
	workspace_required = true,
	settings = {
		vtsls = {
			enableMoveToFileCodeAction = true,
			autoUseWorkspaceTsdk = true,
		},
		typescript = {
			tsserver = { pluginPaths = { "./node_modules" } },
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = false },
			},
			preferences = {
				importModuleSpecifier = "non-relative",
				quoteStyle = "auto",
			},
		},
		javascript = {
			updateImportsOnFileMove = { enabled = "always" },
			inlayHints = {
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = false },
			},
		},
	},
})

vim.lsp.enable("vtsls")

vim.api.nvim_create_user_command("LspOrganizeImports", function()
	vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
end, { desc = "Organize imports" })
