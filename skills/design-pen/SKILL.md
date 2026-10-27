---
name: design-pen
description: "Flow design adapter, invoked only by /flow:design by its qualified name; never for general questions."
user-invocable: false
---

# Flow: design adapter, Pen

The adapter `/flow:design` uses for `design: pen`: it says how to reach the Pen design tool and how its files are laid out. A project that prefers another tool replaces it with `design=<skill>` (`presets:` in `.flow.yml`, or `stack_presets`); nothing here is a command to the user.

## Requires

One of these, detected in this order:

1. The Pencil MCP tools: a tool of the session whose name ends in `get_app_state`, from a server whose name contains `pencil` (plugin servers are namespaced, so match the server name, not the full tool name). They read and write files with the app open.
2. The `pen` CLI, for headless work only: `command -v pen` succeeds.

Neither present: the requirement is not met. Say that the Pencil app's MCP tools or the `pen` CLI are missing, and that `/flow:design` goes on with Claude artifacts only.

## Files

- Extensions: `.pen` and `.lib.pen`.
- Role: a `.lib.pen` file is a library (the app's Libraries convention; nothing inside the file marks it). Any other `.pen` file is an area file, named after its area.
- Imports: a document-level field `imports`, `{"<alias>": "<file>"}`, with the file path relative to the importer. Set it in the app (Libraries tab, **+**): `execute` cannot set it.
- In-file note: a `note` node at the document's top level, saying what the file holds, so the file describes itself.
- Reading a file for the index (its `imports` and the names of its top-level frames): through the MCP tools, or, when only the CLI is present, through a headless `pen interactive` session.
- Files may be encrypted: never Read or Grep them. Open them only through the MCP tools or the CLI.

## Operations

Not described yet: drawing, composing from a library and promoting components are not written in this version. Say so to the user and stop after the medium choice.

## Cautions

- Save and close the files in the app before any branch switch, so unsaved work does not follow the checkout or collide with it.
- Moving a library breaks its importers' relative `imports` and image paths: move it together with its importers, or rewrite the import in the app afterwards.
- Resolve merge conflicts in the app by keeping both versions; never edit a `.pen` file by hand.
