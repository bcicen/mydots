filetype off

set mat=2
set showmatch
set showcmd
set history=700

set nu
set so=7 "scrolloff
set t_Co=256
set hidden
set relativenumber
set tabpagemax=30
set nocompatible
set foldmethod=manual
set foldlevel=99
set iskeyword+=-
set splitright
"set foldmarker={,} foldlevel=0 foldmethod=manual

function! VResize(n)
  exe 'vertical resize '  . (winwidth(0) * a:n/100)
endfunction

function! Percent()
  let byte = line2byte( line( "." ) ) + col( "." ) - 1
  let size = (line2byte( line( "$" ) + 1 ) - 1)
  " return byte . " " . size . " " . (byte * 100) / size
  return (byte * 100) / size
endfunction

set laststatus=2
let statusbase="%F%m%r%h%w[%L][%p%%][%{Percent()}%%][%04l,%04v]-%{fugitive#statusline()}"
execute "set statusline=".statusbase
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
set cm=blowfish2

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'pangloss/vim-javascript'
Plugin 'leafgarland/typescript-vim'
Plugin 'jasontbradshaw/pigeon.vim'

Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/nerdcommenter'
Plugin 'jeetsukumaran/vim-buffersaurus'
Plugin 'bcicen/vim-jfmt'
Plugin 'tpope/vim-jdaddy'
Plugin 'diepm/vim-rest-console'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-surround'
Plugin 'junegunn/vim-peekaboo'
Plugin 'jparise/vim-graphql'
Plugin 'guns/xterm-color-table.vim'
Plugin 'leafOfTree/vim-svelte-plugin'

" Go

Plugin 'fatih/vim-go'

"let g:go_debug = ['lsp']
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
"au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
au FileType go nmap <leader>gr <Plug>(go-run)

autocmd FileType go let b:go_fmt_options = {
  \ 'goimports': '-local "' .
    \ trim(system('cd '. shellescape(expand('%:h')) .' && go list -m 2>/dev/null;')) . '"',
  \ }

let g:go_addtags_transform = 'snakecase'
"let g:go_addtags_transform = 'camelcase'


" Yaml
Plugin 'lmeijvogel/vim-yaml-helper'
let g:vim_yaml_helper#auto_display_path = 1

" Makefile
au FileType make set noexpandtab

" Snippets
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

"let g:vrc_curl_opts = {
  "\ '--connect-timeout' : 10,
  "\ '-L': '',
  "\ '-i': '',
  "\ '--max-time': 60,
  "\ '--ipv4': '',
  "\ '-k': '',
"\}


" Colorschemes
Plugin 'bcicen/vim-vice'

" Git
Plugin 'tpope/vim-fugitive'

" Misc
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-unimpaired'
Plugin 'isobit/vim-caddyfile'
Plugin 'cstrahan/vim-capnp'

" TERRAFORM
Plugin 'hashivim/vim-terraform'
Plugin 'vim-syntastic/syntastic'
Plugin 'juliosueiras/vim-terraform-completion'

" Syntastic Config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:go_fmt_fail_silently = 0
let g:go_list_type = "quickfix"
let g:go_highlight_diagnostic_errors = 0
let g:go_highlight_diagnostic_warnings = 0
let g:syntastic_quiet_messages = { "level": "warnings" }
let g:pymode_lint_on_write = 0

let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "active_filetypes": ["go"] }

" (Optional)Hide Info(Preview) window after completions
" autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
" autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" (Optional) Enable terraform plan to be include in filter
let g:syntastic_terraform_tffilter_plan = 1

" (Optional) Default: 0, enable(1)/disable(0) plugin's keymapping
let g:terraform_completion_keys = 1

" (Optional) Default: 1, enable(1)/disable(0) terraform module registry completion
let g:terraform_registry_module_completion = 0


call vundle#end()
filetype plugin indent on
syntax on
let g:ycm_python_binary_path = '/usr/bin/python3'
let g:ycm_show_diagnostics_ui = 0
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 0
let g:ycm_goto_buffer_command = 'split'
let g:ycm_disable_for_files_larger_than_kb = 1400
let g:ycm_auto_hover = ''

function! s:CustomizeYcmQuickFixWindow()
  5wincmd _ " set quickfix window height
endfunction

autocmd User YcmQuickFixOpened call s:CustomizeYcmQuickFixWindow()

" Custom filetype extensions
au BufNewFile,BufRead *.geojson,*.jsonl set filetype=json
au BufNewFile,BufRead Dockerfile* set filetype=dockerfile
au BufRead,BufNewFile *.peg set ft=pigeon

" Theme
set termguicolors
colorscheme vice

" overlength
" au BufRead,BufNewFile *.py match OverLength /\%79v.\+/

