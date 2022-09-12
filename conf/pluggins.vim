call plug#begin('~/.vim/plugged')

" Temas
Plug 'pacokwon/onedarkhc.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'morhetz/gruvbox'
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'sainnhe/sonokai'

"IDE
Plug 'easymotion/vim-easymotion' " Necesario para la creacion de atajos
Plug 'preservim/nerdtree' " Arbol de archivos
Plug 'tiagofumo/vim-nerdtree-syntax-highlight' " acompaña a nerdtree dando color 
Plug 'Xuyuanp/nerdtree-git-plugin' " Git en nerdtree
Plug 'christoomey/vim-tmux-navigator' " Moverse entre pantallas vim o nvim
Plug 'lewis6991/gitsigns.nvim' " Muestra lineas que han sufrido cambio desde git
Plug 'scrooloose/nerdcommenter' " Sirve para hacer comentarios
Plug 'jiangmiao/auto-pairs' "Cierra en auomatico llaves, parentesis, comillas, etc.
Plug 'ryanoasis/vim-devicons' " Poner iconos de tipos de archivos en nerdtree

" Syntax
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' } " Acomodar sintaxis
Plug 'norcalli/nvim-colorizer.lua' " Da color a los codigos de colores hex, rga, rgba, etc en css.
Plug 'https://github.com/adelarsq/vim-matchit' " Colorer parentesis, llaves, etc.
Plug 'tpope/vim-surround' " Alternativa surround
Plug 'lukas-reineke/indent-blankline.nvim' " Resalta saltos de linea, identaciones, espacios, etc.

" status bar - Ayuda a que se acomode la barra que se encuentra abajo de vim, la cual nos dice el modo en el que estamos, lenguaje, etc.
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Autocompleta lenguajes
Plug 'honza/vim-snippets'

" LitElement
Plug 'jonsmithers/vim-html-template-literals'
Plug 'pangloss/vim-javascript'

" Lens - autoajusta pantallas
Plug 'camspiers/lens.vim'

" Bufferline - Agrega la pestaña de arriba de vim, la cual nos dice en que pagina nos encontramos
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }

" Pantalla flotante
Plug 'voldikss/vim-floaterm'

" Fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter'

call plug#end()
