set runtimepath^=~/.vim/after
let &packpath=&runtimepath

" Partes vim
runtime ./conf/generales.vim
runtime ./conf/pluggins.vim
runtime ./conf/atajos.vim
runtime ./conf/confEspeciales.vim

" Coc
runtime ./conf/confPluggins/coc.vim

" prettier
runtime ./conf/confPluggins/prettier.vim

" Colorizer
runtime ./conf/confPluggins/colorizer.lua

" barbar
runtime ./conf/confPluggins/barbar.vim

" indent_blankline
runtime ./conf/confPluggins/indent-blankline.lua
