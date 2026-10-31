---
name: whiteboard
description: Run a turn-based whiteboarding session with Ryan on a live local Excalidraw canvas, for system design, ideation, or both. Start with a topic or board path; end with `done`.
disable-model-invocation: true
argument-hint: "<topic> | <path/to/board.excalidraw> | done"
---

# Whiteboard

Ryan draws in the browser at http://127.0.0.1:3031; you draw through the `excalidraw` MCP tools.
The two of you are **pairing** at the board: you take turns, you think out loud in small moves, and the
pen you hold only touches your own marks. Ryan's elements change only when he approves a change.

The canvas lives in memory and is lost on restart, so the saved board file is the only durable copy.

## Steps

### 1. Start the session

1. **Check the tools.** If no `mcp__excalidraw__*` tools are loaded, stop and give Ryan this to run, then
   restart Claude Code:
   ```
   claude mcp add excalidraw --scope user -e EXPRESS_SERVER_URL=http://127.0.0.1:3031 -e PORT=3031 \
     -e HOST=127.0.0.1 -e EXCALIDRAW_EXPORT_DIR=$HOME -- npx -y mcp-excalidraw-server@2.1.2
   ```
2. **Resolve the board path.**
   - A path argument: use it.
   - A topic, inside a `/task` session: `~/tasks/<slug>/boards/<topic-kebab>.excalidraw`.
   - A topic, otherwise: `~/whiteboards/<YYYY-MM-DD>-<topic-kebab>.excalidraw`.
3. **Clear the way.** `describe_scene`. If the canvas holds anything that isn't this board, `export_scene` it
   to `~/whiteboards/<YYYY-MM-DD>-unsaved-<HHMM>.excalidraw` first and tell Ryan where it went.
4. **Load.** If the board file exists, `import_scene` it with `mode: "replace"`; otherwise `clear_canvas`.
5. Tell Ryan the URL and the board path, then hand him the pen: "Your turn."

Done when the canvas shows exactly this board, any previous canvas content is saved to a file, and Ryan
has the URL and path.

### 2. Take a turn (each time Ryan says "your turn")

1. **Save first:** `export_scene` to the board path, so Ryan's latest drawing is on disk before you touch it.
2. **Read** with `describe_scene` and `get_canvas_screenshot` together. Describe gives ids, positions, and
   connections; the screenshot shows which label sits in which of Ryan's shapes (describe lists his labels
   as separate text elements).
3. **Restate** what changed since your last turn in one or two lines of chat.
4. **Pick 1–3 moves** from the move list below, the ones that most advance what Ryan is working out.
   Read the board's conventions before drawing (see Conventions).
5. **Draw** them using the Marks rules, in one `batch_create_elements` call where possible.
6. **Save:** `export_scene` to the board path, and `export_to_image` (`format: "png"`) next to it.
7. **Hand back:** one line per mark (what and why), ending with "Your turn."

Done when every element you added this turn has a `c<turn>-` id and is a faded proposal or a `Q:`/`Noted:`
note, the board file and PNG are both written, and the handback ends with "Your turn."

### 3. Act on Ryan's replies

| Ryan says | You do |
|---|---|
| "keep it" / yes to a proposal | Set the proposal's `opacity` to 100. For a proposed change to his element, apply the change to his element and delete the faded copy. |
| "drop it" / no | Delete the proposal. |
| Asks you to edit his elements | `get_element` each one and note its prior fields before making the edit, so undo can restore them. |
| "undo that" | Revert only what you touched in your last turn: delete its `c<turn>-` elements, and restore prior fields on any of his you edited. |

Each of these is a turn: finish with step 2's save and handback.

Avoid `restore_snapshot` for undo. It replaces the whole scene and wipes anything Ryan drew after the
snapshot.

### 4. End the session (`/whiteboard done`)

1. `export_scene` and `export_to_image` (`png`) to the board path.
2. Inside a `/task`: append each `Noted:` note to that task's `DECISIONS.md` as an entry, in the task
   skill's format.
3. Tell Ryan the board and PNG paths and how many decisions were recorded.

Done when both files are written, every `Noted:` note is in `DECISIONS.md` (task sessions only), and Ryan
has the paths.

## Reference

### Marks

Your marks are told apart from Ryan's by opacity and text prefix, because he uses colour, shape, and arrow
style for meaning.

- **Proposal**: a new element or a change to one of Ryan's, drawn at `opacity: 40` and otherwise exactly as
  it would look for real, following the board's conventions. A proposed move or edit is a faded copy in the
  new position or form.
- **Question**: a note starting `Q:`, pinned next to the element it's about, with an arrow to it if the
  placement is ambiguous.
- **Record**: a note starting `Noted:`, for a decision or summary Ryan has agreed to.
- Notes all use one style: `backgroundColor: "#e9ecef"`, `strokeColor: "#868e96"`, `roughness: 0`.
- Ids: `c<turn>-<short-name>` (e.g. `c3-cache`), so every mark traces to the turn that made it.
- Use `"text"` for a shape's label, and `startElementId`/`endElementId` to bind arrows; the tool routes
  them to the shapes' edges. Place new marks in open space so they don't overlap Ryan's elements.

### Conventions

Ryan's visual language changes from board to board. Typical uses: colour and shape for groupings or
"same kind", dashed arrows for async, solid arrows for sync calls and dependencies. Work out each board's
conventions from what's drawn, draw your proposals in them, and ask with a `Q:` note when a convention is
ambiguous. Once they're clear, offer to add a small legend.

### Moves

Read the board to pick the kind: labelled shapes joined by arrows want design moves; loose notes want
ideation moves. A session can move between the two.

**Design**
- Trace one request end to end and mark where it breaks or goes unexplained.
- Ask about failure: what happens when this call times out, this queue backs up, this store is down.
- Question an arrow whose direction, sync/async nature, or payload is unclear.
- Propose a missing piece (cache, queue, auth boundary, retry) as a faded shape.

**Ideation**
- Propose a grouping of related notes, using Ryan's grouping convention, faded.
- Name a theme a cluster shares.
- Propose merging two notes that say the same thing.
- Add an option the board is missing, especially one that contradicts the current lean.
- Ask what would rule an option out.

### Boundaries

Keep boards local. Share by handing over the exported file; `export_to_excalidraw_url` uploads the board
to excalidraw.com, so leave it unused.
