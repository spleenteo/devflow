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
- **Links.** From V3 on, links in `README.md` to files V3–V5 remove or move (`skills/dev/decisions-log.md`, `skills/dev/lenses.md`, the guideline and lens templates) may break: add `--glob '!README.md'` to the link check's `rg --files` call until V8 rewrites it. `docs/architecture.md` stays checked.

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
- Until V6 replaces it, the execute step's instruction adds an override: current checkout on `work/<slug>`, no worktree.
- The project layout's archive is its own procedure: a sibling `archive/` folder, possibly outside git, no deny wall, no `archived.md` unless the folder is a repo.
- The merge target is the repo's default branch, detected, never assumed to be `main`.
- "Doesn't merge or push" in `skills/dev/SKILL.md` becomes the new close; push and tag still need an ok.

**Out**: decisions, changelog (V2, V3); the questions that fill `.flow.yml` (V4).

**Done**
- `rg` over `skills/` finds the `STATUS.md` frontmatter and the archive procedure in the reference file only.
- On a throwaway repo, `/flow:dev` opens a work: branch `work/<slug>` in the same checkout, no worktree, `STATUS.md` as the reference says.
- `/flow:archive` archives a closed work there, links fixed, `archived.md` row written.
- `/flow:project` opens a project in a plain folder with the same `STATUS.md` shape.
- Closing that work proposes a local merge, runs it after an ok, and leaves no worktree; with `merge: pr` in `.flow.yml` it proposes a PR instead.
- A project folder's closed project is archived to its sibling `archive/` as the project procedure says.
- In a throwaway repo whose default branch is `master`, the close merges into `master`.

**Deviations found while planning V1**
- The reference lives at `shared/work.md`, outside `skills/` (it is not a skill): the Done's `rg` runs over `skills/` and `shared/`.
- `STATUS.md` (repo layout) gains `base:`, the branch the work was cut from, so the close can find the merge target in repos without a remote.
- The standing-documents reload lists stay in the conductors: they are conductor-specific and moving them would duplicate them.

**Gotchas**: the reference is read by two skills with different layouts; every path in it must say which layout it belongs to. `${CLAUDE_PLUGIN_ROOT}` is substituted in skill text only, not in Bash.

**V1 — done on 2026-10-26**
- `shared/work.md` holds home, `STATUS.md`, slice bookkeeping, close and both archive procedures; `dev`, `project` and `/flow:archive` point to it. `skills/archive/SKILL.md` went from 155 to 19 lines.
- Ruling: T1 was written in session after two executor runs died (a network error, then a stall); the task was transcription from three files already in context.
- The T2 review found a real gap the plan missed: with `STATUS.md` on a work branch, resuming from `main` found nothing. Fixed with "Finding open works", which reads `work/*` branches through `git show`.
- Demonstrated headless on throwaway repos: open on `work/hello` with `base: master` and one worktree; local merge into `master`; `merge: pr` with no remote stops and merges nothing; archive with links fixed both ways and the wall added; a project opened in a plain folder and archived to its sibling `archive/`. Gate green within the narrowing.

## V2 — `flow:docs`

