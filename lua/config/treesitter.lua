-- lua/config/treesitter.lua
local treesitter = require("nvim-treesitter")

local uv = vim.uv or vim.loop

-- ===== Rendimiento / límites =====
local BIG_FILE_SIZE = 500 * 1024 -- 500 KB
local BIG_FILE_LINES = 10000
local parsers = {
	"bash",
	"comment",
	"css",
	"dockerfile",
	"gitignore",
	"html",
	"http",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"regex",
	"scss",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
}
local no_indent = { python = true, css = true, scss = true }

-- Cachés / estados
local notified = {} -- evita spamear notificaciones por buffer
local large_cache = {} -- memoización de "es grande"
_G.BigFile = _G.BigFile or {}
BigFile.state = BigFile.state or {}

local function is_large(buf)
	if vim.b[buf].large_file then
		return true
	end
	if large_cache[buf] ~= nil then
		return large_cache[buf]
	end
	local name = vim.api.nvim_buf_get_name(buf)
	local ok_stat, st = pcall(uv.fs_stat, name)
	local big_file = ok_stat and st and st.size and (st.size > BIG_FILE_SIZE)
	local big_lines = (vim.api.nvim_buf_line_count(buf) or 0) > BIG_FILE_LINES
	local res = (big_file or big_lines) and true or false
	large_cache[buf] = res
	return res
end

local function mark_big_and_maybe_notify(buf, feature, msg)
	BigFile.state[buf] = true
	if notified[buf] then
		return
	end
	notified[buf] = true
	vim.schedule(function()
		vim.notify(msg, vim.log.levels.WARN, { title = ("Treesitter | %s"):format(feature) })
	end)
end

treesitter.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

if vim.fn.executable("tree-sitter") == 1 then
	treesitter.install(parsers)
else
	vim.notify_once(
		"Instala tree-sitter-cli para instalar y actualizar los parsers de Treesitter.",
		vim.log.levels.WARN,
		{ title = "Treesitter" }
	)
end

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local buf = args.buf
		if is_large(buf) then
			mark_big_and_maybe_notify(
				buf,
				"Highlight e indentación",
				("Deshabilitados para archivo grande (> %d KB o > %d líneas)"):format(
					BIG_FILE_SIZE / 1024,
					BIG_FILE_LINES
				)
			)
			return
		end

		local ok_parser = pcall(vim.treesitter.get_parser, buf)
		if not ok_parser then
			return
		end

		BigFile.state[buf] = false
		pcall(vim.treesitter.start, buf)
		if not no_indent[vim.bo[buf].filetype] then
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- Opcional: limpia caché cuando cambie significativamente el buffer
vim.api.nvim_create_autocmd({ "BufReadPost", "TextChanged", "TextChangedI" }, {
	callback = function(args)
		-- Si ya lo marcamos como grande, no tiene sentido recalcular a cada pulsación.
		if BigFile.state[args.buf] then
			return
		end
		-- Recalcular sólo cuando el buffer crezca mucho: cada +2000 líneas aprox.
		local lc = vim.api.nvim_buf_line_count(args.buf)
		if lc % 2000 == 0 then
			large_cache[args.buf] = nil
		end
	end,
})
