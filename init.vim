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
source $HOME/.config/nvim/conf/confPluggins/nvim-tree.lua

" Sintaxis
source $HOME/.config/nvim/conf/confPluggins/gitsigns.lua
source $HOME/.config/nvim/conf/confPluggins/indent-blankline.lua
source $HOME/.config/nvim/conf/confPluggins/treesitter.lua
source $HOME/.config/nvim/conf/confPluggins/lspkind.lua
source $HOME/.config/nvim/conf/confPluggins/nvim-highlight-colors.lua

" Barra superior e inferior
source $HOME/.config/nvim/conf/confPluggins/bufferline.lua
source $HOME/.config/nvim/conf/confPluggins/lualine.lua
source $HOME/.config/nvim/conf/confPluggins/tagbar.vim

" Buscar Archivos
source $HOME/.config/nvim/conf/confPluggins/telescope.lua

" Autocompletar
source $HOME/.config/nvim/conf/confPluggins/lsp-zero.lua
source $HOME/.config/nvim/conf/confPluggins/cmp.lua
source $HOME/.config/nvim/conf/confPluggins/snippets.lua

