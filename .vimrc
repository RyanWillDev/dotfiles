" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

"""""""""""""
"  PLUGINS  "
"""""""""""""

call plug#begin('~/.local/share/nvim/site/plugged')
" Colorschemes
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'AlessandroYorba/Sierra'

Plug 'w0rp/ale'

Plug 'vimwiki/vimwiki'

Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-endwise'
Plug 'airblade/vim-gitgutter'

" Elixir
Plug 'elixir-lang/vim-elixir'

" JavaScript
Plug 'pangloss/vim-javascript'

" TypeScript
Plug 'HerringtonDarkholme/yats.vim'
Plug 'mhartington/nvim-typescript', {'do': './install.sh'}
call plug#end()

"""""""""""""""""
"  END PLUGINS  "
"""""""""""""""""

""""""""""""""""""
"    VIM WIKI    "
""""""""""""""""""

let g:vimwiki_list = [{'path': '~/notes/',
                       \ 'syntax': 'markdown', 'ext': '.md'},]

""""""""""""""""""
"  END VIM WIKI  "
""""""""""""""""""

""""""""""""""""""
"      ALE       "
""""""""""""""""""

let g:ale_completion_enabled = 1
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 1 
let g:ale_fixers = {
      \'javascript': ['prettier'],
      \'markdown': ['prettier'],
      \'css': ['prettier'],
      \'elixir': ['mix_format'],
      \}
let g:ale_elixir_elixir_ls_release='/Users/ryan/elixir-ls/rel'
let g:ale_linters = {'elixir': ['elixir-ls', 'credo']}

""""""""""""""""""
"     END ALE    "
""""""""""""""""""

""""""""""""""""""
"    GITGUTTER   "
""""""""""""""""""

set updatetime=300

""""""""""""""""""
" END GITGUTTER  "
""""""""""""""""""

""""""""""""""""""
"  KEY MAPPINGS  "
""""""""""""""""""

let mapleader = ","

inoremap jk <esc>

" Move up/down editor lines
nnoremap j gj
nnoremap k gk

" Searching
nnoremap / /\v
vnoremap / /\v
map <leader><space> :let @/=''<cr> " clear search

" Remap help key.
inoremap <F1> <ESC>:set invfullscreen<CR>a
nnoremap <F1> :set invfullscreen<CR>
vnoremap <F1> :set invfullscreen<CR>

" Formatting
map <leader>q gqip

""""""""""""""""""""""
"  END KEY MAPPINGS  "
""""""""""""""""""""""

""""""""""""""""""
"     CONIFG     "
""""""""""""""""""

" Turn on syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

" Security
set modelines=0

" Show line numbers
set number

" Show file stats
set ruler

" Blink cursor on error instead of beeping (grr)
set visualbell

" Encoding
set encoding=utf-8

"Highlight Cursor
set cursorline
set cursorcolumn

" Whitespace
set wrap
set textwidth=79
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround

" Cursor motion
set scrolloff=3
set backspace=indent,eol,start
set matchpairs+=<:> " use % to jump between pairs
runtime! macros/matchit.vim

" Allow hidden buffers
set hidden

" Rendering
set ttyfast

" Status bar
set laststatus=2

" Last line
set showmode
set showcmd

set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch

" Visualize tabs and newlines
set listchars=tab:▸\ ,eol:¬
" Uncomment this to enable by default:
" set list " To enable by default
" Or use your leader key + l to toggle on/off
map <leader>l :set list!<CR> " Toggle tabs and EOL


" Color scheme (terminal)
set background=dark 
set termguicolors
colorscheme sierra

""""""""""""""""""
"   END CONFIG   "
""""""""""""""""""

