---
shaping: true
tags: [work, design-flow, slices]
description: "Slices of the design-flow work: shape A cut into four demo-able increments, from the by-hand skill to the /flow:dev and /flow:project hooks."
---

# Design flow — Slices

Mandate: [shaping.md](shaping.md), shape A. Criterion: [frame.md](frame.md). Decisions: [skill plus adapter](../../decisions-log/2026-10-27-design-is-agnostic-skill-plus-tool-adapter.md), [design runs as a dev phase](../../decisions-log/2026-10-27-design-runs-as-a-dev-phase.md). Pen mechanics: [spike](spike-pen-libraries.md).

Every slice is demonstrated in a throwaway repo outside this one (session scratchpad or `/tmp`, never committed) and, from V2 on, in the user's test bed project. The test bed is named only in conversation, never in a shipped file.

| Slice | Parts | Demo in one line |
|---|---|---|
| V1 | A1.2, A1.3, A1.4, A2.1, A2.3, A2.4, A4 | `/flow:design` by hand sets up `docs/design/` and proposes the medium |
| V2 | A1.5, A1.6, A1.7, A2.2 | Two features in a row: the second reuses a component the first promoted |
| V3 | A1.1, A3.1, A3.2, A3.3 | A `/flow:dev` work with a UI goes through `phase: design` and resumes there |
| V4 | A5, plus the plugin's own docs | A `/flow:project` slice gets `/flow:design` proposed only when an artifact fits |

---

## V1 — The skill by hand: place, index, medium

