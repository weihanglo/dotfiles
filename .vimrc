" General {{{
set encoding=utf-8
set clipboard=unnamed,unnamedplus       " share system clipboard
set backspace=2                         " backspace is able to delete
set nocompatible                        " be iMproved, no compatible with vi
set hidden                              " open buf without saving current
set laststatus=2
set showmatch
set hlsearch
set incsearch
set history=10000
set wildmenu wildmode=longest:full,full
set number
set relativenumber                      " relative line number
set cursorline
set dictionary+=/usr/share/dict/words

augroup autoloadview
   autocmd!
   autocmd BufWinEnter *.* silent! loadview
augroup END
" }}}

" filetype {{{
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
" }}}

" warp, break, indent, and folding {{{
set shiftwidth=4 
set softtabstop=4 
set expandtab
set smarttab
set smartindent
set autoindent
set colorcolumn=80
set nowrap
set list listchars=eol:¬,tab:▸\ ,extends:»,precedes:«,trail:•
" }}}

" Key mapping {{{
" map localleader if necessary
let maplocalleader = ','

cnoreabbrev Bd bd
cnoreabbrev Bd! bd!

inoremap hh <Esc>
inoremap jj <Esc>
inoremap kk <Esc>
inoremap jk <Esc>
inoremap kj <Esc>
" }}}

" Vundle plugins setting {{{
if has('nvim')
    set runtimepath+=~/.config/nvim/bundle/Vundle.vim
else
    set runtimepath+=~/.vim/bundle/Vundle.vim
endif
call vundle#begin()

" Put your plugins below ---------------
Plugin 'VundleVim/Vundle.vim'           " required with first priority
Plugin 'edkolev/tmuxline.vim'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-ctrlspace/vim-ctrlspace'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'davidhalter/jedi-vim'
Plugin 'jalvesaq/R-Vim-runtime'
Plugin 'jcfaria/Vim-R-plugin'
Plugin 'jpalardy/vim-slime'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'chrisbra/csv.vim'
" Put your plugins above ---------------
"
call vundle#end()
filetype plugin on
" }}}

" Colorscheme {{{
" solarized
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized
" }}}

" vim-multiple-cursors {{{
" before multiple cursors
function! Multiple_cursors_before()
    if g:jedi#popup_on_dot == 1
        let g:jedi#popup_on_dot = 0
    endif
endfunction

" after multiple cursors
function! Multiple_cursors_after()
    if g:jedi#popup_on_dot == 0
        let g:jedi#popup_on_dot = 1
    endif
endfunction
" }}}

" vim-r-plugin {{{
if !exists("*VimRPluginConf")
    function VimRPluginConf()
        let g:vimrplugin_notmuxconf = 1
        let g:vimrplugin_tmux_ob = 0          " vim split window as object browser
        let g:vimrplugin_restart = 1          " restart new session
        let g:vimrplugin_assign = 0           " Do not bind '_' as ' <- '
        let g:vimrplugin_rconsole_height = 12
        let g:vimrplugin_tmux_title = "automatic"
        " press for sending code to R console
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
let g:CtrlSpaceStatuslineFunction = "airline#extensions#ctrlspace#statusline()"

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

" Neovim-only config {{{
if has('nvim')

endif
" }}}
