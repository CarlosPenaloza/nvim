-- =============================
--  lua/config/lsp.lua (V3)
-- =============================
-- Requiere Neovim >= 0.11 y nvim-lspconfig reciente.

local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")

-- 1) Diagnósticos globales
vim.diagnostic.config({
	underline = true,
	virtual_text = { spacing = 2, prefix = "●" },
	signs = true,
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded", source = "if_many" },
})

-- Handlers con borde
local with_border = function(handler)
	return vim.lsp.with(handler, { border = "rounded" })
end
vim.lsp.handlers["textDocument/hover"] = with_border(vim.lsp.handlers.hover)
vim.lsp.handlers["textDocument/signatureHelp"] = with_border(vim.lsp.handlers.signature_help)

-- 2) Signs (ajusta a tu fuente)
local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- 3) Capacidades por defecto (con fallback)
local base_caps = vim.lsp.protocol.make_client_capabilities()
local default_caps = ok_cmp and cmp_lsp.default_capabilities(base_caps) or base_caps
vim.lsp.config("*", {
	capabilities = default_caps,
})

-- Wrapper inlay hints compatible 0.10/0.11
local function enable_inlay_hints(buf, enable)
	local ok = pcall(function()
		if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
			return vim.lsp.inlay_hint.enable(enable, { bufnr = buf })
		end
	end)
	if not ok then
		pcall(vim.lsp.inlay_hint, buf, true)
	end
end

-- 4) Keymaps/Extras en LspAttach (una sola vez por buffer)
local aug = vim.api.nvim_create_augroup("lsp-attach-keymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
	group = aug,
	callback = function(args)
		local buf = args.buf
		-- evita repetir en buffers con múltiples clientes
		if vim.b[buf].lsp_keymaps_set then
			return
		end
		vim.b[buf].lsp_keymaps_set = true

		enable_inlay_hints(buf, true)

		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
		end

		map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
		map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
		map("n", "gr", vim.lsp.buf.references, "LSP: References")
		map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
		map("n", "gl", vim.diagnostic.open_float, "LSP: Line diagnostics")
		map("n", "[d", vim.diagnostic.goto_prev, "LSP: Prev diagnostic")
		map("n", "]d", vim.diagnostic.goto_next, "LSP: Next diagnostic")
		map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename symbol")
		map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")

		-- Importante: NO mapear aquí <leader>f (lo gestiona tu format.lua)
	end,
})

-- 5) Servidores base
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("jsonls", {})
vim.lsp.config("cssls", {})
vim.lsp.config("html", {})
vim.lsp.config("bashls", {})
vim.lsp.config("pyright", {})
vim.lsp.config("custom_elements_ls", {
  filetypes = {
    "html",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
  },
})
vim.lsp.config("emmet_ls", {
  filetypes = {
    "html",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
  },
})

-- 6) Activación automática
vim.lsp.enable({ "lua_ls", "jsonls", "cssls", "html", "bashls", "pyright", "custom_elements_ls" })
