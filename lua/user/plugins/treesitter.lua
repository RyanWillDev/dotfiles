local vim = _G.vim -- Let lua lsp know that vim is global

local M = {}

function M.config()
  vim.treesitter.language.register('tsx', 'typescriptreact')

  require('nvim-treesitter').setup()
  require('nvim-treesitter').install {
    'bash',
    'diff',
    'erlang',
    'git_rebase',
    'gitcommit',
    'go',
    'javascript',
    'lua',
    'markdown',
    'markdown_inline',
    'proto',
    'python',
    'ruby',
    'rust',
    'sql',
    'terraform',
    'tmux',
    'tsx',
    'typescript',
  }

  -- nvim-treesitter main removed the highlight module; Neovim only auto-starts
  -- treesitter for its bundled languages. Enable it for everything else.
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf = args.buf
      local ok = pcall(vim.treesitter.start, buf)
      if not ok then
        vim.bo[buf].syntax = 'on'
      end
    end,
  })
end

return M
