" General {{{
set autoindent
set clipboard+=unnamed,unnamedplus
set colorcolumn=80
set completeopt=menuone,noinsert,noselect
set cursorline
set dictionary+=/usr/share/dict/words
set expandtab
set foldmethod=indent
set foldnestmax=5
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
    autocmd InsertLeave,WinEnter * setlocal cursorline
    autocmd InsertEnter,WinLeave * setlocal nocursorline
augroup END

augroup ModeChanges
    autocmd!
    autocmd TermOpen * startinsert
    autocmd TermClose term://*:tig* bd!
augroup END
" }}}

" Genernal key mappings {{{
" map localleader if necessary
let maplocalleader = ','

" Move visual block
vnoremap K :m '<-2<cr>gv=gv
vnoremap J :m '>+1<cr>gv=gv

" Highlight visual selected text
vnoremap // y/<c-r>"<cr>

" Highlight clear
nnoremap \\ <cmd>nohl<cr>

" git and tig
function! Tig(args) abort
    let args = expandcmd(a:args)
    tabedit
    execute 'terminal tig ' . args
endfunction
command! -narg=* Tig call Tig(<q-args>)
command! -narg=* Git tabedit|execute 'terminal gitui ' . <q-args>
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
" user interface
Plug 'itchyny/lightline.vim'
Plug 'edkolev/tmuxline.vim', { 'on': ['Tmuxline', 'TmuxlineSnapshot'] }
Plug 'sainnhe/gruvbox-material'

" nvim-lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
Plug 'weihanglo/lsp_extensions.nvim', { 'branch': 'customized' }
Plug 'liuchengxu/vista.vim', { 'on': 'Vista' }
Plug 'kosayoda/nvim-lightbulb'

" fast moves
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'troydm/zoomwintab.vim', { 'on': 'ZoomWinTabToggle' }
Plug 'mg979/vim-visual-multi'

" vcs
Plug 'airblade/vim-gitgutter', { 'on': ['<plug>(GitGutterNextHunk)', '<plug>(GitGutterPrevHunk)'] }

" filetype
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

" registers
Plug 'tversteeg/registers.nvim', { 'on': 'Registers' }

" profiling startup time
Plug 'dstein64/vim-startuptime', { 'on': 'StartupTime' }

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
lua require'lsp'.setup()
" }}}

" nvim-treesitter {{{
lua require'ext'.nvim_treesitter_setup()
" }}}

" vim-gitgutter {{{
let g:gitgutter_map_keys = 0
nmap <silent> ]c                        <plug>(GitGutterNextHunk)
nmap <silent> [c                        <plug>(GitGutterPrevHunk)
" }}}

" Vim-Visual-Multi {{{
let g:VM_mouse_mappings = 1
" }}}

" NERDTree {{{
nnoremap <silent> <LocalLeader>n <cmd>NERDTreeToggle<cr>
nnoremap <silent> <LocalLeader>d <cmd>bp<bar>bd #<cr>
" }}}

" FZF {{{
command! -bang -nargs=? -complete=dir AllFiles call fzf#vim#files(<q-args>, fzf#vim#with_preview({'source': 'rg --files --smart-case -uu --glob !.git'}), <bang>0)
nnoremap <silent> <LocalLeader>b     <cmd>Buffers<cr>
nnoremap <silent> <LocalLeader>c     <cmd>Commands<cr>
nnoremap <silent> <c-p>              <cmd>Files<cr>
nnoremap <silent> <LocalLeader><c-p> <cmd>AllFiles<cr>
nnoremap <silent> <LocalLeader>G     <cmd>Rg<cr>
" }}}

" vim-grepper {{{
let g:grepper = {}
let g:grepper.prompt_quote = 1
let g:grepper.tools = ['rg', 'fixed', 'grep', 'git']
let g:grepper.rg = { 'grepprg': 'rg -HS --no-heading --vimgrep' }
let g:grepper.fixed = { 'grepprg': 'rg -HS --no-heading --vimgrep --fixed-strings' }
" Search working directory
nnoremap <silent> <LocalLeader>g     <cmd>Grepper -tool rg<cr>
" Search the word under the cursor
nnoremap <silent> <LocalLeader>*     <cmd>Grepper -tool rg -cword -noprompt<cr>
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
nnoremap <localLeader>t <cmd>Vista!!<cr>
" }}}

" zoomwintab.vim {{{
let g:zoomwintab_remap = 0
nnoremap <LocalLeader>z <cmd>ZoomWinTabToggle<cr>
nnoremap <c-w>z         <cmd>ZoomWinTabToggle<cr>
tnoremap <LocalLeader>z <c-\><c-n><cmd>ZoomWinTabToggle<cr><cmd>startinsert<cr>
tnoremap <c-w>z         <c-\><c-n><cmd>ZoomWinTabToggle<cr><cmd>startinsert<cr>
" }}}
