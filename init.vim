set runtimepath^=~/.vim/after
let g:python3_host_prog="/usr/bin/python3"
"let g:loaded_python3_provider = 0 " Desactivar suporte de python
let &packpath=&runtimepath

" Partes vim
runtime ./conf/generales.vim
runtime ./conf/pluggins.vim
runtime ./conf/atajos.vim
runtime ./conf/confEspeciales.vim

"Tmux
runtime ./conf/confPluggins/tmux-navigator.vim

" Coc
runtime ./conf/confPluggins/coc.vim

" prettier
runtime ./conf/confPluggins/prettier.vim

" Colorizer
runtime ./conf/confPluggins/colorizer.lua

" airline
runtime ./conf/confPluggins/airline.vim

" indent_blankline
runtime ./conf/confPluggins/indent-blankline.lua

" ultisnips
runtime ./conf/confPluggins/ultisnips.vim

" treesitter
runtime ./conf/confPluggins/treesitter.lua

" Lualine
runtime ./conf/confPluggins/lualine.lua

" Telescope
runtime ./conf/confPluggins/telescope.vim

" Telescope
runtime ./conf/confPluggins/bufferline.lua

" Floaterm
runtime ./conf/confPluggins/floaterm.vim

" fzf
runtime ./conf/confPluggins/fzf.vim

" gitsigns
runtime ./conf/confPluggins/gitsigns.lua


