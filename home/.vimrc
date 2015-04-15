filetype off
set nu
" set lazyredraw
set list
set mat=2
set showmatch
set history=700
set tabpagemax=30
set nocompatible
set so=7
set ic
set hlsearch
set incsearch
set foldmethod=indent
set foldlevel=99
setlocal tabstop=4 expandtab shiftwidth=4 softtabstop=4
set t_Co=256
set relativenumber
set number
set cm=blowfish

" #Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
call vundle#end() 
" #
filetype plugin indent on
syntax on

" #Theme
" colorscheme cake16
" colorscheme spacegray
colorscheme gotham
" #

" #overlength
highlight OverLength ctermbg=red ctermfg=white guibg=#59292
match OverLength /\%79v.\+/
" #

" #Mappings
nnoremap <F5> g:nf_map_next <CR>
inoremap <F5> <C-R> g:nf_map_next <CR>
nmap <F3> a<C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR><Esc>
imap <F3> <C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR>
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
map <c-Down> <c-w>j
map <c-Up> <c-w>k
map <c-Right> <c-w>l
map <c-Left> <c-w>h
map <leader>j :RopeGotoDefinition<CR>
"get rid of 80 char overlength highlighting for odd files:
nmap <F4> :match OverLength /\%7900v.\+/<CR>
let g:pep8_map='<leader>8' "pep8
" #

" #autocmd stuff
"autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" #
