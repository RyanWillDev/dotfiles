--local minuet = require('user.plugins.minuet')
--local nvim_tree = require('user.plugins.nvim-tree')

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
  {
    'prettier/vim-prettier',
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
    config = require('user.plugins.treesitter').config,
    priority = 100, -- Load early
  },
  -- Language Server Protocol support
  {
    "neovim/nvim-lspconfig",
    config = require('user.plugins.lsp').config,
    dependencies = {
      'onsails/lspkind.nvim',
      {
        "hrsh7th/nvim-cmp",           -- Autocompletion system
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",     -- LSP source for nvim-cmp
          "hrsh7th/cmp-buffer",       -- Buffer source
          "hrsh7th/cmp-path",         -- Path source
          "L3MON4D3/LuaSnip",         -- Snippet engine
          "f3fora/cmp-spell",         -- Allows spell suggestions
          "saadparwaiz1/cmp_luasnip", -- Snippet source
        },
      },
    }
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = require('user.plugins.nvim-tree').config
  },

  -- Fuzzy finder
  {
    "ibhagwan/fzf-lua",
    config = require('user.plugins.fzf').config,
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Git
  { "tpope/vim-fugitive", },
  { "airblade/vim-gitgutter", },

  -- Color Themes
  {
    "nordtheme/vim",
    as = "nord",
    priority = 1000,
  },
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
  },

  -- Markdown Rendering
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    ft = { "markdown", "codecompanion" },
  },

  -- LLM Stuff
  {
    'olimorris/codecompanion.nvim',
    cond = function(_) return vim.env.WORK_ENV == 'true' end,
    config = require('user.plugins.codecompanion').config
  },
  {
    'milanglacier/minuet-ai.nvim',
    cond = function(_) return vim.env.WORK_ENV == 'true' end,
  }
})

require('user.plugins.lsp')
