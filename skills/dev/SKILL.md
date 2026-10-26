---
name: dev
description: Use when opening a development work in a repo, resuming an interrupted one, or moving to the next slice. Triggers include "/flow:dev", "open the work X", "resume X", "next slice", "where were we on X". Stack-agnostic; needs nothing in the project's CLAUDE.md.
---

# Flow: dev

Runs a development work from idea to code, one slice at a time.

The high-level plan is the slice list, produced by shaping. The detailed plan of each slice is written right before executing it, after the previous slice is closed: executing slice N teaches things the plan of N+1 must contain, and a plan written weeks earlier ignores them.

## Why

The skills that do the actual work (`shaping` (`shaping-skills:shaping`), `breadboarding` (`shaping-skills:breadboarding`), `framing-doc` (`shaping-skills:framing-doc`), `writing-plans` (`superpowers:writing-plans`), `subagent-driven-development` (`superpowers:subagent-driven-development`)) come from outside, don't know each other and don't know the repo's paths: `writing-plans` saves to `docs/superpowers/plans/`, `brainstorming` (`superpowers:brainstorming`) to `docs/superpowers/specs/`, `shaping` wherever it lands. Without a conductor, every work restarts the debate about which phases apply and where files go, state is lost when the session ends, and the return to the user between steps disappears.

This skill keeps the thread: it opens the work's home, picks the path, invokes each tool at the right moment telling it where to write and what to read, records progress on disk, and has plans verified by someone else before executing.

## What it does NOT do

| Doesn't | Why |
|---|---|
| Write all plans up front | A slice's plan is written when that slice is next |
| Run past a stop | Two stops per slice: after the reviewed plan, after the close. It commits and asks before going on |
| Skip steps silently | When it skips one, it says which and why |
| Apply corrections on its own | Verifications report in one ranked message with a recommendation per finding; the user decides with one answer |
| Pass whole documents to subagents | Each subagent gets a context packet: what it needs, nothing else |
| Touch `CLAUDE.md` or write config on its own | The configuration file is written only to record what the user answered in the profile, on the work's branch |
| Write the changelog, the version or the archive itself | Changelog and version go through `flow:docs` (the work reference, § Closing a work, step 2); archiving through `/flow:archive`. Both in the closing sequence (Step 6), each after asking |
| Merge, push or tag without an ok | Each is proposed and waits for its own yes (Step 6) |
| Install its dependencies | It prints the commands from `dependencies.md`; the user runs them |

**The rule that matters most**: a long session where the skill barrels ahead is worse than no skill. At the two stops of every slice, return to the user.

## Conventions, no configuration

| What | Convention | Detection |
|---|---|---|
| Root | `docs/` | Everything this skill writes lives under it: `docs/work/`, `docs/decisions-log/`, `docs/development-guidelines.md`, `docs/CHANGELOG.md`. Asked at first run (Step 0) |
| Stacks | `rails`, `astro`, `react`, `node`, `generic`; a project can have several | Each signal checked on its own: `Gemfile` + `config/application.rb` → rails; `astro.config.*` → astro; `package.json` with `react` in dependencies → react. `node` only when `package.json` exists and no other JS stack matched; `generic` only when nothing matched. Confirmed in the profile |
| Guidelines | `docs/development-guidelines.md` | Read if present; its relevant sections go into every context packet. Template in `${CLAUDE_SKILL_DIR}/development-guidelines.template.md` |
| Decisions | `docs/decisions-log/` | Read by impact and review; proposed here at the close of a step, written by `flow:docs` on a yes. Criterion and requests: the work reference, § Decisions |
| Changelog | `docs/CHANGELOG.md` | Written by `flow:docs`; searched at opening. An existing one is adopted, not replaced |
| Work reference | `${CLAUDE_PLUGIN_ROOT}/shared/work.md` (in the repo: [shared/work.md](../../shared/work.md)) | The how of a work's home, `STATUS.md`, slice-close bookkeeping, close, merge and archive. This skill says when; the reference says how. Read it when a step points to it |
| Impact lenses | Per stack, in `${CLAUDE_SKILL_DIR}/lenses.md` | Taken for each of the project's stacks |
| Project lenses | `docs/impact-lenses.md` | Read if present by impact and every plan review, on top of the stack lenses. Template in `${CLAUDE_SKILL_DIR}/impact-lenses.template.md` |

