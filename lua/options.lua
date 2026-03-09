-- lua/config/options.lua

-- ===== Interfaz =====
vim.opt.number = true -- número de línea
vim.opt.relativenumber = true -- número relativo
vim.opt.cursorline = true -- resalta línea actual
vim.opt.wrap = false -- no ajustar líneas
vim.opt.termguicolors = true -- colores 24bit
vim.opt.scrolloff = 4 -- margen vertical al hacer scroll
vim.opt.sidescrolloff = 8 -- margen horizontal

-- Columnas laterales estables
vim.opt.signcolumn = "yes:2" -- siempre hasta 2 signos, sin saltos
vim.opt.numberwidth = 4 -- ancho fijo para números

-- Statusline / cmdline
vim.opt.showmode = false -- lualine ya muestra el modo
vim.opt.showcmd = false
vim.opt.laststatus = 3 -- statusline global
vim.opt.cmdheight = 1 -- altura fija (puedes probar 0 si usas noice.nvim)
vim.opt.more = false -- evita "Press ENTER..." (ajustar si falta info)

-- Mensajes menos intrusivos
vim.opt.shortmess:append("FWIc") -- compacto y limpio

-- Líneas “vacías” al final del buffer
vim.opt.fillchars:append({ eob = " " })

-- ===== Ratón =====
vim.opt.mouse = "nv" -- o "a" si quieres todos los modos

-- ===== Búsqueda =====
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- ===== Identación / Tabs =====
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
-- Recomendado: plugin 'tpope/vim-sleuth' para autodetectar indentación

-- ===== Ventanas / Splits =====
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "screen"
vim.opt.equalalways = false
vim.o.hidden = true

-- ===== Codificación =====
-- UTF-8 ya es default, lo dejamos limpio
vim.opt.encoding = "utf-8" -- interno (ya es default, pero explícitalo)
vim.opt.fileencoding = "utf-8" -- codificación al guardar
vim.opt.fileencodings = { "utf-8" } -- SIN latin1/iso-8859-1/etc → sin autodetección

-- (Opcional) Forzar por buffer al abrir/crear
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	pattern = "*",
	callback = function()
		vim.bo.fileencoding = "utf-8"
	end,
})

-- ===== Portapapeles =====
vim.opt.clipboard = "unnamedplus"

-- ===== Archivos temporales =====
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true

-- ===== Rendimiento / LSP / UI popup =====
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.pumheight = 12
vim.opt.completeopt = { "menuone", "noselect" }

-- ===== Plegado (Treesitter) =====
vim.o.foldcolumn = "1" -- columna fija de folds
vim.o.foldmethod = "manual"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldcolumn = "1"
vim.o.fillchars = "fold: ,foldopen:,foldclose:"


-- ===== Coincidencias =====
vim.opt.showmatch = true

-- ===== Miscelánea =====
vim.opt.confirm = true

-- ===== Ajustes opcionales recomendados =====
-- Evitar continuar comentarios automáticos
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Grep integrado (si usas ripgrep)
vim.opt.grepprg = "rg --vimgrep --smart-case --hidden"
vim.opt.grepformat = "%f:%l:%c:%m"

-- Diff más legible
vim.opt.diffopt:append({ "linematch:60", "algorithm:patience" })

-- Popups semitransparentes (si el tema soporta)
vim.opt.winblend = 10
vim.opt.pumblend = 10
