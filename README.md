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

Install [ripgrep](https://github.com/BurntSushi/ripgrep) for [fzf.vim](https://github.com/junegunn/fzf.vim)

## Ale

ALE is used to format with prettier and remove trailing whitespace. It also
lints Elixir files with credo.

### TypeScript and JavaScript

Prettier installed globally
`npm i -g prettier`

### Elixir

Credo installed in project

## Coc.nvim

I opted to install the language servers independent without using Coc
extensions. I'm not a fan of having to manage plugins within a plugin, but Coc
has the best UX of the lsps so far.

If you're using a version manager for your language,
packages must be installed for every version of you have installed

### TypeScript and JavaScript

Node must be installed globally

`npm i -g typescript`
`npm i javascript-typescript-langserver -g`

### Ruby

`gem install solargraph`

### Elixir

[elixir-ls](https://github.com/elixir-lsp/elixir-ls) installed, compiled,
and release created inside `release` directory
