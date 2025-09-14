-- Encapsulamos bloque vim-plug en Lua
vim.cmd [[
call plug#begin('~/.vim/plugged')

" Temas
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'morhetz/gruvbox'

" Árbol de archivos
Plug 'nvim-tree/nvim-web-devicons' " optional
Plug 'stevearc/oil.nvim'
Plug 'refractalize/oil-git-status.nvim'

" Atajos y movimientos
Plug 'christoomey/vim-tmux-navigator'
Plug 'echasnovski/mini.nvim'

" Sintaxis
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'HiPhish/rainbow-delimiters.nvim'
Plug 'onsails/lspkind.nvim'

" Barra superior e inferior
Plug 'akinsho/bufferline.nvim'
Plug 'nvim-lualine/lualine.nvim'

" Autocompletar
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Búsqueda de archivos
Plug 'nvim-telescope/telescope.nvim', {'branch': '0.1.x'}
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }


call plug#end()
]]
