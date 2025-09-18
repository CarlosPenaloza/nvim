-- lua/config/lsp_ts.lua
-- TS/JS LSP: vtsls ▸ typescript-tools.nvim ▸ tsserver (fallback)
-- Instala vtsls con Mason si falta, configura React/Lit, sin formateo (Prettier/Conform)

-- ========= Capacidades (cmp) =========
local caps = (function()
	local ok, cmp = pcall(require, "cmp_nvim_lsp")
	return ok and cmp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()
end)()

-- ========= Guard archivos grandes =========
local function large_guard(client, bufnr)
	if vim.b.large_file then
		client.server_capabilities.semanticTokensProvider = nil
		client.server_capabilities.documentFormattingProvider = false
		vim.diagnostic.disable(bufnr)
		pcall(function()
			client.stop()
		end)
		return true
	end
	return false
end

-- ========= on_attach común =========
local function on_attach_ts(client, bufnr)
	if large_guard(client, bufnr) then
		return
	end

	-- Formateo por Prettier/Conform
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false

	local map = function(m, lhs, rhs)
		vim.keymap.set(m, lhs, rhs, { silent = true, buffer = bufnr })
	end
	map("n", "K", vim.lsp.buf.hover)
	map("n", "gd", vim.lsp.buf.definition)
	map("n", "gi", vim.lsp.buf.implementation)
	map("n", "gr", vim.lsp.buf.references)
	map("n", "gy", vim.lsp.buf.type_definition)
	map("n", "]g", vim.diagnostic.goto_next)
	map("n", "[g", vim.diagnostic.goto_prev)
	map("n", "<leader>rn", vim.lsp.buf.rename)

	if vim.lsp.inlay_hint then
		pcall(vim.lsp.inlay_hint, bufnr, true)
	end
end

-- ========= Preferencias comunes (React/Lit) =========
local FILE_PREFS = {
	-- React/JSX moderno
	jsxPreference = "react-jsx",
	preferTypeOnlyAutoImports = true,
	includeCompletionsForModuleExports = true,
	includeCompletionsWithSnippetText = true,
	includeCompletionsWithInsertTextCompletions = true,
	-- Inlay hints
	includeInlayParameterNameHints = "all",
	includeInlayParameterNameHintsWhenArgumentMatchesName = false,
	includeInlayFunctionParameterTypeHints = true,
	includeInlayVariableTypeHints = true,
	includeInlayPropertyDeclarationTypeHints = true,
	includeInlayFunctionLikeReturnTypeHints = true,
	includeInlayEnumMemberValueHints = true,
}

-- ========= Utilidades Mason (instalar desde este archivo) =========
local function mason_pkg(name)
	local ok, mr = pcall(require, "mason-registry")
	if not ok then
		return nil
	end
	if not mr.is_installed and mr.refresh then
		-- mason-registry API antigua: refrescamos para seguridad
		mr.refresh()
	end
	local ok_pkg, pkg = pcall(mr.get_package, name)
	return ok_pkg and pkg or nil
end

local function ensure_mason(pkgs)
	local ok, mr = pcall(require, "mason-registry")
	if not ok then
		return
	end
	mr.refresh(function()
		for _, name in ipairs(pkgs) do
			local ok_pkg, pkg = pcall(mr.get_package, name)
			if ok_pkg and not pkg:is_installed() then
				pkg:install()
				pkg:on("install:success", function()
					vim.schedule(function()
						vim.notify(
							("[Mason] %s instalado. Reinicia Neovim para activarlo."):format(name),
							vim.log.levels.INFO
						)
					end)
				end)
			end
		end
	end)
end

-- Pedimos estos paquetes; el esencial es vtsls. TLS es opcional por si luego quisieras usarlo.
ensure_mason({ "vtsls", "typescript-language-server" })

-- ========= Setup con orden preferido =========
local ok_lspc, lspconfig = pcall(require, "lspconfig")
if not ok_lspc then
	return
end

local function has_exec(bin)
	return vim.fn.executable(bin) == 1
end

local function setup_vtsls()
	lspconfig.vtsls.setup({
		capabilities = caps,
		on_attach = on_attach_ts,
		single_file_support = true,
		settings = {
			vtsls = {
				tsserver = {
					-- Plugins TS globales (se activan si existen en node_modules del proyecto)
					globalPlugins = {
						{ name = "typescript-lit-html-plugin" }, -- LitElement (opcional)
					},
				},
			},
			typescript = { preferences = FILE_PREFS, format = { semicolons = "insert" } },
			javascript = { preferences = FILE_PREFS, format = { semicolons = "insert" } },
		},
	})
end

local function setup_typescript_tools()
	local ok_tts, tts = pcall(require, "typescript-tools")
	if not ok_tts then
		return false
	end
	tts.setup({
		capabilities = caps,
		on_attach = on_attach_ts,
		single_file_support = true,
		settings = {
			tsserver_plugins = { "typescript-lit-html-plugin" }, -- Lit templates
			tsserver_file_preferences = FILE_PREFS,
			tsserver_format_options = {
				allowIncompleteCompletions = true,
				allowRenameOfImportPath = true,
			},
			separate_diagnostic_server = true,
			publish_diagnostic_on = "insert_leave",
			-- tsserver_max_memory = 4096, -- descomenta si monorepos gigantes
		},
	})
	return true
end

local function setup_tsserver()
	lspconfig.tsserver.setup({
		capabilities = caps,
		on_attach = on_attach_ts,
		init_options = {
			hostInfo = "neovim",
			preferences = FILE_PREFS,
			plugins = { { name = "typescript-lit-html-plugin" } },
		},
	})
	vim.schedule(function()
		vim.notify(
			"[tsserver] usado como fallback. Cuando Mason termine de instalar vtsls, reinicia Neovim.",
			vim.log.levels.WARN
		)
	end)
end

-- ¿Está vtsls disponible ya? (por Mason o PATH)
local vtsls_pkg = mason_pkg("vtsls")
local vtsls_installed = (vtsls_pkg and vtsls_pkg:is_installed()) or has_exec("vtsls")

if vtsls_installed and lspconfig.vtsls then
	-- 1) vtsls (preferido)
	setup_vtsls()
else
	-- 2) typescript-tools.nvim (si el plugin está presente)
	local ok_tts = setup_typescript_tools()
	if not ok_tts then
		-- 3) Fallback final: tsserver
		setup_tsserver()
	end
end
