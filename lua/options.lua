-- lua/config/options.lua

-- ===== Sintaxis / resaltado =====
vim.cmd('syntax enable') -- habilita sintaxis (por compatibilidad)

-- ===== Interfaz =====
vim.opt.number         = true      -- número de línea
vim.opt.relativenumber = true      -- número relativo (navegación más rápida)
vim.opt.cursorline     = true      -- resalta línea actual
vim.opt.wrap           = false     -- no ajustar líneas
vim.opt.termguicolors  = true      -- colores 24bit
vim.opt.scrolloff      = 4         -- margen vertical al hacer scroll
vim.opt.sidescrolloff  = 8         -- margen horizontal

-- Columnas laterales estables (evitan saltos)
vim.opt.signcolumn     = "auto:2"  -- reserva hasta 2 signos siempre
vim.opt.foldcolumn     = "1"       -- una columna fija de folds
vim.opt.numberwidth    = 4         -- ancho fijo para números de línea

-- Modo / cmdline / statusline (perfil ULTRA estable)
vim.opt.showmode       = false     -- lualine ya muestra el modo
vim.opt.showcmd        = false     -- no reservar espacio para showcmd
vim.opt.laststatus     = 3         -- statusline global (ideal con lualine)
vim.opt.cmdheight      = 1         -- ⬅️ reserva 1 línea fija (evita saltos por completo)
vim.opt.more           = false     -- evita "Press ENTER or type command to continue"

-- Mensajes menos intrusivos (no empujan el footer)
vim.opt.shortmess:append("F")      -- suprime “file messages” largos
vim.opt.shortmess:append("W")      -- menos warnings en cmdline
vim.opt.shortmess:append("I")      -- no mostrar intro innecesaria
vim.opt.shortmess:append("c")      -- mensajes de completado compactos
-- Opcionalmente puedes probar añadir: vim.opt.shortmess:append("S") -- menos mensajes de búsqueda

-- Líneas “vacías” más limpias al final del buffer
vim.opt.fillchars:append({ eob = " " })

-- ===== Ratón =====
-- "nv" = normal/visual; si quieres en todos los modos, usa "a"
vim.opt.mouse = "nv"

-- ===== Búsqueda =====
vim.opt.ignorecase  = true -- ignora mayúsculas por defecto
vim.opt.smartcase   = true -- si hay mayúsculas en la búsqueda, respeta mayúsculas
vim.opt.incsearch   = true -- resalta mientras escribes
vim.opt.hlsearch    = true -- resaltar resultados (puedes limpiar con <Esc> -> :noh)

-- ===== Identación / Tabs =====
vim.opt.expandtab   = true
vim.opt.smarttab    = true
vim.opt.smartindent = true
vim.opt.tabstop     = 2
vim.opt.shiftwidth  = 2
vim.opt.softtabstop = 2

-- ===== Ventanas / Splits =====
vim.opt.splitbelow  = true
vim.opt.splitright  = true
vim.opt.splitkeep   = "screen"   -- mantiene el contenido estable al dividir/redimensionar
vim.opt.equalalways = false      -- evita reajustes automáticos de tamaños al cambiar de ventana

-- ===== Estado / comandos =====
vim.opt.ruler       = true

-- ===== Codificación =====
-- Neovim ya usa UTF-8 por defecto, pero lo dejamos explícito
vim.opt.encoding     = "utf-8"
vim.opt.fileencoding = "utf-8"

-- ===== Portapapeles =====
vim.opt.clipboard    = "unnamedplus" -- integra con portapapeles del SO

-- ===== Archivos temporales =====
vim.opt.backup    = false
vim.opt.swapfile  = false
vim.opt.undofile  = true -- historial persistente de deshacer (~/.local/share/nvim/undo)

-- ===== Rendimiento / LSP / UI popup =====
vim.opt.updatetime  = 250                       -- más rápido para diagnósticos y CursorHold
vim.opt.timeoutlen  = 400                       -- feeling ágil para mappings
vim.opt.pumheight   = 12                        -- altura del menú de completado
vim.opt.completeopt = { "menuone", "noselect" } -- recomendado para nvim-cmp/coc

-- ===== Plegado (Treesitter) =====
-- Requiere nvim-treesitter. Lo dejamos listo pero desactivado por defecto.
vim.opt.foldmethod  = "expr"
vim.opt.foldexpr    = "nvim_treesitter#foldexpr()"
vim.opt.foldenable  = false

-- ===== Coincidencias =====
vim.opt.showmatch   = true

-- ===== Miscelánea útil =====
vim.opt.confirm     = true -- confirma al cerrar buffer con cambios
