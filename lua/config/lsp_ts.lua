-- lua/config/lsp_ts.lua
local caps = require("cmp_nvim_lsp").default_capabilities()

-- ===== Helpers para archivos grandes =====
local function largefile_on_attach_guard(client, bufnr)
	if vim.b[bufnr] and vim.b[bufnr].large_file then
		-- Apaga semántica y diagnósticos, y corta el cliente en este buffer
		client.server_capabilities.semanticTokensProvider = nil
		vim.diagnostic.disable(bufnr)
		pcall(function()
			client.stop()
		end)
		return true -- indica que ya manejamos el caso "grande"
	end
	return false
end

local function ts_on_attach(client, bufnr)
	if largefile_on_attach_guard(client, bufnr) then
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
	-- Nota: no mapeamos <leader>f aquí (lo llevas en config/format.lua)
end

-- ===== Opción A: typescript-tools.nvim (recomendada) =====
local ok, ts = pcall(require, "typescript-tools")
if ok then
	ts.setup({
		capabilities = caps,
		on_attach = ts_on_attach,
		settings = {
			-- Plugin global para templates de Lit
			tsserver_plugins = {
				"typescript-lit-html-plugin",
			},
			-- Opcional: fuerza la ruta de tsserver global si no hay local
			tsserver_path = vim.fn.exepath("tsserver"),
			-- (Opcional) deshabilitar formateo de tsserver si prefieres sólo Prettier:
			-- separate_diagnostic_server = true,
			-- publish_diagnostic_on = "insert_leave",
		},
	})
	return
end

-- ===== Opción B: Fallback con lspconfig.tsserver =====
local lspconfig = require("lspconfig")
lspconfig.tsserver.setup({
	capabilities = caps,
	on_attach = ts_on_attach,
	-- Para tsserver "puro", el plugin va en init_options.plugins
	init_options = {
		hostInfo = "neovim",
		plugins = {
			{ name = "typescript-lit-html-plugin" },
		},
	},
})