" Mappings
let mapleader = "\<Space>"
let g:pep8_map='<leader>8' "pep8
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
map <c-Down> <c-w>j
map <c-Up> <c-w>k
map <c-Right> <c-w>l
map <c-Left> <c-w>h
map <Leader>w <Esc>:w<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>n :n<CR>
nnoremap gb :ls<CR>:b<Space>
nnoremap gv :ls<CR>:vert belowright sb<Space>
nnoremap <Leader>; :noh<CR>
nnoremap <Leader>' :SyntasticCheck<CR>

" shift + HJKL
nnoremap H ^
nnoremap L $
"nnoremap J <C-d>
"nnoremap K <C-u>

" search for matches of current visual selection
vnoremap // y/<C-R>"<CR>

" yank current selection to command line
vnoremap : y:Bsgrep <C-r>"<C-b>

"insert timestamp under cursor
nmap <F3> a<C-R>=strftime("%Y-%m-%d %a %I:%M %p %Z")<CR><Esc>
imap <F3> <C-R>=strftime("%Y-%m-%d %a %I:%M %p %Z")<CR>

"clear 80 char overlength highlighting:
nmap <F4> :match OverLength /\%79v.\+/<CR>

" gitv/fugitive mappings
nnoremap <F5> g:nf_map_next <CR>
inoremap <F5> <C-R> g:nf_map_next <CR>
nnoremap <space>gl :silent! Glog<CR>:bot copen<CR>

nmap <F6> :tab sball<CR>
nmap <F7> :vertical sball<CR>
nmap <F8> :TagbarToggle<CR>
nmap <F9> :TagbarOpenAutoClose<CR>

"quote single word
nnoremap qw :silent! normal mpea"<Esc>bi"<Esc>`pl
" substitute word under cursor global
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
" substitute word under cursor local
nnoremap <Leader>d :s/\<<C-r><C-w>\>/<C-r><C-w>

" ctrl+t for new tab
nmap <C-t> :tabnew<CR>
" ctrl+d close tab
nmap <C-d> :q<CR>
" ctrl+l/h to switch tabs
nmap <C-l> :tabn<CR>
nmap <C-h> :tabp<CR>

" autocmd stuff
"autocmd vimenter * NERDTree

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" automatically save and load views/folds
"autocmd BufWinLeave *.* mkview
"autocmd BufWinEnter *.* silent loadview
" open at last known cursor position, if possible
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Custom commands
"enables to search in all open buffers with :Search <pattern>
command! -nargs=1 Search call setqflist([]) | silent cex [] | bufdo vimgrepadd /<args>/g %

let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'go']

let g:rg_command = '
  \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
  \ -g "!{.git,node_modules,vendor}/*" '

command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)

" let g:jfmt_autofmt = 1

let g:UltiSnipsExpandTrigger="<c-\\>"

command! RegFlush for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor

function! Flt_term_win(cmd, width, height, border_highlight) abort
    let width = float2nr(&columns * a:width)
    let height = float2nr(&lines * a:height)
    let bufnr = term_start(a:cmd, {'hidden': 1, 'term_finish': 'close'})

    let winid = popup_create(bufnr, {
            \ 'line': 1,
            \ 'col': float2nr(&columns * 0.5),
            \ 'minwidth': width,
            \ 'maxwidth': width,
            \ 'minheight': height,
            \ 'maxheight': height,
            \ 'border': [],
            \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
            \ 'borderhighlight': [a:border_highlight],
            \ 'padding': [0,1,0,1],
            \ 'highlight': a:border_highlight
            \ })

    " Optionally set the 'Normal' color for the terminal buffer
    " call setwinvar(winid, '&wincolor', 'Special')

    return winid
endfunction

nnoremap <silent> <leader>gz :call Flt_term_win('lazygit',0.9,0.6,'clear')<CR>

nnoremap <leader>jd :rightbelow vertical YcmCompleter GoTo<CR>
nnoremap <leader>jr :YcmCompleter GoToReferences<CR>

set previewpopup=highlight:PMenuSbar
set completeopt+=popup
set completepopup=border:on,highlight:PMenuSbar

function! LabelPop(txt,offset) abort
  let w = strlen(a:txt)
  let col = strlen(getline('.')) + float2nr(w) + a:offset
  let height = 1

  let winid = popup_create(a:txt, {
          \ 'line': line('.')-1,
          \ 'col': col,
          \ 'minwidth': 1,
          \ 'maxwidth': 50,
          \ 'minheight': height,
          \ 'maxheight': height,
          \ 'border': [],
          \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
          \ 'borderhighlight': ['clear'],
          \ 'padding': [0,1,0,1],
          \ 'highlight': 'clear'
          \ })

  return winid
endfunction
