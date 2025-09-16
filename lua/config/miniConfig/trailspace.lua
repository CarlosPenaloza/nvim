-- mini.trailspace configuración básica
require("mini.trailspace").setup()

-- Helper para saber si se debe saltar por filetype
local function should_skip(ft)
	return ft == "markdown" or ft == "txt"
end

-- Envuelve una acción preservando vista y agrupando undo
local function with_preserved_view(fn)
	local view = vim.fn.winsaveview()
	vim.api.nvim_command("silent undojoin") -- intenta unir con el último cambio (si aplica)
	local ok, err = pcall(fn)
	vim.fn.winrestview(view)
	if not ok then
		vim.notify("mini.trailspace: " .. tostring(err), vim.log.levels.ERROR)
	end
end

-- :TrimWS  (usa bang para forzar en markdown/txt)
vim.api.nvim_create_user_command("TrimWS", function(opts)
	local ft = vim.bo.filetype
	if should_skip(ft) and not opts.bang then
		vim.notify(('TrimWS: omitido en "%s" (usa :TrimWS! para forzar)'):format(ft), vim.log.levels.INFO)
		return
	end
	with_preserved_view(function()
		MiniTrailspace.trim()
	end)
	vim.notify("Trailing spaces eliminados", vim.log.levels.INFO)
end, { bang = true })

-- :TrimLastLines  (siempre permitido)
vim.api.nvim_create_user_command("TrimLastLines", function()
	with_preserved_view(function()
		MiniTrailspace.trim_last_lines()
	end)
	vim.notify("Líneas en blanco finales normalizadas", vim.log.levels.INFO)
end, {})

-- (Opcional) mapping rápido
-- <leader>tw => TrimWS  | <leader>tW => TrimWS! | <leader>tl => TrimLastLines
vim.keymap.set("n", "<leader>tw", "<cmd>TrimWS<CR>", { desc = "Trim trailing spaces (respetando md/txt)" })
vim.keymap.set("n", "<leader>tW", "<cmd>TrimWS!<CR>", { desc = "Trim trailing spaces (forzar)" })
vim.keymap.set("n", "<leader>tl", "<cmd>TrimLastLines<CR>", { desc = "Trim last blank lines" })
