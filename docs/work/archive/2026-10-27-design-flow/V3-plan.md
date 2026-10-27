---
tags: [work, design-flow, plan]
description: "Plan of V3 of the design-flow work: /flow:design gets its called mode, /flow:dev a tracked design phase between breadboard and slicing, and shared/work.md the save-and-close reminder at every branch switch."
---

# V3 — The `/flow:dev` phase

**Mandate**: [slices.md § V3](slices.md) (criterion: [frame.md](frame.md); decision: [design runs as a dev phase](../../../decisions-log/2026-10-27-design-runs-as-a-dev-phase.md)). **Guidelines**: [development-guidelines.md](../../../development-guidelines.md). **Lessons**: [lessons.md](lessons.md). **Execution rules**: the executor's policy, `agents/executor.md` in the plugin; test level `none`. Never touch `docs/design/flow_home-page.pen`.

## The slice, decided here

- Called mode is told apart by its args: the Skill tool `flow:design` with args holding the `## The criterion` block verbatim (when the work has one), then `Shaping: <absolute path of shaping.md>` and `Screens: <the screens to draw, comma-separated>`. A `Shaping:` line means called; none means by hand.
- Called, the skill runs Place, Adapter, First use, Medium, Compose, Promote and Safety unchanged, every consent step still asked of the user (it runs in the conductor's session). It reads `shaping.md` and never writes it; it writes only under `docs/design/` and never commits.
- A requirement correction is anything the design shows wrong, missing or unneeded in `shaping.md`, collected as one line: `<requirement id, or new> — <the correction> — <what in the design showed it>`. When a criterion was passed, each names the criterion line it serves, like `flow:grill`'s anchor, and one that serves none is reported as such; with no criterion, no anchor.
- Called, it returns two lists: **Files touched** (every path written or moved under `docs/design/`, the index included; design files or the artifact's HTML source) and **Requirement corrections** (lines as above, or `none`). Code to write is the work's later slices: said in one line, never proposed as `/flow:dev`.
- "Touches a UI" is read from `shaping.md` (requirements or parts naming a screen, page, form or component the user sees) and from `breadboard.md`'s places when present. The phase is offered when it does, or when an interactive flow is worth clicking through. Skipped, with the reason in the stop message, when nothing is seen or no `shaping.md` exists (`/flow:design` by hand stays available).
- The offer is made at Step 5's stop of shaping (or breadboard): it names the screens to pass, the medium `/flow:design` will propose by the rule of its § Medium (a Claude artifact for an interactive or exploratory need, or when `.flow.yml` has no `design:`; a design file through the tool for static screens with `design:` set), with the reason naming which case held, and, when `docs/design/` holds files, the reminder below. `/flow:design`'s § Medium still settles the medium with the user (an adapter that doesn't resolve turns it into an artifact there).
- On the user's yes, `phase: design`, `updated:` and a Log line go into `STATUS.md`, committed alone (`Open the design phase`), before `/flow:design` is invoked: an interrupted session resumes there. Resuming at `phase: design` reloads `shaping.md` and `docs/design/README.md` and invokes `/flow:design` called again.
- The conductor writes each correction into `shaping.md` in place (the requirement's row amended in the requirements table, and in the fit-check table when it has one; a new row for `new`), in the document's language; then Step 5: fidelity check on the corrected `shaping.md` by `flow:plan-reviewer` (skipped and said when the list was `none`), one commit (`Close the design phase`) of `shaping.md`, the files touched and `STATUS.md` with `phase: slicing`, `updated:` and the Log line, so the branch never keeps `phase: design` once the phase is closed; stop.
- The reminder, one wording everywhere: *"When `docs/design/` holds files, ask the user to save and close them in the design tool first: a tool holding a file open can write its copy back over the switched branch."*

## Tasks

### T1 — /flow:design, called
- **What**: in `skills/design/SKILL.md`: (1) the intro's "This version runs by hand only. It writes, never commits, and says so." becomes: two modes, called by `/flow:dev`'s design phase or by hand; it writes and never commits in either. (2) New `## Called` between the intro and § Place: the args and how called is detected, what it reads and never writes, the corrections and their format and anchor, all as decided above. (3) § Safety, Direction: "By hand with code to write, propose `/flow:dev`" gains "called, say the code belongs to the work's later slices". (4) § Exit: called, return the two lists as decided, say the caller commits; by hand, as today.
- **Files**: `skills/design/SKILL.md`.
- **Verified**: `claude plugin validate .` passes with only the guidelines' expected warnings; `rg -n '^## ' skills/design/SKILL.md` prints Called, Place, Adapter, First use, Medium, Compose, Promote, Safety, Exit in that order; `rg -n 'runs by hand only' skills/design/SKILL.md` prints nothing (exit 1); `rg -c 'Files touched|Requirement corrections' skills/design/SKILL.md` prints 2 or more; `rg -n 'Shaping:' skills/design/SKILL.md` prints one line or more; `rg -n -i -w 'pen|pencil|figma|execute|import_library' skills/design/SKILL.md` prints only the shipped-list line; `rg -n '\]\(' skills/design/SKILL.md` prints nothing.
- **Done**: committed, `Give /flow:design a called mode`.
- **Interfaces**: produces the args (criterion block, `Shaping:`, `Screens:`) and the two returned lists that T2 names.

### T2 — The design phase in /flow:dev (critical, depends on: T1)
- **What**: in `skills/dev/SKILL.md`:
  1. Line 8: name `flow:design` with `flow:brainstorm` and `flow:grill` (the qualified form, as the sentence is about qualified names).
  2. `.flow.yml` key list: `design` (the design tool `/flow:design` uses: `design: pen`); `presets` described as per stack or `design` (`presets: [astro=my-stacks:astro, design=my-tools:design-x]`).
  3. Resume table: Always reloaded gains "at `phase: design`, `shaping.md` and `docs/design/README.md`"; Never reloaded's `shaping.md` reads "`shaping.md` (except at `phase: design`)".
  4. Step 3 table: a `design` row between `breadboard` and `slicing`: When "The work touches a UI, or an artifact fits; needs `shaping.md`"; Tool `/flow:design` (called); Produces "design files or the artifact's HTML source under `docs/design/`; corrections in `shaping.md`".
  5. After the definition-path paragraph, a **The design phase.** paragraph: offer and skip with their reasons, the reminder, the `STATUS.md` write and commit before the call, the args, writing the corrections, the close, all as decided above.
  6. "The criterion travels" paragraph: `/flow:design` joins `shaping`, `framing-doc` and `breadboarding`.
  7. Step 5: "Applies to frame, shaping, breadboard, design, slicing and impact."; under move 1, one sentence: at `design` the document checked is the corrected `shaping.md`, skipped when there were no corrections; under move 2, the design phase commits `shaping.md` with the files `/flow:design` returned and `STATUS.md` already at `phase: slicing`, in one commit.
  8. The short path: "No frame, shaping, breadboard or design."; the example reads "skipping frame, shaping, breadboard and design (`/flow:design`), doing slicing and impact, then the loop."
  9. The lifecycle sentence under the table: `/flow:design` joins the tools.
- **Files**: `skills/dev/SKILL.md`.
- **Verified**: `claude plugin validate .` passes as in T1; `rg -n '^\| .(breadboard|design|slicing). \|' skills/dev/SKILL.md` prints three consecutive lines in that order; `rg -nF 'Applies to frame, shaping, breadboard, design, slicing and impact' skills/dev/SKILL.md` prints one line; `rg -c '/flow:design' skills/dev/SKILL.md` prints 6 or more; `rg -c 'docs/design/README.md' skills/dev/SKILL.md` prints 2 or more; `rg -n 'phase: design' skills/dev/SKILL.md` prints one line or more; `rg -n 'design=' skills/dev/SKILL.md` prints one line; `rg -c 'save and close' skills/dev/SKILL.md` prints 1 or more; `rg -n 'Shaping:' skills/dev/SKILL.md` prints one line or more; read-through of § Step 3, the resume table and Step 5 against `skills/design/SKILL.md` § Called and § Exit: names and list labels match.
- **Done**: committed, `Add the design phase to /flow:dev`.

### T3 — Design in the work reference (critical)
- **What**: in `shared/work.md`: (1) § `STATUS.md`, repo template: `phase: <frame | shaping | breadboard | design | slicing | impact | slice | done>`. (2) The reminder, verbatim as decided, at: § Finding open works, after "With uncommitted changes in the checkout, ask first."; § Closing a work, step 4, before the `git switch <target>` block; § Upgrade, Writing, repo, before cutting `flow-upgrade`; § Upgrade, Resume on an old file (a), before the switch that merges the default branch.
- **Files**: `shared/work.md`.
- **Verified**: `rg -nF 'phase: <frame | shaping | breadboard | design | slicing | impact | slice | done>' shared/work.md` prints one line; `rg -c 'save and close them in the design tool first' shared/work.md` prints 4; the link check of the Gate run on `shared/work.md` alone prints nothing.
- **Done**: committed, `Remind to close design files before a branch switch`.

## Order

- T1 and T3 in parallel (disjoint files); T2 after T1 (it cites T1's args and lists). No gate narrowing.
- The Done demos run `/flow:dev` in sessions, which an executor cannot: the conductor runs them at the close, after T3.
- **Beds**, each a `git init` repo under `<scratchpad>/v3-<name>`, commits on `main`, never committed here: `.flow.yml` with `stacks: [generic]`, `merge: local` (and `design: pen` where said); `docs/development-guidelines.md` holding `## Tests` with `Level: none` and `Sensitive areas:` (no profile questions); `docs/notes.md`, one English paragraph. Then `git switch -c work/<slug>` and `docs/work/2026-10-27-<slug>/` with `frame.md` (a `## The criterion` block, four English lines), `shaping.md` (a requirements table and a confirmed shape) and `STATUS.md` from the repo template with `phase: shaping`, `base: main`, `stacks: [generic]` and the Log line `10-27 — shaping — shape A confirmed by the user, document written — close the phase next — 20 min — n/a`; committed.
  - `v3-pen` (`design: pen`, slug `checkout-page`): shaping describes the checkout payment screen (R1 cart summary with prices, R2 a Pay button). `docs/design/` holds `ds.lib.pen` (a `Button` with child `label`, colour `accent`) and `README.md` with its row, built as in [V2-plan § Order](V2-plan.md#order), `pen` run from the bed's root.
  - `v3-cli` (`design: pen`, slug `export-flag`): shaping describes a `--format csv` flag of a command-line export, no screen.
  - `v3-art` (no `design:`, slug `signup-form`): shaping describes a signup form with inline validation.
- **Sessions**, cwd the bed: `claude -p --plugin-dir /Users/spleenteo/Sites/me/flow --strict-mcp-config --permission-mode acceptEdits --allowedTools 'Skill Agent Bash(pen:*) Bash(git:*) Bash(rg:*) Bash(test:*) Bash(command:*) Bash(ls:*) Bash(cat:*) Bash(find:*) Bash(cd:*) Bash(echo:*) Bash(python3:*) Bash(mkdir:*) Bash(date:*) Bash(printenv:*)' --output-format stream-json --verbose "<prompt>"`, prompts in Italian; every turn's result event has an empty `permission_denials` (a denial: add the tool, rerun the turn, note it). A missing `shaping-skills` is reported by the dependency check and doesn't block this phase.
- `v3-pen`: "/flow:dev riprendi checkout-page: lo shaping è confermato, chiudilo" → the shaping close runs and the stop message offers the design phase, a design file through `pen`, the checkout screen, and the save-and-close reminder. `--continue` "sì, fase di design" → `git log -1 --format=%s` is `Open the design phase` and `STATUS.md` shows `phase: design`; here copy the bed to `v3-pen-resume`. Go on with `--continue`, answering the skill's consent steps (file, components, approval; decline the promotion), adding "il codice sconto va sopra il totale: è un requisito nuovo" → the return lists the files and one `new` correction; `shaping.md` gains the discount-code row, written in English; a `flow:plan-reviewer` dispatch shows in the stream; the last commit is `Close the design phase` and `git show --stat HEAD` lists `shaping.md`, `STATUS.md` and `docs/design/` files; `git show HEAD:docs/work/2026-10-27-checkout-page/STATUS.md` reads `phase: slicing`; the turn ends asking before slicing.
- `v3-pen-resume`, a new session (no `--continue`): "/flow:dev" → the opening names `checkout-page` at `phase: design` and asks resume-or-new; `--continue` "riprendi" → the stream shows `Read` of `shaping.md` and `docs/design/README.md`, and `/flow:design` invoked with a `Shaping:` line.
- `v3-cli`: same first prompt with `export-flag` → the stop message says the design phase is skipped because nothing in `shaping.md` is a screen, and proposes slicing; no `Open the design phase` commit.
- `v3-art`: same first prompt with `signup-form` → the offer names a Claude artifact, because `.flow.yml` has no `design:`. In `v3-pen`, the offer names a design file for the static checkout screen.
- Last, in this repo: `git status --short` shows only `docs/design/flow_home-page.pen` and this work's files.

## Deviations from the mandate

- The phase opens with a commit of `STATUS.md` alone (`Open the design phase`): Step 5 moves `phase:` only at a close, and the resume Done needs `phase: design` on disk mid-phase.
- The offer names the medium by `/flow:design`'s § Medium rule before the skill runs, and the skill confirms it: the Done wants the medium and its reason in the offer, and the skill keeps the final say.
- A1.1's "the root" is not passed: `docs/design/` is fixed whatever `root` says (impact ruling), and `shaping.md`'s absolute path carries the work's place.
