-- TODOs:
-- Fix autoformat
-- Configure LSP
-- Fix hidden file select in telescope
--  - DONE 
-- Fix multi file select in telescope
--  - https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-1679797700
-- Configure plugins
-- Move everything to its own file

-- TODO: Move to ./lua/plugins.lua
-- plugins.lua
-- Bootstrap Lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  print("Lazy.nvim installed!")
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require("lazy").setup({
  -- Essential plugins
  "nvim-lua/plenary.nvim", -- Utility functions (dependency for many plugins)

  -- Notes
  'jkramer/vim-checkbox', -- Toggle checkboxes in markdown files

  -- General Code Plugins
  'jiangmiao/auto-pairs',
  'tpope/vim-endwise',
  {'prettier/vim-prettier',
    build = 'yarn install --frozen-lockfile --production',
    ft = {
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
      'css',
      'less',
      'scss',
      'json',
      'graphql',
      'markdown',
      'vue',
      'svelte',
      'yaml',
      'html'
    }
  },
  'elixir-tools/elixir-tools.nvim',

  -- Treesitter for syntax highlighting (load early)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    priority = 100, -- Load early
  },
   -- Language Server Protocol support
  { "neovim/nvim-lspconfig", }, -- Base LSP configurations 

  -- Autocompletion system
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",   -- Buffer source
      "hrsh7th/cmp-path",     -- Path source
      "L3MON4D3/LuaSnip",     -- Snippet engine
      "f3fora/cmp-spell",     -- Allows spell suggestions
      "saadparwaiz1/cmp_luasnip", -- Snippet source
    },
  },
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  -- Git
  { "tpope/vim-fugitive", },
  { "airblade/vim-gitgutter", },

  -- Color Themes
  { 
    "nordtheme/vim", 
    as = "nord",
    priority = 1000, -- load last
  },
  {
    "EdenEast/nightfox.nvim",
    priority = 1000, -- load last
  },

  -- LLM Stuff
  {'olimorris/codecompanion.nvim', cond = vim.env.WORK_ENV == 'true'},
})

-- TODO: Move to ./lua/keymaps.lua
-- Keymaps
--vim.api.nvim_set_keymap('i', 'jk', '<esc>', { noremap = true, silent = true })
-- Leader key
vim.g.mapleader = ',' -- Comma as the leader key
vim.g.maplocalleader = ',' -- Comma as the leader key
vim.api.nvim_set_keymap('i', 'jk', '<esc>', { noremap = true, silent = true })

-- vim.keymap.set("n", "<leader>ff", "<cmd>Files<CR>")
-- vim.keymap.set("n", "<leader>fp", "<cmd>GFiles<CR>")
-- vim.keymap.set("n", "<leader>fg", "<cmd>Commits<CR>")
-- vim.keymap.set("n", "<leader>fs", "<cmd>Rg <space>")
--  vim.keymap.set("n", "<leader>fb", "<cmd>Buffers<CR>")
vim.keymap.set("n", "<leader>ft", "<cmd>Rg <space>TODO\\|FIXME<CR>")
vim.keymap.set("i", "jk", "<esc>")
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>")
vim.keymap.set("n", "<leader>gd", "<cmd>Gdiff<CR>")
vim.keymap.set("n", "<leader>gl", "<cmd>Gclog<CR><CR><C-w>j")

-- Using nvim-tree
--vim.keymap.set("n", "<leader>nt", "<cmd>NERDTreeToggle<CR>")
--vim.keymap.set("n", "<leader>nf", "<cmd>NERDTreeFind<CR>")

-- Window Management
vim.keymap.set("n", "<C-w>.", "15<C-w>>")
vim.keymap.set("n", "<C-w>,", "15<C-w><")
vim.keymap.set("n", "<C-w>+", "15<C-w>+")
vim.keymap.set("n", "<C-w>-", "15<C-w>-")
vim.keymap.set("n", "<C-w>V", "<C-w>H")
vim.keymap.set("n", "<C-w>S", "<C-w>K")
vim.keymap.set("n", "<C-w>0", "<C-w>=")
vim.keymap.set("n", ",v", "<C-w>v<C-w>l")
vim.keymap.set("n", ",s", "<C-w>s<C-w>j")
vim.keymap.set("n", "<C-w>t", "<cmd>tab split<CR>")

-- Yank to system clipboard
vim.keymap.set("v", "Y", '"*y')
vim.keymap.set("n", "Y", '"*y')

-- Yank filename
vim.keymap.set("n", "<leader>yf", ':let @" = expand("%:t")<CR>:let @*=@"<CR>')

-- Yank file path relative to pwd
vim.keymap.set("n", "<leader>yrf", ':let @" = "/" . expand("%:.")<CR>:let @*=@"<CR>')

-- Move up/down editor lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Searching
vim.keymap.set("n", "/", "/\\v")
vim.keymap.set("v", "/", "/\\v")
vim.keymap.set("n", "<leader><space>", ":let @/=''<CR>") -- clear search

-- Since , is the leader key use ,; to replace , for going
-- back to last result of f or t
vim.keymap.set("n", "<leader>;", ",")

-- Formatting
vim.keymap.set("n", "<leader>q", "gqip")
-- End Keymaps
--


