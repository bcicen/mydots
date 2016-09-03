filetype off

set mat=2
set showmatch
set showcmd
set history=700

set nu
set so=7 "scrolloff
set t_Co=256
set relativenumber
set tabpagemax=30
set nocompatible
set foldmethod=indent
set foldlevel=99
set laststatus=2
set statusline=%F%m%r%h%w[%L][%p%%][%04l,%04v]-%{fugitive#statusline()}
"              | | | | |  |   |     |    |       |
"              | | | | |  |   |     |    |       + current git branch
"              | | | | |  |   |     |    + current column
"              | | | | |  |   |     +-- current line
"              | | | | |  |   +-- current % into file
"              | | | | |  +-- number of lines
"              | | | | +-- preview flag in square brackets
"              | | | +-- help flag in square brackets
"              | | +-- readonly flag in square brackets
"              | +-- rodified flag in square brackets
"              +-- full path to file in the buffer
set ic
set hlsearch
set incsearch

" set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set directory=~/.vim/swap
set cm=blowfish2

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Autocomplete / Syntax Highlighting
Plugin 'fatih/vim-go'
Plugin 'rodjek/vim-puppet'
Plugin 'Valloric/YouCompleteMe'
Plugin 'pangloss/vim-javascript'
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'scrooloose/nerdcommenter'

" Status line
" Plugin 'vim-airline/vim-airline'
" Plugin 'vim-airline/vim-airline-themes'
" let g:airline_theme="vice"
" let g:airline_powerline_fonts = 1

" Colorschemes
Plugin 'bcicen/vim-vice'

" Git
Plugin 'tpope/vim-fugitive'

" Misc
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-unimpaired'
Plugin 'severin-lemaignan/vim-minimap'

call vundle#end()
filetype plugin indent on
syntax on
let g:ycm_python_binary_path = '/usr/bin/python3'

" Theme
colorscheme vice

" overlength
au BufRead,BufNewFile *.py match OverLength /\%79v.\+/

" Mappings
let mapleader = "\<Space>"
let g:pep8_map='<leader>8' "pep8
nnoremap <Leader>w :w<CR>
nnoremap <Leader>n :n<CR>
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

au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
au FileType go nmap <leader>gr <Plug>(go-run)

" gitv/fugitive mappings
nnoremap <F5> g:nf_map_next <CR>
inoremap <F5> <C-R> g:nf_map_next <CR>
nnoremap <space>gl :silent! Glog<CR>:bot copen<CR>

"make json pretty
nnoremap <F6> :%!python -m json.tool<CR>:w<CR>

"quote single word
nnoremap qw :silent! normal mpea"<Esc>bi"<Esc>`pl

" autocmd stuff
"autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" automatically save and load views/folds
"autocmd BufWinLeave *.* mkview
"autocmd BufWinEnter *.* silent loadview

" Custom commands
"enables to search in all open buffers with :Search <pattern>
command! -nargs=1 Search call setqflist([]) | silent cex [] | bufdo vimgrepadd /<args>/g %

