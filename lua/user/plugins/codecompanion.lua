local vim = _G.vim -- Let lua lsp know that vim is global

local M = {}

local prompts = {
  require("user.plugins.codecompanion.prompts.tech-spec-collaboration")
}

local prompt_library = {}

for _k, mod in pairs(prompts) do
  local name, config = mod.prompt()
  prompt_library[name] = config
end

function M.keymaps()
  vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
  vim.keymap.set("v", "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
  vim.keymap.set("v", "<leader>ae", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true })
end

function M.config(_plugin, _opts)
  local gemini_api_key = os.getenv("GEMINI_API_KEY")
  require("codecompanion").setup({
    display = {
      action_palette = {
        width = 95,
        height = 10,
        prompt = "Prompt ",                   -- Prompt used for interactive LLM calls
        provider = "telescope",               -- default|telescope|mini_pick
        opts = {
          show_default_actions = true,        -- Show the default actions in the action palette?
          show_default_prompt_library = true, -- Show the default prompt library in the action palette?
        },
      },
    },
    strategies = {
      chat = {
        adapter = "gemini",
        slash_commands = {
          ["file"] = {
            opts = {
              provider = "fzf_lua",
              contains_code = true
            }
          },
          ["buffer"] = {
            opts = {
              provider = "fzf_lua",
              contains_code = true
            }
          },
          ["help"] = {
            opts = {
              provider = "fzf_lua",
              contains_code = true
            }
          },
          ["symbols"] = {
            opts = {
              provider = "fzf_lua",
              contains_code = true
            }
          }
        }
      },
      inline = {
        adapter = "gemini",
      },
    },
    adapters = {
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          env = {
            api_key = gemini_api_key,
          },
          schema = {
            model = {
              default = "gemini-2.0-flash",
            },
          },
        })
      end,
    },
    opts = {
      system_prompt = function(opts)
        return [[
          You are an AI programming assistant named "CodeCompanion". You are currently plugged into the Neovim text editor on a user's machine.

          Your core tasks include:
          - Answering general programming questions.
          - Explaining how the code in a Neovim buffer works.
          - Reviewing the selected code in a Neovim buffer.
          - Generating unit tests for the selected code.
          - Proposing fixes for problems in the selected code.
          - Scaffolding code for a new workspace.
          - Finding relevant code to the user's query.
          - Proposing fixes for test failures.
          - Answering questions about Neovim.
          - Running tools.

          You must:
          - Follow the user's requirements carefully and to the letter.
          - Keep your answers short and impersonal, especially if the user's context is outside your core tasks.
          - Minimize additional prose unless clarification is needed.
          - Use Markdown formatting in your answers.
          - Include the programming language name at the start of each Markdown code block.
          - Avoid including line numbers in code blocks.
          - Avoid wrapping the whole response in triple backticks.
          - Only return code that's directly relevant to the task at hand. You may omit code that isn’t necessary for the solution.
          - Avoid using H1 and H2 headers in your responses.
          - Use actual line breaks in your responses; only use "\n" when you want a literal backslash followed by 'n'.
          - All non-code text responses must be written in the English language indicated.
          - Avoid outputting the editor command xml in the chat buffer.

          When given a task:
          1. Think step-by-step and, unless the user requests otherwise or the task is very simple, describe your plan in detailed pseudocode.
          2. Importantly, be sure to ask any clarifying questions prior to generating repsonses or taking any action to ensure you have all relevant context.
          3. If you have more than one topic or point to provide to the user, summarize and list the topics so the conversation can be directed.
          4. Output the final code in a single code block, ensuring that only relevant code is included.
          5. If asked to use the editor tool to change a file, confirm with the user that you should add changes to a file **before** doing so.
          6. End your response with a short suggestion for the next user turn that directly supports continuing the conversation.
          7. Provide exactly one complete reply per conversation turn.
        ]]
      end

    }
  })
end

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

return M
