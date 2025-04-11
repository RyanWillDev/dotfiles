local vim = _G.vim -- Let lua lsp know that vim is global
local M = {}

-- Calculate window number and set the statusline to include it
vim.cmd [[
 function! WindowNumber()
     return tabpagewinnr(tabpagenr())
 endfunction

 set statusline=\ <<\ %.50f\ >>\ %m\ %r\ %h\ %=\ [%{WindowNumber()}]\ %-l:%c\ %p%{'%'}
]]


-- Return to last position in file
vim.cmd [[
 au BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif

 autocmd QuickFixCmdPost *grep* cwindow
]]

function M.keymaps()
  -- Jump to window
  for i = 1, 9 do
    vim.keymap.set("n", "<Leader>" .. i, ":" .. i .. "wincmd w<CR>")
  end
end

return M
