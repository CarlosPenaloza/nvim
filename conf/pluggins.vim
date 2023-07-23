call plug#begin('~/.vim/plugged')

" Temas
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Arbol de archivos
Plug 'nvim-tree/nvim-web-devicons' " optional
Plug 'nvim-tree/nvim-tree.lua'

" Atajos y movimientos
Plug 'christoomey/vim-tmux-navigator' " Moverse entre pantallas vim o nvim
Plug 'echasnovski/mini.nvim' " Atajos como: comentarios, moverse entre lineas, multiple seleccion, poner llaves, etc.

" Sintaxis
Plug 'lewis6991/gitsigns.nvim' " Muestra lineas que han sufrido cambio desde git
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'HiPhish/nvim-ts-rainbow2' " module nvim-treesitter
Plug 'NvChad/nvim-colorizer.lua' " Da color a los codigos de colores hex, rga, rgba, etc en css.
Plug 'lukas-reineke/indent-blankline.nvim' " Resalta saltos de linea, identaciones, espacios, etc.
Plug 'andymass/vim-matchup' " Colorer parentesis, llaves, etc.
Plug 'anuvyklack/pretty-fold.nvim' " fold
Plug 'anuvyklack/fold-preview.nvim' "Muestra lo que esta dentro del fold
Plug 'anuvyklack/keymap-amend.nvim' "Plugin necesario para usar fold-preview
Plug 'onsails/lspkind.nvim' " Plugin para atajos visuales

" Barra superior e inferior
Plug 'akinsho/bufferline.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'preservim/tagbar'

" AUTOCOMPLETAR
" LSP Support
Plug 'neovim/nvim-lspconfig'             " Required
Plug 'williamboman/mason.nvim'           " Optional
Plug 'williamboman/mason-lspconfig.nvim' " Optional
" Autocompletion Engine
Plug 'hrsh7th/nvim-cmp'         " Required
Plug 'hrsh7th/cmp-nvim-lsp'     " Required
Plug 'hrsh7th/cmp-buffer'       " Optional
Plug 'hrsh7th/cmp-path'         " Optional
Plug 'saadparwaiz1/cmp_luasnip' " Optional
Plug 'hrsh7th/cmp-nvim-lua'     " Optional
"  Snippets
Plug 'L3MON4D3/LuaSnip'             " Required
Plug 'rafamadriz/friendly-snippets' " Optional
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}

" Autoajustar Pantalla
Plug 'camspiers/lens.vim'

" Pantalla flotante
Plug 'voldikss/vim-floaterm'

" Busqueda de archivos
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', {'branch': '0.1.x'}

call plug#end()
