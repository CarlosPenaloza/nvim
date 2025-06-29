call plug#begin('~/.vim/plugged')

" Temas
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'morhetz/gruvbox'

" Arbol de archivos
Plug 'nvim-tree/nvim-web-devicons' " optional
Plug 'nvim-tree/nvim-tree.lua'

" Atajos y movimientos
Plug 'christoomey/vim-tmux-navigator' " Moverse entre pantallas vim o nvim
Plug 'echasnovski/mini.nvim' " Atajos como: comentarios, moverse entre lineas, multiple seleccion, poner llaves, etc.

" Sintaxis
Plug 'lewis6991/gitsigns.nvim' " Muestra lineas que han sufrido cambio desde git
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'HiPhish/rainbow-delimiters.nvim' " Colors for parentheses, brackets, braces. 
Plug 'lukas-reineke/indent-blankline.nvim' " Resalta saltos de linea, identaciones, espacios, etc.
Plug 'onsails/lspkind.nvim' " Plugin para atajos visuales
Plug 'brenoprata10/nvim-highlight-colors' " Plugin para colores

" Barra superior e inferior
Plug 'kyazdani42/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'preservim/tagbar'

" AUTOCOMPLETAR
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Autoajustar Pantalla
Plug 'camspiers/lens.vim'

" Busqueda de archivos
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', {'branch': '0.1.x'}

call plug#end()
