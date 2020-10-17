" General {{{
set autoindent
set backspace=indent,eol,start
set clipboard+=unnamed,unnamedplus
set colorcolumn=80
set completeopt=menuone,noinsert,noselect
set cursorline
set dictionary+=/usr/share/dict/words
set expandtab
set foldmethod=indent
set foldnestmax=2
set hidden
set history=10000
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set lazyredraw
set linebreak
set list listchars=eol:¬,tab:▸\ ,extends:»,precedes:«,trail:•
set mouse=a
set nonumber
set noswapfile
set nowrap
set scrolloff=2
set shiftwidth=4
set showmatch
set sidescrolloff=4
set shortmess+=c
set smartcase
set smartindent
set smarttab
set softtabstop=4
set splitbelow
set splitright
set termguicolors
set timeoutlen=500
set undodir=/tmp/nvim/undo
set undofile
set undolevels=10000
set updatetime=500
set wildignore+=*.swo,*.swp,*~,*.log,*.db,*.sqilte,*__pycache__/*
set wildignorecase
set wildmenu wildmode=longest:full,full
set winminheight=0
" }}}

" Filetype {{{
" auto load view if exists
augroup autoloadview
   autocmd!
   autocmd BufWinEnter *.* silent! loadview
augroup END

" vimL
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" for web development
augroup filetype_web
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead
        \ *.{js,jsx,ts,tsx,css,html,yaml,yml,toml,json,md}
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END
" Go
augroup filetype_go
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead
        \ *.{go}
        \ setlocal tabstop=4 noexpandtab softtabstop=0 shiftwidth=4
augroup END
" }}}

" Key mapping {{{
" map localleader if necessary
let maplocalleader = ','

cnoreabbrev W w
cnoreabbrev W! w!
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev Wa wa
cnoreabbrev WA wa
cnoreabbrev Q q
cnoreabbrev Q! q!
cnoreabbrev q1 q!
cnoreabbrev Q1 q!
cnoreabbrev qA qa
cnoreabbrev Qa qa
cnoreabbrev QA qa
cnoreabbrev qA! qa!
cnoreabbrev Qa! qa!
cnoreabbrev QA! qa!
cnoreabbrev qA1 qa!
cnoreabbrev Qa1 qa!
cnoreabbrev QA1 qa!
cnoreabbrev Bd bd
cnoreabbrev BD bd
cnoreabbrev Bd! bd!
cnoreabbrev BD! bd!
cnoreabbrev Nohl nohl
cnoreabbrev NOhl nohl

" Move visual block
vnoremap K <cmd>m '<-2<CR>gv=gv
vnoremap J <cmd>m '>+1<CR>gv=gv

" Highlight visual selected text
vnoremap // y/<C-R>"<CR>
" }}}

" Neovim Python Setup {{{
if !empty(glob('/usr/local/bin/python'))
    let g:python_host_prog = '/usr/local/bin/python'
else
    let g:python_host_prog = '/usr/bin/python'
endif

" Reference: https://duseev.com/articles/vim-python-pipenv/
let pipenv_venv_path = system('pipenv --venv')
if v:shell_error == 0
    let venv_path = substitute(pipenv_venv_path, '\n', '', '')
    let g:ycm_python_binary_path = venv_path . '/bin/python'
else
    if !empty(glob('/usr/local/bin/python3'))
        let g:python3_host_prog = '/usr/local/bin/python3'
        let g:ycm_python_binary_path = '/usr/local/bin/python3'
    else
        let g:python3_host_prog = '/usr/bin/python3'
        let g:ycm_python_binary_path = '/usr/bin/python3'
    endif
endif

" }}}

" Vim-plug {{{
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

" fast moves
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'mg979/vim-visual-multi'

" scm
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive', { 'on': ['Git', 'Gblame', 'G'] }

" linter
Plug 'dense-analysis/ale'

" snippets/autocompletions
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'ycm-core/YouCompleteMe', { 'do':
    \ './install.py --ts-completer --go-completer' }

" filetype
Plug 'sheerun/vim-polyglot'

" search
Plug 'junegunn/fzf', {
    \ 'dir': '~/.fzf',
    \ 'do': { -> fzf#install() },
    \ 'on': 'FZF'
    \}
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

call plug#end()
" }}}

" UltiSnips {{{
let g:UltiSnipsExpandTrigger = '<c-j>'
" }}}

" YouCompleteMe {{{
nnoremap <silent><LocalLeader>K :YcmCompleter GoTo<CR>
nnoremap <silent><LocalLeader>R :YcmCompleter GoToReferences<CR>
nnoremap <F2> :YcmCompleter RefactorRename<space>
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_show_diagnostics_ui = 1
let g:ycm_key_list_select_completion = ['<c-n>']
let g:ycm_key_list_previous_completion = ['<c-p>']
let g:ycm_filetype_specific_completion_to_disable = {
    \ 'vim': 1,
    \ 'gitcommit': 1
    \}
let g:ycm_language_server =
    \ [
    \   {
    \     'name': 'rust',
    \     'cmdline': ['rust-analyzer'],
    \     'filetypes': ['rust'],
    \     'project_root_files': ['Cargo.toml']
    \   }
    \ ]
" }}}"

" ALE {{{
let g:ale_completion_enabled = 0
let g:ale_lint_delay = 1000
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
let g:ale_linters = {
    \   'javascript': ['eslint'],
    \   'typescript': ['eslint', 'tsserver', 'typecheck'],
    \   'python': ['flake8', 'pylint']
    \}
let g:ale_fixers = {
    \   'javascript': ['eslint'],
    \   'typescript': ['eslint', 'tsserver', 'typecheck']
    \}
" }}}

" NERDTree {{{
nnoremap <silent> <LocalLeader>n <cmd>NERDTreeToggle<CR>
nnoremap <silent> <LocalLeader>c <cmd>bp<bar>bd #<CR>
" }}}

" FZF {{{
" Use system's default options.
nnoremap <silent> <c-p> <cmd>FZF<CR>
" Do not ignore ignores!
nnoremap <silent><LocalLeader><C-P> :call
    \ fzf#run({'source': 'rg --files -u'})<CR>
" }}}

" vim-grepper {{{
let g:grepper = { 'tools': ['rg', 'grep', 'git'] }
let g:grepper.rg = { 'grepprg': 'rg -HS --no-heading --vimgrep' }
" Search working directory
nnoremap <silent> <LocalLeader>g <cmd>Grepper<cr>
" Search opened buffers
nnoremap <silent> <LocalLeader>G <cmd>Grepper -buffers<cr>
" Search the word under the cursor
nnoremap <silent> <LocalLeader>g* <cmd>Grepper -cword -noprompt<cr>
" Search with operators
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
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
let g:tmuxline_separators.left_alt = ''
let g:tmuxline_separators.right = ''
let g:tmuxline_separators.right_alt = ''
let g:tmuxline_separators.space = ' '
let g:tmuxline_preset = {}
let g:tmuxline_preset.a = '#S'
let g:tmuxline_preset.cwin = ['#F#I', '#W']
let g:tmuxline_preset.win = ['#F#I', '#W']
let g:tmuxline_preset.y = ['%R', '%b %d']
let g:tmuxline_preset.z = '#H'
let g:tmuxline_preset.options = { 'status-justify' : 'left'}
" }}}

" {{{ vim-polyglot
let g:vim_markdown_conceal = 0
" }}}