-- TODO: Move to ./lua/options.lua
-- Colorscheme
vim.o.background = "dark"
-- vim.g.everforest_background = "soft"
vim.cmd("colorscheme nordfox")
vim.cmd("set noshiftround")

vim.o.number = true
vim.o.relativenumber = true

vim.o.updatetime = 300 -- Shows gitgutter signs (faster?)

vim.g.auto_format_enabled = 0 -- Used by autoformat function. Default to off
-- vim.o.nocompatible = true
vim.o.modelines = 0
vim.o.number = true
vim.o.relativenumber = true
vim.o.nu = true
vim.o.rnu = true
vim.o.visualbell = true
vim.o.encoding = "utf-8"
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.wrap = true
vim.o.textwidth = 100
vim.o.formatoptions = "tcrnl1j"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
-- vim.o.noshiftround = true
vim.o.scrolloff = 3
vim.o.backspace = "indent,eol,start"
vim.o.matchpairs = vim.o.matchpairs .. ",<:>"
vim.o.hidden = true
vim.o.laststatus = 2
vim.o.showmode = true
vim.o.showcmd = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.showmatch = true
vim.o.spellfile = vim.fn.expand("~/.config/nvim/en.utf-8.add") .. "," .. vim.fn.expand("~/.config/nvim/work.utf-8.add")
vim.o.listchars = "tab:  ,trail:•,"
vim.o.list = true
vim.o.autoread = true
vim.o.conceallevel = 2
vim.o.signcolumn = "yes"
vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.shortmess = vim.o.shortmess .. "c"

-- Calculate window number and set the statusline to include it
vim.cmd [[
 function! WindowNumber()
     return tabpagewinnr(tabpagenr())
 endfunction

 set statusline=\ <<\ %.50f\ >>\ %m\ %r\ %h\ %=\ [%{WindowNumber()}]\ %-l:%c\ %p%{'%'}
]]

for i = 1, 9 do
  vim.keymap.set("n", "<Leader>" .. i, ":" .. i .. "wincmd w<CR>")
end

-- Window Number Mappings
-- augroup AutoSaveAndFormatting
--   autocmd! AutoSaveAndFormatting
--   au FocusLost,BufLeave,WinLeave,TabLeave * call AutoSaveAndFormat()
--   au BufWriteCmd * call AutoSaveAndFormat()
-- augroup END

-- Autocommands
-- Return to last position in file
vim.cmd [[
 au BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
 
 autocmd QuickFixCmdPost *grep* cwindow
]]

-- End options.lua


-- TODO: Move to ./lua/nvim-tree.lua
-- -- explorer.lua
-- Check if nvim-tree is available
local has_tree, nvim_tree = pcall(require, "nvim-tree")
if not has_tree then
  print("Warning: nvim-tree not found. File explorer won't be available.")
  return
end

-- End nvim-tree.lua

-- Set up nvim-tree with error handling
local setup_ok, _ = pcall(nvim_tree.setup, {
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false,
  },
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true,
    },
  },
  on_attach = function(bufnr)
    local api = require "nvim-tree.api"

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings
    vim.keymap.set("n", "P", api.tree.change_root_to_parent, opts("Up"))
    vim.keymap.set("n", "?",     api.tree.toggle_help, opts("Help"))
    vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("Change Root"))
    vim.keymap.set("n", "x",     api.tree.collapse_all, opts("Collapse node"))
  end
})

-- Recommended mappings
vim.keymap.set('n', '<leader>nt', '<cmd>NvimTreeToggle<CR>', { desc = "Toggle file explorer" })
vim.keymap.set('n', '<leader>nf', '<cmd>NvimTreeFindFile<CR>', { desc = "Focus file in explorer" })

if not setup_ok then
  print("Error setting up nvim-tree. Some features might not work correctly.")
  return
end

-- End nvim-tree


-- TODO: move to ./lua/telescope.lua
-- Check if telescope is available
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  print("Warning: telescope not found. Fuzzy finding won't be available.")
  return
end

-- Set up telescope with error handling
local setup_ok, _ = pcall(telescope.setup, {
  defaults = {
    prompt_prefix = "🔍 ",
    selection_caret = "❯ ",
    path_display = { "truncate" },
    layout_config = {
      horizontal = {
        preview_width = 0.55,
        results_width = 0.8,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    file_ignore_patterns = {
      "node_modules/",
      ".git/",
      ".DS_Store"
    },
  },
  extensions = {
    -- Configure any extensions here
  },
  pickers = {
    live_grep = {
        file_ignore_patterns = { 'node_modules', '.git', '.venv' },
        additional_args = function(_)
            return { "--hidden" }
        end
    },
    find_files = {
        file_ignore_patterns = { 'node_modules', '.git', '.venv' },
        hidden = true
    }
  },
})

if not setup_ok then
  print("Error setting up telescope. Some features might not work correctly.")
  return
end

-- Load telescope extensions if available
pcall(function() require('telescope').load_extension('fzf') end)

-- Useful Telescope mappings with error handling
local builtin_ok, builtin = pcall(require, 'telescope.builtin')
if builtin_ok then
  vim.keymap.set('n', '<leader>fp', builtin.find_files, { desc = "Find files" })
  vim.keymap.set('n', '<leader>fs', builtin.live_grep, { desc = "Live grep" })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffers" })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help tags" })
  -- LSP-related searches
  vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, { desc = "Find definitions" })
  vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = "Find references" })
end

