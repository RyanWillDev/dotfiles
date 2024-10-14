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
Plug 'joshdick/onedark.vim', {'branch': 'main'}
Plug 'nordtheme/vim', { 'as': 'nord' }
Plug 'sainnhe/everforest'
Plug 'EdenEast/nightfox.nvim'

Plug 'jkramer/vim-checkbox'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Auto add matching praens and brackets
Plug 'jiangmiao/auto-pairs'

" Auto add end to languages that use do/end sytax EG: ruby and elixir
Plug 'tpope/vim-endwise'

" Linting and Autocompletion
Plug 'w0rp/ale'

" LSP & Autocomplete stuff
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp', {'branch': 'main'}
Plug 'onsails/lspkind.nvim'
Plug 'hrsh7th/cmp-nvim-lsp', {'branch': 'main'}
Plug 'hrsh7th/cmp-buffer', {'branch': 'main'}
Plug 'f3fora/cmp-spell'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Fuzzy searching files, commits, colorschemes, etc
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'

" Elixir
Plug 'elixir-tools/elixir-tools.nvim'
Plug 'nvim-lua/plenary.nvim'

" HTML
Plug 'mattn/emmet-vim', {'for': ['html', 'css', 'eruby', 'eelixir']}

" Markdown
Plug 'preservim/vim-markdown'
Plug 'godlygeek/tabular'

" Rust
Plug 'simrat39/rust-tools.nvim'

Plug 'prettier/vim-prettier', {
      \ 'do': 'npm install',
      \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'],
      \}

" treesitter does not work for fenced markdown languages
" You can enable regex highlighting, but that is supposed to cause performance issues.
" treesitter is already disabled for markdown in order to use the `vim-markdown` plugin,
" so we'll just load the fenced language plugs for markdown files
Plug 'vim-ruby/vim-ruby', {'for': 'markdown'}

" Elixir
Plug 'elixir-lang/vim-elixir', {'for': 'markdown'}

" JavaScript
Plug 'pangloss/vim-javascript', {'for': 'markdown'}

" TypeScript
Plug 'HerringtonDarkholme/yats.vim', {'for': 'markdown'}

Plug 'jparise/vim-graphql', {'for': 'markdown'}

" Zig
Plug 'ziglang/zig.vim', {'for': 'markdown'}

" Scheme/Lisp/Clojure
"Plug 'Olical/conjure', {'branch': 'develop'} " Specifying develop is a temporary fix for crashing on launch https://github.com/Olical/conjure/issues/293
"Plug 'bhurlow/vim-parinfer'
"Plug 'guns/vim-sexp'

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

" Override W windows command
command! W w

""""""""""""""""""
"       ZK       "
""""""""""""""""""
nnoremap <leader>nn :NewNote<space>
command! -nargs=+ NewNote :call MakeNote(0, <f-args>)

nnoremap <leader>nwn :NewWorkNote<space>
command! -nargs=+ NewWorkNote :call MakeNote(1, <f-args>)

nnoremap <leader>td <esc>:execute 'normal! i'.strftime('%b %d, %Y')<CR>
nnoremap <leader>tss <esc>:exe "normal! A **Start: ".strftime('%H:%M')."**"<CR>
nnoremap <leader>tse <esc>:exe "normal! A **End: ".strftime('%H:%M')."**"<CR>

function! MakeNote(is_work_note, ...)
  "let s:file_name = join(a:000, ' ') . '.md'
  "let s:time = strftime("%Y%m%d%H%M%S")
  "execute 'e ' . fnameescape($ZK_PATH . '/' . s:time . ' ' . s:file_name)
  let s:file_name = join(a:000, ' ') " zk new adds extension

  if a:is_work_note
  let path = system('zk work_note "' . s:file_name . '"') " -p prints path instead of opens
  else
  let path = system('zk new -p -t "' . s:file_name . '"') " -p prints path instead of opens
  endif

  "let path = system('zk new -p -t "' . s:file_name . '"') " -p prints path instead of opens
  let path = trim(path) " Remove newlines
  execute 'e ' . fnameescape(path)
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
      \}

let g:ale_linters = {
      \'rust': ['rls', 'cargo'],
      \}

let g:ale_rust_rls_executable = $HOME . '/.cargo/bin/rls'

""""""""""""""""""
"     END ALE    "
""""""""""""""""""

""""""""""""""""""
"    Prettier    "
""""""""""""""""""
let g:prettier#autoformat = 1
let g:prettier#autoformat_config_present = 0
let g:prettier#autoformat_require_pragma = 0
let g:prettier#autoformat_config_files = [
      \      'javascript',
      \      'typescript',
      \      'javascriptreact',
      \      'typescriptreact',
      \      'css',
      \      'less',
      \      'scss',
      \      'json',
      \      'graphql',
      \      'markdown',
      \      'vue',
      \      'yaml',
      \      'html'
      \      ]

""""""""""""""""""
"  End Prettier  "
""""""""""""""""""

""""""""""""""""""
"    Markdown    "
""""""""""""""""""
let g:vim_markdown_new_list_item_indent = 2
" Disable setting tabstop to 4 in .md files
let g:markdown_recommended_style = 0
" Get the ge command back
map <Leader>ge <Plug>Markdown_EditUrlUnderCursor

