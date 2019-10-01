" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

" Use , as leader
let mapleader = ","

"""""""""""""
"  PLUGINS  "
"""""""""""""

call plug#begin('~/.local/share/nvim/site/plugged')
" Colorschemes
Plug 'AlessandroYorba/Sierra'
Plug 'RyanWillDev/vim-citylights'

Plug 'scrooloose/nerdtree'
Plug 'w0rp/ale'
Plug 'vimwiki/vimwiki'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-endwise'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-fugitive'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" HTML
Plug 'mattn/emmet-vim'

" Ruby
Plug 'vim-ruby/vim-ruby'

" Elixir
Plug 'elixir-lang/vim-elixir'
Plug 'slashmili/alchemist.vim'
Plug 'GrzegorzKozub/vim-elixirls', { 'do': ':ElixirLsCompileSync' }

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
"      FZF       "
""""""""""""""""""

nnoremap <leader>ff :Files<CR>
nnoremap <leader>fp :GFiles<CR>
nnoremap <leader>fg :Commits<CR>
nnoremap <leader>fs :Rg<space>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>ft :Rg<space>TODO\|FIXME<cr>

""""""""""""""""""
"    END FZF     "
""""""""""""""""""

""""""""""""""""""
"    VIM WIKI    "
""""""""""""""""""

let g:vimwiki_global_ext = 0
let g:vimwiki_listsyms = ' ○◐●✓'
let g:vimwiki_listsym_rejected = '✗'
let g:vimwiki_list = [{'path': '~/notes/',
                      \ 'syntax': 'markdown',
                      \'ext': '.md',
                      \'diary_rel_path': 'daily/',
                      \'diary_index': 'daily',
                      \'diary_header': 'Daily Notes',
                      \'auto_diary_index': 1},
                      \{'path': '~/work_notes/',
                      \ 'syntax': 'markdown',
                      \'ext': '.md',
                      \'diary_rel_path': 'daily/',
                      \'diary_index': 'daily',
                      \'diary_header': 'Daily Notes',
                      \'auto_diary_index': 1},]

augroup vimwikicmds
  autocmd! vimwikicmds
  autocmd Filetype vimwiki nnoremap <buffer> <leader>db  :call VimwikiDailyBoilerPlate()<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>tb  :call VimwikiTicketBoilerPlate()<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>td <esc>:put='## '.strftime('%b %d, %Y')<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>tl :TicketLink<space>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dn :VimwikiMakeTomorrowDiaryNote<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dp :VimwikiMakeYesterdayDiaryNote<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dc :VimwikiMakeDiaryNote<CR>

  command! -nargs=1 TicketLink put='## ['.toupper('<args>').'](/tickets/'.toupper('<args>').')'
augroup END

""""""""""""""""""
"  END VIM WIKI  "
""""""""""""""""""

""""""""""""""""""
"    DEOPLETE    "
""""""""""""""""""

let g:deoplete#enable_at_startup = 1
" Close preview window when pum is closed
autocmd CompleteDone * silent! pclose!

""""""""""""""""""
"  END DEOPLETE  "
""""""""""""""""""

""""""""""""""""""
"      ALE       "
""""""""""""""""""

"let g:ale_completion_enabled = 1
let g:ale_lint_on_save = 1
let g:ale_fixers = {
      \'*': ['trim_whitespace'],
      \'css': ['prettier'],
      \'elixir': ['mix_format'],
      \'html': ['prettier'],
      \'javascript': ['prettier'],
      \'json': ['prettier'],
      \'markdown': ['prettier'],
      \'ruby': ['rubocop'],
      \'rust': ['rustfmt'],
      \'scss': ['prettier'],
      \'typescript': ['prettier']
      \}
let g:ale_linters = {
      \'elixir': ['elixir-ls', 'credo'],
      \'rust': ['rls', 'cargo']
      \}

let g:ale_elixir_elixir_ls_release = $HOME . '/elixir-ls/release'
let g:vim_elixir_ls_elixir_ls_dir = $HOME . '/elixir-ls'
let g:ale_elixir_elixir_ls_config = { 'elixirLS': { 'dialyzerEnabled': v:false } }
let g:ale_rust_rls_executable = $HOME . '/.cargo/bin/rls'

nmap gd <Plug>(ale_go_to_definition)
nmap gvd <Plug>(ale_go_to_definition_in_vsplit)
nmap gsd <Plug>(ale_go_to_definition_in_split)
nmap gh <Plug>(ale_hover)

" Tab completion
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<c-y>" : "\<TAB>"


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
"    FUGITIVE    "
""""""""""""""""""
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gl :0Glog<CR><CR><C-w>j

""""""""""""""""""
"  END FUGITIVE  "
""""""""""""""""""

""""""""""""""""""
"  INDENT GUIDE  "
""""""""""""""""""

let g:indent_guides_enable_on_vim_startup = 1

