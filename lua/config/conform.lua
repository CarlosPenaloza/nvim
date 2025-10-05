-- =====================================================================
--  lua/config/conform.lua
--  Conform: usa Prettier para TS/JS y derivados; nada de "format on save"
-- =====================================================================

require("conform").setup({
	formatters_by_ft = {
		-- TS/JS y derivados: SOLO prettier (como pediste)
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },

		-- Otros que también cubre Prettier
		html = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		json = { "prettier" },
		markdown = { "prettier" },

		-- Extras
		lua = { "stylua" },
		sh = { "shfmt" },
	},

	-- Nada de format on save: sólo manual (:Format / :FormatSelection)
	format_on_save = nil,
})
