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
Plug 'preservim/nerdtree'
"Plug 'scrooloose/nerdtree'  "Arbol de archivos
Plug 'tiagofumo/vim-nerdtree-syntax-highlight' " acompaña a nerdtree dando color 
Plug 'christoomey/vim-tmux-navigator' " Moverse entre pantallas vim o nvim
Plug 'airblade/vim-gitgutter' " Muestra  que lineas han sufrido cambio
Plug 'scrooloose/nerdcommenter' " Sirve para hacer comentarios
Plug 'jiangmiao/auto-pairs' "Cierra en auomatico llaves, parentesis, comillas, etc.
Plug 'ryanoasis/vim-devicons' " Poner iconos de tipos de archivos en nerdtree

" Syntax
Plug 'sheerun/vim-polyglot' " Resalta texto de cada tipo de lenguaje
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' } " Acomodar sintaxis
Plug 'norcalli/nvim-colorizer.lua' " Da color a los codigos de colores hex, rga, rgba, etc en css.
Plug 'https://github.com/adelarsq/vim-matchit' " Colorer parentesis, llaves, etc.
Plug 'yaocccc/vim-surround' " Poner parentesis, llaves, seleccionados
Plug 'lukas-reineke/indent-blankline.nvim' " Resalta saltos de linea, identaciones, espacios, etc.

" status bar - Ayuda a que se acomode la barra que se encuentra abajo y arriba de vim, que nos dice el modo en el que estamos, lenguaje, etc.
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Autocompleta lenguajes

" Lenguajes

call plug#end()
