" EasyMotion
" Tecla que iniciara los atajos, en este caso espacio.
let mapleader = " "
" nmap -> Comandos que ejecutaran estando en modo normal
" Leader -> Tecla definida en mapleader

 "Generales
nmap <Leader>w :w<CR>
nmap <Leader>q :q<CR>
nmap <Leader>wq :wq!<CR>
nmap <Leader>s <Plug>(easymotion-s2)

"NerdTree
let NERDTreeQuitOnOpen=1
nmap <Leader>nt :NERDTreeFind<CR>

" FNZ
nmap <Leader>p :Files<CR>
nmap <Leader>ag :Ag<CR>

" Buffers
nmap <Leader>ob :Buffers<cr>

" Comentarios
" espacio c espacio

" vim-surround
" espacio S simboloEnElQueSeEncerrara

" prettier-vim
nmap <Leader>pt <Plug>(Prettier)

" Salto de linea sin cambiar a modo insertar
nmap <Leader>o o<ESC>
nmap <Leader>O O<ESC>

" Bracey - live server
nmap <Leader>live :Bracey<CR>