**In**
- `skills/design/SKILL.md`, tool-agnostic (R4.1): the by-hand mode only (A1.2). Writes, doesn't commit, says so. No `user-invocable` key (true is the default, and no existing skill writes it). Description in the brainstorm/grill pattern, so it doesn't take over general design requests: *"Flow's design step, run by Flow's conductors, or by hand with /flow:design. …"*.
- First use (A1.3, R8.2): looks for design files outside `docs/design/` (by the resolved adapter's extensions; skipped when no tool resolves) and for a missing `docs/design/README.md`; one message listing the moves and offering the index from the template; moves only on an ok, after asking to close files open in the app.
- `docs/design/` is fixed, whatever `root` says (settled: never split the paths; `root` governs Flow's own folders, not the project's design files).
- Index template `skills/design/design-index.template.md` (A4, R8.3): table with file, role (library or area), contents, imported libraries. File names as code spans, never Markdown links, so the Gate's link check stays green.
- Medium choice (A1.4, R6): proposes a Claude artifact or a design file with its reason. **A Claude artifact** is produced with the session's artifact tool when one is available, and its source is always also saved as a self-contained HTML file under `docs/design/`, so it doesn't stay closed inside Claude; with no artifact tool, the HTML file alone (as `flow:brainstorm`'s visuals). Artifacts only (R4.3) when `design:` is absent, its adapter doesn't resolve, or the adapter's tool requirement isn't met in the session; the message says which.
- Adapter resolution (A2.4, R4.2): `design: <tool>` in `.flow.yml`; adapter by `presets: [design=…]` → the `stack_presets` user config (`design=…`) → the shipped adapter, from a fixed list (`pen` → `flow:design-pen`), never looked up in the skill listing. A tool with no mapping and no shipped adapter, or a mapped adapter not in the session: say so, never fall back to the shipped one, artifacts only.
- `skills/design-pen/SKILL.md`, `user-invocable: false`, description in the presets' pattern with no tool keywords: *"Flow design adapter, invoked only by /flow:design by its qualified name; never for general questions."* Sections: `## Requires` (A2, R4.3: the Pencil MCP tools, or the `pen` CLI for headless work; how to detect them), `## Files` (A2.1: `.pen` vs `.lib.pen`, `imports`, the in-file note as a `note` node), `## Cautions` (A2.3: save and close before a branch switch; moving a library breaks its importers' relative imports), and the adapter implementation notes from `shaping.md`.
- The fixed section list every adapter fills (`## Requires`, `## Files`, `## Operations`, `## Cautions`), stated in `/flow:design` so a project's own adapter knows its contract. `## Operations` is a stub in V1.
- `.claude-plugin/plugin.json`: the `stack_presets` description says it also takes `design=<skill>`.
- `dependencies.md`: a note outside the table that the design tool is checked by `/flow:design` through its adapter, not by `install.sh`.

**Out**
- Compose and promote (V2). The called mode and every conductor change (V3, V4).

**Done**
- `claude plugin validate .` passes with the two new skills.
- In a throwaway repo with `design: pen` and two `.pen` files at its root, `/flow:design` by hand lists both for a move, offers the index, and after the ok leaves `docs/design/` with the files and a filled `README.md`; nothing is committed.
- In the `design: pen` repo, asked for a landing page, `/flow:design` proposes a design file and says why.
- The same repo without `design:`: asked for a landing page, `/flow:design` proposes a Claude artifact and says why.
- The same repo with `design: figma` and no mapping: `/flow:design` says no adapter resolves and offers artifacts only.
- A read-through of `skills/design/SKILL.md` finds no Pen-specific word; a general "draw a landing page" request, without `/flow:design`, loads neither new skill (descriptions read against the presets' and brainstorm's).

**Gotchas**
- Moving a `.pen` file breaks relative `imports` and image paths in files that point at it: the adapter's `## Cautions` says to move a library together with its importers, or to rewrite the import in the app.

**Deviations found while planning V1**
- The index's Role column also accepts `artifact`, next to library and area: each artifact's HTML lands in `docs/design/`, and a file there without an index row would break R1.1.
- "No Pen-specific word" in `skills/design/SKILL.md` reads as "no Pen mechanics": the one line naming the shipped adapter (`pen` → `flow:design-pen`) stays, as the resolution bullet requires.

**V1 — done on 2026-10-27**
- Five tasks, one fix round: T3's first draft gated the file search on the design tool being present (moving needs only `mv`), and didn't read the adapter's `## Cautions` before a move; fixed in one round.
- Demos run with `claude -p --plugin-dir <this repo>` in scratchpad repos, `--continue` for the second turn: first use moved two files and wrote the index; `design: pen`, no `design:` and `design: figma` each proposed the right medium with its reason; a general "draw a landing page" loaded neither skill; nothing committed anywhere.
- Observed: the index rows were written in the conversation's language (Italian), not the folder's. V2 adds the rule, as `flow:brainstorm` has it: write in the language of the folder's other documents.
- Ruling: fix commit 4bb38e6 keeps a non-standard subject (the conductor dictated it).

## V2 — Compose and promote, by hand

**In**
- Index rows and in-file notes are written in the language of the folder's other documents, whatever the conversation's (V1 observation).
- `/flow:design` by hand: reads the index, picks the file, asks the adapter to compose the screen from the library's components and tokens; proposes a new component when one is missing (A1.5, R2).
- Promotion on the user's approval (A1.6, R3): the adapter's two calls, then the index row and the in-file note updated.
- Safety rules written into the skill (A1.7, R7.1–R7.3): no delete unasked (the promotion's removal of the local component is part of the approved move), consent on every change of direction, exports only on request, checked by the file's existence.
- `flow:design-pen` `## Operations` (A2.2): open; list components and tokens; compose with `ref: "<alias>:<id>"` and `$<alias>:<token>`; a missing import asked of the user in the app; promote in two calls with the override remap by child name; write the note; export with the check.

**Out**
- Any conductor change. Bootstrap from code. Alignment.

**Done** (this is the criterion's Measure)
- In a test bed (a throwaway copy in the session scratchpad; the user repeats it in their own test project), with a design-system library and an area file: feature 1 is drawn by hand with `/flow:design`, one new component is approved and promoted; the library holds it, the area file uses a linked instance, the index and the note say so.
- Feature 2, in a new session: `/flow:design` finds the promoted component through the index and uses it without redrawing it.
- No file, frame or component disappeared that the user didn't approve.
- An export the user asks for is produced and its file checked; no export happens unasked; moving a change from design to code (or back) is proposed, never done silently.

**Gotchas**
- One file per `execute` call: promotion is never atomic. If the second call fails, the library has the component and the area file still has its local copy; the skill says so and offers to finish, never retries blindly.
- A failing operation rolls back the whole `execute` call, `try` included.

**Deviations found while planning V2**
- With only the `pen` CLI present, the adapter adds a missing import itself with `import_library` on the user's ok (listed in `pen interactive --help`, 0.3.10), instead of asking in the app; the test bed's setup exercises it first.
- When no area file fits the screen, `/flow:design` proposes a new one.
- The description of `/flow:design` also says it composes from the design system and promotes approved components; the trigger-word check still holds.

**V2 — done on 2026-10-27**
- Two tasks and a close fix. Probing `import_library` and nested promotion before T1 paid off: the alias is generated (`9`, `B`), never `ds`, and the plan would have hardcoded it.
- The Measure, shown headless in a scratchpad bed: feature 1 promoted Price Row; feature 2, in a new session, reused it six times and made no new component. The user repeats it with the app in their test project.
- The demos found three defects the reviews missed: an API shorthand `U(...)` that doesn't exist; a commands file left in the repo root; export folders resolving from the `.pen` file. All fixed.
- Not demoed: the app's MCP path (no app in the demo sessions), nested refs from a promoted component (covered by the probe, not by a session).

## V3 — The `/flow:dev` phase

**In**
- `/flow:design` called mode (A1.1): receives the criterion, the work's `shaping.md` path and the screens to draw; returns the files touched (design files, or the artifact's HTML source) and the requirement corrections; doesn't commit.
- `skills/dev/SKILL.md` Step 3 table: a `design` row between `breadboard` and `slicing` (A3.1, R5.1), offered when the work touches a UI and `design:` is set or an artifact fits, with the medium proposed by `/flow:design`; skipped with a reason otherwise, and skipped when the work has no `shaping.md` (the corrections need a target; `/flow:design` by hand stays available); `phase: design` in `STATUS.md` (R5.2).
- The conductor writes the returned corrections into `shaping.md` and closes the phase by Step 5 (A3.2, R5.3): `design` added to Step 5's list, and the corrected `shaping.md` goes through the fidelity check again.
- The criterion travels with the `/flow:design` invocation (the "criterion travels" paragraph names it).
- Resume table: at `phase: design`, `shaping.md` and `docs/design/README.md` are reloaded (an exception to "never reloaded").
- `.flow.yml` key list in `skills/dev/SKILL.md`: `design`, and `presets` described as per stack or `design`.
- Branch-switch reminder (A3.3, R7.4): before the phase, and in `shared/work.md` at every switch the conductors make (§ Finding open works, § Closing a work step 4, § Upgrade, Writing, repo): when `docs/design/` holds files, ask the user to save and close them first.
- `shared/work.md` § `STATUS.md` (repo): `design` added to the `phase:` values.
- The short-path example and the lifecycle table of `skills/dev/SKILL.md` name `/flow:design` as a tool, like `flow:brainstorm`.

**Out**
- `/flow:project` (V4). A per-slice design check (out of the first release).

**Done**
- In a throwaway repo with `design: pen` and a work whose shaping describes a screen: `/flow:dev` offers the design phase after shaping, `STATUS.md` shows `phase: design`, the corrections land in `shaping.md`, the phase commits and stops.
- The same session interrupted mid-phase: a new `/flow:dev` resumes at `phase: design` with `shaping.md` and the index reloaded.
- A work with no UI: the phase is skipped, and the message says why.
- A repo with no `design:` key and a work with a UI: the phase is offered with a Claude artifact as the medium, and the reason is given.

**Deviations found while planning V3**
- On accepting the design phase, the conductor commits `STATUS.md` alone with `phase: design` before calling `/flow:design`, so an interrupted session resumes there (Step 5 moves `phase:` only at a close).
- The offer names the medium early, by `/flow:design`'s § Medium rule (interactive or no `design:` → artifact; static with `design:` → design file); the skill keeps the final say.
- The root is not passed to `/flow:design`: `docs/design/` is fixed (ruling at impact) and the absolute `shaping.md` path places the work.

**V3 — done on 2026-10-27**
- Three tasks, two fix rounds by the conductor (T2: the close commit must carry `STATUS.md` at `phase: slicing` with its Log line; T3: lead-ins around the reminder), and one close fix in V2's adapter.
- Shown in four scratchpad beds: a static screen with `design: pen` gets a design file and the save-and-close reminder; no `design:` gets a Claude artifact; a CLI flag skips the phase with its reason. The phase opens with its own commit, an interrupted session resumes at `phase: design` and reloads `shaping.md` and `docs/design/README.md`, and a requirement found by looking at the screen lands in `shaping.md` in English, checked again for fidelity, in one close commit.
- The demo also ran V2's compose on new ground and found the adapter's override path inside a library instance wrong (it needs the alias): fixed in the adapter.
- Not demoed: the app's MCP path; a work with a `breadboard.md`.

## V4 — `/flow:project`, and the plugin's own docs

**In**
- `skills/project/SKILL.md` `step: plan`: an action can read *"/flow:design: <artifact>"*, proposed only when the slice's context calls for an artifact (A5, R5.4); the user runs it by hand, like a `/flow:dev` row, and the row closes when the user approves the artifact; files under `<home>/docs/design/` (R8.1). Files table (`:38`) gains `docs/design/`.
- Where `design:` lives for a project: a `design:` field in the project's `STATUS.md` frontmatter (ruling, see below), added to the project template in `shared/work.md` § `STATUS.md`.
- The plugin's docs, required by the guidelines' Releases section (a merge into `main` is a release, so the docs ship with the code):
  - `README.md`: the `/flow:dev` row and its phases, the Definition and Resume bullets, the presets section (`design=` is not a stack), the "What lands in a project" tree (`docs/design/`), the yaml example (`design:`), the `stack_presets` row, the lists of skills that take over process.
  - `docs/architecture.md`: the intro's skill list, the non-invocable list, the lifecycle diagram, the resume line and phase list, the "What a project holds" table and diagram (`docs/design/`, `design:`), the skill directory list, `stack_presets`.
  - `site/index.html`: the phases strip shows the optional design phase if it shows breadboard; the grid's column count follows.
  - `docs/development-guidelines.md` Naming: `flow:design-<tool>` among the non-invocable examples.
- `skills/brainstorm/SKILL.md`: one line that its visuals stay sketches for the dialogue, and real artifacts go through `/flow:design`.
- Found at V3's close: `/flow:design` § Place stops outside a repo and § Adapter reads `design:` only from `.flow.yml`. V4 extends both for a project home (a folder whose `STATUS.md` has `project:`): files under `<home>/docs/design/`, `design:` from that `STATUS.md`.

**Out**
- Changelog and version (the work's close, through `flow:docs`).

**Done**
- In a throwaway project folder, a slice whose action is a deck gets `/flow:design` proposed with a medium and a reason; a slice of phone calls does not.
- With `design: pen` in the project's `STATUS.md`, the deck action proposes a design file, written under `<home>/docs/design/`.
- The gate from `docs/development-guidelines.md` is green: validate, old-names check, links check.

**Deviations found while planning V4** (rulings by the conductor, user away; open to overrule at the close)
- `/flow:design` takes `Home: "<absolute path>"` by hand (quoted, vault paths hold spaces), else the cwd when its `STATUS.md` has `project:`, else the repo root; `/flow:project` gives the user that line to type.
- `design:` and `presets: [design=…]` live in the top home's `STATUS.md` (`parent: null`); a sub-project's design files live in that home too. Adapter chain in a project home: those `presets:` → `stack_presets` → the shipped list (R4.2 holds per project).
- The README gains a `/flow:design` row in Usage and a paragraph on `/flow:project`'s design rows; `docs/architecture.md` a sentence in its `/flow:project` paragraph. In a project home the design files ride the slice's close commit, only when the home is under version control.
- The site has no Breadboard item: the design phase gets its own item (05), Slice becomes 06, six columns.
- `skills/design-pen/SKILL.md` says "the base" instead of "the repo root"; the site grid's column count lives in `site/styles.css`.

**V4 — done on 2026-10-27**
- Eight tasks; the reviews found no high, the conductor fixed every medium and most lows by hand.
- `/flow:design` now works in a project home: `Home: "<path>"`, else the working directory with a project `STATUS.md`, else the repo root; `design:` and `presets:` from the top home's `STATUS.md`. `/flow:project` plans write a `/flow:design:` row with medium, reason and the line to type, and never for actions done in the world.
- Shown in four beds, one in a vault path with a space and no git. A headless Claude Code shell check stopped the repo session's Pen commands (a brace next to a quote): the adapter now writes command strings in backticks.
- Not demoed: the app's MCP path; a sub-project walking up to its top home.

## Rulings taken at impact (user away, authorized)

- `docs/design/` does not follow `root` — the user settled "always `docs/design/`, never split" — cost if wrong: a project with `root: flow` gets design files outside its Flow root; one line to change.
- The Claude-artifact medium always leaves an HTML source under `docs/design/` — the user's complaint was that artifacts "stay closed inside" — cost if wrong: an extra file per artifact.
- The design phase is skipped when a work has no `shaping.md` — the corrections need a target — cost if wrong: a frame-only product work misses the phase; the by-hand mode covers it.
- `design:` for a project lives in its `STATUS.md` frontmatter — the grill leaned that way and a project home has no `.flow.yml` — cost if wrong: a field to move; the user may overrule it at the close.
