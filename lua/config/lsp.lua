-- lua/config/lsp.lua
local ok_lsp, lspconfig = pcall(require, "lspconfig")
if not ok_lsp then
	return
end

local ok_mason, mason = pcall(require, "mason")
local ok_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
local ok_mti, mti = pcall(require, "mason-tool-installer")

if ok_mason then
	mason.setup()
end

-- Auto-instalar formatters/linters con Mason (igual que tenías)
if ok_mti then
	mti.setup({
		ensure_installed = {
			-- JS/TS
			"prettierd",
			"prettier",
			"eslint_d",
			-- Otros que ya usas en conform
			"jq", -- JSON
			"stylua", -- Lua
			"shfmt", -- Shell
			"black", -- Python
			"ruff", -- Python (para ruff_format)
		},
		auto_update = false,
		run_on_start = true,
	})
end

if ok_mlsp then
	mason_lspconfig.setup({
		ensure_installed = {
			"eslint",
			"html",
			"cssls",
			"emmet_ls",
			"jsonls",
			"lua_ls",
			"bashls",
			"pyright",
			"marksman",
			-- tsserver lo manejas en config/lsp_ts.lua
		},
		automatic_installation = true,
	})
end

local caps = require("cmp_nvim_lsp").default_capabilities()

-- Early stop para buffers marcados como "grandes" antes de adjuntar
local function on_init_largefile_stop(client)
	if vim.b.large_file then
		pcall(function()
			client.stop()
		end)
		return false
	end
	return true
end

-- on_attach con guard para archivos grandes
local function on_attach(client, bufnr)
	if vim.b[bufnr] and vim.b[bufnr].large_file then
		-- Cortamos capacidades pesadas y diagnósticos en este buffer
		client.server_capabilities.semanticTokensProvider = nil
		vim.diagnostic.disable(bufnr)
		pcall(function()
			client.stop()
		end)
		return
	end

	-- Mapeos LSP (sin <leader>f> para no chocar con config/format.lua)
	local map = function(mode, lhs, rhs)
		vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = bufnr })
	end

	map("n", "K", vim.lsp.buf.hover)
	map("n", "gd", vim.lsp.buf.definition)
	map("n", "gi", vim.lsp.buf.implementation)
	map("n", "gr", vim.lsp.buf.references)
	map("n", "gy", vim.lsp.buf.type_definition)
	map("n", "]g", vim.diagnostic.goto_next)
	map("n", "[g", vim.diagnostic.goto_prev)
	map("n", "<leader>rn", vim.lsp.buf.rename)
end

-- Diagnósticos globales
vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	float = { border = "rounded" },
	severity_sort = true,
})

-- ========================
-- Configuración por servidor
-- ========================

-- ESLint: autodetección de directorios (útil en monorepos)
lspconfig.eslint.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	settings = {
		workingDirectories = { mode = "auto" },
		-- packageManager = "npm", -- o "yarn" / "pnpm" si aplica
	},
})

lspconfig.html.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
})

lspconfig.cssls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
})

lspconfig.emmet_ls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
})

lspconfig.jsonls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
})

lspconfig.lua_ls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
		},
	},
})

lspconfig.bashls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
})

lspconfig.pyright.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
})

lspconfig.marksman.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
})
