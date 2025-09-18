-- lua/config/treesitter.lua
local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
if not ok then
	return
end

local uv = vim.uv or vim.loop

-- ===== Rendimiento / límites =====
local BIG_FILE_SIZE = 500 * 1024 -- 500 KB
local BIG_FILE_LINES = 10000

-- Cachés / estados
local notified = {} -- evita spamear notificaciones por buffer
local large_cache = {} -- memoización de "es grande"
_G.BigFile = _G.BigFile or {}
BigFile.state = BigFile.state or {}

local function is_large(buf)
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

-- ===== Rainbow (opcional, sólo si está instalado) =====
local has_rd, rd = pcall(require, "rainbow-delimiters")
local rainbow_conf
if has_rd then
	rainbow_conf = {
		enable = true,
		query = "rainbow-parens", -- compatible con la mayoría de sets
		strategy = rd.strategy["local"], -- ligero por buffer visible
		disable = function(_, buf)
			if is_large(buf) then
				mark_big_and_maybe_notify(
					buf,
					"Rainbow",
					("Deshabilitado en archivo grande (> %d KB o > %d líneas)"):format(
						BIG_FILE_SIZE / 1024,
						BIG_FILE_LINES
					)
				)
				return true
			end
			return false
		end,
	}
else
	rainbow_conf = { enable = false }
end

-- ===== Setup principal =====
ts_configs.setup({
	ensure_installed = {
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
	},
	sync_install = false,
	auto_install = true,
	ignore_install = {},

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
		disable = function(_, buf)
			if is_large(buf) then
				mark_big_and_maybe_notify(
					buf,
					"Highlight",
					("Deshabilitado para archivo grande (> %d KB o > %d líneas)"):format(
						BIG_FILE_SIZE / 1024,
						BIG_FILE_LINES
					)
				)
				return true
			end
			BigFile.state[buf] = false
			return false
		end,
	},

	indent = {
		enable = true,
		disable = function(lang, buf)
			-- Desactiva indent TS en lenguajes problemáticos y en archivos grandes
			if lang == "python" or lang == "css" or lang == "scss" or is_large(buf) then
				if is_large(buf) then
					mark_big_and_maybe_notify(
						buf,
						"Indent",
						("Deshabilitado en archivo grande (> %d KB o > %d líneas)"):format(
							BIG_FILE_SIZE / 1024,
							BIG_FILE_LINES
						)
					)
				end
				return true
			end
			return false
		end,
	},

	-- Sólo se aplica si tienes rainbow-delimiters instalado
	rainbow = rainbow_conf,

	-- Selección incremental (sin requires extra ni keymaps sueltos)
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>",
			node_incremental = "<TAB>",
			node_decremental = "<S-TAB>",
			scope_incremental = false,
		},
	},
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
