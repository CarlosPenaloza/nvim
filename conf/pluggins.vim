call plug#begin('~/.vim/plugged')

" Temas
Plug 'pacokwon/onedarkhc.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'morhetz/gruvbox'
 
"IDE
Plug 'easymotion/vim-easymotion' " Necesario para la creacion de atajos
Plug 'scrooloose/nerdtree'  "Arbol de archivos
Plug 'christoomey/vim-tmux-navigator' " Moverse entre pantallas vim o nvim
Plug 'scrooloose/nerdcommenter' " Sirve para hacer comentarios
Plug 'jiangmiao/auto-pairs' "Cierra en auomatico llaves, parentesis, comillas, etc.
Plug 'ryanoasis/vim-devicons' " Poner iconos de tipos de archivos en nerdtree

" Syntax
Plug 'sheerun/vim-polyglot' " Resalta texto de cada tipo de lenguaje
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' } " Acomodar sintaxis
Plug 'norcalli/nvim-colorizer.lua' " Da color a los codigos de colores hex, rga, rgba, etc en css.
Plug 'https://github.com/adelarsq/vim-matchit' " Colorer parentesis, llaves, etc.
Plug 'yaocccc/vim-surround' " Poner parentesis, llaves, seleccionados
Plug 'lukas-reineke/indent-blankline.nvim'

" status bar - Ayuda a que se acomode la barra que se encuentra abajo de vim, que nos dice el modo en el que estamos, lenguaje, etc.
Plug 'maximbaz/lightline-ale' 
Plug 'itchyny/lightline.vim'

" Menu navegacion
Plug 'kyazdani42/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'

" autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Autocompleta lenguajes

" Multi - nos permite seleccionar multiples veces :help visual-multi
Plug 'mg979/vim-visual-multi', {'branch': 'master'}


call plug#end()
