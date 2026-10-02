local M = {}

function M.render_markdown_config(_plugin, _opts)
  local vim = _G.vim -- Let lua lsp know that vim is global
  -- 'padded' (default) breaks rows where prettier pads an otherwise-empty
  -- cell with whitespace to match column width; 'overlay' redraws cells
  -- fully instead of relying on raw spacing, at the cost of inline-code
  -- concealment inside table cells.
  require("render-markdown").setup({ pipe_table = { cell = "overlay" } })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      vim.keymap.set("n", "gx", function()
        local seen = {}
        for _, url in ipairs(require("vim.ui")._get_urls()) do
          if not seen[url] then
            seen[url] = true
            local _, err = vim.ui.open(url)
            if err then vim.notify(err, vim.log.levels.ERROR) end
          end
        end
      end, { buffer = true, noremap = true, desc = "Open URL (deduped)" })
    end,
  })
end

function M.table_mode_init(_plugin)
  local vim = _G.vim -- Let lua lsp know that vim is global
  -- Must be set before the plugin loads: vim-table-mode reads this to build
  -- its default mappings as soon as it's sourced, so setting it in `config`
  -- (which runs after load) would be too late.
  --
  -- Default tableize map is <leader>tt, which collides with
  -- <leader>tt ToggleCheckbox mapping (lua/user/notes/init.lua).
  vim.g.table_mode_tableize_map = "<leader>ta"
  vim.g.table_mode_delete_row = "<leader>trd"
  vim.g.table_mode_delete_column = "<leader>tcd"
end

function M.table_mode_config(_plugin, _opts)
  local vim = _G.vim -- Let lua lsp know that vim is global
  -- Markdown pipe tables use '|' corners, not vim-table-mode's default '+'.
  vim.g.table_mode_corner = "|"
end

function M.peek_config(_plugin, _opts)
  local vim = _G.vim -- Let lua lsp know that vim is global
  -- 'browser' opens the preview in your default system browser (a real tab
  -- with find-in-page, zoom, etc.) instead of peek's chromeless webview.
  require("peek").setup({ app = "browser" })
  vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
  vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
end

return M
