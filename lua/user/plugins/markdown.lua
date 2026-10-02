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

function M.peek_config(_plugin, _opts)
  local vim = _G.vim -- Let lua lsp know that vim is global
  require("peek").setup()
  vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
  vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
end

return M
