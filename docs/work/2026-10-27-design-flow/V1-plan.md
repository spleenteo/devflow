---
tags: [work, design-flow, plan]
description: "Plan of V1 of the design-flow work: the /flow:design skill by hand (place, index, medium), the flow:design-pen adapter, the index template, and the stack_presets and dependencies notes."
---

# V1 — The skill by hand: place, index, medium

**Mandate**: [slices.md § V1](slices.md) (criterion: [frame.md](frame.md); Pen mechanics: [spike](spike-pen-libraries.md); adapter notes: [shaping.md](shaping.md) § Adapter implementation notes). **Guidelines**: [development-guidelines.md](../../development-guidelines.md). **Lessons**: none yet (no `lessons.md` in the work dir). **Execution rules**: the executor's policy, `agents/executor.md` in the plugin; test level `none`. Never touch `docs/design/flow_home-page.pen`.

## The slice, decided here

- `skills/design/SKILL.md` holds the by-hand mode only; the called mode is written in V3, so this slice adds no section for it.
- Description: *"Flow's design step, run by Flow's conductors, or by hand with /flow:design. Sets up the project's docs/design/ folder and its index, and proposes the medium for a work's design step."* No words like landing, page, UI, mockup, draw, artifact, so a general "draw a landing page" does not load it.
- The only tool word allowed in `skills/design/SKILL.md` is the shipped-adapter list line (`pen` → `flow:design-pen`), the same way `/flow:dev` fixes its shipped presets; no extension, file format, MCP or CLI name.
- Place: `docs/design/` at the repo root (`git rev-parse --show-toplevel`); outside a repo, V1 says it works in repos only and stops (the project's home is V4); `root` in `.flow.yml` is not read for it (ruling at impact).
- First-use search: files with the adapter's extensions (its `## Files`), outside `docs/design/`, `.git/`, `node_modules/`; moved with `git mv` when tracked, `mv` otherwise; nothing committed.
- Index rows for moved files: role from the adapter's naming rule; contents and imports read as the adapter's `## Files` says when its tool requirement is met, else asked from the user in the same message as the move list.
- A saved artifact HTML gets an index row with role `artifact`, so the index lists every file in `docs/design/` (see Deviations).
- `## Operations` in the adapter is a stub stating that drawing is not described yet: on a confirmed design file, `/flow:design` says so and stops after the medium choice (compose is V2).
- Tool detection for Pen: a session tool whose name ends in `get_app_state` from a server whose name contains `pencil` (plugin servers are namespaced); else `command -v pen` succeeds (headless only). Neither: requirement not met, artifacts only.

## Tasks

### T1 — Index template
- **What**: create the template for `docs/design/README.md`: `# Design files` heading; one paragraph (what the folder holds, that `/flow:design` keeps the table current, that each file also describes itself inside, that names are code spans); a table `| File | Role | Contents | Imports |` with one placeholder row `` | `<file>` | library, area: <name>, or artifact | <what it holds> | `<library file>`, or none | ``. No Markdown links anywhere; no frontmatter (as `skills/dev/impact-lenses.template.md`).
- **Files**: `skills/design/design-index.template.md` (new).
- **Verified**: `rg -c '\]\(' skills/design/design-index.template.md` prints nothing (exit 1); `rg -n '^\| File \| Role \| Contents \| Imports \|$' skills/design/design-index.template.md` prints one line.
- **Done**: committed, `Add the design index template`.
- **Interfaces**: produces the path `${CLAUDE_SKILL_DIR}/design-index.template.md` and the four columns T3 fills.

### T2 — The Pen adapter (critical)
- **What**: frontmatter `name: design-pen`, `description: "Flow design adapter, invoked only by /flow:design by its qualified name; never for general questions."`, `user-invocable: false` (as `skills/stack-astro/SKILL.md`). Heading `# Flow: design adapter, Pen`, one line on what it is and that a project replaces it with `design=<skill>`. Sections in this order:
  - `## Requires`: the Pencil MCP tools or the `pen` CLI for headless work, with the detection of the decisions above; what to say when neither is present.
  - `## Files`: extensions `.pen` and `.lib.pen`; `.lib.pen` is a library (the app's Libraries convention, nothing inside marks it), any other `.pen` an area file; `imports` is a document-level field `{"<alias>": "<file>"}`, set in the app (Libraries tab, **+**) because `execute` cannot set it; the in-file note is a `note` node at the document's top level; reading a file for the index: through the MCP tools, or through a headless `pen interactive` session when only the CLI is present; its `imports` and top-level frame names. Files may be encrypted: never Read or Grep them.
  - `## Operations`: the stub of the decisions above, one paragraph.
  - `## Cautions`: save and close files in the app before any branch switch; moving a library breaks its importers' relative `imports` and image paths, so move it with its importers or rewrite the import in the app; merge conflicts resolved in the app by keeping both versions, never by hand.
- **Files**: `skills/design-pen/SKILL.md` (new).
- **Verified**: `claude plugin validate .` passes with only the guidelines' expected warnings; `rg -n '^## ' skills/design-pen/SKILL.md` prints exactly Requires, Files, Operations, Cautions in that order.
- **Done**: committed, `Add the flow:design-pen adapter`.
- **Interfaces**: produces the contract T3 states (the four section names) and the extensions and role rule T3 reads at run time.

### T3 — The /flow:design skill, by hand (critical, depends on: T1, T2)
- **What**: frontmatter `name: design` and the description above, no `user-invocable` key. Body, in order:
  1. The process line, worded as in `skills/brainstorm/SKILL.md:8`.
  2. `## Place`: `docs/design/` as decided; `root` does not move it.
  3. `## Adapter`: `design: <tool>` in `.flow.yml`; resolution, first hit wins: `presets:` pair `design=<skill>`, then `${user_config.stack_presets}` pair `design=<skill>` (empty or beginning with `${` is unset), then the shipped list (`pen` → `flow:design-pen`), fixed here, never looked up in the skill listing. Invoked with the Skill tool by qualified name. No `design:` in `.flow.yml`: no adapter, artifacts only, saying so. No mapping and nothing shipped, or a mapped skill missing from the session: say which, never fall back to the shipped one, artifacts only. Then read the adapter's `## Requires`; unmet: artifacts only, saying so. The contract: every adapter fills `## Requires`, `## Files`, `## Operations`, `## Cautions`; what each holds, one line each.
  4. `## First use`: when an adapter resolves, search for its extensions as decided; and check `docs/design/README.md`. One message: the moves (from → to), the caution to save and close those files in the design tool, and the index offer from `${CLAUDE_SKILL_DIR}/design-index.template.md`, with the questions for unreadable rows. Nothing moves or is written before an ok; a declined index is not created. Without an adapter: only the index check.
  5. `## Medium`: interactive or exploratory → Claude artifact; static (a page, a screen, a deck) → design file; propose one with its reason, the user confirms or changes. Artifacts only in the four cases of § Adapter (no `design:`; nothing resolves; mapped skill missing; `## Requires` unmet), and the message names which. A Claude artifact: the session's artifact tool when present, and always its source as one self-contained HTML file (inline CSS and script, no external fetch) under `docs/design/`, name agreed with the user, plus its index row; no artifact tool: the HTML file alone. A design file: follow the adapter's `## Operations`.
  6. `## Exit`: writes, never commits, says so and lists the files written or moved.
- **Files**: `skills/design/SKILL.md` (new).
- **Verified**: `claude plugin validate .` passes as in T2; `rg -n -i -w 'pen|pencil|figma' skills/design/SKILL.md` prints only the shipped-list line; the `description:` line of `skills/design/SKILL.md` gives no match for `rg -n -i -w 'landing|page|ui|mockup|draw|sketch|wireframe|artifact'`; `rg -n '\]\(' skills/design/SKILL.md` prints nothing.
- **Done**: committed, `Add the /flow:design skill, by hand`.

### T4 — stack_presets also takes design (critical)
- **What**: in `userConfig.stack_presets.description`, say it takes a skill per stack and for the design tool: `"Skill to use per stack, and for the design tool, as comma-separated pairs stack=skill or design=skill. Example: astro=my-stacks:astro, design=my-design:design-sketchpad"`. Nothing else in the file changes.
- **Files**: `.claude-plugin/plugin.json`.
- **Verified**: `jq -r '.userConfig.stack_presets.description' .claude-plugin/plugin.json` prints the new text; `claude plugin validate .` passes as in T2; `git diff --stat .claude-plugin/plugin.json` shows 1 line changed.
- **Done**: committed, `Let stack_presets map the design adapter`.

### T5 — Dependencies note
- **What**: below the table, after the "Per-stack rows" paragraph, one paragraph: the design tool (the Pencil app or its `pen` CLI for `design: pen`) is not a skill and is not listed here; `/flow:design` checks it through its adapter's `## Requires`, and `install.sh` does not.
- **Files**: `dependencies.md`.
- **Verified**: `rg -c '^\|' dependencies.md` prints 6 (table untouched); `rg -n 'install\.sh' dependencies.md` prints the new line; `git diff --stat dependencies.md` shows only insertions.
- **Done**: committed, `Note that the design tool is checked by its adapter`.

## Order

- T1, T2, T4, T5 in parallel (separate files). T3 after T1 and T2.
- The slice's Done demos need `/flow:design` run in a session, which an executor cannot do: the conductor runs them at the close, after T3. Setup: a `git init` repo in the session scratchpad; two `.pen` files created headless with `pen interactive` (one `*.lib.pen`) at its root; a fresh `claude -p --plugin-dir /Users/spleenteo/Sites/me/flow` session per variant (`design: pen` with `pen` on PATH; no `design:`; `design: figma`; a general "draw a landing page" request without `/flow:design`); `git status --short` shows nothing committed.

## Deviations from the mandate

- Index role gains `artifact` beside library and area: the mandate saves every artifact's HTML under `docs/design/`, and an unindexed file there would break R1.1.
- Outside a repo, V1 stops instead of using the current directory (review finding).
- "No Pen-specific word" in `skills/design/SKILL.md` is read as no Pen mechanics: the shipped-adapter list line names `pen` and `flow:design-pen`, which the mandate's own resolution bullet requires.
