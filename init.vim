set runtimepath^=~/.vim/after
let g:python3_host_prog="/usr/bin/python3"
let &packpath=&runtimepath

" Bases Vim
source $HOME/.config/nvim/conf/atajos.vim
source $HOME/.config/nvim/conf/generales.vim
source $HOME/.config/nvim/conf/pluggins.vim
source $HOME/.config/nvim/conf/confPluggins/catppuccin.lua

" Atajos y movimientos
source $HOME/.config/nvim/conf/confPluggins/mini.lua
source $HOME/.config/nvim/conf/confPluggins/tmux-navigator.vim

" Arbol de archivos
source $HOME/.config/nvim/conf/confPluggins/nerdtree.vim
source $HOME/.config/nvim/conf/confPluggins/nerdtree-git-plugin.vim
source $HOME/.config/nvim/conf/confPluggins/vim-nerdtree-syntax-highlight.vim

" Sintaxis
" source $HOME/.config/nvim/conf/confPluggins/ufo.lua
source $HOME/.config/nvim/conf/confPluggins/pretty-fold.lua
source $HOME/.config/nvim/conf/confPluggins/colorizer.lua
source $HOME/.config/nvim/conf/confPluggins/gitsigns.lua
source $HOME/.config/nvim/conf/confPluggins/indent-blankline.lua
source $HOME/.config/nvim/conf/confPluggins/prettier.vim
source $HOME/.config/nvim/conf/confPluggins/treesitter.lua

" Barra superior e inferior
source $HOME/.config/nvim/conf/confPluggins/bufferline.lua
source $HOME/.config/nvim/conf/confPluggins/lualine.lua
source $HOME/.config/nvim/conf/confPluggins/tagbar.vim

" Buscar Archivos
source $HOME/.config/nvim/conf/confPluggins/telescope.vim
source $HOME/.config/nvim/conf/confPluggins/telescope.lua

" Terminal
source $HOME/.config/nvim/conf/confPluggins/floaterm.vim

" Autocompletar
source $HOME/.config/nvim/conf/confPluggins/lsp-zero.lua
