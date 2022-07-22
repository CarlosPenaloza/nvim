" EasyMotion
" Tecla que iniciara los atajos, en este caso espacio.
let mapleader = " "
" nmap -> Comandos que ejecutaran estando en modo normal
" Leader -> Tecla definida en mapleader

 "Generales
nmap <Leader>w :w<CR>
nmap <Leader>Q :q<CR>
nmap <Leader>W :wq!<CR>
nmap <Leader>s <Plug>(easymotion-s2)

"NerdTree
let NERDTreeQuitOnOpen=1
nmap <Leader>nt :NERDTreeFind<CR>

" FNZ
nmap <Leader>p :Files<CR>
nmap <Leader>ag :Ag<CR>

" Comentarios
" espacio c espacio

" vim-surround
" espacio S simboloEnElQueSeEncerrara

" prettier-vim
nmap <Leader>pt <Plug>(Prettier)

" Tamaño Buffers
nmap <silent> <right> :vertical resize +5<CR>
nmap <silent> <left> :vertical resize -5<CR>
nmap <silent> <up> : resize +5<CR>
nmap <silent> <down> : resize -5<CR>

" Buffers
nmap <Leader>l :bnext<CR>
nmap <Leader>h :bprevious<CR>
nmap <Leader>q :bdelete<CR>

" Splits
nmap <leader>vs :vsp<CR>
nmap <leader>sp :sp<CR>

"Salto de linea sin cambiar a modo insertar
nmap <Leader>o o<ESC>
nmap <Leader>O O<ESC>

" Terminal
nmap <Leader>t :split <CR>:ter<CR>:resize 10<CR>
vmap <Leader>t :split <CR>:ter<CR>:resize 10<CR>
