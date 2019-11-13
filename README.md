# dotfiles

A collection of my dotfiles

## TODO: Create a script to setup dotfiles on new computer
## TODO: Add vale.ini file
## TODO: Backup COC.nvim config

## Setup new project
1. Create .config/nvim/ dir and symlink .vimrc -> .config/init.vim
2. symlink .zshrc && .prettierrc && .tmux.conf to home directory
3. Regenerate spell check files [this](https://thoughtbot.com/blog/vim-spell-checking) will help

## Requirements

### Vim
1. JavaScript/TypeScript
   - Prettier - installed globaly
   - TypeScript - installed in project or globally
2. Elixir
   - ElixirLS
     - vim-elixirls
   - Credo - Installed in project
3. Ruby
   - Rubocop - installed globally
4. tmux
5. fzf.vim
   - ripgrep
   - Install zsh autocompletions for fzf
6. Rust
   - RLS

## Coc.nvim
### Requirements
- Node
- neovim npm package
- Ruby
  - coc-solargraph
  - solargraph gem
- Elixir
  - elixirls cloned and compiled
  ```
    {
      "languageserver": {
        "elixirLS": {
          "command": "~/elixir-ls/release/language_server.sh",
          "filetypes": ["elixir", "eelixir"]
        }
      }
    }
  ```
- JavaScript
  prettier
  coc-tsserver
  typescript installed globally
