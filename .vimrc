" Don't try to be vi compatible
set nocompatible

" Helps force plugins to load correctly when it is turned back on below
filetype off

" Use , as leader
let mapleader = ","
let maplocalleader = ","
let g:auto_format_enabled = 0

"""""""""""""
"  PLUGINS  "
"""""""""""""

call plug#begin('~/.local/share/nvim/site/plugged')
" Colorschemes
Plug 'drewtempelmeyer/palenight.vim'
Plug 'dracula/vim'
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim', {'branch': 'main'}

Plug 'vimwiki/vimwiki'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Auto add matching praens and brackets
Plug 'jiangmiao/auto-pairs'

" Auto add end to languages that use do/end sytax EG: ruby and elixir
Plug 'tpope/vim-endwise'

" Linting and Autocompletion
Plug 'w0rp/ale'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
Plug 'hrsh7th/cmp-nvim-lsp', {'branch': 'main'}
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Fuzzy searching files, commits, colorschemes, etc
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'

" HTML
Plug 'mattn/emmet-vim', {'for': ['html', 'css', 'eruby', 'eelixir']}

Plug 'simrat39/rust-tools.nvim'

" Ruby
Plug 'vim-ruby/vim-ruby', {'for': ['ruby', 'eruby' ]}

" Elixir
Plug 'elixir-lang/vim-elixir', {'for': ['elixir', 'eelixir']}

" JavaScript
Plug 'pangloss/vim-javascript', {'for': 'javascript'}
Plug 'maxmellon/vim-jsx-pretty', {'for': 'javascript'}

" TypeScript
Plug 'HerringtonDarkholme/yats.vim', {'for': 'typescript'}

" Zig
Plug 'ziglang/zig.vim', {'for': 'zig'}

" Scheme/Lisp/Clojure
Plug 'Olical/conjure', {'branch': 'develop'} " Specifying develop is a temporary fix for crashing on launch https://github.com/Olical/conjure/issues/293
Plug 'bhurlow/vim-parinfer'
Plug 'guns/vim-sexp'

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

" Override W windows command
command! W w

""""""""""""""""""
"    END FZF     "
""""""""""""""""""

""""""""""""""""""
"    VIM WIKI    "
""""""""""""""""""

let g:vimwiki_global_ext = 0
let g:vimwiki_listsyms = ' ○◐●✓'
let g:vimwiki_listsym_rejected = '✗'
let g:vimwiki_list = [{'path': '~/notes',
                      \ 'syntax': 'markdown',
                      \'ext': '.md',
                      \'diary_rel_path': 'daily/',
                      \'diary_index': 'daily',
                      \'diary_header': 'Daily Notes',
                      \'auto_diary_index': 1,
                      \'nested_syntaxes': {'elixir': 'elixir', 'js': 'javascript', 'ruby': 'ruby', 'sql': 'sql'},
                    \}]

augroup vimwikicmds
  autocmd! vimwikicmds
  autocmd Filetype vimwiki nnoremap <buffer> <leader>db  :call VimwikiDailyBoilerPlate()<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>tb  :call TicketBoilerPlate()<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>td <esc>:execute 'normal! i'.strftime('%b %d, %Y')<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>tss <esc>:exe "normal! i**Start: ".strftime('%H:%M')."**"<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>tse <esc>:exe "normal! i**End: ".strftime('%H:%M')."**"<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>tl :TicketLink<space>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dn :VimwikiMakeTomorrowDiaryNote<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dp :VimwikiMakeYesterdayDiaryNote<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>dc :VimwikiMakeDiaryNote<CR>
  autocmd Filetype vimwiki nnoremap <buffer> <leader>tn :VimwikiTable

  autocmd Filetype vimwiki nnoremap <leader>bu :call Backup()<CR>

  command! -nargs=+ TicketLink :call MakeTicketLink(<f-args>)
augroup END

""""""""""""""""""
"  END VIM WIKI  "
""""""""""""""""""

""""""""""""""""""
"       ZK       "
""""""""""""""""""
nnoremap <leader>nn :NewNote<space>
nnoremap <leader>no :call OpenNote()<CR>
nnoremap <leader>na :call YankNoteAnchor()<CR>
command! -nargs=+ NewNote :call MakeNote(<f-args>)

