---
shaping: true
tags: [work, design-flow, shaping]
description: "Shaping of the design-flow work: requirements, two shapes for where the design step lives, the adapter contract, fit check."
---

# Design flow — Shaping

Inputs: [frame.md](frame.md) (the criterion), [brainstorm.md](brainstorm.md) (its `## Settled` section is fixed: those answers are requirements here, not options), [the decision on skill plus adapter](../../decisions-log/2026-10-27-design-is-agnostic-skill-plus-tool-adapter.md).

## Requirements (R)

| ID | Requirement | Status |
|----|-------------|--------|
| **R0** | **When a work touches a UI or needs a static artifact, Flow offers a design step built on the project's design system** | Core goal |
| **R1** | **Discovery** | Must-have |
| R1.1 | The design step finds which design file fits the task (design system, brand, an area) without opening every file | Must-have |
| R1.2 | The file index is readable by people outside Flow and lives next to the files | Must-have |
| R1.3 | Each design file also describes itself from inside, for whoever opens it in the tool | Must-have |
| **R2** | **Reuse**: a feature's design is composed from the design system's existing components and tokens; a missing one is proposed as new | Must-have |
| **R3** | **Promotion**: an approved new component ends up in the design system, the feature's file keeps a linked use of it, and the index reflects the change | Must-have |
| **R4** | **Tool independence** | Must-have |
| R4.1 | The loop's instructions name no tool-specific mechanics | Must-have |
| R4.2 | A project can replace the shipped tool knowledge with its own, without touching the loop | Must-have |
| R4.3 | A project states which tool it uses; with none, only Claude artifacts are offered | Must-have |
| **R5** | **Entry points** | Must-have |
| R5.1 | In `/flow:dev`: an optional step after shaping (or breadboard) and before slicing, offered only when the work touches a UI | Must-have |
| R5.2 | The `/flow:dev` design step survives an interrupted session like any other phase | Must-have |
| R5.3 | Requirements corrected while looking at the design go back into `shaping.md` | Must-have |
| R5.4 | In `/flow:project`: proposed for a slice only when that slice's context calls for an artifact | Must-have |
| R5.5 | Usable on its own, with no work open | Must-have |
| **R6** | **Medium**: the step proposes a Claude artifact (interactive, exploratory) or a design file (static: landing, UI, web), with its reason; the user confirms or changes it | Must-have |
| **R7** | **Safety** | Must-have |
| R7.1 | No design file, frame or component is deleted unless the user asks | Must-have |
| R7.2 | Every change of direction (design to code, code to design) is proposed and approved | Must-have |
| R7.3 | Exports happen only on request and are checked by the output file's existence | Must-have |
| R7.4 | Design files survive Flow's branch work: the user is told to save and close them before a branch switch Flow makes | Must-have |
| **R8** | **Place** | Must-have |
| R8.1 | Design files live only in `docs/design/`, relative to the repo root or the project's home | Must-have |
| R8.2 | On first use in a repo or project, design files found elsewhere are listed and proposed for a move, moved only on an ok | Must-have |
| R8.3 | Flow ships a template for the index | Must-have |

Out, by the frame: bootstrap from code, design/code alignment and its per-slice check, mandatory exports.

---

## CURRENT

