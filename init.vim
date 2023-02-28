set runtimepath^=~/.vim/after
let g:python3_host_prog="/usr/bin/python3"
"let g:loaded_python3_provider = 0 " Desactivar suporte de python
let &packpath=&runtimepath

" Partes vim
source $HOME/.config/nvim/conf/generales.vim
source $HOME/.config/nvim/conf/pluggins.vim
source $HOME/.config/nvim/conf/atajos.vim
source $HOME/.config/nvim/conf/confEspeciales.vim

" Tmux
source $HOME/.config/nvim/conf/confPluggins/tmux-navigator.vim

" NERDTree
source $HOME/.config/nvim/conf/confPluggins/nerdtree.vim

" prettier
source $HOME/.config/nvim/conf/confPluggins/prettier.vim

" Colorizer
source $HOME/.config/nvim/conf/confPluggins/colorizer.lua

" airline
source $HOME/.config/nvim/conf/confPluggins/airline.vim

" indent_blankline
source $HOME/.config/nvim/conf/confPluggins/indent-blankline.lua

" treesitter
runtime $HOME/.config/nvim/conf/confPluggins/treesitter.lua

" Lualine
source $HOME/.config/nvim/conf/confPluggins/lualine.lua

" Telescope
source $HOME/.config/nvim/conf/confPluggins/telescope.vim

" Bufferline
source $HOME/.config/nvim/conf/confPluggins/bufferline.lua

" Floaterm
source $HOME/.config/nvim/conf/confPluggins/floaterm.vim

" gitsigns
source $HOME/.config/nvim/conf/confPluggins/gitsigns.lua

" lsp-zero
source $HOME/.config/nvim/conf/confPluggins/lsp-zero.lua

