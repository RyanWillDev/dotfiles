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
Plug 'RyanWillDev/vim-citylights'

Plug 'vimwiki/vimwiki'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'nathanaelkane/vim-indent-guides'

" Auto add matching praens and brackets
Plug 'jiangmiao/auto-pairs'

" Auto add end to languages that use do/end sytax EG: ruby and elixir
Plug 'tpope/vim-endwise'

" Linting and Autocompletion
Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Fuzzy searching files, commits, colorschemes, etc
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'

" HTML
Plug 'mattn/emmet-vim', {'for': ['html', 'css']}

" Ruby
Plug 'vim-ruby/vim-ruby', {'for': ['ruby', 'eruby' ]}

" Elixir
Plug 'elixir-lang/vim-elixir', {'for': ['elixir', 'eelixir']}
Plug 'GrzegorzKozub/vim-elixirls', {'for': ['elixir', 'eelixir'], 'do': ':ElixirLsCompileSync'}

" JavaScript
Plug 'pangloss/vim-javascript', {'for': 'javascript'}
Plug 'maxmellon/vim-jsx-pretty', {'for': 'javascript'}

" TypeScript
Plug 'HerringtonDarkholme/yats.vim', {'for': 'typescript'}

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
  autocmd Filetype vimwiki nnoremap <buffer> <leader>mb  :call VimwikiMeetingBoilerPlate()<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>td <esc>:put='## '.strftime('%b %d, %Y')<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>tl :TicketLink<space>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>ml :MeetingLink<space>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dn :VimwikiMakeTomorrowDiaryNote<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dp :VimwikiMakeYesterdayDiaryNote<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dc :VimwikiMakeDiaryNote<CR>

  command! -nargs=+ TicketLink :call MakeTicketLink(<f-args>)
  command! -nargs=+ MeetingLink :call MakeMeetingLink(<f-args>)
augroup END

""""""""""""""""""
"  END VIM WIKI  "
""""""""""""""""""

""""""""""""""""""
"      ALE       "
""""""""""""""""""

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

let g:vim_elixir_ls_elixir_ls_dir = $HOME . '/elixir-ls'
let g:ale_rust_rls_executable = $HOME . '/.cargo/bin/rls'

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gvd ,v<Plug>(coc-definition)
nmap <silent> gsd ,s<Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> gh :call CocAction('doHover')<CR>
nnoremap <leader>aft :call ToggleAleFixOnSave()<CR>

let g:coc_snippet_next = '<C-n>'
let g:coc_snippet_prev = '<C-p>'

" Enter for completion
" Endwise is overwriting <CR> map
" If -1 means no complete option is selected
" Using >= 0 would cause the completion to not be selected in some cases
imap <CR> <c-r>=pumvisible() && complete_info()['selected'] != -1 ? coc#_select_confirm() : "\n"<CR>

""""""""""""""""""
"     END ALE    "
""""""""""""""""""

"""""""""""""
"   EMMET   "
"""""""""""""

let g:user_emmet_leader_key=','

" Only enable Emmet for html and css
let g:user_emmet_install_global = 0
au FileType html,css,eelixir EmmetInstall

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

" Since , is the leader key use ,; to replace , for going
" back to last result of f or t
nnoremap <leader>; ,

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

  for section in ['TODOs', 'Tickets', 'Meetings', 'Notes']
    put=''
    put='## '.section
  endfor
endfunction

function! VimwikiTicketBoilerPlate()
  normal! gg
  0put='# '.toupper(expand('%:t:r'))
  put=''
  put='[TICKET]('. $JIRA_URL .toupper(expand('%:t:r')).')'

  for section in ['Subtasks', 'TODOs', 'Questions', 'Notes', 'Work Log']
    put=''
    put='## '.section
  endfor
endfunction

function! VimwikiMeetingBoilerPlate()
  normal! gg
  0put='# '.toupper(expand('%:t:r'))

  for section in ['TODOs', 'Considerations', 'Questions', 'Notes']
    put=''
    put='## '.section
  endfor
endfunction

function! MakeTicketLink(...)
  let s:link = '[' . toupper(a:1) .'](/tickets/' . toupper(a:1) . ')'

  if a:0 > 1 && a:2
    " Add the link on the next line
    put='- ' . s:link
  else
    " Add the link in line
    execute 'normal! i ' . s:link
  endif
endfunction

function! MakeMeetingLink(...)
  let s:split_title = split(a:1, '-')
  let s:proper_title = []

  for word in s:split_title
    call add(s:proper_title, toupper(word))
  endfor

  let s:link = '[' . join(s:proper_title, ' ') .'](/meetings/' . strftime("%Y-%m-%d") . '/' . a:1 .  ')'

  if a:0 > 1 && a:2
    " Add the link on the next line
    put='- ' . s:link
  else
    " Add the link in line
    execute 'normal! i ' . s:link
  endif
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
"set listchars=tab:▸\ ,eol:¬,trail:•
set listchars=trail:•
set list
map <leader>l :set list!<CR> " Toggle tabs and EOL

" Color scheme (terminal)
set background=dark
set termguicolors
colorscheme citylights

""""""""""""""""""
"   END CONFIG   "
""""""""""""""""""

