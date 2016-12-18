" General {{{
"set encoding=utf-8
set mouse=a
"set nocompatible
set termguicolors " neovim
set hidden
set laststatus=2
set showmatch
set hlsearch
set incsearch
set ignorecase
set smartcase
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
set splitbelow
set splitright
set autoindent
set linebreak
set colorcolumn=80
set timeoutlen=500
set winminheight=0
set backspace=indent,eol,start
set clipboard+=unnamed,unnamedplus
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

" R
augroup filetype_r
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead *.{R,Rnw,Rd,Rmd,Rrst,Rout} 
        \ call RConfig()
augroup END

" vimL
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" python
augroup filetype_python
    autocmd!
    autocmd FileType python 
        \ setlocal foldmethod=indent completeopt-=preview
augroup END

" for web development
augroup filetype_web
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead *.{js,css,html,yaml,yml,toml}
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2
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
cnoreabbrev q1 q!
cnoreabbrev Qa qa
cnoreabbrev QA qa
cnoreabbrev Qa! qa!
cnoreabbrev QA! qa!
cnoreabbrev Bd bd
cnoreabbrev BD bd
cnoreabbrev Bd! bd!
cnoreabbrev BD! bd!
cnoreabbrev Nohl nohl
cnoreabbrev NOhl nohl

" Move visual block
vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

"" Highlight visual selected text
vnoremap // y/<C-R>"<CR>

" }}}

" Vim-plug {{{
" if using Vim
if !has('nvim')
    set runtimepath+=~/.config/nvim/
endif

" auto install vim-plug.vim
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'w0ng/vim-hybrid'
Plug 'weihanglo/tmuxline.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'jpalardy/vim-slime'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'davidhalter/jedi-vim', {'for': 'python'}
Plug 'jalvesaq/Nvim-R', {'for': 'r'}
Plug 'chrisbra/csv.vim', {'for': ['csv', 'tsv']}
Plug 'ternjs/tern_for_vim', {'for': ['jsx', 'js', 'es', 'es6']}

call plug#end()
" }}}

" Colorscheme {{{
" hybrid
set background=dark
colorscheme hybrid
"hi Normal ctermbg=none
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

" Nvim-R {{{
if !exists("*RConfig")
    function RConfig()
        if has("nvim")
            let Rout_more_colors = 1
            let R_assign = 0
            let R_args = ['--no-save', '--no-restore', '--quiet']
"            inoremap <C-Space> <C-x><C-o>      " conflicts with ctrl-space
        endif
    endfunction
endif
" }}}

" vim-slime (REPL via tmux) {{{
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}
let g:slime_dont_ask_default = 1
let g:slime_paste_file = tempname()
" }}}

" airline {{{
" theme
let g:airline_powerline_fonts = 0
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_left_sep = '»'
let g:airline_left_sep = ' '
let g:airline_right_sep = '«'
let g:airline_right_sep = ' '
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.maxlinenr = '☰'
let g:airline_symbols.branch = ''
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = '∄'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_theme='hybrid'

" integration
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#branch#enabled = 1             " fugitive
let g:airline#extensions#csv#column_display = 'Name'    " csv.vim
let g:airline#extensions#tabline#enabled = 1            " tabline
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#buffer_nr_format = '%s '

" auto-generate snapshots
let g:airline#extensions#tmuxline#snapshot_file = '~/.tmuxline'
" }}}

" tmuxline {{{
let g:tmuxline_powerline_separators = 0
let g:tmuxline_separators = {
    \ 'left' : '',
    \ 'left_alt': '»',
    \ 'right' : '',
    \ 'right_alt' : '«',
    \ 'space' : ' '}
let g:tmuxline_preset = {
    \'a'    : '#S',
    \'cwin' : ['#F#I', '#W'],
    \'win'  : ['#F#I', '#W'],
    \'y'    : ['%R', '%b %d'],
    \'z'    : '#H',
    \'options' : {'status-justify' : 'left'}}
" }}}
