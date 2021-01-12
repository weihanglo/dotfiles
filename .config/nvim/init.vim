" General {{{
set autoindent
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
set undolevels=10000
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
    " inlay hints for rust
    autocmd CursorHold,CursorHoldI *.rs
        \ silent lua require'lsp_extensions'.inlay_hints{
        \  only_current_line = true,
        \  prefix = ' » ',
        \  highlight = "NonText",
        \}
    autocmd InsertLeave,WinEnter * setlocal cursorline
    autocmd InsertEnter,WinLeave * setlocal nocursorline
augroup END

augroup ModeChanges
    autocmd!
    autocmd TermOpen * startinsert
    autocmd TermClose term://*:tig* bd!
augroup END

" List all filetype that is enabled omnifunc with lsp.
augroup LspCompletionOmnifunc
    autocmd!
    autocmd FileType
        \ go,rust,python,javascript,typescript,lua,c,cpp,objc,objcpp
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

" git and tig
function! Tig(args) abort
    let args = expandcmd(a:args)
    tabedit
    execute 'terminal tig ' . args
endfunction
command! -narg=* Tig call Tig(<q-args>)
command! -narg=* Git tabedit|execute 'terminal git ' . <q-args>
command! Gblame execute 'Tig blame % +' . line('.')
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
Plug 'weihanglo/lsp_extensions.nvim', { 'branch': 'customized' }
Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
Plug 'RRethy/vim-illuminate'

" user interface
Plug 'itchyny/lightline.vim'
Plug 'edkolev/tmuxline.vim', { 'on': ['Tmuxline', 'TmuxlineSnapshot'] }
Plug 'sainnhe/gruvbox-material'

" fast moves
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'troydm/zoomwintab.vim', { 'on': 'ZoomWinTabToggle' }
Plug 'mg979/vim-visual-multi'

" vcs
Plug 'airblade/vim-gitgutter'

" linter
Plug 'dense-analysis/ale', { 'for': ['javascript', 'typescript'] }

" filetype
Plug 'sheerun/vim-polyglot'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" search
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-symbols.nvim'
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

call plug#end()
" }}}

" colorscheme {{{
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_diagnostic_line_highlight = 1
let g:gruvbox_material_transparent_background = 1
colorscheme gruvbox-material
"hi! Normal  ctermbg=NONE guibg=NONE
"hi! NonText ctermbg=NONE guibg=NONE
"hi! EndOFBuffer ctermbg=NONE guibg=NONE
" }}}

" LSP configurations {{{
lua require'language_server'.setup()

" Show virtual text for diagnoses
let g:diagnostic_enable_virtual_text = 1
" Delay showing virtual text while inserting
let g:diagnostic_insert_delay = 1

" Support snippets completions
let g:completion_sorting = 'none'
let g:completion_auto_change_source = 1
let g:completion_enable_fuzzy_match = 1
let g:completion_matching_strategy_list = ['exact', 'substring']
let g:completion_abbr_length = 50
let g:completion_menu_length = 30
" CompletionItemKind from https://bit.ly/343efwm
" 100 -> none
" 90 -> property
" 80 -> declaration
" 70 -> variables/values, keywords
" 50 -> Snips
" 40 -> misc.
let g:completion_items_priority = {
    \ 'Mtd': 90,
    \ 'Fd': 90,
    \ 'Cls': 80,
    \ 'E': 80,
    \ 'S': 80,
    \ 'Evt': 80,
    \ 'Fn': 80,
    \ 'I': 80,
    \ 'Mod': 80,
    \ 'TyPar': 80,
    \ 'Var': 70,
    \ 'Val': 70,
    \ 'Kw': 70,
    \ 'Cnst': 70,
    \ 'Op': 70,
    \ 'Snip': 50,
    \ 'Ref': 40,
    \ 'Text': 0,
    \}
let g:completion_customize_lsp_label = {
    \ 'Buffers': 'Buf',
    \ 'Class': 'Cls',
    \ 'Color': 'Clr',
    \ 'Constant': 'Cnst',
    \ 'Constructor': 'Fn',
    \ 'Enum': 'E',
    \ 'EnumMember': 'E',
    \ 'Event': 'Evt',
    \ 'Field': 'Fd',
    \ 'File': 'File',
    \ 'Folder': 'Dir',
    \ 'Function': 'Fn',
    \ 'Interface': 'I',
    \ 'Keyword': 'Kw',
    \ 'Method': 'Mtd',
    \ 'Module': 'Mod',
    \ 'Operator': 'Op',
    \ 'Property': 'Fd',
    \ 'Reference': 'Ref',
    \ 'Snippet': 'Snip',
    \ 'Struct': 'S',
    \ 'Text': 'Text',
    \ 'TypeParameter': 'TyPar',
    \ 'Unit': 'E',
    \ 'Value': 'Val',
    \ 'Variable': 'Var',
    \}

function! LspRestart(force) abort
lua << EOF
    if not vim.lsp.buf.server_ready() or vim.fn.nvim_eval('a:force') then
        vim.lsp.stop_client(vim.lsp.get_active_clients())
    end
