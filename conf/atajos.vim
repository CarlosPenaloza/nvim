" EasyMotion
" Tecla que iniciara los atajos, en este caso espacio.
let mapleader = " "
" nmap -> Comandos que ejecutaran estando en modo normal
" Leader -> Tecla definida en mapleader

 "Generales
nmap <Leader>w :w<CR>
nmap <Leader>q :q<CR>
nmap <Leader>s <Plug>(easymotion-s2)

"NerdTree
let NERDTreeQuitOnOpen=1
nmap <Leader>nt :NERDTreeFind<CR>

" FNZ
map <Leader>p :Files<CR>
map <Leader>ag :Ag<CR>

" Buffers
map <Leader>ob :Buffers<cr>

" Comentarios
" espacio c espacio

" vim-surround
" espacio S simboloEnElQueSeEncerrara

" prettier-vim
nmap <Leader>pt <Plug>(Prettier)
