syntax on
set nu
" set lazyredraw
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
filetype off                  " required

" #Vundle
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
"
Bundle 'gmarik/vundle'
Bundle 'rodjek/vim-puppet'
Bundle 'Valloric/YouCompleteMe'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-unimpaired'
Bundle 'scrooloose/nerdtree'
" #Colorschemes
Bundle 'whatyouhide/vim-gotham'
Bundle 'zefei/cake16'
Bundle 'ajh17/spacegray.vim'
Bundle 'endel/vim-github-colorscheme' 
" #snipmate 
" Bundle 'garbas/vim-snipmate'
" Bundle "MarcWeber/vim-addon-mw-utils"
" Bundle "tomtom/tlib_vim"
" Bundle "honza/vim-snippets"
" #
" Bundle 'gregsexton/gitv'
Bundle 'vim-scripts/pep8'
Bundle 'ivanov/vim-ipython'
" Bundle 'python-rope/ropevim'
filetype plugin indent on " required
" # 

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
let g:pep8_map='<leader>8' "pep8
" #

" #autocmd stuff
"autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" #
