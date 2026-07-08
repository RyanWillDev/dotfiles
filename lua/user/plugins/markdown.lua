local M = {}

function M.render_markdown_config(_plugin, _opts)
  local vim = _G.vim -- Let lua lsp know that vim is global
  require("render-markdown").setup({})

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