function! MakeNote(...)
  "let s:file_name = join(a:000, ' ') . '.md'
  "let s:time = strftime("%Y%m%d%H%M%S")
  "execute 'e ' . fnameescape($ZK_PATH . '/' . s:time . ' ' . s:file_name)

  let s:file_name = join(a:000, ' ') " zk new adds extension
  let path = system('zk new -p -t "' . s:file_name . '"') " -p prints path instead of opens
  let path = trim(path) " Remove newlines
  execute 'e ' . fnameescape(path)
endfunction

function! OpenNote()
  " Uses the id of the note and a wild card to open the file by id.
  " Since the ids should always be unique we can rely on this.
  e <cword>*
endfunction

function! YankNoteAnchor()
let filename = expand('%:t')
let parts = split(filename)
let id = parts[0]
let anchor = '[[' . id . ']]'

let @" = anchor
let @*=@"
endfunction

""""""""""""""""""
"     END ZK     "
""""""""""""""""""

""""""""""""""""""
"      ALE       "
""""""""""""""""""

let g:ale_lint_on_save = 1
let g:ale_fixers = {
      \'*': ['trim_whitespace'],
      \'css': ['prettier'],
      \'html': ['prettier'],
      \'javascript': ['prettier'],
      \'javascriptreact': ['prettier'],
      \'json': ['prettier'],
      \'markdown': ['prettier'],
      \'scss': ['prettier'],
      \'typescript': ['prettier']
      \}

let g:ale_linters = {
      \'elixir': ['credo'],
      \'rust': ['rls', 'cargo'],
      \}

let g:ale_rust_rls_executable = $HOME . '/.cargo/bin/rls'

""""""""""""""""""
"     END ALE    "
""""""""""""""""""


""""""""""""""""""
"      LSP       "
""""""""""""""""""
lua << EOF
  local cmp = require'cmp'
  cmp.setup({
    -- Default mappings were removed. See https://github.com/hrsh7th/nvim-cmp/issues/231#issuecomment-1098175017
    mapping = cmp.mapping.preset.insert({}),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name =  'buffer'}
    }),
    snippet = {
      -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#no-snippet-plugin
      -- You have to have a snippet support otherwise it breaks nvim-cmp if the language server returns snippets
      -- like tsserver does.
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  require'lspconfig'.elixirls.setup{
    cmd = { vim.env.HOME .. "/elixir-ls/release/language_server.sh" },
    capabilities = capabilities,
    settings = {
      --dialyzerEnabled = false
    }
  }

  require'lspconfig'.solargraph.setup{
    settings = {
      solargraph = {
        diagnostics = true
      }
    },
    capabilities = capabilities
  }

  require'lspconfig'.tsserver.setup{
    capabilities = capabilities,
    on_attach = function(client)
      formatting = {
        insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = false,
        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
        semicolons = "insert"
      }

      settings = {
        settings = vim.tbl_deep_extend("force", client.config.settings, {
          typescript = { format = formatting },
          javascript = { format = formatting },
        })
      }

      client.notify("workspace/didChangeConfiguration", settings)
    end,
  }

  require'lspconfig'.zk.setup{
    cmd = { 'zk', 'lsp' },
    filetypes = { 'markdown' },
    capabilities = capabilities,
  }

  require('rust-tools').setup({})

  -- Enable diagnostics
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = true,
      signs = true,
      update_in_insert = true,
    }
  )

  -- vim.lsp.set_log_level("debug")
EOF

" LSP Keymaps
nnoremap gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap gh <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap ,e <cmd>lua vim.diagnostic.open_float()<CR>

let g:vim_elixir_ls_elixir_ls_dir = $HOME . '/elixir-ls'

" Configure completion

" Doesn't auto select/insert from completion menu
set completeopt=menuone,noinsert,noselect
" Turns off additonal message
set shortmess+=c

""""""""""""""""""
"     END LSP    "
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
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gl :Gclog<CR><CR><C-w>j

""""""""""""""""""
"  END FUGITIVE  "
""""""""""""""""""

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
nnoremap <C-w>+ 15<C-w>+
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

" Yank filename
nnoremap <leader>yf :let @" = expand('%:t')<CR>:let @*=@"<CR>

" Yank file path relative to pwd
nnoremap <leader>yrf :let @" = '/' . expand('%:.')<CR>:let @*=@"<CR>

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

nnoremap <leader>aft :call ToggleFormatOnSave()<CR>