"""""""""""""""""""""
" END INDENT GUIDE  "
"""""""""""""""""""""

""""""""""""""""""
"    NERDTREE    "
""""""""""""""""""

let NERDTreeShowHidden=1

nnoremap <leader>nt :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>

augroup nerdtreecmds
  autocmd! nerdtreecmds
  autocmd Filetype nerdtree nmap <buffer> <leader>s i
  autocmd Filetype nerdtree nmap <buffer> <leader>v s
augroup END

""""""""""""""""""
"  END NERDTREE  "
""""""""""""""""""

""""""""""""""""""
"  KEY MAPPINGS  "
""""""""""""""""""
inoremap jk <esc>

" Window Mangagement
nnoremap <C-w>. 15<C-w>>
nnoremap <C-w>, 15<C-w><
nnoremap <C-w>= 15<C-w>+
nnoremap <C-w>- 15<C-w>-
nnoremap <C-w>V <C-w>H
nnoremap <C-w>S <C-w>K
nnoremap <C-w>0 <C-w>=
nnoremap ,v <C-w>v<C-w>l
nnoremap ,s <C-w>s<C-w>j
let i = 1
while i <= 9
    execute 'nnoremap <Leader>' . i . ' :' . i . 'wincmd w<CR>'
    let i = i + 1
endwhile

" Yank to system clipboard
vnoremap Y "*y
nnoremap Y "*y

" Move up/down editor lines
nnoremap j gj
nnoremap k gk

" Searching
nnoremap / /\v
vnoremap / /\v
map <leader><space> :let @/=''<CR> " clear search

" Ale
nnoremap <leader>aft :call ToggleAleFixOnSave()<CR>

" Formatting
map <leader>q gqip


""""""""""""""""""""""
"  END KEY MAPPINGS  "
""""""""""""""""""""""

"""""""""""""""""""
"    FUNCTIONS    "
"""""""""""""""""""

function! AutoSaveAndFormat()
  " BufLeave event was not triggered by popup
  if !pumvisible()
    " File is both modifiable and has a name
    if &modifiable && expand('%') != ''
      wa " Write all buffers
      ALELint
      if g:ale_fix_on_save
        ALEFix
      endif
    endif
  endif
endfunction

function! ToggleAleFixOnSave()
  if g:ale_fix_on_save
    let g:ale_fix_on_save = 0
  else
    let g:ale_fix_on_save = 1
  endif
endfunction

function! WindowNumber()
    return tabpagewinnr(tabpagenr())
endfunction

function! VimwikiDailyBoilerPlate()
  normal! gg
  0put='# '.strftime('%b %d, %Y')

  for section in ['*TODOs*', '*Tickets*', '*Notes*'] 
    put=''
    put=''.section
  endfor
endfunction

function! VimwikiTicketBoilerPlate()
  normal! gg
  0put='# '.toupper(expand('%:t:r'))
  
  for section in ['*Subtasks*', '*TODOs*', '*Questions*', '*Notes*'] 
    put=''
    put=''.section
  endfor
endfunction

"""""""""""""""""""
"  END FUNCTIONS  "
"""""""""""""""""""


"""""""""""""""""
"    COMMANDS   "
"""""""""""""""""

au FocusLost,BufLeave,WinLeave,TabLeave * call AutoSaveAndFormat()

" Return to last edit position when opening files
au BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

autocmd QuickFixCmdPost *grep* cwindow

autocmd FileType gitcommit,markdown setlocal spell spelllang=en_us,es complete+=kspell

""""""""""""""""""
"  END COMMANDS  "
""""""""""""""""""

""""""""""""""""""
"     CONFIG     "
""""""""""""""""""

" Reload file if it changes outside of vim
set autoread

" Always keep sign column open
set signcolumn=yes

" Turn on syntax highlighting
syntax on

" Enable Code Fencing
let g:markdown_fenced_languages = ['elixir', 'js=javascript', 'ruby', 'bash=sh']

" For plugins to load correctly
filetype plugin indent on

" Security
set modelines=0

" Show line numbers in hybrid
set number relativenumber
set nu rnu

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

" Always show Status bar
set laststatus=2
set statusline=\ <<\ %.50f\ >>\ %m\ %r\ %h\ %=\ [%{WindowNumber()}]\ %-l:%c\ %p%{'%'}

" Last line
set showmode
set showcmd

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch

" Spellcheck
set spellfile=~/.config/nvim/tech.utf-8.add,~/.config/nvim/en.utf-8.add,~/.config/nvim/es.utf-8.add,~/.config/nvim/work.utf-8.add

" Visualize tabs and newlines
set listchars=tab:▸\ ,eol:¬
set nolist
map <leader>l :set list!<CR> " Toggle tabs and EOL

" Color scheme (terminal)
set background=dark
set termguicolors
colorscheme citylights

""""""""""""""""""
"   END CONFIG   "
""""""""""""""""""

