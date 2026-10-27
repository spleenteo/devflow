---
tags: [work, design-flow, spike]
description: "Spike on Pen libraries: how files import each other, how imported components and tokens are used, and how a component is promoted into a library, tested headless with the pen CLI."
---

## A2.2 Spike: Pen libraries, import and promotion

### Context

Shapes A and B both fail R2 (reuse) and R3 (promotion) on the same flag: the adapter's operations assume a feature file can compose from a library's components and that a component can move into a library leaving a linked instance behind. The docs show libraries only through the app's UI.

### Goal

Learn the concrete steps the adapter's `## Operations` take for compose and promote, and which of them need the user's hands in the app.

### Setup

`pen` CLI 0.3.10, headless (`pen interactive -i <file> -o <file>`, commands piped on stdin), on throwaway files in the session scratchpad. The Pencil app was closed: headless needs no app. No file of this repo was opened.

### Questions and answers

| # | Question | Answer |
|---|----------|--------|
| **X1-Q1** | How does a file become a library through the MCP or the CLI? | Nothing in the file marks it as a library: the saved JSON has `version`, `children`, `variables`, `fileToken`. Any `.pen` can be imported, a plain `site.pen` as well as `ds.lib.pen`. The `.lib.pen` suffix is the app's convention for its Libraries tab; saving under that name is all the CLI needs. The app's irreversible "Turn this file into a library" was not tested. |
| **X1-Q2** | How does a file import a library, and how is an imported component referenced? | `imports` is a document-level field (`"imports": {"ds": "ds.lib.pen"}`). **`execute` cannot set it**: `Update(document, …)` fails with "Node 'document' not found", and the API has no import function. It is set either in the app (Libraries tab, **+** beside Imported Libraries) or by writing the field into the file's JSON before opening it. Once present, components are referenced as `ref: "<alias>:<componentId>"` and tokens as `"$<alias>:<variable>"`. |
| **X1-Q3** | How is a component moved from an area file into a library while the area file keeps a linked instance? | Two calls, one per file. (1) In the library: `Insert` the component's tree as a new reusable node; ids are always regenerated, and token references written as `$ds:x` in the area file become `$x` in the library. (2) In the area file: for every instance of the local component, `Replace` it with a `ref` to `<alias>:<newId>`, remapping the `descendants` override keys from old child ids to the new ones (by child name), since `Update` cannot change `ref`; then `Delete` the local component. Verified: the override (`content: "Hello"`) survived and resolves through the library. |
| **X1-Q4** | How are a library's components and tokens listed from an importing file? | `get_app_state` lists them under "Reusable components" as `` `ds:w9Dlt`: Card ``; `GetVariables()` returns them as `ds:accent`. |
| **X1-Q5** | Can one `execute` touch two files? | No. One file per call: `filePath` per MCP call, one `-i`/`-o` per CLI session. Library changes appear in an importing file when that file is (re)opened. |

### Also observed

- A file saved by the CLI is plain, readable JSON. The Pencil MCP server states that `.pen` files are encrypted and must be accessed only through its tools; a file saved by the app was not inspected, so whether writing `imports` by hand works on it is unknown. The safe default for the adapter: ask the user to add the import in the app, and edit the JSON only on a file known to be plain.
- In one `execute`, a failing operation rolls back the whole call, including operations wrapped in `try`.
- The promotion's `Delete` of the local component is part of the move the user approved; it is not a separate deletion (R7.1 holds as long as promotion itself is approved).

### Acceptance

Met: the adapter's compose step is "read the index → open the area file → check the import exists (else ask the user to add it) → insert `ref`s to `<alias>:<id>` and use `$<alias>:<token>`". Its promote step is the two calls of X1-Q3. Only adding an import may need the user's hands in the app.

### Follow-up probe (V2 planning, 2026-10-27)

- `import_library({ path })` exists in the `pen interactive` shell (0.3.10, with `list_libraries()` and `remove_library({ id })`). `path` is resolved **against the shell's working directory**, not the edited file; the stored `imports` value is relative to the importing file (`"9": "ds.lib.pen"`).
- The alias is **generated** (here `"9"`), not chosen: read it from `get_app_state` (`9:f8ZHSL`) or `list_libraries()` (`id`). Never assume `ds`.
- A component promoted into a library that itself holds library instances: its nested `ref: "<alias>:<id>"` is rewritten to `ref: "<id>"` inside the library, like tokens (`$<alias>:x` → `$x`). Verified: the area file instance resolves the nested Button (`9:EiDUJ/9:l76wsb`) and its token (`$9:accent`).
