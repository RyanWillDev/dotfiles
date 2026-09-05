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

### Claude Code

Everything lives in `claude/` and gets symlinked into `~/.claude/`:

```
ln -s ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/dotfiles/claude/settings.json ~/.claude/settings.json
```

Skills and plugins are symlinked individually (one link per directory, not the
whole `skills/` dir, so machine-local skills can coexist):

```
for s in ~/dotfiles/claude/skills/*/; do
  ln -s "${s%/}" ~/.claude/skills/"$(basename "$s")"
done
```

The `expert-lsp` entry in `claude/skills/` is a Claude Code plugin, not a
skill — it registers [Expert](https://expert-lsp.org) as the Elixir language
server. Claude Code auto-loads any directory under `~/.claude/skills/` that
contains `.claude-plugin/plugin.json` (shows up as `expert-lsp@skills-dir` in
`/plugin list`). It needs the binary on `$PATH`:

```
brew install expert
```

Claude Code's LSP client never answers `client/registerCapability`
([claude-code#32595](https://github.com/anthropics/claude-code/issues/32595),
closed not-planned), and Expert blocks on it before starting — so the plugin
launches Expert through `expert-shim` (in the plugin dir), a stdio proxy that
answers those requests on the client's behalf. It must be symlinked onto
`$PATH`:

```
ln -s ~/dotfiles/claude/skills/expert-lsp/expert-shim ~/.local/bin/expert-shim
```

###
`cp .gitconfig ~/.gitconfig`

## Requirements

### Neovim

Install [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter/tree/master/cli) — required by nvim-treesitter (main branch) to compile parsers from source:
`brew install tree-sitter-cli`

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

### zk

Install and build [zk](https://github.com/zk-org/zk?tab=readme-ov-file#build-from-scratch) for notes

### Alloy

The `alloy.nvim` plugin (in `plugins/alloy.nvim/`) runs the Alloy analyzer
against `.als` files. Two pieces are needed on a fresh machine:

1. **JDK 11+** — Temurin via Homebrew cask:
   ```
   brew install --cask temurin
   ```
   If `brew install --cask` hangs silently with no download progress, it's
   stuck on a Spotlight query for Xcode — clear it with
   `pkill -f "mdfind.*Xcode"` and brew will continue.

2. **Alloy jar** — pulled by the plugin's Makefile (no sudo needed):
   ```
   cd ~/dotfiles/plugins/alloy.nvim && make install-jar
   ```
   This downloads `org.alloytools.alloy.dist.jar` to
   `~/.local/share/alloy/alloy.jar`.

The `ALLOY_JAR` env var is already exported in `.zshrc`. Verify with
`make check` from the plugin dir; `make doctor` runs the analyzer's help
output as a smoke test. Tree-sitter grammar is built via `make parser`.