| Part | Mechanism |
|------|-----------|
| CUR1 | `/flow:dev` Step 3 table: `frame` → `shaping` → `breadboard` → `slicing` → `impact`; each row invokes a tool with a path and the criterion, commits, moves `phase:` in `STATUS.md`, stops |
| CUR2 | `flow:brainstorm` and `flow:grill` already have two modes: **called** (the conductor passes the path and commits) and **by hand** (user-invoked, writes, doesn't commit) |
| CUR3 | Stack presets: `flow:stack-<name>` skills, `user-invocable: false`, with `## Rules`, `## Lenses`…; resolved per stack by `presets:` in `.flow.yml` → `stack_presets` user config → shipped |
| CUR4 | `/flow:project` `step: plan`: action plan written in session; a software action reads *"flow:dev work `<slug>` merged"* |
| CUR5 | Design today: by hand, outside Flow; `docs/design/flow_home-page.pen` in this repo |

---

In both shapes `/flow:design` is a standalone skill, usable by hand with no work open and callable by `/flow:project`. They differ only in what happens when it runs **inside a `/flow:dev` work**: whether the work keeps a trace of it.

## A: Standalone skill that leaves a trace in the work

`/flow:dev` records the step as a phase, the way it records brainstorm and grill; `/flow:design` follows their pattern (called or by hand), and is the same skill in both modes.

| Part | Mechanism | Flag |
|------|-----------|:----:|
| **A1** | **`/flow:design` skill**, tool-agnostic, two modes like CUR2 | |
| A1.1 | Called: receives the criterion, the target (`shaping.md` and the screens to draw), the root; returns the files touched and the requirement corrections, for the caller to write and commit | |
| A1.2 | By hand: no work; does its job in `docs/design/`, writes, doesn't commit, says so | |
| A1.3 | First use: looks for design files outside `docs/design/` and for a missing index; proposes the move and the index from the template in one message (→ A4) | |
| A1.4 | Medium choice: proposes artifact or design file with a reason; with no `design:` tool, artifacts only | |
| A1.5 | Reads the index, picks the file, asks the adapter to compose the screen from the library's components (→ A2) | |
| A1.6 | Promotion: on the user's approval of a new component, asks the adapter to promote it, then updates the index row (→ A2) | |
| A1.7 | Safety rules: no delete unasked, consent on every direction change, exports on request only | |
| **A2** | **Adapter `flow:design-pen`**, `user-invocable: false`, a fixed set of sections every adapter fills | |
| A2.1 | `## Files`: extensions, library vs area file (`.lib.pen` vs `.pen`), how a file imports a library, how to write the in-file note | |
| A2.2 | `## Operations`: open; list a library's components and tokens (`get_app_state`, `GetVariables`); compose with `ref: "<alias>:<id>"` and `$<alias>:<token>`, asking the user to add a missing import in the app; promote in two calls (insert into the library, then repoint the area file's instances and remove the local component); write the note; export with the existence check. See [the spike](spike-pen-libraries.md) | |
| A2.3 | `## Cautions`: encrypted files, conflicts resolved in the tool, save and close before a branch switch | |
| A2.4 | Resolution: `design: <tool>` in `.flow.yml`; adapter by `presets: [design=…]` → `stack_presets` → `flow:design-<tool>` | |
| **A3** | **`/flow:dev` changes** | |
| A3.1 | New row in the Step 3 table, `phase: design`, between `breadboard` and `slicing`; offered when the work touches a UI and `design:` is set or an artifact fits; skipped with a reason otherwise | |
| A3.2 | Invokes `/flow:design` called, with the criterion and the path; writes the returned corrections into `shaping.md`; Step 5 closing (fidelity, commit, `STATUS.md`, stop) as for every phase | |
| A3.3 | Before the phase, reminds the user to save and close open design files if a branch switch is pending | |
| **A4** | **Index**: `docs/design/README.md` from a template shipped in `skills/design/`, one row per file: file, role, contents, imported libraries | |
| **A5** | **`/flow:project` change**: at `step: plan`, an action can read *"/flow:design: <artifact>"*; the conductor proposes it only when the slice's context calls for an artifact; files under `<home>/docs/design/` | |

## B: Standalone skill, the conductors only suggest it

`/flow:dev` and `/flow:project` say "this is a good moment for `/flow:design`" and step aside; the work keeps no trace of the step.

| Part | Mechanism | Flag |
|------|-----------|:----:|
| **B1** | **`/flow:design` conductor**: own first run, index, medium choice, compose, promote (as A1.3–A1.7); keeps its own state in `docs/design/` | |
| **B2** | **Adapter** as A2 | |
| **B3** | **`/flow:dev` change**: one line after shaping/breadboard: "the work touches a UI: run `/flow:design` now?"; no phase, nothing in `STATUS.md` | |
| B3.1 | Requirement corrections: `/flow:design` writes them into whichever `shaping.md` it finds on the branch | |
| **B4** | **Index** as A4 | |
| **B5** | **`/flow:project` change**: same one-line proposal at `step: plan` | |

---

## Fit Check