EOF
    edit
endfunction

command! LspCodeAction       lua vim.lsp.buf.code_action()
command! LspDeclaration      lua vim.lsp.buf.declaration()
command! LspDefinition       lua vim.lsp.buf.definition()
command! LspDocumentSymbol   lua vim.lsp.buf.document_symbol()
command! LspHover            lua vim.lsp.buf.hover()
command! LspImplementation   lua vim.lsp.buf.implementation()
command! LspIncomingCalls    lua vim.lsp.buf.incoming_calls()
command! LspInfo             lua print(vim.inspect(vim.lsp.buf_get_clients()))
command! LspOutgoingCalls    lua vim.lsp.buf.outgoing_calls()
command! LspReferences       lua vim.lsp.buf.references()
command! LspRename           lua vim.lsp.buf.rename()
command! -bang LspRestart    call LspRestart(<bang>0)
command! LspServerReady      lua print(vim.lsp.buf.server_ready())
command! LspSignatureHelp    lua vim.lsp.buf.signature_help()
command! LspTypeDefinition   lua vim.lsp.buf.type_definition()
command! LspWorkspaceSymbol  lua vim.lsp.buf.workspace_symbol()

nnoremap <silent> <c-]>                 <cmd>LspDefinition<CR>
nnoremap <silent> K                     <cmd>LspHover<CR>
nnoremap <silent> <c-k>                 <cmd>LspSignatureHelp<CR>
nnoremap <silent> <LocalLeader><space>  <cmd>LspCodeAction<CR>
" NOTE: Rename sometimes malfunctions. Use at your own risk.
nnoremap <silent> <F2>                  <cmd>LspRename<CR>

" manually trigger completion on Ctrl-Space
imap     <silent> <c-space>             <plug>(completion_trigger)

" Jump between diagnostics.
nnoremap <silent> ]e                    <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <silent> [e                    <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
" }}}

" nvim-treesitter {{{
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  highlight = { enable = true },
  incremental_selection = { enable = true },
  indent = { enabled = true },
}
EOF
" }}}

" vim-gitgutter {{{
let g:gitgutter_map_keys = 0
nmap <silent> ]c                        <plug>(GitGutterNextHunk)
nmap <silent> [c                        <plug>(GitGutterPrevHunk)
" }}}

" Vim-Visual-Multi {{{
let g:VM_mouse_mappings = 1
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
let g:ale_fix_on_save = 0
let g:ale_fixers = {}
let g:ale_fixers.javascript = ['eslint']
let g:ale_fixers.typescript = ['eslint', 'tsserver', 'typecheck']
" }}}

" NERDTree {{{
nnoremap <silent> <LocalLeader>n <cmd>NERDTreeToggle<CR>
nnoremap <silent> <LocalLeader>d <cmd>bp<bar>bd #<CR>
" }}}

" telescope.vim {{{
lua << EOF
require'telescope'.setup{
  defaults = {
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
  }
}
EOF
nnoremap <silent> <LocalLeader>b     <cmd>Telescope buffers<CR>
nnoremap <silent> <LocalLeader>c     <cmd>Telescope commands<CR>
nnoremap <silent> <c-p>              <cmd>Telescope find_files<CR>
nnoremap <silent> <LocalLeader><c-p> <cmd>Telescope find_files find_command=rg,-S,--files,-uu,--glob,!.git<CR>
nnoremap <silent> <LocalLeader>G     <cmd>Telescope live_grep<CR>
" }}}

" vim-grepper {{{
let g:grepper = { 'tools': ['rg', 'grep', 'git'] }
let g:grepper.rg = { 'grepprg': 'rg -HS --no-heading --vimgrep' }
" Search working directory
nnoremap <silent> <LocalLeader>g     <cmd>Grepper<CR>
" Search the word under the cursor
nnoremap <silent> <LocalLeader>*     <cmd>Grepper -cword -noprompt<CR>
" Search with operators
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
" }}}

" Lightline {{{
let g:lightline = {}
let g:lightline.colorscheme = 'gruvbox_material'
let g:lightline.subseparator = { 'left': '', 'right': '' }

" Tmuxline {{{
let g:tmuxline_powerline_separators = 0
let g:tmuxline_preset = 'minimal'
" }}}

" Vista.vim {{{
let g:vista_default_executive = 'nvim_lsp'
let g:vista#renderer#enable_icon = 0
nnoremap <localLeader>t <cmd>Vista!!<CR>
" }}}

" zoomwintab.vim {{{
let g:zoomwintab_remap = 0
nnoremap <LocalLeader>z <cmd>ZoomWinTabToggle<CR>
nnoremap <c-w>z         <cmd>ZoomWinTabToggle<CR>
tnoremap <LocalLeader>z <c-\><c-n><cmd>ZoomWinTabToggle<CR><cmd>startinsert<CR>
tnoremap <c-w>z         <c-\><c-n><cmd>ZoomWinTabToggle<CR><cmd>startinsert<CR>
" }}}
