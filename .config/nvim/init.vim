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
set shortmess+=I
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
    autocmd TermOpen * setlocal signcolumn=no nonu nornu|startinsert
    autocmd TermClose term://*:tig*,term://*:gitui* bd!
augroup END
" }}}

" Genernal key mappings {{{
let maplocalleader = ','
" Move visual block
vnoremap K :m '<-2<cr>gv=gv
vnoremap J :m '>+1<cr>gv=gv
" Highlight visual selected text
vnoremap // y/<c-r>"<cr>
" Highlight clear
nnoremap \\ <cmd>nohl<cr>
" Buffer deletion
nnoremap <silent> <localleader>d <cmd>bp<bar>bd #<cr>
" gitui and tig
function! Tig(args) abort
    let args = expandcmd(a:args)
    tabedit
    execute 'terminal tig ' . args
endfunction
command! -narg=* Tig call Tig(<q-args>)
command! -narg=* Git tabedit|execute 'terminal gitui ' . <q-args>
command! Gblame execute 'Tig blame % +' . line('.')
" Check highlight group under current cursor
command! CheckHighlight echo synIDattr(synID(line("."), col("."), 1), "name")

" Use map <buffer> to only map dd in the quickfix/loclist buffer.
" Ref: https://stackoverflow.com/a/48817071/8851735
function! RemoveListItem() abort
    let l:idx = line('.') - 1
    if getwininfo(win_getid())[0].loclist
        let l:list = getloclist(winnr())
        call remove(l:list, l:idx)
        call setloclist(winnr(), l:list, 'r')
        :lopen
    elseif getwininfo(win_getid())[0].quickfix
        let l:list = getqflist()
        call remove(l:list, l:idx)
        call setqflist(l:list, 'r')
        :copen
    else
        echoerr 'both quickfix and loclist not found'
    endif
    let l:idx = idx + 1
    execute l:idx
endfunction
autocmd FileType qf map <buffer> dd <cmd>call RemoveListItem()<cr>
" }}}

" packer.nvim {{{
lua require'plugins'.load_all()
" }}}

" colorscheme {{{
let g:gruvbox_material_background = 'soft'
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_diagnostic_line_highlight = 1
let g:gruvbox_material_diagnostic_text_highlight = 1
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_transparent_background = 1
colorscheme gruvbox-material
"hi! Normal  ctermbg=NONE guibg=NONE
"hi! NonText ctermbg=NONE guibg=NONE
"hi! EndOFBuffer ctermbg=NONE guibg=NONE
" }}}

" Vim-Visual-Multi {{{
let g:VM_mouse_mappings = 1
" }}}

" zoomwintab.vim {{{
let g:zoomwintab_remap = 0
nnoremap <localleader>z <cmd>ZoomWinTabToggle<cr>
nnoremap <c-w>z         <cmd>ZoomWinTabToggle<cr>
tnoremap <localleader>z <c-\><c-n><cmd>ZoomWinTabToggle<cr><cmd>startinsert<cr>
tnoremap <c-w>z         <c-\><c-n><cmd>ZoomWinTabToggle<cr><cmd>startinsert<cr>
" }}}