""""""""""""""""""""""
"  END KEY MAPPINGS  "
""""""""""""""""""""""

"""""""""""""""""""
"    FUNCTIONS    "
"""""""""""""""""""

function! Backup()
  wa

  let output = system('git add . && git commit -m "backup"')
  if v:shell_error != 0
    echo output
  else
    let output = system('git push origin')
    if v:shell_error != 0
      echo output
    else
      echo "Backup complete"
    endif
  endif
endfunction

function! CanModifyFile()
  let l:value = 0

  " File is both modifiable and has a name
  if &modifiable && expand('%') != ''
    let l:value = 1
  endif

  return l:value
endfunction

function! AutoSave()
  " Event was not triggered by popup
  if CanModifyFile() && !pumvisible() && &modified
    wa " Write all buffers
  endif
endfunction

function! FormatFile()
  if CanModifyFile() && g:auto_format_enabled && &modified
    "Calling asynchronously formats the file your entering not leaving
    "Not ideal to do sync format, but will have to do for now
    " Format file asynchronously and save file when complete
    "call CocActionAsync('format', { err, res -> execute('call AutoSave()') })
    "call CocAction('format')

    lua vim.lsp.buf.formatting_sync()

    " Used for removing whitepsace & prettier formatter
    ALEFix
  endif
endfunction

function! AutoSaveAndFormat()
  call FormatFile()
  call AutoSave()
endfunction

function! ToggleFormatOnSave()
  if g:auto_format_enabled
    let g:auto_format_enabled = 0
    echo "Auto format disabled"
  else
    let g:auto_format_enabled = 1
    echo "Auto format enabled"
  endif
endfunction

function! WindowNumber()
    return tabpagewinnr(tabpagenr())
endfunction

function! VimwikiDailyBoilerPlate()
  normal! gg
  0put='# '.strftime('%b %d, %Y')

  for section in ['TODOs', 'Tickets', 'Notes']
    put=''
    put='## '.section
  endfor
endfunction

function! MakeTicketLink(newline, ...)
  let s:ticket_name = []

  for word in a:000
    call add(s:ticket_name, toupper(word))
  endfor

  let s:link = '[' . join(s:ticket_name, '-') .'](/tickets/' . join(s:ticket_name, '-') . ')'

  if a:newline
    " Add the link on the next line
    put='- ' . s:link
  else
    " Add the link in line
    execute 'normal! i ' . s:link
  endif
endfunction

function! TicketBoilerPlate()
  normal! gg
  0put='# '.toupper(expand('%:t:r'))
  put=''
  put='[TICKET]('. $TICKET_TRACKER_URL .toupper(expand('%:t:r')).')'

  put=''
  put='## TOC'

  for section in ['TODOs', 'Notes', 'Log']
    put='- ['.section.']'.'(#'.section.')'
  endfor

  for section in ['TODOs', 'Notes', 'Log']
    put=''
    put='## '.section
  endfor
endfunction

"""""""""""""""""""
"  END FUNCTIONS  "
"""""""""""""""""""


"""""""""""""""""
"    COMMANDS   "
"""""""""""""""""
augroup AutoSaveAndFormatting
  autocmd! AutoSaveAndFormatting
  au FocusLost,BufLeave,WinLeave,TabLeave * call AutoSaveAndFormat()
  au BufWriteCmd * call AutoSaveAndFormat()
augroup END

" Return to last edit position when opening files
au BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

autocmd QuickFixCmdPost *grep* cwindow

autocmd FileType gitcommit,markdown setlocal spell spelllang=en_us complete+=kspell

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

" Enable Code Fencing
let g:markdown_fenced_languages = ['elixir', 'js=javascript', 'json', 'ruby', 'bash=sh', 'sql']

" Opens Image files using the open command
let g:netrw_browsex_viewer="xdg-open"

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
set textwidth=80
set formatoptions=tcrnl1j
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
set spellfile=~/.config/nvim/en.utf-8.add,~/.config/nvim/work.utf-8.add

" Visualize tabs and newlines
"set listchars=tab:▸\ ,eol:¬,trail:•
set listchars=trail:•
set list
map <leader>l :set list!<CR> " Toggle tabs and EOL

" Color scheme (terminal)
set background=dark
colorscheme onedark

if (has("termguicolors"))
  set termguicolors
endif
""""""""""""""""""
"   END CONFIG   "
""""""""""""""""""

