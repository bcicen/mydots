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

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

set directory=~/.vim/swap
set cm=blowfish

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Autocomplete / Syntax Highlighting
Plugin 'rodjek/vim-puppet'
Plugin 'Valloric/YouCompleteMe'
Plugin 'fatih/vim-go'
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'pangloss/vim-javascript'

Plugin 'tpope/vim-unimpaired'
Plugin 'scrooloose/nerdtree'

" Colorschemes
Plugin 'whatyouhide/vim-gotham'

" Git
Plugin 'tpope/vim-fugitive'

call vundle#end()
filetype plugin indent on
syntax on
let g:ycm_python_binary_path = '/usr/bin/python3'

" Theme
colorscheme gotham

" overlength
highlight OverLength ctermbg=red ctermfg=white guibg=#59292
au BufRead,BufNewFile *.py match OverLength /\%79v.\+/

" Mappings
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

" gitv/fugitive mappings
nnoremap <F5> g:nf_map_next <CR>
inoremap <F5> <C-R> g:nf_map_next <CR>
nnoremap <space>ga :Git add %:p<CR><CR>
nnoremap <space>gs :Gstatus<CR>
nnoremap <space>gc :Gcommit -v -q<CR>
nnoremap <space>gt :Gcommit -v -q %:p<CR>
nnoremap <space>gd :Gdiff<CR>
nnoremap <space>ge :Gedit<CR>
nnoremap <space>gr :Gread<CR>
nnoremap <space>gw :Gwrite<CR><CR>
nnoremap <space>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <space>gp :Ggrep<Space>
nnoremap <space>gm :Gmove<Space>
nnoremap <space>gb :Git branch<Space>
nnoremap <space>go :Git checkout<Space>

"make json pretty
nnoremap <F6> :%!python -m json.tool<CR>:w<CR>

"quote single word
nnoremap qw :silent! normal mpea"<Esc>bi"<Esc>`pl

" autocmd stuff
"autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Custom commands
"enables to search in all open buffers with :Search <pattern>
command! -nargs=1 Search call setqflist([]) | silent cex [] | bufdo vimgrepadd /<args>/g %
