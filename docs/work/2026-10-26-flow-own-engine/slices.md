---
shaping: true
work: flow-own-engine
tags: [slices, flow-own-engine]
description: "Eight slices for flow-own-engine, in dependency order, shipping together as v0.2.0."
---

# Flow's own engine — Slices

Shape A from [`shaping.md`](shaping.md), cut in dependency order. One branch, one merge, one release (v0.2.0): no slice leaves `main` in a half state because nothing reaches `main` before the close.

Every slice is demonstrated by running the plugin from this checkout on a throwaway repo outside this repo: `claude -p "<prompt>" --plugin-dir /Users/spleenteo/Sites/me/devflow` (headless), or an interactive session with `--plugin-dir`. The guidelines' `## Gate` runs at every close, with the narrowing below.

## Gate narrowing, until V8 closes

- **Old names.** The `.devflow.yml` fallback sentence and the "devflow work … merged" note are allowed wherever V1–V7 move them (the work-layer reference, `flow:docs`, the thin `/flow:changelog` and `/flow:archive` entry points), on top of the places the Gate already lists. V8 removes them all but the upgrade step.
- **Links.** From V5 on, links to `skills/dev/lenses.md` in `README.md` and `docs/architecture.md` may break: add `--glob '!README.md' --glob '!docs/architecture.md'` to the link check's `rg --files` call until V8 rewrites both.

| Slice | Parts | Depends on |
|---|---|---|
| V1 Work layer | A5, A4.1, A4.3, the `merge` key | — |
| V2 `flow:docs` | A6.1, A6.3, A6.4 | V1 |
| V3 Decision format | A6.2 | V2 |
| V4 Project profile | A1 | V1 |
| V5 Stack presets | A2 | V4 |
| V6 Engine | A3.1–A3.4, A4.2 | V4, V5 |
| V7 Widen and narrow | A7, A3.5 | V2, V3, V6 |
| V8 Upgrade and docs | A8, documentation (housekeeping) | all |

## V1 — Work layer

**In**
- One reference file in the plugin (A5.1) holding the work's home, the `STATUS.md` format and its transitions, `slices.md`, `lessons.md`, archiving and `archived.md`, for both layouts: `docs/` in a repo, the project folder for `project`.
- `dev` and `project` read it instead of carrying their own copies; what stays in each conductor is when to use it.
- Archiving moves in from `/flow:archive`, which stays as a thin entry point (A5.2).
- Opening a work creates `work/<slug>` in the current checkout; a worktree only when the user asks (A4.1).
- The closing sequence proposes a local merge into `main` and runs it after an ok; `merge: pr` in `.flow.yml` or the user's request switches to a PR; push and tag still need an ok (A4.3). This slice defines the `.flow.yml` key `merge` (`local` | `pr`, default `local`); V4 adds the question that fills it.

**Out**: decisions, changelog (V2, V3); the questions that fill `.flow.yml` (V4).

**Done**
- `rg` over `skills/` finds the `STATUS.md` frontmatter and the archive procedure in the reference file only.
- On a throwaway repo, `/flow:dev` opens a work: branch `work/<slug>` in the same checkout, no worktree, `STATUS.md` as the reference says.
- `/flow:archive` archives a closed work there, links fixed, `archived.md` row written.
- `/flow:project` opens a project in a plain folder with the same `STATUS.md` shape.
- Closing that work proposes a local merge, runs it after an ok, and leaves no worktree; with `merge: pr` in `.flow.yml` it proposes a PR instead.

**Gotchas**: the reference is read by two skills with different layouts; every path in it must say which layout it belongs to. `${CLAUDE_PLUGIN_ROOT}` is substituted in skill text only, not in Bash.

## V2 — `flow:docs`

**In**
- New skill `flow:docs` with `context: fork` and `background: false` (A6.1): conductors send a self-contained request and get one line back. Serves both layouts.
- Changelog and `.version` operations move in from `/flow:changelog`, which stays as a thin entry point (A6.3).
- Memory search: key words over changelog, decisions and `archived.md` (A6.4); search by `touches:` arrives with V3.
- `dev` and `project` replace their own changelog and memory-search instructions with requests to `flow:docs`.