" Jump to anchors on page
let g:vim_markdown_follow_anchor = 1
" Allow anchors to be specified with -
" https://github.com/preservim/vim-markdown/issues/493
let g:vim_markdown_anchorexpr = "'# ' .. substitute(v:anchor, '-', '[- ]', 'g') .. ' \*\\n\\c'"

""""""""""""""""""
"  End Markdown  "
""""""""""""""""""

""""""""""""""""""
"      LSP       "
""""""""""""""""""
lua << EOF
  local ls = require('luasnip')

  function on_attach(_client, _bufnr)
    vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { buffer = true, noremap = true })
    vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", { buffer = true, noremap = true })
    vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { buffer = true, noremap = true })
    vim.keymap.set("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", { buffer = true, noremap = true })


    vim.keymap.set({"i"}, "<C-Y>", function() ls.expand() end, {silent = true})
    vim.keymap.set({"i", "s"}, "<C-N>", function() ls.jump( 1) end, {silent = true})
    vim.keymap.set({"i", "s"}, "<C-P>", function() ls.jump(-1) end, {silent = true})

    vim.keymap.set({"i", "s"}, "<C-C>", function()
      if ls.choice_active() then
      ls.change_choice(1)
    end
    end, {silent = true})
  end

  local cmp = require'cmp'
  local lspkind = require('lspkind')
  cmp.setup({
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol',
        menu = {
          buffer = '[Buffer]',
          luasnip = '[LuaSnip]',
          nvim_lsp = '[LSP]',
          spell = '[Spell]'
        },
      }),
    },
    -- Default mappings were removed. See https://github.com/hrsh7th/nvim-cmp/issues/231#issuecomment-1098175017
    mapping = cmp.mapping.preset.insert({}),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
      { name = 'spell' },
    }),
    snippet = {
      -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#no-snippet-plugin
      -- You have to have a snippet support otherwise it breaks nvim-cmp if the language server returns snippets
      -- like tsserver does.
      expand = function(args)
        ls.lsp_expand(args.body)
      end,
    },
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  require("elixir").setup({
    nextls = {
      enable = true,
      spitfire = true,
      on_attach = on_attach,
      -- This breaks because workspace is incorrect
      -- capabilities = capabilities,
      init_options = {
        mix_env = "dev",
        experimental = {
          completions = {
            enable = true -- control if completions are enabled. defaults to false
          }
        }
      }
    },
    credo = {enable = true},
    elixirls = {enable = false},
  })

  --require'lspconfig'.elixirls.setup{
  --  cmd = { vim.env.HOME .. "/elixir-ls/release/language_server.sh" },
  --  on_attach = on_attach,
  --  capabilities = capabilities,
  --  settings = {
  --    --dialyzerEnabled = false
  --  }
  --}

  require'lspconfig'.erlangls.setup{
    on_attach = on_attach
  }

  require'lspconfig'.solargraph.setup{
    on_attach = on_attach,
    settings = {
      solargraph = {
        diagnostics = true
      }
    },
    capabilities = capabilities
  }

  require'lspconfig'.ts_ls.setup{
    capabilities = capabilities,
    on_attach = function(client)
      on_attach() -- Configure Keymaps

      formatting = {
        insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = false,
        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
        semicolons = "ignore"
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
    on_attach = on_attach,
    cmd = { 'zk', 'lsp' },
    filetypes = { 'markdown' },
    capabilities = capabilities,
  }

  require('rust-tools').setup({
    on_attach = on_attach,
    tools = {
      inlay_hints = {
        auto = true,
        show_parameter_hints = true,
      },
    }
  })

  require'lspconfig'.gopls.setup{
    on_attach = on_attach,
  }

  -- diagnostics seem to show with or without this
  -- Enable diagnostics
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = true,
      signs = true,
      update_in_insert = true,
    }
  )

  -- vim.lsp.set_log_level("debug")

    require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = {},

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = {},

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = {'markdown'},
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
   -- disable = function(lang, buf)
   --     local max_filesize = 100 * 1024 -- 100 KB
   --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
   --     if ok and stats and stats.size > max_filesize then
   --         return true
   --     end
   -- end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

EOF

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
let NERDTreeShowLineNumbers=1

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
    lua vim.lsp.buf.format()

    " Used for removing whitepsace
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

" Spell check
setlocal spelllang=en_us complete+=kspell
" Automatically enable spell check for specific file types
autocmd BufReadPost * setlocal spell spelllang=en_us complete+=kspell

" Toggle spell check
nnoremap ,tsc :set spell!<CR>

""""""""""""""""""
"  END COMMANDS  "
""""""""""""""""""

""""""""""""""""""
"     CONFIG     "
""""""""""""""""""

" Reload file if it changes outside of vim
set autoread

" Conceal Markdown syntax
set conceallevel=2

" Always keep sign column open
set signcolumn=yes

" Enable Code Fencing
let g:markdown_fenced_languages = ['elixir', 'graphql', 'javascript', 'typescript', 'json', 'ruby', 'bash', 'sql']
" Turns off auto folding for vim-markdown
let g:vim_markdown_folding_disabled = 1

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
set textwidth=100
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
set listchars=tab:\ \ ,trail:•,
set list
map <leader>l :set list!<CR> " Toggle tabs and EOL

" Color scheme (terminal)
if (has("termguicolors"))
  " Fixes italic fonts
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

set background=dark
let g:everforest_background = 'soft'
colorscheme everforest
""""""""""""""""""
"   END CONFIG   "
""""""""""""""""""

