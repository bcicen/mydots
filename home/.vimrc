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
filetype plugin indent on     " required
" end vundle shit
set so=7
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
match OverLength /\%79v.\+/
nnoremap <F5> "=strftime("%c")<CR>P
inoremap <F5> <C-R>=strftime("%c")<CR>
nmap <F3> a<C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR><Esc>
imap <F3> <C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR>
" com! FormatJSON %!python -m json.tool
nmap <F4> <C-R>%!python -m json.tool<CR>
imap <F4> <C-R>%!python -m json.tool<CR>
