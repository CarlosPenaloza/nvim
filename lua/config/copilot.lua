-- GitHub Enterprise
vim.g.copilot_enterprise_uri = "https://bbva.ghe.com"

-- Evita que Copilot se apropie de Tab
vim.g.copilot_no_tab_map = true

-- Aceptar sugerencia
vim.keymap.set("i", "<leader>ca", function()
	return vim.fn["copilot#Accept"]("")
end, {
	expr = true,
	replace_keycodes = false,
	silent = true,
	desc = "Copilot: aceptar",
})

-- Siguiente sugerencia
vim.keymap.set("i", "<leader>cn", "<Plug>(copilot-next)", {
	silent = true,
	desc = "Copilot: siguiente",
})

-- Sugerencia anterior
vim.keymap.set("i", "<leader>cp", "<Plug>(copilot-previous)", {
	silent = true,
	desc = "Copilot: anterior",
})

-- Descartar sugerencia
vim.keymap.set("i", "<leader>cd", "<Plug>(copilot-dismiss)", {
	silent = true,
	desc = "Copilot: descartar",
})
