call plug#begin('~/.vim/plugged')

" Temas
Plug 'arcticicestudio/nord-vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

"IDE
Plug 'preservim/nerdtree' " Arbol de archivos
Plug 'Xuyuanp/nerdtree-git-plugin' " Git en nerdtree
Plug 'christoomey/vim-tmux-navigator' " Moverse entre pantallas vim o nvim
Plug 'lewis6991/gitsigns.nvim', { 'tag': 'v0.6' } " Muestra lineas que han sufrido cambio desde git
Plug 'ryanoasis/vim-devicons' " Poner iconos de tipos de archivos en nerdtree
Plug 'echasnovski/mini.nvim', { 'branch': 'stable' }

" Syntavx
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' } " Acomodar sintaxis
Plug 'norcalli/nvim-colorizer.lua' " Da color a los codigos de colores hex, rga, rgba, etc en css.
Plug 'lukas-reineke/indent-blankline.nvim' " Resalta saltos de linea, identaciones, espacios, etc.
Plug 'andymass/vim-matchup' " Colorer parentesis, llaves, etc.

" status bar - Ayuda a que se acomode la barra que se encuentra abajo de vim, la cual nos dice el modo en el que estamos, lenguaje, etc.
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

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
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v1.x'}

" Lens - autoajusta pantallas
Plug 'camspiers/lens.vim'

" Bufferline - Agrega la pestaña de arriba de vim, la cual nos dice en que pagina nos encontramos
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }

" Pantalla flotante
Plug 'voldikss/vim-floaterm'

" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

call plug#end()
