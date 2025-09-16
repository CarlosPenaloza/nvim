-- lua/index.lua

-- ===== Settings base =====
pcall(require, "options")
pcall(require, "config.globals")

-- ===== Tema por defecto (opcional) =====
vim.cmd.colorscheme("gruvbox")
vim.api.nvim_create_user_command("ThemeToggle", function()
	local c = vim.g.colors_name
	if c == "gruvbox" then
		vim.cmd.colorscheme("catppuccin")
	else
		vim.cmd.colorscheme("gruvbox")
	end
end, {})

-- ===== Cargar configs de plugins cuando lazy esté listo =====
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		-- UI / Utilidades
		pcall(require, "config.telescope")
		pcall(require, "config.catppuccin")
		pcall(require, "config.devicons") -- si lo usas
		pcall(require, "config.bufferline")
		pcall(require, "config.mini")
		pcall(require, "config.lualine")
		pcall(require, "config.gitsigns")
		pcall(require, "config.treesitter")
		pcall(require, "config.other-pluggins-config")
		pcall(require, "config.largefile")

		-- ===== LSP / Completion / Format =====
		-- Servidores base (html, cssls, jsonls, eslint, lua_ls, bashls, pyright, marksman, emmet_ls, etc.)
		pcall(require, "config.lsp")

		-- TypeScript/Lit global (elige tu implementación: typescript-tools o lspconfig puro)
		pcall(require, "config.lsp_ts")

		-- Autocompletado (nvim-cmp + luasnip + lspkind)
		pcall(require, "config.cmp")

		-- Formateo (conform.nvim)
		pcall(require, "config.format")

		-- Diagnosticos (trouble.nvim)
		pcall(require, "config.diagnostics")
	end,
})

-- ===== Mapeos globales (no dependen de plugins) =====
pcall(require, "mapped")