Configuration lives in `.flow.yml` at the project root. If it's absent and a `.devflow.yml` exists, read that instead: same keys. When it reads `.devflow.yml`, say so once in the session and suggest renaming it. A project can override the defaults with `.flow.yml`: keys `root`, `stacks` (a flow list: `stacks: [astro, node]`; an older `stack: <name>` reads as `[<name>]`, isn't asked again and is never rewritten), `changelog`, `version_file`, `merge` (`local` | `pr`, default `local`), `areas` (the area words a decision may carry, as a flow list: `areas: [engine, ui]`). Read if present. The skill writes it only through the profile (below), on the work's branch. Paths in this document assume the default root. `.version` stays at the repo root: one line, read by tools.

## Project memory

`docs/` is the project's memory, and this skill reads it before writing anything new:

| File | What it holds | When this skill reads it |
|---|---|---|
| `docs/CHANGELOG.md` | What shipped, by version, with the work slug | At opening, to see whether the request touches something already built |
| `docs/decisions-log/` | Why things are the way they are: alternatives discarded, problems deferred | At opening, in the impact lens "Memory and debt", in every plan review |
| `docs/work/archived.md` | Which works existed and where their outcome is | At opening, to check the slug and find related works |
| `docs/development-guidelines.md` | How code is written here: tests, naming, placement, gate | In every plan, review, execution and close |

Search before reading, through `flow:docs`: invoke the Skill tool with skill `flow:docs` and args one line, self-contained, since the fork sees no conversation:

```
op: search, layout: repo, dir: <absolute repo root>, keywords: <k1>, <k2>
```

It returns at most ten `path — excerpt` lines, or `none`; read only the files they name. `op: descriptions` (same fields) returns the `description:` line of each matching decision instead. When the user asks what the project knows about something, search and report. A file whose path is already known is read directly, no search. `docs/work/archive/` is walled on purpose: `flow:docs` never reads it.

## Cost discipline

Token cost comes from fresh contexts rereading the same documents. Wall-clock cost comes from waiting for the user. Five rules, applied in every step below:

1. **Context packets, not documents.** A subagent gets the slice's section of `slices.md`, `lessons.md`, the guideline sections that apply to it, the project lenses when `docs/impact-lenses.md` exists, and its own task or plan. Not `slices.md` in full, not `shaping.md` or `breadboard.md` unless the slice's section points to them.
2. **Same packet, same position.** Within a slice, the packet is one verbatim text placed at the top of every subagent prompt, with the specific instruction after it. Identical prefixes hit the prompt cache.
3. **Two stops per slice.** After the reviewed plan, and after the close. Plan and review run back to back.
4. **One message per verification.** Findings ranked by severity, each with a recommended action, one question at the end. Never one finding at a time.
5. **Reasoning and model where they pay.** `ultrathink` at impact, and on plan reviews only when the plan has more than five tasks. Task reviewers on a smaller model (the Agent tool's `model` option) unless the task is marked `critical`. Tasks without dependencies dispatched in parallel.

And measure: every Log line in `STATUS.md` carries wall-clock and cost (from `/cost`), so the next tuning is a comparison, not an opinion.

## Dependencies

Runs first, on every invocation: before anything else in this skill and before any file is written. The skills this one hands work to are listed in `${CLAUDE_PLUGIN_ROOT}/dependencies.md` (in the repo: [dependencies.md](../../dependencies.md)). Read it and compare it with the skills listed in the session: a dependency is present when a listed skill has its name, or its segment after `:` equals it.

If any are missing, report them in one message, required first, then optional. For each: the install commands from `dependencies.md` at user and project scope and the phase that needs it (from this skill's tables). Never install anything, and don't block the start: the check at each phase stops it if needed.

At a phase or step that invokes a dependency, check again: if a required one isn't listed, stop that phase and give its commands from `dependencies.md`; don't do its job without it.

## Profile

The project's profile is three things the conductor must know and never guess: the `stacks`, the `merge` style and the test level. It runs on every invocation, right after the dependency check and before anything is opened or resumed. **The order is fixed**: dependency check → profile questions (on a first run, with Step 0's) → find the open works → open (Step 1) or resume → the profile's write, on the work's branch. Step 1's message may share the turn with the profile's questions; the writes never come before the answers.

| Piece | Lives in |
|---|---|
| `stacks`, `merge` | the configuration file: `.flow.yml`, or `.devflow.yml` when that is the one in use. Never create `.flow.yml` beside a `.devflow.yml` |
| Test level, sensitive areas | `## Tests` of the guidelines, opening with two lines: `Level: <none \| essential \| full>` and `Sensitive areas: <path or concept>, …` (empty allowed with `none` and `full`) |

`none`: no tests required. `essential`: tests required for code in the sensitive areas only. `full`: TDD on new code.

**Reading.** A piece is present when it is in the checkout, or in the same file on an open `work/*` branch (`git show <branch>:<file>`): an unmerged profile lives there. Present pieces are never asked again. `merge` has its default, `local`, but is still asked once, like the others.

**Proposing.** One proposal per missing piece:

- **Stacks**: the detection rule of the Conventions table, all matches listed.
- **Level**: `essential` when a test runner is configured, else `none`. Configured means: a test dev-dependency (`vitest`, `jest`, `mocha`, `@playwright/test`, `cypress`) in `package.json`, or a `scripts.test` other than npm's stub (`echo "Error: no test specified" && exit 1`); `spec/` with `rspec` in the `Gemfile`, or `test/` with `minitest`; `pytest` configured (`pytest.ini`, or `[tool.pytest]` in `pyproject.toml`). Areas proposed from paths that look sensitive: auth, payments, billing, migrations, data import and export.
- **Merge**: `pr` when the repo has a remote and `.github/pull_request_template.md` or `.github/workflows/`, else `local`.

**Asking.** Only the missing pieces, in one message, each with its proposal; on a first run, Step 0's questions are in the same message. Asking writes nothing:

> "Before opening: **stacks** `[node]` (detected: `package.json`, no framework); **tests** `essential`, since `vitest` is configured, sensitive areas `src/auth/`, `src/billing/`; **merge** `local` (no remote). Also: keep `docs/` for the flow's folders, and create `docs/development-guidelines.md` with only `## Tests`? Correct what's wrong."

**Writing.** Never on the default branch. A new work: with the home, on `work/<slug>` after Step 2. A resume: right after the switch to the work's branch. Only what is missing is written: the configuration file gains the missing keys (a `root` chosen in Step 0 included); `## Tests` with its two lines goes at the top of the existing guidelines file, or into a new file holding only `## Tests` when there is none and the user accepted it. The full template stays an offer; a declined one is never created. Commit with explicit paths:

```bash
git add .flow.yml docs/development-guidelines.md
git commit -m "Record the project profile"
```

**Raise.** At opening (Step 1), if the request touches a sensitive area (by path or concept), propose a level for this work in the same message. On a yes, `tests: <level>` goes in its `STATUS.md`; the project's `## Tests` stays as it is. A work without `tests:` uses the project level.

## Step 0 — First run in a repo

The dependency check has already run. Step 0 only gathers answers, in the profile's message, and writes nothing: its writes happen with the profile's, on `work/<slug>`.

Runs once: when there is no `docs/work/`, no `.flow.yml` and no `.devflow.yml`.

```bash
ls -d docs docs/work docs/decisions-log docs/development-guidelines.md docs/impact-lenses.md docs/CHANGELOG.md .flow.yml .devflow.yml 2>/dev/null
```

**`docs/` doesn't exist** → say that `docs/work/` will be created with the work's home.

**`docs/` exists** → it's already someone's namespace. Say what this skill will add inside it (`work/`, `decisions-log/`, `development-guidelines.md`, `CHANGELOG.md`, and optionally `impact-lenses.md`), report any collision (one of those paths already present with content this skill didn't write; an existing `CHANGELOG.md` is adopted, not a collision), and ask:

1. **Keep `docs/` (recommended).** The flow's folders sit next to the existing ones. If something collides, the user moves or renames it first: the flow never moves files it doesn't own.
2. **Use a top-level `flow/` folder (discouraged).** Documentation splits in two places, and readers look in `docs/` first. If chosen, `root: flow` goes into the configuration file with the profile's write, and the home is created under it.

Also in the message: if `docs/development-guidelines.md` is missing, offer to create it, from `${CLAUDE_SKILL_DIR}/development-guidelines.template.md` for the full form or with only `## Tests` for the minimum. If `docs/impact-lenses.md` is missing, offer to create it from `${CLAUDE_SKILL_DIR}/impact-lenses.template.md`, under the chosen root: the project's own lenses, applied at impact and in every plan review. Accepted files are created with the profile's write; the user fills them in. Declined → not created: an empty template is worse than none.

## On start: open or resume

The dependency check and the profile questions (`## Profile`) have already run, and their answers are in hand.

Find the open works as the work reference, § Finding open works, says: the current checkout and every `work/*` branch.

- No result → new work (Step 1; its message can share the turn with the profile's questions).
- One or more works with `phase:` other than `done` → say so and ask:

> "`2026-09-02-mobile-menu` is at slice **V3**, step **execute**. Resume there, or open a new work?"

Resuming reloads the **standing documents**, and nothing else:

| Always reloaded | Never reloaded |
|---|---|
| `STATUS.md`; the `## The criterion` block of `frame.md` when the work has one; the sections of `docs/development-guidelines.md` that apply; `lessons.md`; the `description:` line of the `docs/decisions-log/` files that match the work (`flow:docs`, `op: descriptions`, `layout: repo`, `dir`, `keywords` from the `description:` in `STATUS.md`); the current slice's plan | `shaping.md`; `breadboard.md`; closed plans; `spike-*.md`; `frame.md` below its criterion |

A standing document is one that is still true. A closed phase is a debate that ended. The frame belongs to the first kind: it carries the criterion every later document is measured against, and a work that resumes without it resumes on whatever was written last.

On a resume, the profile's write follows the switch to the work's branch. Open with what you reloaded, in five lines — work, phase and slice, cost so far from the Log, the criterion in the frame's own words, the blockers from the last Log line — then ask. The user has to be able to see that the frame is in the room.

## Step 1 — Opening

One message, five questions, each with the answer this skill proposes from what it already knows. The user corrects what's wrong and answers what's missing. If the request touches a sensitive area of the profile, the message also carries the raise (`## Profile`).

1. **What do you want to build?** In the user's words. Becomes `description` in the frontmatter.
2. **Code name?** Propose a short lowercase slug with hyphens, checked against `docs/work/` and `docs/work/archived.md`.
3. **Source material?** Call transcripts, threads, notes. If yes, the frame starts from them with `framing-doc`.
4. **The visible-outcome test.** *Can you already say in one sentence what changes for the product's users, without answering "it depends"?* **Yes** → technical work: skip to slicing. **No** → product work: start from the frame. State your reading: *"I read this as product work: describing the outcome I'd say 'it depends on which pages change'. If it's already defined for you, I'll skip to slicing."*
5. **If product work: is the problem already clear?** Yes → skip the frame, start from shaping. No → frame, using `brainstorming` as the dialogue technique.

Before sending the message, check the project memory with the key words of the request (`flow:docs`, `op: search`, `layout: repo`, `dir`). If a changelog entry, a decision or an archived work touches the same area, say so in the same message: *"v1.9 moved the list filters into `FilterBar`; the decision of 2026-06-12 rules out server-side filtering. I'll take both into account."*

If the doubt is about the domain (what the code does today, which rule applies), the answer is in the repo: read it before asking.

## Step 2 — Create the home

The work opens on branch `work/<slug>` in the current checkout, with its dated folder under `docs/work/`. No worktree unless the user asks. Commands: the work reference, § Creating the home.

Then write the profile's answers (`## Profile`, § Writing) and commit them there. Write `STATUS.md` in it as § `STATUS.md` (repo) says: `description` is the answer to question 1, **Entry** is the visible-outcome test answer, and `base:` records the branch the work was cut from, `stacks:` the confirmed stacks, `tests:` only when the user accepted a raise. `phase:`, `slice:` and `step:` are kept current as that section says: without them an interrupted work shows up the next morning as finished, or as never started.

`lessons.md` is created at the first slice close (§ `slices.md` and `lessons.md`).

## Step 3 — Define: from problem to slices

For each phase: invoke the tool telling it where to save, commit, update `phase:`, stop. These phases are dialogues with the user; the stops are natural.

| `phase:` | When | Tool | Produces |
|---|---|---|---|
| `frame` | The problem isn't defined yet | `framing-doc` with source material, else `brainstorming` | `frame.md` |
| `shaping` | Several solutions with different outcomes | `shaping` | `shaping.md` |
| `breadboard` | The work introduces places or affordances that don't exist yet. On existing code, skip by default and say so | `breadboarding` | `breadboard.md` |
| `slicing` | Always, even with one slice | `shaping` (slicing section) or `breadboarding` | `slices.md` |
| `impact` | Always, after slicing | Two subagents (below) | Corrections in `slices.md` |

If the tool the row picks for the case at hand isn't listed in the session, stop that phase and give its commands from `dependencies.md`. Never swap in another tool (`brainstorming` in place of a missing `framing-doc`).

### The criterion

`frame.md` opens, right under the frontmatter, with a block of at most ten lines:

```markdown
## The criterion

- **Problem**: <one sentence>
- **Outcome**: <what changes for the product's users, one sentence>
- **Less about**: <what this is explicitly not, named while it is still tempting>
- **Measure**: <what tells us a document is serving this>
```

Everything else in the frame is body: sources, transcripts, numbers, the history of the reasoning. The block is the part that travels — on resume, into every definition phase, into every slice packet — so it has to survive being read alone. Keep source material out of it, and when a transcript already exists as a file, link it instead of copying it in.

A technical work that skipped the frame has no criterion, and nothing here applies to it. A frame written before this convention gets the block added at the top of its next update, built from what it already says and confirmed with the user.

**`slices.md` is the high-level plan.** Per slice: what's in, what's out, how it's demonstrated (the "Done"), known gotchas. It's the mandate every detailed plan must honor, and where closed slices leave their narrative. Every slice ends in something you can see or run; a slice with no visible outcome is a horizontal layer, not a slice.

**The path instruction is mandatory on every invocation.** Without it, the tool uses its own default:

> Save to `docs/work/2026-09-02-mobile-menu/shaping.md`. Don't use default paths.

**The criterion travels with every invocation.** `shaping`, `framing-doc` and `breadboarding` don't know the work: put the `## The criterion` block verbatim at the top of the prompt, above the path instruction, with the guideline sections that bear on it. Without it a shape can contradict the frame, and the contradiction surfaces only when a human reads the finished document.

**If a point stays vague** (a requirement nobody can decide, an alternative that won't close), settle that point in dialogue before moving on: one question at a time, each with the answer you'd propose, until it closes or the user parks it as an open question. It's tightening, not a phase.

**If an unknown is technical** (how a library behaves, what a piece of code really does, whether a platform limit holds), it's a spike: a `spike-<topic>.md` with questions and outcomes, done before the plan of the slice that depends on it. A plan is not written on top of a guess.

**If a phase isn't needed**, say so and skip: *"The affordances here are three calls to an existing endpoint: skipping the breadboard."* Never silently.

### `phase: impact`, once, on `slices.md`

The slices against the real code, before the first plan. Two subagents in parallel, both with `ultrathink` in the prompt: one with the common lenses, one with the lenses of each of the project's stacks (`${CLAUDE_SKILL_DIR}/lenses.md`: put its expanded absolute path in the packet, never the variable) and the project lenses, same report format. The common-lens subagent receives the project lenses in the packet but doesn't run them. On a one-slice work, one subagent with all of them. Packet: `slices.md` in full (here it is the object under review), the descriptions of `docs/decisions-log/` files that match the work's key words and the files the slices name (`flow:docs`, `op: descriptions`, `layout: repo`, `dir`, `keywords`, `files`), the guidelines, and the contents of `docs/impact-lenses.md` verbatim when present. The code they read themselves.

Not in session: whoever just ran the shaping is the worst head for seeing what breaks elsewhere.

Report in one message: findings ranked by severity, each as **what** · **where** (`file:line`) · **why it's a problem** · **recommended fix**; lenses that found nothing named as such, project lenses included; when `docs/impact-lenses.md` is absent, one line "project lenses: none", not a finding; one question at the end: *"Apply the recommended fixes? Say which to skip."* Silence on a lens reads as "didn't run".

Approved corrections go into `slices.md`. If a correction splits or reorders slices, go back to `phase: slicing`.

On a one-slice work, impact is often the check that saves you: the twenty-line fix that breaks another page. Always propose it; the user may skip it.

## Step 4 — The slice loop

From here `phase: slice`. For each slice, in `slices.md` order, four steps and two stops. `step:` in `STATUS.md` says which.

**The slice packet**, built once per slice and placed verbatim at the top of every subagent prompt in it: the `## The criterion` block when the work has one; the slice's section of `slices.md`; `lessons.md`; the work's effective test level (`tests:` in `STATUS.md`, else the project's `Level:`) and the sections of `docs/development-guidelines.md` that apply (tests, naming, placement, gate); the descriptions of matching decisions (`flow:docs`, `op: descriptions`, `layout: repo`, `dir`, `keywords`, and `files:` the slice's files); the contents of `docs/impact-lenses.md` when present. `shaping.md` and `breadboard.md` only if the slice's section points to them.

### `step: plan`

If `writing-plans` isn't listed in the session, stop this step and give its commands from `dependencies.md`. Otherwise invoke it with the packet and this instruction:

> Save the plan to `docs/work/2026-09-02-mobile-menu/V2-plan.md`. **Not** in `docs/superpowers/plans/`. Task level: for each task, what it does, which files it touches, how it's verified, what done means. No minute-by-minute steps: the implementer reads the code. TDD where the `## Tests` section of the guidelines requires it, not elsewhere. Mark dependencies between tasks (`depends on: T1`) and mark `critical` the tasks that touch shared or risky code. Aim for under 100 lines.

Writing the plan surfaces deviations from the mandate: an affordance better moved to another slice, a file that doesn't exist, a mechanism the shape didn't foresee. Record them in `slices.md` under **"Deviations found while planning V<n>"** and carry on to the review without stopping.

### `step: review`

Right after the plan, one subagent, never in session: whoever just wrote the plan is the worst head for finding its contradictions. `ultrathink` only if the plan has more than five tasks. Packet plus the plan. The decisions in the packet match the plan too: ask `op: descriptions` again with `keywords` and `files:` the plan's files, and add any new description.

| Lens | Looks for |
|---|---|
| **Mandate fidelity** | The plan does things the slice doesn't call for; contradicts a shaping or breadboard choice, or the frame's criterion; the Done criteria aren't covered by the tasks |
| **Ignored lessons** | A rule in `lessons.md` the plan doesn't follow; the same mistake already made and documented |
| **Existence** | The files, symbols and methods the plan names exist, and do what the plan assumes |
| **Guideline compliance** | Tests, naming, function size and code placement in the plan follow the guidelines |
| **Project lenses** | The project's own lenses from `docs/impact-lenses.md`, applied to the plan: what this change breaks in this project, not how its code is written. When the file is absent, one line "project lenses: none", not a finding |

**First stop.** One message: the plan in ten lines, the findings ranked with a recommended fix each, the deviations recorded, one question: *"Apply the recommended fixes and execute? Say which to skip."*

Approved fixes go into the plan in place. Reopen `writing-plans` only if the structure changes: tasks split, reordered or added.

### `step: execute`

If `subagent-driven-development` isn't listed in the session, stop this step and give its commands from `dependencies.md`. Otherwise run it on the plan, with the packet and these overrides stated in the instruction:

- task reviewers on a smaller model, unless the task is marked `critical`;
- tasks without pending dependencies dispatched in parallel;
- the final whole-branch review only if the plan has more than four tasks or touches files shared with other slices;
- current checkout on `work/<slug>`, no worktree (temporary: removed when `flow-own-engine` V6 replaces this skill's execution).

That skill runs without stopping between tasks and settles conflicts with rulings in its ledger: it stops only for its own four reasons (irreversible operations, security, side effects outside the worktree, a plan broken beyond guessing). This skill doesn't interrupt it to fix the plan; the rulings are read at the close.

### `step: close`

1. Verify the slice's Done as written in `slices.md`, plus the gate: the `## Gate` section of the guidelines if present, else tests green, typecheck or lint green, build green. If the slice is a refactor, the Done is a regression checklist written before starting and run by hand before committing.
2. Lessons, in two places. The narrative under the slice in `slices.md`, as **"V<n> — done on <date>"**: what execution revealed, the rulings taken from the ledger. The rules, one line each, appended to `lessons.md`: *"before declaring something unused, grep all of `src`, value and setter, and say in the report where you looked."* A ruling that discarded a real alternative is a decision candidate (see the work reference, § Decisions).
3. Update `STATUS.md` as the work reference says (§ `slices.md` and `lessons.md`, closing a slice), with wall-clock and cost in the Log line.
4. Commit. **Second stop.** One message: what closed, the gate result, the new rules, the decision candidate if any with the question whether to record it, and: *"V3 closed and committed. Plan V4, or stop here?"*

A closed slice isn't reopened (rule in the same section).

## Step 5 — Closing a definition phase

Applies to frame, shaping, breadboard, slicing and impact. Five moves, in order:

1. **Fidelity check**, before the commit. For each requirement, shape or slice just produced: which line of the criterion does it serve? Whatever traces back to nothing is named in the report, with what it would take to keep it. On `shaping.md` and `slices.md` — the documents the rest of the work inherits — a subagent runs it, with a packet of the criterion, the applicable guidelines and the document alone. On the others, in session. Skipped entirely on a work with no frame, and said so.
2. **Commit** the document just produced. Explicit `git add` on the touched files, never `-A` or `.`: the working tree may hold unrelated work. Imperative messages, in the language the repo already uses.
3. **Update `STATUS.md`**: `phase:`, `updated:`, Log line with wall-clock and cost. After a verification the line states the outcome: *"09-02 — impact — 2 problems, fixed in V2 and V4 — 14 min — $2.10"*.
4. **Decision candidate** in the same report, when the work reference, § Decisions, says so: a real alternative discarded, a known problem deferred on purpose, a behaviour that will surprise whoever reads the code. Propose it; never write it unasked, and on a yes send the `decision-write` request that section shows.
5. **Stop and ask** before the next phase.

## Step 6 — Exit

When the last slice is closed and the user confirms the work is complete, run the closing sequence. Each step asks before running; the user may stop at any point.

Mechanics of each move: the work reference, § Closing a work (repo) and § Archive, repo.

1. **Close the work.** Mark it closed, final Log line, commit.
2. **Docs.** Ask, then follow the work reference, § Closing a work (repo), step 2: the questions, the `flow:docs` requests (`changelog-propose`, then `changelog-write`) and the report. Changelog entry and `.version`, committed on the branch.
3. **Archive.** Ask, then invoke `/flow:archive`: the work folder moves to the archive, committed on the branch.
4. **Merge.** Ask. Find the target and merge as the reference says: with `merge: local` (the default) propose the local merge and run it after an ok; with `merge: pr` propose a pull request and merge nothing. Push and tag each need their own ok. The branch is deleted only on request.
5. **Report.** Where the work lived, phases done and skipped (with why), slice count, what the verifications found, version assigned, total wall-clock and cost from the Log, and what was merged, pushed or tagged (or that nothing was).

Code, changelog, version and archived work land on the target in one changeset. If something after the close needs the work's documents, the reference says how to move them back.

## The short path

**A bugfix is a one-slice work.** Same skill: the visible-outcome test sends it straight to slicing (`slices.md` with V1 and its Done), impact if it touches more than one file, then the loop once. No frame, shaping, breadboard.

**A small project doesn't need every phase.** State the path in the opening message: *"I read this as technical work in three slices: skipping frame, shaping and breadboard, doing slicing and impact, then the loop."*

## The full lifecycle

| Moment | Skill | Owner |
|---|---|---|
| Opening, definition, slice loop | `/flow:dev` | the `flow` plugin |
| A slice's plan | `writing-plans` | superpowers |
| A plan's execution | `subagent-driven-development` | superpowers |
| Changelog and version | `flow:docs` (by hand: `/flow:changelog`) | the `flow` plugin |
| Archiving | `/flow:archive` | the `flow` plugin |

`shaping`, `breadboarding`, `framing-doc`, `brainstorming` aren't in the table because they aren't moments: they're tools this skill picks up when needed.

A work run with this skill can be one action of a `/flow:project` plan: the project's row says *"flow:dev work `<slug>` merged"* (the older *"devflow work … merged"* means the same), this skill runs the work in its repo, and the row closes at the merge. The two skills share their skeleton and are kept in sync by hand.
