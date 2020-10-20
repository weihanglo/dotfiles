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
set pumheight=15
set scrolloff=2
set shiftwidth=4
set shortmess+=c
set showmatch
set sidescrolloff=4
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
augroup AutoloadView
   autocmd!
   autocmd BufWinEnter *.* silent! loadview
augroup END

" vimL
augroup FiletypeVim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" for web development
augroup FiletypeWeb
    autocmd!
    autocmd BufNewFile,BufFilePre,BufRead
        \ *.{js,jsx,ts,tsx,css,html,yaml,yml,toml,json,md}
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" Go
augroup FiletypeGo
    autocmd!
    autocmd FileType go
        \ setlocal tabstop=4 noexpandtab softtabstop=0 shiftwidth=4
augroup END
" }}}

" Detect python virtualenv. Currently support `pipenv`.
" Ref: https://duseev.com/articles/vim-python-pipenv/
function! GetPythonVenvPath()
    let pipenv_venv_path = system('pipenv --venv')
    if v:shell_error == 0
        return substitute(pipenv_venv_path, '\n', '', '')
    endif
endfunction

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

" Vim-plug {{{
" auto install vim-plug.vim
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')

" nvim-lsp
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'nvim-lua/diagnostic-nvim'
Plug 'weihanglo/lsp_extensions.nvim', { 'branch': 'customized' }

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
Plug 'dense-analysis/ale', { 'for': 
    \ ['javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 
    \ 'typescriptreact', 'typescript.tsx'] }

" snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

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

" LSP configurations {{{
lua <<EOF
local nvim_lsp = require'nvim_lsp'

local on_attach = function(client)
  -- Better diagnose UI from `nvim-lua/diagnostic-nvim`
  require'diagnostic'.on_attach(client)
  -- Auto-completion functionality from `nvim-lua/completion-nvim`
  require'completion'.on_attach(client) 
end

-- `git clone https://github.com/rust-analyzer/rust-analyzer` and build!
nvim_lsp.rust_analyzer.setup{ 
  on_attach = on_attach,
  settings = {
    ['rust-analyzer'] = {
      -- Default 128. Ref: https://git.io/JTczw
      lruCapacity = 512
    }
  }
}

-- `npm i g typescript-language-server`
nvim_lsp.tsserver.setup{ on_attach = on_attach }

-- `GO111MODULE=on go get golang.org/x/tools/gopls@latest`
nvim_lsp.gopls.setup{}

-- `python3 -m pip install 'python-language-server[all]'`
nvim_lsp.pyls.setup{
  on_attach = on_attach,
  settings = {
    pyls = {
      plugins = {
        jedi = { 
          environment = vim.fn.eval('GetPythonVenvPath()') 
        }
      }
    }
  }
}
EOF

" Show virtual text for diagnoses
let g:diagnostic_enable_virtual_text = 1
" Delay showing virtual text while inserting
let g:diagnostic_insert_delay = 1

" Support snippets completions
let g:completion_enable_snippet = 'UltiSnips'
"let g:completion_sorting = 'none'
" NOTE: fuzzy + ignore_case may be a little imprecise
let g:completion_matching_strategy_list = ['exact', 'fuzzy']
let g:completion_matching_ignore_case = 1
" CompletionItemKind from https://bit.ly/343efwm
" 100 -> none
" 90 -> property
" 80 -> declaration
" 70 -> variables/values, keywords
" 50 -> file systems
" 40 -> UltiSnips
" 30 -> misc.
let g:completion_items_priority = {
    \    'Method': 90,
    \    'Constructor': 90,
    \    'Field': 90,
    \    'Property': 90,
    \    'Class': 80,
    \    'Enum': 80,
    \    'Struct': 80,
    \    'Unit': 80,
    \    'Event': 80,
    \    'Function': 80,
    \    'EnumMember': 80,
    \    'Interface': 80,
    \    'Module': 80,
    \    'TypeParameter': 80,
    \    'Variable': 70,
    \    'Value': 70,
    \    'Keyword': 70,
    \    'Constant': 70,
    \    'Operator': 70,
    \    'File': 50,
    \    'Folder': 50,
    \    'UltiSnips': 40,
    \    'Buffers': 30,
    \    'Color': 30,
    \    'Reference': 30,
    \    'Snippet': 30,
    \    'Text': 30,
    \}

augroup LspCompletionOmnifunc
    autocmd!
    autocmd FileType go,rust,python,javascript,typescript
        \ setlocal omnifunc=v:lua.vim.lsp.omnifunc
augroup END

" Convenient custom commands
function! LspRestart()
   lua vim.lsp.stop_client(vim.lsp.get_active_clients())
   edit
endfunction
command! LspRestart call LspRestart()
command! LspInfo lua print(vim.inspect(vim.lsp.buf_get_clients()))
command! LspCodeAction lua vim.lsp.buf.code_action()
command! LspRename lua vim.lsp.buf.rename()

" Inlay hints (via weihanglo/lsp_extensions.nvim)
function! LspToggleInlayHints()
    if exists('#InlayHintsCurrentLine#CursorHold')
        lua require'lsp_extensions'.inlay_hints
            \ { prefix = ' » ', highlight = "NonText" }
        augroup LspInlayHintsCurrentLine
            autocmd!
        augroup END
    else
        augroup LspInlayHintsCurrentLine
            autocmd!
            autocmd CursorHold,CursorHoldI 
                \ *.rs
                \ silent lua require'lsp_extensions'.inlay_hints{
                \     only_current_line = true,
                \     prefix = ' » ', 
                \     highlight = "NonText",
                \}
        augroup END
    endif
endfunction
command! LspToggleInlayHints call LspToggleInlayHints()
" Initialize current lint inlay hints
LspToggleInlayHints

nnoremap <LocalLeader>t <cmd>LspToggleInlayHints<CR>

" Copy from `:help lsp`
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>

" Rename malfunctions. Use at your own risk.
nnoremap <silent> <F2>  LspRename
nnoremap <silent> gA    LspCodeAction

" manually trigger completion on Ctrl-Space
imap <silent> <c-space> <Plug>(completion_trigger)
" }}}

" UltiSnips {{{
let g:UltiSnipsExpandTrigger = '<c-j>'
" }}}

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