**In**
- New skill `flow:docs` with `context: fork` and `background: false` (A6.1): conductors send a self-contained request and get one line back. Serves both layouts.
- Changelog and `.version` operations move in from `/flow:changelog`, which stays as a thin entry point (A6.3).
- Memory search: key words over changelog, decisions and `archived.md` (A6.4); search by `touches:` arrives with V3.
- `dev` and `project` replace their own changelog and memory-search instructions with requests to `flow:docs`.
- `flow:docs` never asks: the conductor, or `/flow:changelog` when invoked by hand, asks first (current version when `.version` is missing, one release or two, objections to the level, the `git status` check) and the request carries the answers.
- Always cited by its qualified name `flow:docs`; its description is narrow (called by Flow's conductors and `/flow:changelog`), so other skills named `docs` don't collide.
- In the project layout, memory search also covers the sibling projects' `STATUS.md`, `lessons.md` and decisions, as `project` does today.

**Out**: the decision format (V3).

**Done**
- On a throwaway repo, closing a one-slice work writes the changelog entry and `.version` through `flow:docs`; the conductor's transcript holds the one-line result and none of `flow:docs`' instructions (checked in the stream JSON as in the spike).
- "What do we know about X" from `/flow:dev` returns matching entries through `flow:docs`.
- `/flow:changelog` invoked by hand writes the same entry through `flow:docs`.
- In a `project` folder, `flow:docs` finds and writes in the project layout.
- On a throwaway repo with no `.version`, the conductor asks the current version before calling `flow:docs`; the fork asks nothing.
- With another skill named `docs` loaded, closing a work still reaches `flow:docs` (stream JSON).
- In a folder of sibling projects, a search finds a lesson recorded in a neighbour.

**Deviations found while planning V2**
- The project layout writes nothing in V2: a project has no changelog, and its decisions arrive in V3. The Done's "finds and writes in the project layout" is met by search here and by decisions in V3.
- The changelog takes two calls, `changelog-propose` then `changelog-write`, so the user can object to the level while the fork never asks and the level rule lives in `flow:docs` only.
- The questions and the propose/write flow live in `shared/work.md` § Closing a work, followed by both the conductor's close and `/flow:changelog`.
- `flow:docs` is `user-invocable: false` and cited without a slash, unlike the Naming rule's `/flow:<skill>`; V8 updates the rule.
- `background: false` can be verified only headless here, where Claude waits anyway: an interactive check is left to the user.

**Gotchas**: a forked skill receives no conversation history: every request must carry the paths and slugs it needs.

**V2 — done on 2026-10-26**
- `skills/docs/SKILL.md` (`flow:docs`, forked, not user-invocable) owns changelog, version and memory search behind a one-line request contract with four ops; `NEEDS:` and `FAILED:` are its only ways to say no. `/flow:changelog` is an 18-line entry point; the questions and the propose/write flow live once, in `shared/work.md` § Closing a work, step 2.
- Task reviews caught what the plan missed: the fork's commit could sweep in already-staged files (now the pathspec form), commands didn't run in `dir` (now `git -C`), and `/flow:project` searched before its home was known (now the parent of the proposed folder).
- Demonstrated headless: the close writes entry and `.version` through `flow:docs`, the conductor receiving one line; "what do we know about export" returns two entries and a decision; `/flow:changelog` by hand gives the same entry; with no `.version` the run stops at the question with no `flow:docs` call, and the follow-up request carries `current:`; a repo-local skill named `docs` is ignored in favour of `flow:docs`; a lesson about a supplier is found in a sibling project. Gate green within the narrowing.
- Observed: the fork's prompt appears in the stream's `system`/`task_started` events, not in the conductor's messages; a commit made by `flow:docs` carries the fork model's co-author trailer. `background: false` outside headless mode is unverified: left to an interactive check.

## V3 — Decision format

**In**
- One decision format for both layouts (A6.2), from the decisions-log brief: kinds `decision`/`deferral`, fixed headings, `## The decision` in one line, `## Reopen when`, `## Status log`, `touches:` (code only), `area:`, description at most 160 characters, the "does it outlive the work?" test.
- `decisions-log.md` (dev) and `decisions.md` (project) replaced by the format inside `flow:docs`.
- The check script (Bash and awk) next to `flow:docs`; files without `kind:` are legacy, skipped and counted; optional copy into a project with a version header.
- Search by `touches:` against a plan's files.
- Dogfooding: the five decisions of this work recorded in the new format: superpowers leaves; branch in the main checkout and local merge; presets as opinionated, replaceable skills; atomic-commits absorbed, not a dependency; one release.
- The test for proposing a decision ("does the choice outlive the work?", a real alternative discarded, a problem deferred on purpose) stays in the work-layer reference, where conductors read it in session; `flow:docs` holds only the format.

**Out**: converting this repo's three existing decisions (they stay legacy).

**Done**
- The check script passes on the five new decisions and reports the three old ones as legacy.
- On a throwaway repo, `/flow:dev` records a decision through `flow:docs`, and a direct request to `flow:docs` to search by a file path finds it through `touches:`.
- In a project folder, `/flow:project` records a decision through `flow:docs` in the project layout (deferred from V2).

**Deviations found while planning V3**
- The `area` vocabulary lives in `.flow.yml` (`areas:`) only, not in a log README; the check reads it through `--areas`.
- This repo gets a `.flow.yml` holding only `areas:`, to dogfood the vocabulary.
- `decision-write` takes a multi-line request: a header line of fields, then the conductor's labelled notes.
- Stale prose in `docs/architecture.md` and `README.md:117` about the old decision files is left for V8; no link breaks outside `README.md`.

**Gotchas**: the brief's evidence and project names stay out of the repo.

## V4 — Project profile

**In**
- `.flow.yml` keys: `stacks` (a list), `merge` (`local` | `pr`), plus the existing ones (A1.1).
- At every start the conductor checks the profile for missing pieces (stacks, test level with sensitive areas, merge style), proposes an answer for each from the repo, asks in one message, writes the answers back. Nothing is asked twice.
- Test levels none / essential / full in the guidelines' `## Tests`; at opening, a work touching a sensitive area gets a proposed raise, recorded as `tests:` in its `STATUS.md` (A1.3).
- `userConfig` in `plugin.json` for personal settings: model preference per tier and preset mappings (A1.2), never written to a repo.
- The guidelines template becomes the short form: references, test level, gate, deviations.
- A project's existing `stack:` key is read as a one-item `stacks` list, so it isn't asked again; V8 converts it; the `STATUS.md` template's `stack:` field follows.
- Before planning: a runtime check of `userConfig` on a throwaway plugin loaded with `--plugin-dir` and from a local marketplace: where values are stored, how a list renders in `${user_config.KEY}`, an unset value. Every option gets a default and none is `required`; mappings use whatever encoding the check proves.
- The skill text saying `.flow.yml` is written only at Step 0 is corrected: the profile writes it back.

**Out**: the presets themselves (V5); the prompts that obey the test level (V6).

**Done**
- On a throwaway repo with no profile, the first start asks stacks, test level and merge style in one message with proposals; a second start asks nothing.
- A repo with `## Tests` already filled is asked only for what's missing.
- Opening a work whose request touches a declared sensitive area proposes a raise; accepted, `tests:` appears in that work's `STATUS.md` and the project's level is unchanged.
- `claude plugin validate .` passes with `userConfig` declared.
- A repo with `stack: astro` in `.flow.yml` isn't asked its stack.
- The `userConfig` check is recorded in the spike on personal settings, with the encoding chosen.

## V5 — Stack presets

**In**
- One skill per stack the owner uses, `flow:stack-<name>` (A2.1): opinionated patterns and peculiarities, impact lenses, pointers to external skills (e.g. thoughtbot's `rails-patterns`), gate commands, proposed test level. Which stacks ship is asked at this slice's plan.
- The common lenses become their own file; `lenses.md` is removed.
- Resolution per stack: `.flow.yml` mapping, then `userConfig` mapping, then the shipped preset; a mapped custom preset means the shipped one is never invoked (A2.2). Several stacks per project, each resolved on its own.
- First-run draft of `docs/development-guidelines.md` from the resolved presets and the code's observed conventions (A2.3); when the file already exists, only its missing sections are proposed, never a rewrite. After the draft, gate and test level come only from the guidelines.
- Per-stack optional rows in `dependencies.md`, reported only in that stack's projects (A2.4).
- Impact uses the common lenses plus the resolved presets' lenses.
- `install.sh` keeps parsing five columns: a per-stack row carries the stack in the Need cell (e.g. `optional (astro)`) and the script labels it.
- Impact gets a preset's lenses by invoking the resolved preset by name, or the conductor puts the lens text in the packet; never a path into another plugin.
- Preset descriptions say they are invoked only by Flow's conductors and carry no bare stack keywords, so they don't trigger on their own.

**Out**: presets for stacks nobody here uses.

**Done**
- On a throwaway Astro repo with a headless CMS dependency, the first start detects both stacks, invokes both presets and drafts the guidelines.
- With `.flow.yml` mapping one stack to a custom skill (a throwaway plugin), the shipped preset of that stack is not invoked (stream JSON), the other one is.
- The same with the mapping in `userConfig` instead of `.flow.yml`.
- A repo with its own `docs/development-guidelines.md` gets only the missing sections proposed; existing sections are untouched.
- The start check reports a stack's optional dependencies only in a repo of that stack.
- `./install.sh` in a throwaway Astro repo labels the Astro rows and omits the others.
- A session in an Astro repo asked a generic Astro question doesn't invoke the preset by itself.

## V6 — Engine

**In**
- Agents in `agents/`: planner, plan reviewer, impact, executor, task reviewer; `model` alias and `effort` in each definition; instructions speak in tiers; precedence force variable → explicit request → `userConfig` → definition (A3.3).
- Flow's own plan instructions, replacing `writing-plans` (A3.1); executor and task-reviewer prompts with the slice packet, the test policy and the commit rules (A3.2, A3.4); ledger and reports in the work folder, recording the model each agent ran on.
- Test policy: the level and areas from the guidelines (or the work's `tests:`), focused runs per task, full suite only at the gate.
- Commit rules (atomic-commit criteria, credited), written only in the executor prompt.
- Server rule in the executor prompt (A4.2).
- Every `ultrathink` removed; effort set by the agent definitions.
- Rules taken from superpowers credited with their MIT licence.
- `project`'s reality check and plan review get an agent each (or reuse impact and plan reviewer, stated), with their effort, so removing `ultrathink` there doesn't leave them without one.

**Out**: removing superpowers from `dependencies.md` (V7, after brainstorming is replaced).

**Done**
- On a throwaway repo with test level `none`, a one-slice work runs plan → review → execute → close with no test file written and no test command run; the ledger shows the models used.
- The same work with `tests: essential` on one area writes tests for that area only.
- `rg -i ultrathink skills agents` returns nothing.
- With test level `full`, each task's report shows only the tests of the files it touched; the full suite runs once, at the gate.
- One commit per task in `git log`, each with a single kind of work.
- With a `userConfig` model preference and then an explicit request in the prompt, the stream JSON shows the request winning over the preference, and the preference over the agent definition.
- No background server is left running after execute (`lsof -i` on the usual dev ports, before and after).
- `/flow:project`'s reality check runs on its agent, with the effort of its definition (stream JSON).

**Gotchas**: plugin agents ignore `permissionMode`, `hooks`, `mcpServers`.

## V7 — Widen and narrow

**In**
- `flow:brainstorm` ported from superpowers' `brainstorming` (MIT, credited): exits instead of executing, writes where the caller says, proposes artifacts, keeps the builder check, no local server (A7.1).
- `flow:grill` from `grilling` (MIT, credited): frontier rounds with recommendations, criterion anchor, caller's target, parked questions, decision candidates handed to `flow:docs` (A7.2).
- Definition path in `dev` and `project`: brainstorm → grill → frame; inside a slice, grill on the doubt, replacing "one question at a time" (A7.3).
- superpowers removed from `dependencies.md` and from every skill (A3.5).
- Conductors cite `flow:brainstorm` and `flow:grill` by qualified name only and say not to use any other `brainstorming` skill, so superpowers' or a personal one can't take over.
- The decision `2026-10-25-no-grill-me-dependency.md` gets a status-log line: partly superseded by `flow:grill` (one-question rule replaced; `grilling` ported, still not a dependency).

**Done**
- `rg -i superpowers skills agents dependencies.md` returns only credit lines.
- `/flow:brainstorm` on a clear one-line request exits and says so; on a visual topic it proposes an artifact and starts no server.
- `/flow:grill` on a small plan asks a numbered frontier round and records a parked question in the target file.
- `/flow:dev` on a product request runs brainstorm → grill → frame; `/flow:project` follows the same path.
- The brainstorm → grill → frame path runs with superpowers still installed and enabled, and its `brainstorming` is not invoked (stream JSON).

## V8 — Upgrade and documentation

**In**
- One upgrade step in the work layer (A8.1): recognises old traces, lists the changes, runs after an ok, commits on the work's branch or `work/flow-upgrade`; points at `CLAUDE.md` lines without editing them; also brings the project to this work's conventions (profile, presets, merge rule).
- Fallback sentences for `.devflow.yml` and "devflow work … merged" removed everywhere else (A8.2).
- README, `docs/architecture.md`, `dependencies.md` and the guidelines' Gate updated to the new shape.
- Also stale before V8 and fixed here: "doesn't merge" in `README.md` and `docs/architecture.md`; the `#project-memory` anchor in `docs/architecture.md`; the `superpowers:writing-plans` example in the guidelines' Naming; README's coexistence note for users who keep superpowers installed.
- Existing `stack:` keys converted to `stacks:` by the upgrade step.

**Done**
- On a throwaway repo carrying old traces, the start proposes the upgrade, runs it after an ok and commits it on a branch; `main` untouched.
- The Gate's old-name grep matches only the upgrade step.
- Every Mermaid block in `docs/architecture.md` renders with `mmdc` (as at v0.1.0) and is checked by eye.
