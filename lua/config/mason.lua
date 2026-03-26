-- =====================================================================
--  lua/config/mason.lua
--  Instala servidores LSP y formateadores (CLI) automáticamente
-- =====================================================================

-- Mason base: añade los binarios de Mason al PATH de Neovim
require("mason").setup({
	PATH = "prepend", -- asegura que <stdpath('data')/mason/bin> esté al inicio
	ui = { border = "rounded" },
})

-- LSP servers via mason-lspconfig
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"jsonls",
		"cssls",
		"custom_elements_ls",
		"html",
		"emmet_ls",
		"bashls",
		"pyright",
		"vtsls", -- TypeScript: vtsls (preferido)
		"ts_ls", -- fallback tsserver (typescript-language-server)
	},
	automatic_installation = true,
})

-- Herramientas CLI (formateadores/linters) via mason-tool-installer
require("mason-tool-installer").setup({
	ensure_installed = {
		-- Formateadores que usará Conform
		"prettier", -- TS/JS/HTML/CSS/JSON/MD (lo pediste como único para TS/JS)
		"stylua", -- Lua
		"shfmt", -- Shell
	},
	run_on_start = true, -- instala/actualiza al arrancar (si faltan)
	auto_update = false, -- si quieres actualizar siempre, pon true
	start_delay = 0, -- sin retraso
	debounce_hours = 5, -- evita reinstalar seguido
})
