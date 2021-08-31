set nocompatible
let mapleader=" "

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin('~/.vim/plugged')
"Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
Plug 'itchyny/lightline.vim'
Plug 'ap/vim-css-color'
Plug 'preservim/nerdtree'
Plug 'plasticboy/vim-markdown'
Plug 'mechatroner/rainbow_csv'
Plug 'tpope/vim-surround'
Plug 'liuchengxu/vim-which-key'
Plug 'mbbill/undotree'
Plug 'gyim/vim-boxdraw'
Plug 'vim-scripts/DrawIt'
Plug 'baskerville/vim-sxhkdrc'
Plug 'ackyshake/VimCompletesMe'
Plug 'morhetz/gruvbox'
Plug 'axvr/org.vim'
Plug 'mboughaba/i3config.vim'
"Plug 'jamessan/vim-gnupg'
"Plug 'jceb/vim-orgmode'
Plug 'markonm/traces.vim'
call plug#end()

" vimwiki
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext = 0

" rainbow_csv
let g:rcsv_colorpairs = [['lightmagenta', 'lightmagenta'], ['green', 'green'], ['red', 'red'],
			\ ['yellow', 'yellow'], ['cyan', 'cyan'], ['blue', 'blue'], ['darkyellow', 'darkyellow'],
			\ ['darkred', 'darkred'], ['darkyellow', 'darkyellow'], ['darkcyan', 'darkcyan']]
let g:disable_rainbow_hover=1
let g:disable_rainbow_key_mappings=1

" lightline.vim
set laststatus=2
set noshowmode
set ttimeout
set ttimeoutlen=30

let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ }

set number
set relativenumber
set hlsearch
set incsearch
set encoding=utf-8
set ignorecase
set smartcase
set mouse=a
set termguicolors
set softtabstop=4
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set wrap
set linebreak
set nofoldenable
set background=dark
set ruler
set cmdheight=1
set fileformat=unix
set wildmenu
set wildmode=longest,list,full
set wildignore=*.jpg,*.jpeg,*.png,*.gif,*.pdf,*.docx,*.mkv,*.mp4,*.webm,*.torrent
set splitbelow
set splitright
set ttymouse=sgr
set scrolloff=10
set nowrapscan
set history=1000

set clipboard=unnamedplus
vnoremap <C-c> "+y :let @+=@*<CR>
map <C-p> "+P

syntax on
filetype plugin on
filetype indent on
set autoread
autocmd FocusGained,BufEnter * checktime

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
autocmd BufWritePre * %s/\s\+$//e

" change cursor in different modes
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
let &t_SR = "\e[4 q"

" Avoid getting stuck in Ex mode
map Q <Nop>
map gQ <Nop>

" macros on multiple lines
function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

" // searches for the current selection in visual mode
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" leader key
nnoremap <leader>s :set spell spelllang=en_us<CR>
nnoremap <Leader>ns :set nospell<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>u :UndotreeToggle<CR>
nnoremap <leader>f :filetype detect<CR>
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>w :w!<CR>
nnoremap <leader>q :q<CR>
nnoremap <Leader>r :source ~/.vimrc<CR>

" disable arrow keys
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" misc
nnoremap S :%s//g<Left><Left>
nnoremap <tab> >>
nnoremap # I#<Esc>
vnoremap # :norm I#<Esc>
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" abbreviations
ab -> →
ab up. ↑
ab down. ↓
ab <- ←
ab a. α
ab b. β
ab g. γ
ab d. δ
ab D. Δ
ab half. ½
ab max. maximum
ab min. minimum
ab >. ≥
ab <. ≤
ab sh. #!/bin/sh
ab shk. # shellcheck disable=
ab filetype. # vim: filetype=
ab degc °C
ab degf °F
ab deg. °
ab pi. π

source ~/.config/specific/vimrc
