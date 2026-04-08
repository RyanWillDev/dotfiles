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
local resize_cycle = { idx = 0, axis = nil, win = nil, timer = nil }
local proportions = { 0.67, 0.33, 0.5 }

local function cycle_resize(axis)
  return function()
    local win = vim.api.nvim_get_current_win()
    local cur_nr = vim.fn.winnr()
    local has_neighbor = (axis == "width")
      and (vim.fn.winnr('h') ~= cur_nr or vim.fn.winnr('l') ~= cur_nr)
      or (vim.fn.winnr('j') ~= cur_nr or vim.fn.winnr('k') ~= cur_nr)

    if not has_neighbor then return end

    if resize_cycle.axis == axis and resize_cycle.win == win then
      resize_cycle.idx = (resize_cycle.idx % #proportions) + 1
    else
      resize_cycle.axis = axis
      resize_cycle.win = win
      resize_cycle.idx = 1
    end

    if resize_cycle.timer then
      resize_cycle.timer:stop()
    end
    resize_cycle.timer = vim.defer_fn(function()
      resize_cycle.axis = nil
    end, 2000)

    local proportion = proportions[resize_cycle.idx]
    if axis == "width" then
      local total = vim.o.columns
      vim.api.nvim_win_set_width(win, math.floor(total * proportion))
    else
      local total = vim.o.lines - vim.o.cmdheight - 1
      vim.api.nvim_win_set_height(win, math.floor(total * proportion))
    end
  end
end

vim.keymap.set("n", "<leader>w", cycle_resize("width"), { desc = "Cycle split width: 1/2 → 2/3 → 1/3" })
vim.keymap.set("n", "<leader>W", cycle_resize("height"), { desc = "Cycle split height: 1/2 → 2/3 → 1/3" })
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
require('user.notes.redact').keymaps()
require('user.windows').keymaps()

-- Plugins
require('user.plugins.codecompanion').keymaps()
require('user.plugins.fzf').keymaps()
require('user.plugins.nvim-tree').keymaps()
