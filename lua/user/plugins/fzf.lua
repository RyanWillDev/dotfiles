local M = {}
local vim = _G.vim -- Let lua lsp know that vim is global

function M.config(_plugin, opts)
  local fzf = require('fzf-lua')

  local ignore_patterns = [[-g "!.git" -g "!_build" -g "!deps" -g "!node_modules" -g "!.elixir_ls" -g "!cover/**/*"]]

  fzf.setup({
    grep = {
      hidden    = true,
      no_ignore = true,
      rg_opts   = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 ]] .. ignore_patterns,
    },
    files = {
      hidden    = true,
      no_ignore = true,
      rg_opts   = [[--color=never --hidden --files ]] .. ignore_patterns,
    }
  })
end

function M.keymaps()
  local fzf = require('fzf-lua')

  vim.keymap.set('n', '<leader>fp', fzf.files, { desc = "Find files", noremap = true })
  vim.keymap.set('n', '<leader>fs', fzf.live_grep, { desc = "Live grep", noremap = true })
  vim.keymap.set('n', '<leader>ft', function()
    require('fzf-lua').grep('TODO')
  end, { desc = "Find TODO comments", noremap = true })

  -- Vim related searches
  vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = "Buffers", noremap = true })
  vim.keymap.set('n', '<leader>fh', fzf.helptags, { desc = "Help tags", noremap = true })
  vim.keymap.set('n', '<leader>fk', fzf.keymaps, { desc = "Keymaps", noremap = true })

  -- Git related searches
  vim.keymap.set('n', '<leader>fg', fzf.git_commits, { desc = "Keymaps", noremap = true })

  -- LSP-related searches
  vim.keymap.set('n', 'gd', fzf.lsp_definitions, { desc = "Find definitions", noremap = true })
  vim.keymap.set('n', 'gr', fzf.lsp_references, { desc = "Find references", noremap = true })
  vim.keymap.set('n', 'go', fzf.lsp_outgoing_calls, { desc = "Find outgoing calls", noremap = true })
  vim.keymap.set('n', 'gi', fzf.lsp_incoming_calls, { desc = "Find incoming calls", noremap = true })
end

return M
