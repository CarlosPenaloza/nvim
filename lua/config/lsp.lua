-- lua/config/lsp.lua
-- LSP compacto, eficiente y “fail-safe”

-- ===== Requires seguros =====
local ok_lsp, lspconfig = pcall(require, "lspconfig")
if not ok_lsp then
	return
end

local util = require("lspconfig.util")

-- ===== Mason =====
local ok_mason, mason = pcall(require, "mason")
if ok_mason then
	mason.setup()
end

local ok_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
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
			-- tsserver se maneja aparte (config/lsp_ts.lua)
		},
		automatic_installation = true,
	})
end

local ok_mti, mti = pcall(require, "mason-tool-installer")
if ok_mti then
	mti.setup({
		ensure_installed = {
			-- Formatters / linters
			"prettierd",
			"prettier",
			"eslint_d",
			"jq",
			"stylua",
			"shfmt",
			"black",
			"ruff",
		},
		auto_update = false,
		run_on_start = true,
	})
end

-- ===== Capacidades (cmp) =====
local caps = (function()
	local ok_cmp, cmp_caps = pcall(require, "cmp_nvim_lsp")
	if ok_cmp then
		return cmp_caps.default_capabilities()
	end
	return vim.lsp.protocol.make_client_capabilities()
end)()

-- ===== Flags comunes =====
local LSP_FLAGS = { debounce_text_changes = 150 }

-- ===== Guard archivos grandes =====
local function on_init_largefile_stop(client)
	if vim.b.large_file then
		pcall(function()
			client.stop()
		end)
		return false
	end
	return true
end

-- ===== on_attach mínimo y veloz =====
local function on_attach(client, bufnr)
	if vim.b.large_file then
		client.server_capabilities.semanticTokensProvider = nil
		vim.diagnostic.disable(bufnr)
		pcall(function()
			client.stop()
		end)
		return
	end

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

-- ===== Diagnósticos globales =====
vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	float = { border = "rounded" },
	severity_sort = true,
})

-- ===== ESLint: iniciar solo si existe (local o global real) =====
local npm_root_g_cached ---@type string|nil
local function npm_root_g()
	if npm_root_g_cached ~= nil then
		return npm_root_g_cached
	end
	local ok, out = pcall(vim.fn.system, "npm root -g")
	out = ok and (out or ""):gsub("%s+$", "") or ""
	npm_root_g_cached = (out ~= "" and vim.fn.isdirectory(out) == 1) and out or nil
	return npm_root_g_cached
end

local function has_local_eslint(root)
	if not root or root == "" then
		return false
	end
	return vim.fn.isdirectory(util.path.join(root, "node_modules", "eslint")) == 1
end

local function has_global_eslint()
	local g = npm_root_g()
	return g and (vim.fn.isdirectory(util.path.join(g, "eslint")) == 1) or false
end

local function eslint_project_root(fname)
	return util.root_pattern(
		"eslint.config.js",
		"eslint.config.cjs",
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.json",
		"package.json"
	)(fname) or util.find_git_ancestor(fname)
end

lspconfig.eslint.setup({
	capabilities = caps,
	-- Si no hay eslint (local NI global) => root_dir = nil => NO inicia (sin warnings)
	root_dir = function(fname)
		local root = eslint_project_root(fname)
		if not root then
			return nil
		end
		if has_local_eslint(root) or has_global_eslint() then
			return root
		end
		return nil
	end,
	single_file_support = false, -- no adjuntar en archivos sueltos
	flags = LSP_FLAGS,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	settings = {
		workingDirectories = { mode = "auto" },
		codeAction = {
			disableRuleComment = { enable = true },
			showDocumentation = { enable = true },
		},
		nodePath = (function()
			local g = npm_root_g()
			if g and vim.fn.isdirectory(util.path.join(g, "eslint")) == 1 then
				return g
			end
			return nil
		end)(),
	},
})

-- ===== Resto de servidores =====
lspconfig.html.setup({ capabilities = caps, on_init = on_init_largefile_stop, on_attach = on_attach, flags = LSP_FLAGS })
lspconfig.cssls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	flags = LSP_FLAGS,
})
lspconfig.emmet_ls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	flags = LSP_FLAGS,
})
lspconfig.jsonls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	flags = LSP_FLAGS,
})
lspconfig.lua_ls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	flags = LSP_FLAGS,
	settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})
lspconfig.bashls.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	flags = LSP_FLAGS,
})
lspconfig.pyright.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	flags = LSP_FLAGS,
})
lspconfig.marksman.setup({
	capabilities = caps,
	on_init = on_init_largefile_stop,
	on_attach = on_attach,
	flags = LSP_FLAGS,
})

-- Fin
