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
Plug 'turbio/bracey.vim' " Live server para vim

" Syntax
Plug 'sheerun/vim-polyglot' " Resalta texto de cada tipo de lenguaje
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' } " Acomodar sintaxis
Plug 'nathanaelkane/vim-indent-guides' " Se agrega un simbolo cuando hay algo identado
Plug 'norcalli/nvim-colorizer.lua' " Da color a los codigos de colores hex, rga, rgba, etc en css.
Plug 'https://github.com/adelarsq/vim-matchit' " Colorer parentesis, llaves, etc.
Plug 'yaocccc/vim-surround' " Poner parentesis, llaves, seleccionados

" status bar - Ayuda a que se acomode la barra que se encuentra abajo de vim, que nos dice el modo en el que estamos, lenguaje, etc.
Plug 'maximbaz/lightline-ale' 
Plug 'itchyny/lightline.vim'

" autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Autocompleta lenguajes


" Multi - nos permite seleccionar multiples veces :help visual-multi
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

call plug#end()