**Out**: the decision format (V3).

**Done**
- On a throwaway repo, closing a one-slice work writes the changelog entry and `.version` through `flow:docs`; the conductor's transcript holds the one-line result and none of `flow:docs`' instructions (checked in the stream JSON as in the spike).
- "What do we know about X" from `/flow:dev` returns matching entries through `flow:docs`.
- `/flow:changelog` invoked by hand writes the same entry through `flow:docs`.
- In a `project` folder, `flow:docs` finds and writes in the project layout.

**Gotchas**: a forked skill receives no conversation history: every request must carry the paths and slugs it needs.

## V3 — Decision format

**In**
- One decision format for both layouts (A6.2), from the decisions-log brief: kinds `decision`/`deferral`, fixed headings, `## The decision` in one line, `## Reopen when`, `## Status log`, `touches:` (code only), `area:`, description at most 160 characters, the "does it outlive the work?" test.
- `decisions-log.md` (dev) and `decisions.md` (project) replaced by the format inside `flow:docs`.
- The check script (Bash and awk) next to `flow:docs`; files without `kind:` are legacy, skipped and counted; optional copy into a project with a version header.
- Search by `touches:` against a plan's files.
- Dogfooding: the five decisions of this work recorded in the new format: superpowers leaves; branch in the main checkout and local merge; presets as opinionated, replaceable skills; atomic-commits absorbed, not a dependency; one release.

**Out**: converting this repo's three existing decisions (they stay legacy).

**Done**
- The check script passes on the five new decisions and reports the three old ones as legacy.
- On a throwaway repo, `/flow:dev` records a decision through `flow:docs`, and a direct request to `flow:docs` to search by a file path finds it through `touches:`.

**Gotchas**: the brief's evidence and project names stay out of the repo.

## V4 — Project profile

**In**
- `.flow.yml` keys: `stacks` (a list), `merge` (`local` | `pr`), plus the existing ones (A1.1).
- At every start the conductor checks the profile for missing pieces (stacks, test level with sensitive areas, merge style), proposes an answer for each from the repo, asks in one message, writes the answers back. Nothing is asked twice.
- Test levels none / essential / full in the guidelines' `## Tests`; at opening, a work touching a sensitive area gets a proposed raise, recorded as `tests:` in its `STATUS.md` (A1.3).
- `userConfig` in `plugin.json` for personal settings: model preference per tier and preset mappings (A1.2), never written to a repo.
- The guidelines template becomes the short form: references, test level, gate, deviations.

**Out**: the presets themselves (V5); the prompts that obey the test level (V6).

**Done**
- On a throwaway repo with no profile, the first start asks stacks, test level and merge style in one message with proposals; a second start asks nothing.
- A repo with `## Tests` already filled is asked only for what's missing.
- Opening a work whose request touches a declared sensitive area proposes a raise; accepted, `tests:` appears in that work's `STATUS.md` and the project's level is unchanged.
- `claude plugin validate .` passes with `userConfig` declared.

## V5 — Stack presets

