" General {{{
set autoindent
set backspace=indent,eol,start
set clipboard+=unnamed,unnamedplus
set colorcolumn=80
set completeopt=menu,menuone,preview,noinsert,noselect
set cursorline
set dictionary+=/usr/share/dict/words
set expandtab
set foldmethod=indent
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
set nonumber
set norelativenumber
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

" recognize *.md as markdown
augroup filetype_markdown
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead *.md setfiletype markdown
        \ setlocal nofoldenable
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
cnoreabbrev qA qa
cnoreabbrev Qa qa
cnoreabbrev QA qa
cnoreabbrev qA! qa!
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

" fast moves
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" scm
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" linter
Plug 'dense-analysis/ale'

" snippets/autocompletions
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'ycm-core/YouCompleteMe', { 'do':
    \ './install.py --ts-completer  --rust-completer --go-completer' }

" filetype
Plug 'sheerun/vim-polyglot'
Plug 'rust-lang/rust.vim', {'for': 'rust'}

" search
Plug 'junegunn/fzf', {
    \ 'dir': '~/.fzf',
    \ 'do': './install --all',
    \ 'on': 'FZF'
    \}
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

" miscellaneous
Plug 'jpalardy/vim-slime',
    \{ 'for': ['javascript', 'python', 'r', 'typescript', 'bash'] }
Plug 'tpope/vim-commentary'

call plug#end()
" }}}

" UltiSnips {{{
let g:UltiSnipsExpandTrigger = '<c-j>'
" }}}

" YouCompleteMe {{{
" map to <LocalLeader>K to act like default man.vim's keymapping.
nnoremap <silent><LocalLeader>K :YcmCompleter GoToDefinition<CR>
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_show_diagnostics_ui = 0
let g:ycm_key_list_select_completion = ['<tab>', '<c-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<s-tab>', '<c-p>', '<Up>']
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
" Enable completion where available.
let g:ale_completion_enabled = 0
let g:ale_lint_delay = 1000
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
let g:ale_linters = {
    \   'javascript': ['eslint'],
    \   'typescript': ['tslint', 'tsserver', 'typecheck'],
    \   'python': ['flake8', 'pylint']
    \}
let g:ale_fixers = {
    \   'javascript': ['eslint'],
    \   'typescript': ['tslint', 'tsserver', 'typecheck']
    \}
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

" NERDTree {{{
nnoremap <silent><LocalLeader>n :NERDTreeToggle<CR>
nnoremap <silent><LocalLeader>c :bp\|bd #<CR>
" }}}

" FZF {{{
" Use system's default options.
nnoremap <silent><c-p> :FZF<CR>
" Do not ignore ignores!
nnoremap <silent><LocalLeader><C-P> :call
    \ fzf#run({'source': 'rg --files -u'})<CR>
" }}}

" vim-slime {{{
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}
let g:slime_dont_ask_default = 1
let g:slime_paste_file = tempname()
" }}}

" vim-grepper {{{
let g:grepper = { 'tools': ['rg', 'grep', 'git'] }
let g:grepper.rg = { 'grepprg': 'rg -HS --no-heading --vimgrep' }
" Search working directory
nnoremap <silent><LocalLeader>g :Grepper<cr>
" Search opened buffers
nnoremap <silent><LocalLeader>G :Grepper -buffers<cr>
" Search the word under the cursor
nnoremap <silent><LocalLeader>g* :Grepper -cword -noprompt<cr>
" Search with operators
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
" }}}

" Colorscheme {{{
"set background=dark
"colorscheme onedark
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

" {{{ vim-polyglot
let g:vim_markdown_conceal = 0
" }}}
