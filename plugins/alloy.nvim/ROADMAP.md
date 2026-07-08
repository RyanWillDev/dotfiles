# alloy.nvim — roadmap

The MVP ships headless analyzer runs + lenient diagnostics. The two big asks
left on the table are an LSP and an in-editor visualizer. Notes below capture
what each would actually take so future-you (or another claude) can pick it up.

## Status

| Feature                       | State    |
|------------------------------ |----------|
| `.als` filetype detection     | done     |
| `:AlloyRun` / `:AlloyCheck`   | done     |
| Async output split            | done     |
| Lenient diagnostic parser     | done (needs tightening once tree-sitter lands and we see real error shapes) |
| `:AlloyOpenGui` escape hatch  | done — launches detached Swing GUI |
| Tree-sitter grammar           | done — Alloy 6 grammar + highlights, built via `make parser` |
| LSP                           | not started |
| Native visualizer             | not started |

---

## LSP

There is no first-party LSP for Alloy. Community attempts exist but are
sparse and unmaintained. Three plausible paths:

### Path A — write a real LSP against the Alloy Java API (recommended)

Alloy's analyzer exposes a usable parser/typechecker:

- `edu.mit.csail.sdg.alloy4compiler.parser.CompUtil.parseEverything_fromFile(...)`
  returns a `Module` (sigs, fields, predicates, functions, commands).
- Parse / type errors arrive through an `A4Reporter` callback with a `Pos`
  object (`filename`, `x`, `y`, `x2`, `y2`) — direct LSP `Diagnostic` material.

Build a small Java/Kotlin server that:

1. Depends on `org.alloytools.alloy.dist.jar` (or a slimmer core artifact).
2. Speaks LSP over stdio via [LSP4J](https://github.com/eclipse-lsp4j/lsp4j).
3. On `textDocument/didOpen` + `didChange`, runs parse-only and publishes
   diagnostics. Debounce changes (~200 ms) — parsing isn't free.
4. Optional but cheap wins from the same `Module`:
   - `textDocument/documentSymbol` — list sigs / preds / funs / asserts
   - `textDocument/hover` — show the source span of the sig/pred under cursor
   - `textDocument/definition` — Alloy's `Pos` makes this trivial
   - `textDocument/completion` — names of sigs/fields in scope

**Effort:** ~1 weekend for diagnostics + documentSymbol; another for
hover/definition/completion. The hard part is build/packaging, not the LSP
plumbing.

**Distribution:** ship a fat jar; the Makefile can pull it the same way it
pulls the analyzer. Add to the existing `lsp.lua` config:
```lua
vim.lsp.config.alloy = {
  cmd = { "java", "-jar", vim.env.ALLOY_LSP_JAR },
  filetypes = { "alloy" },
  root_markers = { ".git" },
}
vim.lsp.enable("alloy")
```

### Path B — diagnostic-only shim via `none-ls` / `efm-langserver`

Skip writing a server. Use the existing CLI output we already parse and feed
it through `none-ls.nvim` as a "diagnostics source." Works today; gives you
red squigglies on save. **No hover, completion, or goto-def** — those need
the AST and the CLI doesn't expose it.

Cheap; mostly a config change. Worth doing as a stepping stone.

### Path C — adopt an existing community LSP

Periodically check:
- `alloy-lsp` forks on GitHub
- Any LSP shipped inside the official `org.alloytools.alloy` repo (none as
  of v6.2.0, but the project has been waking up).

Lowest effort if something usable exists; highest risk of bit-rot.

### Decision points before starting

- JVM vs non-JVM server? JVM is the only one that gets the real typechecker.
- Single-file vs project-aware? Alloy has `open` directives — proper LSP
  needs to follow them to resolve symbols across files.
- Incremental parsing? Probably not worth it; Alloy files are small.

---

## In-editor visualizer

Alloy's visualizer is a Swing GUI that renders instances as relation graphs.
There's no headless render mode that emits an image. Three plausible paths,
in increasing ambition:

### Path A — Sterling (browser-based Alloy visualizer)

[Sterling](https://github.com/atdyer/sterling) is an existing JS visualizer
that consumes Alloy instance XML. The flow:

1. Tell the analyzer to emit instance XML (`A4SolutionWriter.writeInstance`
   or the CLI's `-o file.xml` if available in your version).
2. POST it to a local Sterling server (or open Sterling pointed at the XML).
3. From nvim, just `:!open http://localhost:.../?instance=...`.

Lowest engineering cost for a *good* visualization. Loses the "stays in
nvim" property — viz pops in browser, not a buffer.

### Path B — static image rendered into nvim

1. Capture instance as XML.
2. Convert XML → Graphviz DOT (small Lua/Python script — atoms are nodes,
   tuples in relations are edges, label edges with relation name).
3. Run `dot -Tpng` (or `-Tsvg`) to produce an image.
4. Display via [`image.nvim`](https://github.com/3rd/image.nvim) using the
   Kitty/Ghostty graphics protocol.

Pros: stays in nvim, no extra server. Cons: static — no instance navigation,
no theming, the Alloy GUI's careful layout heuristics are lost. Looks
clearly worse than Alloy's native viz for non-trivial models.

**Requires:** terminal that supports Kitty graphics (Kitty, WezTerm,
Ghostty). Confirm your daily-driver terminal first or this path is moot.

### Path C — embedded Swing in a floating buffer

Not realistically achievable. Swing can't render into a terminal. Skip.

### What's needed before starting

- Pick A or B. A is the better investment unless "must stay in nvim" is
  load-bearing.
- For B: confirm Kitty graphics availability; commit to image.nvim and its
  dependency chain (magick, etc.).
- Either way, the analyzer needs to be invoked with an instance-export
  flag. The current CLI's `exec` subcommand may or may not expose this
  cleanly — first task is checking the v6.2.0 CLI options.

---

## Smaller follow-ups (not blocked on the big two)

- **Tighten the diagnostic parser** once tree-sitter is in and we see real
  error output shapes from the v6.2.0 CLI. Current regex catches the common
  case; the parser is intentionally lenient and silent on misses.
- **Per-command output buffers** — today everything writes to a single
  shared `alloy://output`. Fine for one user; would need keying for
  parallel runs.
- **Result summary line** — parse "Instance found / No instance found" and
  surface as a one-line `:echo` so you don't have to read the split.
- **Makefile target for the LSP jar** — mirror the analyzer install once an
  LSP exists.
