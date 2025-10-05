-- =============================
--  lua/config/lsp_ts.lua (V3)
-- =============================
-- Setup específico para TypeScript/JavaScript usando VTSLS (recomendado) o fallback ts_ls.

local has_vtsls, _ = pcall(require, "vtsls")
local util = require("lspconfig.util")
local configs = require("lspconfig.configs")

if has_vtsls then
	if not configs.vtsls then
		configs.vtsls = require("vtsls").lspconfig
	end

	vim.lsp.config("vtsls", {
		filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		root_dir = util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git"),
		-- Para excluir Deno explícitamente, usa este root_dir en su lugar:
		-- root_dir = function(fname)
		--   if util.root_pattern('deno.json', 'deno.jsonc')(fname) then return nil end
		--   return util.root_pattern('tsconfig.json', 'package.json', 'jsconfig.json', '.git')(fname)
		-- end,

		single_file_support = false,

		settings = {
			vtsls = {
				enableMoveToFileCodeAction = true,
				autoUseWorkspaceTsdk = true,
			},
			typescript = {
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
				format = { semicolons = "insert" },
			},
			javascript = {
				inlayHints = {
					enumMemberValues = { enabled = true },
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
else
	-- Fallback: typescript-language-server (alias ts_ls en lspconfig recientes)
	vim.lsp.config("ts_ls", {
		root_dir = util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git"),
		single_file_support = false,
		settings = {
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "literals",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = false,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
				preferences = {
					includeCompletionsForModuleExports = true,
					includeCompletionsWithClassMemberSnippets = true,
					importModuleSpecifierPreference = "non-relative",
				},
			},
			javascript = {
				inlayHints = {
					includeInlayParameterNameHints = "literals",
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = false,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
				},
			},
		},
	})

	vim.lsp.enable("ts_ls")
end

-- Helper: Organize Imports (usa VtsExec si existe, si no, code action estándar)
vim.api.nvim_create_user_command("LspOrganizeImports", function()
	if vim.fn.exists(":VtsExec") == 2 then
		vim.cmd("VtsExec organize_imports")
	else
		vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
	end
end, { desc = "Organize imports (vtsls/tsserver)" })
