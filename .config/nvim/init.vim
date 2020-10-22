" General {{{
set autoindent
set clipboard+=unnamed,unnamedplus
set colorcolumn=80
set completeopt=menuone,noinsert,noselect
set dictionary+=/usr/share/dict/words
set expandtab
set foldmethod=indent
set foldnestmax=2
set hidden
set history=10000
set hlsearch
set ignorecase
set incsearch
set lazyredraw
set linebreak
set list listchars=eol:¬,tab:▸\ ,extends:»,precedes:«,trail:•
set mouse=a
set nofoldenable
set nonumber
set noswapfile
set nowrap
set pumblend=15
set pumheight=15
set scrolloff=2
set shiftwidth=4
set shortmess+=c
set showmatch
set showtabline=0
set sidescrolloff=4
set smartcase
set smartindent
set smarttab
set softtabstop=4
set splitbelow
set splitright
set synmaxcol=200
set termguicolors
set timeoutlen=500
set undodir=/tmp/nvim/undo
set undofile
set undolevels=5000
set updatetime=350
set wildignore+=*.swo,*.swp,*~,*.log,*.db,*.sqilte,*__pycache__/*
set wildignorecase
set wildmenu wildmode=longest:full,full
set winminheight=0
" }}}

" Filetype {{{
augroup FiletypeDetectPlus
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
    " two space indent for web developing
    autocmd BufNewFile,BufFilePre,BufRead
        \ *.{js,jsx,ts,tsx,css,html,yaml,yml,toml,json,md}
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2
    " go use tab
    autocmd FileType go
        \ setlocal tabstop=4 noexpandtab softtabstop=0 shiftwidth=4
    " auto rustfmt
    autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync()
    " inlay hints for rust
    autocmd CursorHold,CursorHoldI *.rs
        \ silent lua require'lsp_extensions'.inlay_hints{
        \     only_current_line = true,
        \     prefix = ' » ',
        \     highlight = "NonText",
        \}
augroup END

augroup TerminalSettings
    autocmd!
    autocmd TermOpen term://* startinsert
    autocmd TermClose term://*:tig bd!
augroup END

" List all filetype that is enabled omnifunc with lsp.
augroup LspCompletionOmnifunc
    autocmd!
    autocmd FileType
        \ go,rust,python,javascript,typescript,lua
        \ setlocal omnifunc=v:lua.vim.lsp.omnifunc
augroup END
" }}}

" Genernal key mappings {{{
" map localleader if necessary
let maplocalleader = ','

" Move visual block
vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv

" Highlight visual selected text
vnoremap // y/<C-R>"<CR>

" Launch tig and expand to fullscreen!
function! Tig()
    tabedit
    terminal tig
    ZoomWinTabToggle
    startinsert
endfunction
command! Tig call Tig()
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
Plug 'liuchengxu/vista.vim', { 'on': ['Vista', 'Vista!', 'Vista!!'] }

" user interface
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
Plug 'rakr/vim-one'

" fast moves
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'troydm/zoomwintab.vim', { 'on': 'ZoomWinTabToggle' }
Plug 'mg979/vim-visual-multi'

" scm
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive', { 'on': ['Git', 'Gblame', 'G', 'GDiff'] }

" linter
Plug 'dense-analysis/ale', { 'for': [
    \ 'javascript',
    \ 'javascriptreact',
    \ 'javascript.jsx',
    \ 'typescript',
    \ 'typescriptreact',
    \ 'typescript.tsx'
    \] }

" snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" filetype
Plug 'sheerun/vim-polyglot'

" search
let b:fzf_on = ['Files', 'Buffers', 'Commands', 'Rg', 'BCommits', 'Maps']
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim', { 'on': b:fzf_on }
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

call plug#end()
" }}}

" colorscheme {{{
let g:one_allow_italics = 1
colorscheme one
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE
" }}}

" LSP configurations {{{
lua require'language_server'.setup()

" Show virtual text for diagnoses
let g:diagnostic_enable_virtual_text = 1
" Delay showing virtual text while inserting
let g:diagnostic_insert_delay = 1

" Support snippets completions
let g:completion_enable_snippet = 'UltiSnips'
let g:completion_sorting = 'none'
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
    \ 'Method': 90,
    \ 'Constructor': 90,
    \ 'Field': 90,
    \ 'Property': 90,
    \ 'Class': 80,
    \ 'Enum': 80,
    \ 'Struct': 80,
    \ 'Unit': 80,
    \ 'Event': 80,
    \ 'Function': 80,
    \ 'EnumMember': 80,
    \ 'Interface': 80,
    \ 'Module': 80,
    \ 'TypeParameter': 80,
    \ 'Variable': 70,
    \ 'Value': 70,
    \ 'Keyword': 70,
    \ 'Constant': 70,
    \ 'Operator': 70,
    \ 'File': 50,
    \ 'Folder': 50,
    \ 'UltiSnips': 40,
    \ 'Buffers': 30,
    \ 'Color': 30,
    \ 'Reference': 30,
    \ 'Snippet': 30,
    \ 'Text': 30,
    \}

" LspDeclaration seems having conflicts with airline....
command! LspCodeAction       lua vim.lsp.buf.code_action()
command! LspDeclaratio       lua vim.lsp.buf.declaration()
command! LspDefinition       lua vim.lsp.buf.definition()
command! LspDocumentSymbol   lua vim.lsp.buf.document_symbol()
command! LspHover            lua vim.lsp.buf.hover()
command! LspImplementation   lua vim.lsp.buf.implementation()
command! LspIncomingCalls    lua vim.lsp.buf.incoming_calls()
command! LspInfo             lua print(vim.inspect(vim.lsp.buf_get_clients()))
command! LspOutgoingCalls    lua vim.lsp.buf.outgoing_calls()
command! LspReferences       lua vim.lsp.buf.references()
command! LspRename           lua vim.lsp.buf.rename()
command! LspRestart          lua vim.lsp.stop_client(vim.lsp.get_active_clients())
command! LspServerReady      lua print(vim.lsp.buf.server_ready())
command! LspSignatureHelp    lua vim.lsp.buf.signature_help()
command! LspTypeDefinition   lua vim.lsp.buf.type_definition()
command! LspWorkspaceSymbol  lua vim.lsp.buf.workspace_symbol()

nnoremap <silent> <LocalLeader>t       <cmd>LspInlayHints<CR>
nnoremap <silent> <c-]>                <cmd>LspDefinition<CR>
nnoremap <silent> K                    <cmd>LspHover<CR>
nnoremap <silent> <c-k>                <cmd>LspSignatureHelp<CR>
nnoremap <silent> <LocalLeader><space> <cmd>LspCodeAction<CR>
" Rename sometimes malfunctions. Use at your own risk.
nnoremap <silent> <F2>                 <cmd>LspRename<CR>

" manually trigger completion on Ctrl-Space
imap     <silent> <c-space>            <plug>(completion_trigger)
" }}}

" UltiSnips {{{
let g:UltiSnipsExpandTrigger = '<c-j>'
" }}}

" Vim-Visual-Multi {{{
let g:VM_mouse_mappings = 1
" }}}

" Startify {{{
let g:startify_change_to_vcs_root = 1
let g:startify_custom_header_quotes = taiwanese_proverbs#predefined()
let g:startify_enable_special = 0
let g:startify_fortune_use_unicode = 1
let g:startify_padding_left = 7
let g:startify_relative_path = 1
let g:startify_update_oldfiles = 1
let g:startify_files_number = 7
" }}}

" ALE {{{
let g:ale_completion_enabled = 0
let g:ale_lint_delay = 1000
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_linters = {}
let g:ale_linters.javascript = ['eslint']
let g:ale_linters.typescript = ['eslint', 'tsserver', 'typecheck']
let g:ale_fix_on_save = 1
let g:ale_fixers = {}
let g:ale_fixers.javascript = ['remove_trailing_lines', 'eslint']
let g:ale_fixers.typescript = ['remove_trailing_lines', 'eslint', 'tsserver', 'typecheck']
" }}}

" NERDTree {{{
nnoremap <silent> <LocalLeader>n <cmd>NERDTreeToggle<CR>
nnoremap <silent> <LocalLeader>c <cmd>bp<bar>bd #<CR>
" }}}

" FZF {{{
" Use system's default options.
nnoremap <silent> <c-s-p>            <cmd>Commands<CR>
nnoremap <silent> <LocalLeader>b     <cmd>Buffers<CR>
nnoremap <silent> <c-p>              <cmd>Files<CR>
" Do not ignore ignores!
nnoremap <silent> <LocalLeader><c-p> <cmd>call
    \ fzf#run({'source': 'rg --files -uu --glob !.git', 'sink': 'edit'})<CR>
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
let g:airline_theme = 'jellybeans'

" extensions
let g:airline#extensions#vista#enabled = 0

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

" Vista.vim {{{
let g:vista_default_executive = 'nvim_lsp'
" }}}

" zoomwintab.vim {{{
let g:zoomwintab_remap = 0
nnoremap <LocalLeader>z <cmd>ZoomWinTabToggle<CR>
nnoremap <c-w>z         <cmd>ZoomWinTabToggle<CR>
nnoremap <c-w><c-z>     <cmd>ZoomWinTabToggle<CR>
tnoremap <LocalLeader>z <c-\><c-n><cmd>ZoomWinTabToggle<CR><cmd>startinsert<CR>
tnoremap <c-w>z         <c-\><c-n><cmd>ZoomWinTabToggle<CR><cmd>startinsert<CR>
tnoremap <c-w><c-z>     <c-\><c-n><cmd>ZoomWinTabToggle<CR><cmd>startinsert<CR>
" }}}