| Req | Requirement | Status | A | B |
|-----|-------------|--------|---|---|
| R0 | When a work touches a UI or needs a static artifact, Flow offers a design step built on the project's design system | Core goal | ✅ | ✅ |
| R1.1 | The design step finds which design file fits the task without opening every file | Must-have | ✅ | ✅ |
| R1.2 | The file index is readable by people outside Flow and lives next to the files | Must-have | ✅ | ✅ |
| R1.3 | Each design file also describes itself from inside, for whoever opens it in the tool | Must-have | ✅ | ✅ |
| R2 | A feature's design is composed from the design system's existing components and tokens; a missing one is proposed as new | Must-have | ✅ | ✅ |
| R3 | An approved new component ends up in the design system, the feature's file keeps a linked use of it, and the index reflects the change | Must-have | ✅ | ✅ |
| R4.1 | The loop's instructions name no tool-specific mechanics | Must-have | ✅ | ✅ |
| R4.2 | A project can replace the shipped tool knowledge with its own, without touching the loop | Must-have | ✅ | ✅ |
| R4.3 | A project states which tool it uses; with none, only Claude artifacts are offered | Must-have | ✅ | ✅ |
| R5.1 | In `/flow:dev`: an optional step after shaping (or breadboard) and before slicing, offered only when the work touches a UI | Must-have | ✅ | ✅ |
| R5.2 | The `/flow:dev` design step survives an interrupted session like any other phase | Must-have | ✅ | ❌ |
| R5.3 | Requirements corrected while looking at the design go back into `shaping.md` | Must-have | ✅ | ❌ |
| R5.4 | In `/flow:project`: proposed for a slice only when that slice's context calls for an artifact | Must-have | ✅ | ✅ |
| R5.5 | Usable on its own, with no work open | Must-have | ✅ | ✅ |
| R6 | The step proposes a Claude artifact or a design file, with its reason; the user confirms or changes it | Must-have | ✅ | ✅ |
| R7.1 | No design file, frame or component is deleted unless the user asks | Must-have | ✅ | ✅ |
| R7.2 | Every change of direction is proposed and approved | Must-have | ✅ | ✅ |
| R7.3 | Exports happen only on request and are checked by the output file's existence | Must-have | ✅ | ✅ |
| R7.4 | The user is told to save and close design files before a branch switch Flow makes | Must-have | ✅ | ❌ |
| R8.1 | Design files live only in `docs/design/`, relative to the repo root or the project's home | Must-have | ✅ | ✅ |
| R8.2 | On first use, design files found elsewhere are listed and proposed for a move, moved only on an ok | Must-have | ✅ | ✅ |
| R8.3 | Flow ships a template for the index | Must-have | ✅ | ✅ |

**Notes:**
- R2 and R3 were failing on the A2.2 flag; [the spike](spike-pen-libraries.md) resolved it. Compose and promote work through `execute`; only adding an import to a file may need the user's hands in the app.
- B fails R5.2: with no phase in `STATUS.md`, a session interrupted mid-design resumes as "shaping done", and the design step is lost.
- B fails R5.3: `/flow:design` writing into a work's `shaping.md` crosses ownership: the conductor commits and keeps the documents in step, and B leaves it out of the loop.
- B fails R7.4: the branch switch is the conductor's; B's one-line proposal sits outside it.

## Recommendation

**A**. The spike cleared A2.2. It reuses two patterns Flow already has (called/by hand from CUR2, presets resolution from CUR3) and keeps the conductor as the only writer of the work's documents.

## Spike needed before selecting

`spike-pen-libraries.md`, on a throwaway file in the session scratchpad, never on `docs/design/flow_home-page.pen`:

| # | Question |
|---|----------|
| X1-Q1 | How does a file become a library through the MCP or the CLI (set `.lib.pen`, a flag, only the app's button)? |
| X1-Q2 | How does a file import a library through `execute` (the `imports` field), and how is an imported component referenced in a `ref`? |
| X1-Q3 | How is a component moved from an area file into a library while the area file keeps a linked instance? |
| X1-Q4 | How are a library's components and tokens listed from an importing file? |
| X1-Q5 | Can one `execute` session touch two files, or does each file need its own call (`filePath`)? |

Acceptance: we can describe the concrete steps the adapter's `## Operations` takes for compose and promote, and which of them need the user's hands in the app.
