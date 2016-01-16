"---------------------------------------
" General
"---------------------------------------
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
set wildmenu wildmode=longest:full
set guifont=inconsolata\ 12
set ruler
set number relativenumber               " relative line number
set cursorline
set guioptions=M
syntax off                              " turn on after loading plugins
filetype off                            " turn on after loading plugins


"---------------------------------------
" filetype
"---------------------------------------
" map localleader if necessary
let maplocalleader = ','

" recognize *.md files
au BufNewFile,BufFilePre,BufRead *.md setfiletype markdown


"---------------------------------------
" warp, break, indent, and folding
"---------------------------------------
set shiftwidth=4 softtabstop=4 expandtab
set linebreak breakat-=. showbreak=------>\ 
set cpoptions+=n
set smarttab
set smartindent
set autoindent
set colorcolumn=80
set nowrap
set list listchars=eol:¬,tab:▸\ ,extends:»,precedes:«,trail:•


"---------------------------------------
" Keymapping
"---------------------------------------
inoremap hh <Esc>
inoremap jj <Esc>
inoremap kk <Esc>


"---------------------------------------
" Vundle plugins setting
"---------------------------------------
set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Put your plugins below ---------------
Plugin 'VundleVim/Vundle.vim'           " required with first priority
Plugin 'bling/vim-bufferline'
Plugin 'bling/vim-airline'
Plugin 'edkolev/tmuxline.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'vim-ctrlspace/vim-ctrlspace'
Plugin 'jalvesaq/R-Vim-runtime'
Plugin 'davidhalter/jedi-vim'
Plugin 'jcfaria/Vim-R-plugin'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'jpalardy/vim-slime'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'chrisbra/csv.vim'
" Put your plugins above ---------------
"
call vundle#end()
filetype plugin on


"---------------------------------------
" Colorscheme
"---------------------------------------
" solarized
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

" toggle backgrond transparent
let g:colorschemeToggler=0
function ColorschemeToggle()
    if g:colors_name == 'solarized'
        colorscheme PaperColor
        AirlineTheme PaperColor
    else
        set background=dark
        colorscheme solarized
        AirlineTheme murmur
    endif
endfunction

nmap <leader>t :call ColorschemeToggle()<CR>



"---------------------------------------
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
"
au BufNewFile,BufFilePre,BufRead *.{R,Rnw,Rd,Rmd,Rrst} call VimRPluginConf()


"---------------------------------------
" vim-slime (REPL)
"---------------------------------------
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
let g:slime_default_config = {"socket_name": "default", "target_pane": "1"}
let g:slime_dont_ask_default = 1
let g:slime_paste_file = tempname()


"---------------------------------------
" airline
"---------------------------------------
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


"---------------------------------------
" tmuxline
"---------------------------------------
let g:tmuxline_preset = {
    \'a'    : '#S',
    \'cwin' : ['#F#I', '#W'],
    \'win'  : ['#F#I', '#W'],
    \'x'    : '#(uptime | rev | cut -d":" -f1 | rev | sed s/,//g)',
    \'y'    : ['⏰ %R', '%b %d'],
    \'z'    : '#H',
    \'options' : {'status-justify' : 'left'}}
