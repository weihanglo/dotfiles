" General {{{
set autoindent
set backspace=indent,eol,start
set clipboard+=unnamed,unnamedplus
set colorcolumn=80
set cursorline
set dictionary+=/usr/share/dict/words
set expandtab
set foldnestmax=2
set hidden
set history=100
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set linebreak
set list listchars=eol:¬,tab:▸\ ,extends:»,precedes:«,trail:•
set mouse=a
set nowrap
set number
set relativenumber
set scrolloff=2
set shiftwidth=4
set showmatch
set smartcase
set smartindent
set smarttab
set softtabstop=4
set splitbelow
set splitright
set timeoutlen=500
set wildignore+=*.swo,*.swp,*.RData,*~,*.log,*.db,*.sqilte,*__pycache__/*
set wildmenu wildmode=longest:full,full
set winminheight=0
if has('termguicolors')
    set termguicolors
endif
" }}}

" Filetype {{{
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
    autocmd BufNewFile,BufFilePre,BufRead *.{js,css,html,yaml,yml,toml,json,md}
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

" Sort quickly
vnoremap gs :sort<CR>

"" Highlight visual selected text
vnoremap // y/<C-R>"<CR>

" }}}

" Neovim Python Setup {{{
"let g:loaded_python_provider = 0 " disable python2 neovim support
if exists(glob('/usr/local/bin/python3'))
    let g:python3_host_prog = '/usr/local/bin/python3'
    let g:ycm_python_binary_path = '/usr/local/bin/python3'
else
    let g:python3_host_prog = '/usr/bin/python3'
    let g:ycm_python_binary_path = '/usr/bin/python3'
endif
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

" user interface
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
Plug 'joshdick/onedark.vim'
Plug 'bling/vim-bufferline'

" fast moves
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" scm
Plug 'airblade/vim-gitgutter'

" linter
Plug 'w0rp/ale'

" snippets/completions
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" filetype and completions
Plug 'sheerun/vim-polyglot'
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'Valloric/YouCompleteMe', { 'do': 
    \ './install.py --js-completer --rust-completer' }

" miscellaneous
Plug 'jpalardy/vim-slime', { 'for': ['javascript', 'python', 'r'] }
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'ryanss/vim-hackernews'

call plug#end()
" }}}

" Colorscheme {{{
set background=dark
colorscheme onedark
" }}}

" ALE {{{
" Enable completion where available.
let g:ale_completion_enabled = 1
let g:ale_lint_delay = 1000
let g:ale_lint_on_text_changed = 'never'
let g:ale_fix_on_save = 1
let g:ale_lint_on_enter = 0
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
" }}}

" YCM {{{
" make YCM compatible with UltiSnips <tab>
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
"}}}

" UltiSnips {{{
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
" }}}
"
" NERDTree {{{
nnoremap <LocalLeader><C-o> :NERDTreeToggle<CR>
nnoremap <LocalLeader>c :bp\|bd #<CR>
" }}}

" vim-slime {{{
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}
let g:slime_dont_ask_default = 1
let g:slime_paste_file = tempname()
" }}}

" vim-grep {{{
let g:grepper = {}
let g:grepper.tools = ['rg', 'grep', 'git']
" Search working directory
nnoremap <leader>g :Grepper<cr>
" Search opened buffers
nnoremap <leader>G :Grepper -buffers<cr>
" Search the word under the cursor
nnoremap <leader>* :Grepper  -cword -noprompt<cr>
" Search with operators
nmap gs  <plug>(GrepperOperator)
xmap gs  <plug>(GrepperOperator)
" }}}

" Airline {{{
" theme
let g:airline_powerline_fonts = 0
let g:airline_left_sep = '»'
let g:airline_left_sep = ' '
let g:airline_right_sep = '«'
let g:airline_right_sep = ' '
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.maxlinenr = '☰'
let g:airline_symbols.branch = ''
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = '∄'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_theme = 'jellybeans'

" integration
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s '

" auto-generate snapshots
let g:airline#extensions#tmuxline#snapshot_file = '~/.tmuxline'
" }}}

" Tmuxline {{{
let g:tmuxline_powerline_separators = 0
let g:tmuxline_separators = {}
let g:tmuxline_separators.left = ''
let g:tmuxline_separators.left_alt = '»'
let g:tmuxline_separators.right = ''
let g:tmuxline_separators.right_alt = '«'
let g:tmuxline_separators.space = ' '
let g:tmuxline_preset = {}
let g:tmuxline_preset.a = '#S'
let g:tmuxline_preset.cwin = ['#F#I', '#W']
let g:tmuxline_preset.win = ['#F#I', '#W']
let g:tmuxline_preset.y = ['%R', '%b %d']
let g:tmuxline_preset.z = '#H'
let g:tmuxline_preset.options = { 'status-justify' : 'left'}
" }}}
