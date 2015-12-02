filetype off

" set lazyredraw

set mat=2
set showmatch
set history=700

set t_Co=256
set nu
set relativenumber
set tabpagemax=30
set nocompatible
set so=7 "scrolloff
set foldmethod=indent
set foldlevel=99

set ic
set hlsearch
set incsearch

set tabstop=2
set shiftwidth=2
set softtabstop=2
" set noexpandtab 

set cm=blowfish

" #Vundle
set rtp+=~/.vim/vundle.git/
call vundle#rc()

Bundle 'gmarik/Vundle.vim'

Bundle 'rodjek/vim-puppet'
Bundle 'Valloric/YouCompleteMe'
Bundle 'tpope/vim-unimpaired'
Bundle 'scrooloose/nerdtree'
Bundle 'jistr/vim-nerdtree-tabs'
Bundle 'fatih/vim-go'
" Bundle 'vim-scripts/pep8'

" #Colorschemes
Bundle 'whatyouhide/vim-gotham'
" Bundle 'zefei/cake16'
" Bundle 'ajh17/spacegray.vim'
" Bundle 'endel/vim-github-colorscheme'

" #Git
Bundle 'tpope/vim-fugitive'
" Bundle 'gregsexton/gitv'

filetype plugin indent on
syntax on

" #Theme
" colorscheme cake16
" colorscheme spacegray
colorscheme gotham
" #

" #overlength
highlight OverLength ctermbg=red ctermfg=white guibg=#59292
au BufRead,BufNewFile *.py match OverLength /\%79v.\+/
" #

" #Mappings
let mapleader = "\<Space>"
let g:pep8_map='<leader>8' "pep8
nnoremap <Leader>w :w<CR>
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
map <c-Down> <c-w>j
map <c-Up> <c-w>k
map <c-Right> <c-w>l
map <c-Left> <c-w>h
map <leader>j :RopeGotoDefinition<CR>
"insert timestamp under cursor
nmap <F3> a<C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR><Esc>
imap <F3> <C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR>
"clear 80 char overlength highlighting:
nmap <F4> :match OverLength /\%7900v.\+/<CR>
"for gitv
nnoremap <F5> g:nf_map_next <CR>
inoremap <F5> <C-R> g:nf_map_next <CR>
"make json pretty
nnoremap <F6> :%!python -m json.tool<CR>:w<CR>
" #

" #autocmd stuff
"autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" #
