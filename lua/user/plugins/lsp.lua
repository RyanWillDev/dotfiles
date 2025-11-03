local vim = _G.vim -- Let lua lsp know that vim is global

local M = {}

function M.config()
  local cmp = require('cmp')
  local ls = require('luasnip')
  local lspkind = require('lspkind')

  function on_attach(_client, _bufnr)
    vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", { buffer = true, noremap = true })
    vim.keymap.set("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", { buffer = true, noremap = true })


    vim.keymap.set({ "i" }, "<C-Y>", function() ls.expand() end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-N>", function() ls.jump(1) end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-P>", function() ls.jump(-1) end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-C>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true })
  end

  cmp.setup({
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol',
        menu = {
          buffer = '[Buffer]',
          luasnip = '[LuaSnip]',
          nvim_lsp = '[LSP]',
          spell = '[Spell]'
        },
      }),
    },
    -- Default mappings were removed. See https://github.com/hrsh7th/nvim-cmp/issues/231#issuecomment-1098175017
    mapping = cmp.mapping.preset.insert({}),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'spell' },
      { name = 'buffer' },
      per_filetype = {
        codecompanion = { "codecompanion" },
      },
    }),
    snippet = {
      -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#no-snippet-plugin
      -- You have to have a snippet support otherwise it breaks nvim-cmp if the language server returns snippets
      -- like tsserver does.
      expand = function(args)
        ls.lsp_expand(args.body)
      end,
    },
  })

  -- Codecompanion's nvim-cmp setup overrides my existing sources.
  -- In order to use the buffer source, I have to reconfigure after the other sources have been added.
  -- Snippet below pulled from https://github.com/olimorris/codecompanion.nvim/blob/88111765a8d7d1f9b359f74bb6ec44e4c0f5f0b2/plugin/codecompanion.lua#L89-L97
  cmp.setup.filetype("codecompanion", {
    enabled = true,
    sources = vim.list_extend({
      { name = "codecompanion_models" },
      { name = "codecompanion_slash_commands" },
      { name = "codecompanion_tools" },
      { name = "codecompanion_variables" },
    }, cmp.get_config().sources),
  })

  -- Language Servers
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- require("elixir").setup({
  --   nextls = {
  --     enable = true,
  --     spitfire = true,
  --     on_attach = on_attach,
  --     -- This breaks because workspace is incorrect
  --     -- capabilities = capabilities,
  --     init_options = {
  --       mix_env = "dev",
  --       experimental = {
  --         completions = {
  --           enable = true -- control if completions are enabled. defaults to false
  --         }
  --       }
  --     }
  --   },
  --   credo = {enable = true},
  --   elixirls = {enable = false},
  -- })

  vim.lsp.config('elixirls', {
    cmd = { vim.env.HOME .. "/elixir-ls/release/language_server.sh" },
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      --dialyzerEnabled = false
    }
  })
  vim.lsp.enable('elixirls')


  vim.lsp.config('pylsp', {
    on_attach = on_attach,
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
            ignore = { 'W391' },
            maxLineLength = 100
          }
        }
      }
    }
  })
  vim.lsp.enable('pylsp')

  vim.lsp.config('erlangls', {
    on_attach = on_attach
  })
  vim.lsp.enable('erlangls')

  vim.lsp.config('solargraph', {
    on_attach = on_attach,
    settings = {
      solargraph = {
        diagnostics = true
      }
    },
    capabilities = capabilities
  })
  vim.lsp.enable('solargraph')

  vim.lsp.config('ts_ls', {
    capabilities = capabilities,
    on_attach = function(client)
      on_attach() -- Configure Keymaps

      local formatting = {
        insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = false,
        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
        semicolons = "ignore"
      }

      local settings = {
        settings = vim.tbl_deep_extend("force", client.config.settings, {
          typescript = { format = formatting },
          javascript = { format = formatting },
        })
      }

      client.notify("workspace/didChangeConfiguration", settings)
    end,
  })
  vim.lsp.enable('ts_ls')

  vim.lsp.config('zk', {
    on_attach = on_attach,
    cmd = { 'zk', 'lsp' },
    filetypes = { 'markdown' },
    capabilities = capabilities,
  })
  vim.lsp.enable('zk')

  --require('lspconfig').rust_analyzer.setup({
  --  on_attach = on_attach,
  --})

  vim.lsp.config('rust-analyzer', {
    on_attach = function(_client, bufnr)
      vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", { buffer = true, noremap = true })
      vim.keymap.set("n", "<leader>e", function()
          vim.cmd.RustLsp('renderDiagnostic', 'current')
        end,
        { buffer = true, noremap = true }
      )

      vim.keymap.set("n", "<leader>x", function()
          vim.cmd.RustLsp('explainError', 'current')
        end,
        { buffer = true, noremap = true }
      )

      vim.keymap.set("n", "<leader>a", function()
          vim.cmd.RustLsp('hover', 'actions')
        end,
        { buffer = true, noremap = true }
      )

      vim.keymap.set("n", "<leader>c", function()
          vim.cmd.RustLsp('codeAction')
        end,
        { buffer = true, noremap = true }
      )

      vim.keymap.set({ "i" }, "<C-Y>", function() ls.expand() end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-N>", function() ls.jump(1) end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-P>", function() ls.jump(-1) end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<C-C>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true })

      --  vim.lsp.inlay_hint.enable(true, { bufnr })
    end,
    inlayHints = {
      enable = true,
      showParameterNames = true,
      parameterHintsPrefix = "<- ",
      otherHintsPrefix = "=> ",
    },
    diagnostics = {
      enable = true
    }
  })
  vim.lsp.enable('rust-analyzer')

  vim.lsp.config('gopls', {
    on_attach = on_attach,
  })
  vim.lsp.enable('gopls')

  vim.lsp.config('lua_ls', {
    on_attach = on_attach
  })
  vim.lsp.enable('lua_ls')

  -- diagnostics seem to show with or without this
  -- Enable diagnostics
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = true,
      signs = true,
      update_in_insert = true,
    }
  )
end

return M
