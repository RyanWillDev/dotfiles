-- Let lua lsp know that vim is global
local vim = _G.vim

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd("set noshiftround")
vim.o.autoread = true
vim.o.backspace = "indent,eol,start"
vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.conceallevel = 2
vim.o.cursorcolumn = true
vim.o.cursorline = true
vim.o.encoding = "utf-8"
vim.o.expandtab = true
vim.o.formatoptions = "tcrnl1j"
vim.o.hidden = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.laststatus = 2
vim.o.list = true
vim.o.listchars = "tab:  ,trail:•,"
vim.o.matchpairs = vim.o.matchpairs .. ",<:>"
vim.o.modelines = 0
vim.o.number = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 3
vim.o.shiftwidth = 2
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.showcmd = true
vim.o.showmatch = true
vim.o.showmode = true
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.softtabstop = 2
vim.o.spellfile = vim.fn.expand("~/.config/nvim/en.utf-8.add") .. "," .. vim.fn.expand("~/.config/nvim/work.utf-8.add")
vim.o.tabstop = 2
vim.o.textwidth = 100
vim.o.updatetime = 300 -- Shows gitgutter signs (faster?)
vim.o.visualbell = true
vim.o.wrap = true

-- Spell check
vim.api.nvim_set_option_value('spelllang', 'en_us', { scope = 'local' })
vim.api.nvim_set_option_value('complete', vim.api.nvim_get_option_value('complete', {}) .. ',kspell', { scope = 'local' })

vim.cmd [[
  autocmd BufReadPost * setlocal spell spelllang=en_us complete+=kspell
]]

-- Fix common mistypes
-- Set :W to just execute w
vim.cmd [[
  command! W w
]]

-- Set :Q to just execute q
vim.cmd [[
  command! Q q
]]


-- Set :Qa to just execute qa
vim.cmd [[
  command! Qa qa
]]

-- Set :Wqa to just execute wqa
vim.cmd [[
  command! Wqa wqa
]]
