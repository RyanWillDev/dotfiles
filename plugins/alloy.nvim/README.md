# alloy.nvim

Neovim support for the [Alloy 6](https://alloytools.org/) modeling language:

- **Filetype detection** for `.als` (`ftdetect/alloy.lua`).
- **Tree-sitter grammar** (`grammar.js`) and **highlight queries**
  (`queries/alloy/highlights.scm`) for syntax highlighting.
- **CLI runner** with diagnostics: `:AlloyRun`, `:AlloyCheck`, `:AlloyStop`,
  `:AlloyOpenGui` (`plugin/alloy.lua`, `lua/alloy/init.lua`).
- **Makefile** for installing the Alloy jar + JDK and for building the
  tree-sitter parser.

## Install

This plugin is local, loaded from `~/dotfiles/plugins/alloy.nvim` by lazy.nvim
(see `lua/user/plugins.lua`).

One-time setup:

```sh
cd ~/dotfiles/plugins/alloy.nvim
make all          # installs JDK (via brew) + alloy.jar AND builds the parser
# or piecemeal:
make install      # JDK + alloy.jar only
make parser       # tree-sitter generate + build → parser/alloy.so
```

Then either `export ALLOY_JAR=$HOME/.local/share/alloy/alloy.jar` in your shell
rc, or pass `jar` to `require('alloy').setup({ jar = '...' })`.

## Commands

| Command         | What it does                                              |
| --------------- | --------------------------------------------------------- |
| `:AlloyRun`     | Run all commands in the current `.als` file               |
| `:AlloyCheck`   | Run a single named `run`/`check` command (tab-completes)  |
| `:AlloyStop`    | Cancel a running job                                      |
| `:AlloyOpenGui` | Launch the Alloy Swing GUI on the current file            |

Output streams into an `alloy://output` split. Diagnostics are published into
the source buffer (best-effort — Alloy CLI error formats vary).

## Tree-sitter grammar

Inspired by [`bakaq/tree-sitter-alloy6`](https://github.com/bakaq/tree-sitter-alloy6),
extended to cover modules, opens, facts, predicates, functions, assertions,
commands, the full expression language, and the Alloy 6 temporal operators
(`always`, `eventually`, `after`, `before`, `historically`, `once`, `until`,
`releases`, `since`, `triggered`).

Pragmatic, not strict — produces useful parse trees for highlighting rather
than enforcing every precedence rule from the language reference.

`make build-parser` writes `parser/alloy.so`, which lands on `runtimepath`
when lazy loads alloy.nvim. `queries/alloy/highlights.scm` is picked up the
same way.

Smoke-test the grammar against the sample model:

```sh
make test-parser
```
