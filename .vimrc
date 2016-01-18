"---------------------------------------
" General
"---------------------------------------
" {{{
set encoding=utf-8
set backup backupdir=~/.vim/backup/
set clipboard=unnamedplus               " share system clipboard
set mousehide                           " hide mouse when typing
set autochdir                           " auto cd to current dir
set backspace=2                         " backspace is able to delete
set nocompatible                        " be iMproved, no compatible with vi
set hidden                              " open buf without saving current
set laststatus=2
set showmatch
set hlsearch incsearch
set showcmd history=500
set wildmenu wildmode=longest:full,full
set guifont=inconsolata\ 12
set ruler
set number relativenumber               " relative line number
set cursorline
set guioptions=M
syntax off                              " turn on after loading plugins
filetype off                            " turn on after loading plugins
" }}}

"---------------------------------------
" filetype
"---------------------------------------
" {{{
" recognize *.md files
autocmd BufNewFile,BufFilePre,BufRead *.md setfiletype markdown

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
" }}}

"---------------------------------------
" warp, break, indent, and folding
"---------------------------------------
" {{{
set shiftwidth=4 softtabstop=4 expandtab
set linebreak breakat-=. showbreak=------>\ 
set cpoptions+=n
set smarttab
set smartindent
set autoindent
set colorcolumn=80
set nowrap
set list listchars=eol:¬,tab:▸\ ,extends:»,precedes:«,trail:•
" }}}

"---------------------------------------
" Key mapping
"---------------------------------------
" {{{
" map localleader if necessary
let maplocalleader = ','

inoremap hh <Esc>
inoremap jj <Esc>
inoremap kk <Esc>
inoremap jk <Esc>
inoremap kj <Esc>
" }}}

"---------------------------------------
" Vundle plugins setting
"---------------------------------------
" {{{
set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Put your plugins below ---------------
Plugin 'VundleVim/Vundle.vim'           " required with first priority
Plugin 'bling/vim-bufferline'
Plugin 'bling/vim-airline'
Plugin 'edkolev/tmuxline.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-ctrlspace/vim-ctrlspace'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'jalvesaq/R-Vim-runtime'
Plugin 'jcfaria/Vim-R-plugin'
Plugin 'davidhalter/jedi-vim'
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

"---------------------------------------
" Colorscheme
"---------------------------------------
" {{{
" solarized
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

" toggle backgrond transparent
let g:colorschemeToggler=1
function ColorschemeToggle()
    if g:colorschemeToggler
        colorscheme solarized
        AirlineTheme base16
        let g:colorschemeToggler=0
    else
        set background=dark
        colorscheme solarized
        AirlineTheme murmur
        let g:colorschemeToggler=1
    endif
endfunction

nmap <leader>t :call ColorschemeToggle()<CR>
" }}}

"---------------------------------------
" vim-r-plugin
"---------------------------------------
" {{{
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
    echom "vim-r-plugin configuration complete"
endfunction
" }}}

"---------------------------------------
" vim-slime (REPL)
"---------------------------------------
" {{{
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}
let g:slime_dont_ask_default = 1
let g:slime_paste_file = tempname()
" }}}

"---------------------------------------
" airline
"---------------------------------------
" {{{
" theme
let g:airline_powerline_fonts = 1
let g:airline_theme='murmur'

" tabline: mapping buffer index on tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6

" integration
let g:airline#extensions#branch#enabled = 1             " fugitive
let g:airline#extensions#csv#column_display = 'Name'    " csv.vim
let g:airline#extensions#bufferline#enabled = 1         " bufferline
let g:airline#extensions#ctrlspace#enabled = 1          " ctrlspace

" auto-generate snapshots
let g:airline#extensions#tmuxline#snapshot_file = '~/.tmuxline'
" }}}

"---------------------------------------
" tmuxline
"---------------------------------------
" {{{
let g:tmuxline_preset = {
    \'a'    : '#S',
    \'cwin' : ['#F#I', '#W'],
    \'win'  : ['#F#I', '#W'],
    \'x'    : '#(uptime | rev | cut -d":" -f1 | rev | sed s/,//g)',
    \'y'    : ['⏰ %R', '%b %d'],
    \'z'    : '#H',
    \'options' : {'status-justify' : 'left'}}
" }}}
