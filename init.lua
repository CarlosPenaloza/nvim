-- Añadir ~/.vim/after al runtimepath (si lo usas todavía)
vim.opt.runtimepath:prepend("~/.vim/after")

-- Python host (necesario si usas plugins que requieren Python3)
vim.g.python3_host_prog = "/usr/bin/python3"

-- Emparejar packpath con runtimepath (lo mismo que tu init.vim)
vim.opt.packpath = vim.o.runtimepath

-- Cargar tu configuración modular
require("index")
