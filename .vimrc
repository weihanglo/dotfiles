" General {{{
set encoding=utf-8
set mouse=a
set nocompatible
set hidden
set laststatus=2
set showmatch
set hlsearch
set incsearch
set number
set relativenumber
set cursorline
set lazyredraw
set history=100
set foldnestmax=2
set nowrap
set scrolloff=2
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab
set smartindent
set autoindent
set colorcolumn=80
set backspace=indent,eol,start
set clipboard=unnamed,unnamedplus
set dictionary+=/usr/share/dict/words
set list listchars=eol:¬,tab:▸\ ,extends:»,precedes:«,trail:•
set wildmenu wildmode=longest:full,full
set wildignore+=*.swo,*.swp,*.RData,*~,*.log,*.db,*.sqilte,*__pycache__/*
" }}}

" filetype {{{
" auto load view if exists
augroup autoloadview
   autocmd!
   autocmd BufWinEnter *.* silent! loadview
augroup END

" recognize *.m as objective-c
augroup filetype_objc
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead *.m setfiletype objc
augroup END

" recognize *.md as markdown
augroup filetype_markdown
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead *.md setfiletype markdown
augroup END

" vim-r-plugin
augroup filetype_r
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead *.{R,Rnw,Rd,Rmd,Rrst}
        \ call VimRPluginConf()
augroup END

" vimL
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" java
augroup filetype_java
    autocmd!
    autocmd FileType java setlocal omnifunc=javacomplete#Complete
augroup END

augroup filetype_python
    autocmd!
    autocmd FileType python setlocal foldmethod=indent
augroup END
" }}}

" Key mapping {{{
" map localleader if necessary
let maplocalleader = ','

inoremap hh <Esc>
inoremap jj <Esc>
inoremap kk <Esc>
inoremap jk <Esc>
inoremap kj <Esc>

cnoreabbrev W w
cnoreabbrev W! w!
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev Wa wa
cnoreabbrev WA wa
cnoreabbrev Q q
cnoreabbrev Q! q!
cnoreabbrev Qa qa
cnoreabbrev QA qa
cnoreabbrev Qa! qa!
cnoreabbrev QA! qa!
cnoreabbrev Bd bd
cnoreabbrev BD bd
cnoreabbrev Bd! bd!
cnoreabbrev BD! bd!

"" Move visual block
vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv
" }}}

" Vim-plug {{{

" auto install vim-plug.vim
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'bling/vim-airline'
Plug 'edkolev/tmuxline.vim'
Plug 'vim-airline/vim-airline-themes'
"Plug 'altercation/vim-colors-solarized'
Plug 'w0ng/vim-hybrid'
Plug 'davidhalter/jedi-vim', {'for': 'python'}
Plug 'jalvesaq/R-Vim-runtime', {'for': 'r'}
Plug 'jcfaria/Vim-R-plugin', {'for': 'r'}
Plug 'chrisbra/csv.vim', {'for': ['csv', 'tsv']}
Plug 'terryma/vim-multiple-cursors'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-ctrlspace/vim-ctrlspace'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'jpalardy/vim-slime'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

filetype plugin indent on

call plug#end()
" }}}

" Colorscheme {{{
" solarized
"syntax enable
"set background=dark
"let g:solarized_termcolors = 256
"colorscheme solarized
" hybrid
set background=dark
colorscheme hybrid
" }}}

" vim-multiple-cursors {{{
" before multiple cursors
function! Multiple_cursors_before()
    if exists('g:jedi#popup_on_dot')
        let g:jedi#popup_on_dot = 0
    endif
endfunction

" after multiple cursors
function! Multiple_cursors_after()
    if exists('g:jedi#popup_on_dot')
        let g:jedi#popup_on_dot = 1
    endif
endfunction
" }}}

" vim-r-plugin {{{
if !exists("*VimRPluginConf")
    function VimRPluginConf()
        let g:vimrplugin_restart = 1          " restart new session
        let g:vimrplugin_assign = 0           " Do not bind '_' as ' <- '
        let g:vimrplugin_tmux_title = "automatic"
        vmap <buffer> <Space> <Plug>RDSendSelection
        nmap <buffer> <Space> <Plug>RDSendLine
    endfunction
endif
" }}}

" vim-slime (REPL) {{{
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}
let g:slime_dont_ask_default = 1
let g:slime_paste_file = tempname()
" }}}

" airline {{{
" theme
let g:airline_powerline_fonts = 1
let g:airline_theme='murmur'

" integration
let g:airline#extensions#tabline#enabled = 1            " tabline
let g:airline#extensions#branch#enabled = 1             " fugitive
let g:airline#extensions#csv#column_display = 'Name'    " csv.vim
let g:airline#extensions#ctrlspace#enabled = 1          " ctrlspace

" auto-generate snapshots
if empty(glob('~/.tmuxline'))
    let g:airline#extensions#tmuxline#snapshot_file = '~/.tmuxline'
endif
" }}}

" tmuxline {{{
let g:tmuxline_preset = {
    \'a'    : '#S',
    \'cwin' : ['#F#I', '#W'],
    \'win'  : ['#F#I', '#W'],
    \'x'    : '#(uptime | rev | cut -d":" -f1 | rev | sed s/,//g)',
    \'y'    : ['%R', '%b %d'],
    \'z'    : '#H',
    \'options' : {'status-justify' : 'left'}}
" }}}
