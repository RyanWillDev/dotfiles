local vim = _G.vim -- Let lua lsp know that vim is global

local M = {}

local auto_format_enabled = 0 -- Used by autoformat function. Default to off
local function can_modify_file()
  local filename = vim.fn.expand('%')
  return vim.bo.modifiable
      and filename ~= ''                         -- filename is not ''
      and not string.match(filename, 'fugitive') -- git-fugitive windows are modifiable
end

local function auto_save()
  if can_modify_file() and not (vim.fn.pumvisible() == 1) and vim.bo.modified then
    vim.cmd('wa') -- Write all buffers
  end
end

local function format_file()
  if can_modify_file() and auto_format_enabled == 1 and vim.bo.modified then
    vim.lsp.buf.format()
  end
end

local function auto_save_and_format()
  if can_modify_file() then
    -- Strip trailing whitespace
    -- Uses string literal to avoid having to figure out escaping
    vim.cmd([[:%s/\s\+$//e]])
  end

  format_file()
  auto_save()
end

local function toggle_auto_format()
  if auto_format_enabled == 1 then
    print('Auto format disabled')
    auto_format_enabled = 0
  else
    print('Auto format enabled')
    auto_format_enabled = 1
  end
end

-- Since we overwrite the `BufWriteCmd` this will be executed when :w is evoked
-- in addition to the other auto-save events
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "WinLeave", "TabLeave", "BufWriteCmd", }, {
  pattern = "*",
  callback = auto_save_and_format,
})

function M.keymaps()
  vim.keymap.set("n", "<leader>aft", toggle_auto_format, { noremap = true })
end

return M