**In**
- One skill per stack the owner uses, `flow:stack-<name>` (A2.1): opinionated patterns and peculiarities, impact lenses, pointers to external skills (e.g. thoughtbot's `rails-patterns`), gate commands, proposed test level. Which stacks ship is asked at this slice's plan.
- The common lenses become their own file; `lenses.md` is removed.
- Resolution per stack: `.flow.yml` mapping, then `userConfig` mapping, then the shipped preset; a mapped custom preset means the shipped one is never invoked (A2.2). Several stacks per project, each resolved on its own.
- First-run draft of `docs/development-guidelines.md` from the resolved presets and the code's observed conventions (A2.3); when the file already exists, only its missing sections are proposed, never a rewrite. After the draft, gate and test level come only from the guidelines.
- Per-stack optional rows in `dependencies.md`, reported only in that stack's projects (A2.4).
- Impact uses the common lenses plus the resolved presets' lenses.

**Out**: presets for stacks nobody here uses.

**Done**
- On a throwaway Astro repo with a headless CMS dependency, the first start detects both stacks, invokes both presets and drafts the guidelines.
- With `.flow.yml` mapping one stack to a custom skill (a throwaway plugin), the shipped preset of that stack is not invoked (stream JSON), the other one is.
- The same with the mapping in `userConfig` instead of `.flow.yml`.
- A repo with its own `docs/development-guidelines.md` gets only the missing sections proposed; existing sections are untouched.
- The start check reports a stack's optional dependencies only in a repo of that stack.

## V6 — Engine

**In**
- Agents in `agents/`: planner, plan reviewer, impact, executor, task reviewer; `model` alias and `effort` in each definition; instructions speak in tiers; precedence force variable → explicit request → `userConfig` → definition (A3.3).
- Flow's own plan instructions, replacing `writing-plans` (A3.1); executor and task-reviewer prompts with the slice packet, the test policy and the commit rules (A3.2, A3.4); ledger and reports in the work folder, recording the model each agent ran on.
- Test policy: the level and areas from the guidelines (or the work's `tests:`), focused runs per task, full suite only at the gate.
- Commit rules (atomic-commit criteria, credited), written only in the executor prompt.
- Server rule in the executor prompt (A4.2).
- Every `ultrathink` removed; effort set by the agent definitions.
- Rules taken from superpowers credited with their MIT licence.

**Out**: removing superpowers from `dependencies.md` (V7, after brainstorming is replaced).

**Done**
- On a throwaway repo with test level `none`, a one-slice work runs plan → review → execute → close with no test file written and no test command run; the ledger shows the models used.
- The same work with `tests: essential` on one area writes tests for that area only.
- `rg -i ultrathink skills agents` returns nothing.
- With test level `full`, each task's report shows only the tests of the files it touched; the full suite runs once, at the gate.
- One commit per task in `git log`, each with a single kind of work.
- With a `userConfig` model preference and then an explicit request in the prompt, the stream JSON shows the request winning over the preference, and the preference over the agent definition.
- No background server is left running after execute (`lsof -i` on the usual dev ports, before and after).

**Gotchas**: plugin agents ignore `permissionMode`, `hooks`, `mcpServers`.

## V7 — Widen and narrow

**In**
- `flow:brainstorm` ported from superpowers' `brainstorming` (MIT, credited): exits instead of executing, writes where the caller says, proposes artifacts, keeps the builder check, no local server (A7.1).
- `flow:grill` from `grilling` (MIT, credited): frontier rounds with recommendations, criterion anchor, caller's target, parked questions, decision candidates handed to `flow:docs` (A7.2).
- Definition path in `dev` and `project`: brainstorm → grill → frame; inside a slice, grill on the doubt, replacing "one question at a time" (A7.3).
- superpowers removed from `dependencies.md` and from every skill (A3.5).

**Done**
- `rg -i superpowers skills agents dependencies.md` returns only credit lines.
- `/flow:brainstorm` on a clear one-line request exits and says so; on a visual topic it proposes an artifact and starts no server.
- `/flow:grill` on a small plan asks a numbered frontier round and records a parked question in the target file.
- `/flow:dev` on a product request runs brainstorm → grill → frame; `/flow:project` follows the same path.

## V8 — Upgrade and documentation

**In**
- One upgrade step in the work layer (A8.1): recognises old traces, lists the changes, runs after an ok, commits on the work's branch or `work/flow-upgrade`; points at `CLAUDE.md` lines without editing them; also brings the project to this work's conventions (profile, presets, merge rule).
- Fallback sentences for `.devflow.yml` and "devflow work … merged" removed everywhere else (A8.2).
- README, `docs/architecture.md`, `dependencies.md` and the guidelines' Gate updated to the new shape.

**Done**
- On a throwaway repo carrying old traces, the start proposes the upgrade, runs it after an ok and commits it on a branch; `main` untouched.
- The Gate's old-name grep matches only the upgrade step.
- Every Mermaid block in `docs/architecture.md` renders with `mmdc` (as at v0.1.0) and is checked by eye.
