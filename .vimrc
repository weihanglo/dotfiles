"---------------------------------------
" General
"---------------------------------------
set encoding=utf-8
set backup backupdir=~/.vim/backup/
set clipboard=unnamedplus           " share system clipboard
set mousehide                       " hide mouse when typing
set autochdir                       " auto cd to current dir
set backspace=2                     " backspace is able to delete
set nocompatible                    " be iMproved, required
set hidden                          " open other buf without saving current
set laststatus=2
set showmatch
set hlsearch
set incsearch
set history=500
set showcmd
set wildmenu
set wildmode=list:longest           " turn on wild mode huge list

syntax off
filetype off 
au BufNewFile,BufFilePre,BufRead *.md setf markdown " recognize .md files

"---------------------------------------
" UI setting
"---------------------------------------
set guifont=inconsolata\ 12
"set lines=50 columns=80
set ruler
set number
set relativenumber
set cursorline
set linespace=0
set guioptions=M


"---------------------------------------
" warp, break, indent, and folding
"---------------------------------------
set shiftwidth=4 softtabstop=4 expandtab
set linebreak
set breakat-=.
set number
set showbreak=-------->\  
set cpoptions+=n
set smarttab
set smartindent
set autoindent
set colorcolumn=80
set nowrap                          " nowarp


"---------------------------------------
" Keymapping
"---------------------------------------
inoremap hh <Esc>
inoremap jj <Esc>
inoremap kk <Esc>


"---------------------------------------
" Vundle plugins setting
"---------------------------------------
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Put your plugins below ---------------
Plugin 'altercation/vim-colors-solarized'
Plugin 'jalvesaq/R-Vim-runtime'
Plugin 'davidhalter/jedi-vim'
Plugin 'jcfaria/Vim-R-plugin'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'jpalardy/vim-slime'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'edkolev/tmuxline.vim'
Plugin 'bling/vim-airline'
Plugin 'bling/vim-bufferline'
Plugin 'chrisbra/csv.vim'
" Put your plugins above ---------------

call vundle#end()            " required

"filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
filetype plugin on


"---------------------------------------
" colorscheme
"---------------------------------------
"colorscheme feral
"colorscheme vendetta
" solarized
syntax enable
set background=dark
set t_Co=16
let g:solarized_termcolors=256
let g:solarized_termtrans=0
colorscheme solarized


"---------------------------------------
" vim-r-plugin
"---------------------------------------
let vimrplugin_notmuxconf = 1
let vimrplugin_tmux_ob = 0            " Use vim split window as object browser
let vimrplugin_restart = 1            " Restart new session if already running
let vimrplugin_assign = 0             " Do not bind '_' as ' <- '
let maplocalleader = ","              " Map localleafer from '\' to ','
let vimrplugin_rconsole_height = 13
let vimrplugin_tmux_title = "automatic"
let vimrplugin_r_args = " --no-save --no-restore --quiet"

" Press the space bar to send lines and selection to R:
vmap <Space> <Plug>RDSendSelection
nmap <Space> <Plug>RDSendLine


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
" statusline
let g:airline_powerline_fonts = 1
let g:airline_theme='murmur'

" git branch
let g:airline#extensions#branch#enabled = 1

" tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1

" mapping buffer index on tabline
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6


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
