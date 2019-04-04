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

Plug 'scrooloose/nerdtree'
Plug 'w0rp/ale'
Plug 'vimwiki/vimwiki'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-endwise'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'nathanaelkane/vim-indent-guides'

" HTML
Plug 'mattn/emmet-vim'

" Ruby
Plug 'vim-ruby/vim-ruby'

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
let g:vimwiki_global_ext = 0
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
      \'*': ['trim_whitespace'],
      \'css': ['prettier'],
      \'elixir': ['mix_format'],
      \'html': ['prettier'],
      \'javascript': ['prettier'],
      \'markdown': ['prettier'],
      \'ruby': ['rubocop'],
      \'typescript': ['prettier']
      \}
let g:ale_elixir_elixir_ls_release='/Users/ryan/elixir-ls/rel'
let g:ale_linters = {'elixir': ['elixir-ls', 'credo']}

""""""""""""""""""
"     END ALE    "
""""""""""""""""""

"""""""""""""
"   EMMET   "
"""""""""""""

let g:user_emmet_leader_key=','

" Only enable Emmet for html and css
let g:user_emmet_install_global = 0
au FileType html,css EmmetInstall

""""""""""""""""
"   END EMMET  "
""""""""""""""""

""""""""""""""""""
"    GITGUTTER   "
""""""""""""""""""
set updatetime=300

""""""""""""""""""
" END GITGUTTER  "
""""""""""""""""""

""""""""""""""""""
"  INDENT GUIDE  "
""""""""""""""""""
let g:indent_guides_enable_on_vim_startup = 1

"""""""""""""""""""""
" END INDENT GUIDE  "
"""""""""""""""""""""

""""""""""""""""""
"  KEY MAPPINGS  "
""""""""""""""""""

" Use space as leader
map <space> <leader>

inoremap jk <esc>

" Buffer Management
nnoremap <leader>bv :vsp<CR><C-w>l
nnoremap <leader>bh :sp<CR><C-w>j

" Move up/down editor lines
nnoremap j gj
nnoremap k gk

" Searching
nnoremap / /\v
vnoremap / /\v
map <leader><space> :let @/=''<cr> " clear search

" Ale
nnoremap gd :ALEGoToDefinition<CR>

" Formatting
map <leader>q gqip

" NerdTree
nnoremap <leader>nt :NERDTreeToggle<CR>

" FZF
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fp :GFiles<CR>
nnoremap <leader>fg :Commits<CR>
nnoremap <leader>fs :Rg<space>


""""""""""""""""""""""
"  END KEY MAPPINGS  "
""""""""""""""""""""""

"""""""""""""""""""
"  AUTO COMMANDS  "
"""""""""""""""""""
function! AutoSaveAndFormat()
  if !pumvisible()
    wa
  endif

  if &modifiable
    ALEFix
  endif
endfunction

au FocusLost,BufLeave,WinLeave,TabLeave * call AutoSaveAndFormat()

"""""""""""""""""""""""
"  END AUTO COMMANDS  "
"""""""""""""""""""""""

""""""""""""""""""
"     CONFIG     "
""""""""""""""""""
" Autosave
set autowriteall

" Always keep sign column open
set signcolumn=yes

" Turn on syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

" Security
set modelines=0

" Show line numbers in hybrid
set number relativenumber
set nu rnu

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

