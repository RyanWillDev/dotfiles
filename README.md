# dotfiles

A collection of my dotfiles

## TODO: Create a script to setup dotfiles on new computer

## TODO: Add vale.ini file

## TODO: Backup COC.nvim config

## Setup new project

### Setting up shell
1. Install tmux
2. Install ohmyzsh
3. symlink .zshrc && .prettierrc && .tmux.conf && devspace.sh to home directory
4. Install asdf

### Installing Neovim
Use asdf plugin to install neovim nightly

1. Create .config/nvim/ dir symlink 2. Add symlinks
  - .vimrc -> .config/nvim/init.vim
  - .en.utf-8.add -> .config/nvim/.en.utf-8.add
2. Create spell files
  - `mkspell! ~/.config/nvim/en.utf-8.add`
3. Download [Plug](https://github.com/junegunn/vim-plug)
4. Regenerate spell check files [this](https://thoughtbot.com/blog/vim-spell-checking) will help

## Requirements

### Vim

Install [ripgrep](https://github.com/BurntSushi/ripgrep) for [fzf.vim](https://github.com/junegunn/fzf.vim)
Install bat `brew install bat` adds syntax highlighting to fzf.vim preview

## Ale

ALE is used to format with prettier and remove trailing whitespace. It also
lints Elixir files with credo.

### TypeScript and JavaScript

Prettier installed globally
`npm i -g prettier`

### Elixir

Credo installed in project

### TypeScript and JavaScript

Node must be installed globally

`npm i -g typescript`
`npm i typescript-langserver -g`

### Ruby

`gem install solargraph`

### Elixir

Install elixirls

Run the following after cloning
 `asdf install`
`mix deps.get && mix compile`

compile, and create release inside `release` directory

The previous steps can be done by opening an elixir file and running
`:ElixirLSCompile`
