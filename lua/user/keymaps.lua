-- Let lua lsp know that vim is global
local vim = _G.vim

vim.g.mapleader = ','      -- Comma as the leader key
vim.g.maplocalleader = ',' -- Comma as the leader key
vim.keymap.set('i', 'jk', '<esc>', { noremap = true, silent = true })

-- Formatting
vim.keymap.set("n", "<leader>q", "gqip")
vim.keymap.set("n", "<leader>p", function()
  vim.cmd("write")
  local filepath = vim.fn.expand("%:p")
  local bufnr = vim.api.nvim_get_current_buf()
  local stderr_output = {}

  vim.fn.jobstart({ "prettier", "--write", filepath }, {
    stderr_buffered = true,
    on_stderr = function(_, data)
      stderr_output = data
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 then
          vim.api.nvim_buf_call(bufnr, function() vim.cmd("edit") end)
          vim.notify("Prettier: formatted successfully", vim.log.levels.INFO)
        else
          local err_msg = table.concat(stderr_output, "\n")
          vim.notify("Prettier failed: " .. err_msg, vim.log.levels.ERROR)
        end
      end)
    end,
  })
end, { desc = "Format file with Prettier" })

-- Time Tracking
vim.keymap.set("n", "<leader>td", "<esc>:execute 'normal! i'.strftime('%m-%d-%Y')<CR>")
vim.keymap.set("n", "<leader>tss", "<esc>:exe 'normal! A**Start: '.strftime('%H:%M').'**'<CR>")
vim.keymap.set("n", "<leader>tse", "<esc>:exe 'normal! A**End: '.strftime('%H:%M').'**'<CR>")

-- Yank to system clipboard
vim.keymap.set("v", "Y", '"*y')
vim.keymap.set("n", "Y", '"*y')

-- Yank filename
vim.keymap.set("n", "<leader>yf", ':let @" = expand("%:t")<CR>:let @*=@"<CR>')

-- Yank file path relative to pwd
vim.keymap.set("n", "<leader>yrf", ':let @" = expand("%:.")<CR>:let @*=@"<CR>')

-- Move up/down editor lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
-- Since , is the leader key use g; to replace , for going
-- back to last result of f or t
vim.keymap.set("n", "g;", ",")

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

-- Searching
vim.keymap.set("n", "/", "/\\v")
vim.keymap.set("v", "/", "/\\v")
vim.keymap.set("n", "<leader><space>", ":let @/=''<CR>") -- clear search

-- Git Gutter
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>")
vim.keymap.set("n", "<leader>gd", "<cmd>Gdiff<CR>")
vim.keymap.set("n", "<leader>gl", "<cmd>Gclog<CR><CR><C-w>j")

require('user.autosave').keymaps()
require('user.notes').keymaps()
require('user.windows').keymaps()

-- Plugins
require('user.plugins.codecompanion').keymaps()
require('user.plugins.fzf').keymaps()
require('user.plugins.nvim-tree').keymaps()
