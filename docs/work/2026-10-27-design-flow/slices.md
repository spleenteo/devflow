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
- `skills/design/SKILL.md`, `user-invocable: true`, tool-agnostic (R4.1): the by-hand mode only (A1.2). Writes, doesn't commit, says so.
- First use (A1.3, R8.2): looks for design files outside `docs/design/` (by the adapter's extensions) and for a missing `docs/design/README.md`; one message listing the moves and offering the index from the template; moves only on an ok, after asking to close files open in the app.
- Index template `skills/design/design-index.template.md` (A4, R8.3): table with file, role (library or area), contents, imported libraries.
- Medium choice (A1.4, R6): proposes a Claude artifact or a design file with its reason; with no `design:` key, artifacts only (R4.3).
- Adapter resolution (A2.4, R4.2): `design: <tool>` in `.flow.yml`; adapter by `presets: [design=…]` → the `stack_presets` user config → `flow:design-<tool>`. The same chain as the stack presets, documented once in the skill.
- `skills/design-pen/SKILL.md`, `user-invocable: false`, with `## Files` (A2.1: `.pen` vs `.lib.pen`, `imports`, the in-file note as a `note` node) and `## Cautions` (A2.3: save and close before a branch switch), plus the adapter implementation notes from `shaping.md`.
- The fixed section list every adapter fills (`## Files`, `## Operations`, `## Cautions`), stated in `/flow:design` so a project's own adapter knows its contract. `## Operations` is a stub in V1.

**Out**
- Compose and promote (V2). The called mode and every conductor change (V3, V4).

**Done**
- `claude plugin validate .` passes with the two new skills.
- In a throwaway repo with `design: pen` and two `.pen` files at its root, `/flow:design` by hand lists both for a move, offers the index, and after the ok leaves `docs/design/` with the files and a filled `README.md`; nothing is committed.
- In the `design: pen` repo, asked for a landing page, `/flow:design` proposes a design file and says why.
- The same repo without `design:`: asked for a landing page, `/flow:design` proposes a Claude artifact and says why.
- A read-through of `skills/design/SKILL.md` finds no Pen-specific word.

**Gotchas**
- `stack_presets` is keyed by stack; `design` is a key in it, not a stack. The configuration description in `.claude-plugin/plugin.json` may need one line saying so.
- Moving a `.pen` file breaks relative `imports` and image paths in files that point at it: the adapter's `## Cautions` must say to move a library with its importers, or to rewrite the import in the app.

## V2 — Compose and promote, by hand

**In**
- `/flow:design` by hand: reads the index, picks the file, asks the adapter to compose the screen from the library's components and tokens; proposes a new component when one is missing (A1.5, R2).
- Promotion on the user's approval (A1.6, R3): the adapter's two calls, then the index row and the in-file note updated.
- Safety rules written into the skill (A1.7, R7.1–R7.3): no delete unasked (the promotion's removal of the local component is part of the approved move), consent on every change of direction, exports only on request, checked by the file's existence.
- `flow:design-pen` `## Operations` (A2.2): open; list components and tokens; compose with `ref: "<alias>:<id>"` and `$<alias>:<token>`; a missing import asked of the user in the app; promote in two calls with the override remap by child name; write the note; export with the check.

**Out**
- Any conductor change. Bootstrap from code. Alignment.

**Done** (this is the criterion's Measure)
- In the test bed, with a design-system library and an area file: feature 1 is drawn by hand with `/flow:design`, one new component is approved and promoted; the library holds it, the area file uses a linked instance, the index and the note say so.
- Feature 2, in a new session: `/flow:design` finds the promoted component through the index and uses it without redrawing it.
- No file, frame or component disappeared that the user didn't approve.
- An export the user asks for is produced and its file checked; no export happens unasked; moving a change from design to code (or back) is proposed, never done silently.

**Gotchas**
- One file per `execute` call: promotion is never atomic. If the second call fails, the library has the component and the area file still has its local copy; the skill must say so and offer to finish, never retry blindly.
- A failing operation rolls back the whole `execute` call, `try` included.

## V3 — The `/flow:dev` phase

**In**
- `/flow:design` called mode (A1.1): receives the criterion, the work's `shaping.md` path and the screens to draw, and the root; returns the files touched and the requirement corrections; doesn't commit.
- `skills/dev/SKILL.md` Step 3 table: a `design` row between `breadboard` and `slicing` (A3.1, R5.1), offered when the work touches a UI and `design:` is set or an artifact fits, with the medium proposed by `/flow:design`; skipped with a reason otherwise; `phase: design` in `STATUS.md` (R5.2).
- The conductor writes the returned corrections into `shaping.md` and closes the phase by Step 5 (A3.2, R5.3).
- Before the phase, and before any branch switch the conductor makes while design files are in the tree, a reminder to save and close them (A3.3, R7.4).
- `shared/work.md` § `STATUS.md`: `design` added to the `phase:` values.

**Out**
- `/flow:project` (V4). A per-slice design check (out of the first release).

**Done**
- In a throwaway repo with `design: pen` and a work whose shaping describes a screen: `/flow:dev` offers the design phase after shaping, `STATUS.md` shows `phase: design`, the corrections land in `shaping.md`, the phase commits and stops.
- The same session interrupted mid-phase: a new `/flow:dev` resumes at `phase: design`.
- A work with no UI: the phase is skipped, and the message says why.
- A repo with no `design:` key and a work with a UI: the phase is offered with a Claude artifact as the medium, and the reason is given.

**Gotchas**
- The resume table of `/flow:dev` lists what is reloaded; the design phase may need `docs/design/README.md` in it.

## V4 — `/flow:project`, and the plugin's own docs

**In**
- `skills/project/SKILL.md` `step: plan`: an action can read *"/flow:design: <artifact>"*, proposed only when the slice's context calls for an artifact (A5, R5.4); files under `<home>/docs/design/` (R8.1).
- The plugin's docs: README (what `/flow:design` is, the `design:` key), `docs/architecture.md` (the skill, the adapter, the phase), `site/` only if it lists the skills. Required by the guidelines' Releases section: a merge into `main` is a release, so the docs ship with the code.

**Out**
- Changelog and version (the work's close, through `flow:docs`).

**Done**
- In a throwaway project folder, a slice whose action is a deck gets `/flow:design` proposed with a medium and a reason; a slice of phone calls does not.
- With a design tool set for the project, the deck action proposes a design file, written under `<home>/docs/design/`.
- The gate from `docs/development-guidelines.md` is green: validate, old-names check, links check.

**Gotchas**
- A project's home has no `.flow.yml`: where `design:` lives for `/flow:project` is settled with `flow:grill` before V4's plan (leaning: a `design:` field in the project's `STATUS.md`).
