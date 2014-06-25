syntax on
set history=700
set nocompatible              " be iMproved, required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'nanotech/jellybeans.vim'
Bundle 'rodjek/vim-puppet'
Bundle 'https://github.com/endel/vim-github-colorscheme.git'
Bundle 'Valloric/YouCompleteMe'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-unimpaired'
Bundle 'gregsexton/gitv'
filetype plugin indent on     " required
" end vundle shit
set so=7
set cm=blowfish
set ic
set hlsearch
set incsearch
" set lazyredraw
set showmatch
set mat=2
" colorscheme desert
" colorscheme jellybeans
colorscheme github
set background=dark
" highlight Normal ctermbg=darkgrey
highlight OverLength ctermbg=red ctermfg=white guibg=#59292
" match OverLength /\%79v.\+/
nnoremap <F5> g:nf_map_next <CR>
inoremap <F5> <C-R> g:nf_map_next <CR>
nmap <F3> a<C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR><Esc>
imap <F3> <C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR>
" for python
setlocal tabstop=4 expandtab shiftwidth=4 softtabstop=4
set nu
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>
