local M = {}

function M.config(_plugin, _opts)
  local vim = _G.vim -- Let lua lsp know that vim is global

  require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
      width = 30,
      number = true,
      relativenumber = true,
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
      local vim = _G.vim -- Let lua lsp know that vim is global
      local api = require("nvim-tree.api")

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)

      -- custom mappings
      vim.keymap.set("n", "P", api.tree.change_root_to_parent, opts("Up"))
      vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
      vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("Change Root"))
      vim.keymap.set("n", "x", api.tree.collapse_all, opts("Collapse node"))
      vim.keymap.set("n", "y", api.fs.copy.node, opts("Copy node"))
      vim.keymap.set("n", "<leader>v", api.node.open.vertical, opts("Open vertical split"))
      vim.keymap.set("n", "<leader>s", api.node.open.horizontal, opts("Open horizontal split"))
    end
  })
end

function M.keymaps()
  -- Recommended mappings
  vim.keymap.set('n', '<leader>nt', '<cmd>NvimTreeToggle<CR>', { desc = "Toggle file explorer" })
  vim.keymap.set('n', '<leader>nf', '<cmd>NvimTreeFindFile<CR>', { desc = "Focus file in explorer" })
end

return M
