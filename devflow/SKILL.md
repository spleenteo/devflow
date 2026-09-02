---
name: devflow
description: Use when opening a development work in a repo, resuming an interrupted one, or moving to the next slice. Triggers include "/devflow", "open the work X", "resume X", "next slice", "where were we on X". Stack-agnostic; needs nothing in the project's CLAUDE.md.
---

# Devflow

Runs a development work from idea to code, one slice at a time.

The high-level plan is the slice list, produced by shaping. The detailed plan of each slice is written right before executing it, after the previous slice is closed: executing slice N teaches things the plan of N+1 must contain, and a plan written weeks earlier ignores them.

## Why

The skills that do the actual work (`shaping`, `breadboarding`, `framing-doc`, `writing-plans`, `subagent-driven-development`) come from outside, don't know each other and don't know the repo's paths: `writing-plans` saves to `docs/superpowers/plans/`, `brainstorming` to `docs/superpowers/specs/`, `shaping` wherever it lands. Without a conductor, every work restarts the debate about which phases apply and where files go, state is lost when the session ends, and the return to the user between steps disappears.

This skill keeps the thread: it opens the work's home, picks the path, invokes each tool at the right moment telling it where to write and what to read, records progress on disk, and has plans verified by someone else before executing.

## What it does NOT do

| Doesn't | Why |
|---|---|
| Write all plans up front | A slice's plan is written when that slice is next |
| Run past a stop | Two stops per slice: after the reviewed plan, after the close. It commits and asks before going on |
| Skip steps silently | When it skips one, it says which and why |
| Apply corrections on its own | Verifications report in one ranked message with a recommendation per finding; the user decides with one answer |
| Pass whole documents to subagents | Each subagent gets a context packet: what it needs, nothing else |
| Touch `CLAUDE.md` or write config on its own | `.devflow.yml` is written only to record a layout the user chose at first run (Step 0) |
| Write the changelog or archive itself | It invokes `devflow-docs` and `devflow-archive` in the closing sequence (Step 6), each after asking |

**The rule that matters most**: a long session where the skill barrels ahead is worse than no skill. At the two stops of every slice, return to the user.

## Conventions, no configuration

| What | Convention | Detection |
|---|---|---|
| Root | `docs/` | Everything devflow writes lives under it: `docs/work/`, `docs/decisions-log/`, `docs/development-guidelines.md`, `docs/CHANGELOG.md`. Checked at first run (Step 0) |
| Stack | `rails`, `astro`, `react`, `node`, `generic` | `Gemfile` + `config/application.rb` → rails; `astro.config.*` → astro; `package.json` with `react` in dependencies → react; `package.json` without → node; else generic |
| Guidelines | `docs/development-guidelines.md` | Read if present; its relevant sections go into every context packet. Template in `development-guidelines.template.md` next to this skill |
| Decisions | `docs/decisions-log/` | Read by impact and review; written on request at the close of a step. Format in `decisions-log.md` next to this skill |
| Changelog | `docs/CHANGELOG.md` | Written by `devflow-docs`; read at opening. An existing one is adopted, not replaced |
| Impact lenses | Per stack, in `lenses.md` next to this skill | Chosen from the detected stack |

A project can override the defaults with `.devflow.yml` at its root: keys `root`, `stack`, `changelog`, `version_file`. Read if present. The skill writes it in one case only: Step 0, to record a non-default root the user chose. Paths in this document assume the default root. `.version` stays at the repo root: one line, read by tools.

## Project memory

`docs/` is the project's memory, and devflow reads it before writing anything new:

| File | What it holds | When devflow reads it |
|---|---|---|
| `docs/CHANGELOG.md` | What shipped, by version, with the work slug | At opening, to see whether the request touches something already built |
| `docs/decisions-log/` | Why things are the way they are: alternatives discarded, problems deferred | At opening, in the impact lens "Memory and debt", in every plan review |
| `docs/work/archived.md` | Which works existed and where their outcome is | At opening, to check the slug and find related works |
| `docs/development-guidelines.md` | How code is written here: tests, naming, placement, gate | In every plan, review, execution and close |

Search before reading: `rg -il "<keywords>" docs/CHANGELOG.md docs/decisions-log/ docs/work/archived.md`, then read only what matches. Never scan `docs/work/archive/`: it's walled on purpose.

## Cost discipline

Token cost comes from fresh contexts rereading the same documents. Wall-clock cost comes from waiting for the user. Five rules, applied in every step below:

1. **Context packets, not documents.** A subagent gets the slice's section of `slices.md`, `lessons.md`, the guideline sections that apply to it, and its own task or plan. Not `slices.md` in full, not `shaping.md` or `breadboard.md` unless the slice's section points to them.
2. **Same packet, same position.** Within a slice, the packet is one verbatim text placed at the top of every subagent prompt, with the specific instruction after it. Identical prefixes hit the prompt cache.
3. **Two stops per slice.** After the reviewed plan, and after the close. Plan and review run back to back.
4. **One message per verification.** Findings ranked by severity, each with a recommended action, one question at the end. Never one finding at a time.
5. **Reasoning and model where they pay.** `ultrathink` at impact, and on plan reviews only when the plan has more than five tasks. Task reviewers on a smaller model (the Agent tool's `model` option) unless the task is marked `critical`. Tasks without dependencies dispatched in parallel.

And measure: every Log line in `STATUS.md` carries wall-clock and cost (from `/cost`), so the next tuning is a comparison, not an opinion.

## Step 0 — First run in a repo

Runs once: when there is no `docs/work/` and no `.devflow.yml`.

```bash
ls -d docs docs/work docs/decisions-log docs/development-guidelines.md docs/CHANGELOG.md .devflow.yml 2>/dev/null
```

**`docs/` doesn't exist** → create `docs/work/` and say so in one line.

**`docs/` exists** → it's already someone's namespace. Say what devflow will add inside it (`work/`, `decisions-log/`, `development-guidelines.md`, `CHANGELOG.md`), report any collision (one of those paths already present with content devflow didn't write; an existing `CHANGELOG.md` is adopted, not a collision), and ask:

1. **Keep `docs/` (recommended).** Devflow's folders sit next to the existing ones. If something collides, the user moves or renames it first: devflow never moves files it doesn't own.
2. **Use a top-level `devflow/` folder (discouraged).** Documentation splits in two places, and readers look in `docs/` first. If chosen, write `.devflow.yml` with `root: devflow` and say so.

Then, if `docs/development-guidelines.md` is missing, offer to create it from `development-guidelines.template.md` next to this skill. The user fills it in; if they decline, don't create it: an empty template is worse than none.

## On start: open or resume

```bash
rg "^phase:" docs/work/*/STATUS.md 2>/dev/null
```

- No result → new work (Step 1).
- One or more works with `phase:` other than `done` → say so and ask:

> "`2026-09-02-mobile-menu` is at slice **V3**, step **execute**. Resume there, or open a new work?"

Resuming means reading `STATUS.md`, `lessons.md` and the current slice's plan. Don't reread closed phases.

## Step 1 — Opening

One message, five questions, each with the answer devflow proposes from what it already knows. The user corrects what's wrong and answers what's missing.

1. **What do you want to build?** In the user's words. Becomes `description` in the frontmatter.
2. **Code name?** Propose a short lowercase slug with hyphens, checked against `docs/work/` and `docs/work/archived.md`.
3. **Source material?** Call transcripts, threads, notes. If yes, the frame starts from them with `framing-doc`.
4. **The visible-outcome test.** *Can you already say in one sentence what changes for the product's users, without answering "it depends"?* **Yes** → technical work: skip to slicing. **No** → product work: start from the frame. State your reading: *"I read this as product work: describing the outcome I'd say 'it depends on which pages change'. If it's already defined for you, I'll skip to slicing."*
5. **If product work: is the problem already clear?** Yes → skip the frame, start from shaping. No → frame, using `brainstorming` as the dialogue technique.

Before sending the message, check the project memory with the key words of the request. If a changelog entry, a decision or an archived work touches the same area, say so in the same message: *"v1.9 moved the list filters into `FilterBar`; the decision of 2026-06-12 rules out server-side filtering. I'll take both into account."*

If the doubt is about the domain (what the code does today, which rule applies), the answer is in the repo: read it before asking.

## Step 2 — Create the home

```bash
mkdir -p docs/work/$(date +%Y-%m-%d)-<slug>
```

With `STATUS.md` inside:

```markdown
---
status: open
phase: <frame | shaping | breadboard | slicing | impact | slice | done>
slice: null
step: null
work: <slug>
stack: <detected>
updated: YYYY-MM-DD
tags: [work, <slug>]
description: "<answer to question 1>"
---

# Status — <Readable name>

> Update at the **end of every session**: done, remaining, blockers.

**Entry**: <product | technical>, decided on <date> because <visible-outcome test answer>.

## Slices

- [ ] (defined during slicing)

## Log

<!-- date — step — done — remaining — wall-clock — cost -->
```

`lessons.md` is created at the first slice close: one rule per line, the digest that every later subagent reads instead of `slices.md` in full.

`work:` is the bare slug; the date lives in the directory name. `phase:` says where the work is; when it's `slice`, `slice:` and `step:` say which slice and where in it. Without these three fields an interrupted work shows up the next morning as finished, or as never started.

## Step 3 — Define: from problem to slices

For each phase: invoke the tool telling it where to save, commit, update `phase:`, stop. These phases are dialogues with the user; the stops are natural.

| `phase:` | When | Tool | Produces |
|---|---|---|---|
| `frame` | The problem isn't defined yet | `framing-doc` with source material, else `brainstorming` | `frame.md` |
| `shaping` | Several solutions with different outcomes | `shaping` | `shaping.md` |
| `breadboard` | The work introduces places or affordances that don't exist yet. On existing code, skip by default and say so | `breadboarding` | `breadboard.md` |
| `slicing` | Always, even with one slice | `shaping` (slicing section) or `breadboarding` | `slices.md` |
| `impact` | Always, after slicing | Two subagents (below) | Corrections in `slices.md` |

**`slices.md` is the high-level plan.** Per slice: what's in, what's out, how it's demonstrated (the "Done"), known gotchas. It's the mandate every detailed plan must honor, and where closed slices leave their narrative. Every slice ends in something you can see or run; a slice with no visible outcome is a horizontal layer, not a slice.

**The path instruction is mandatory on every invocation.** Without it, the tool uses its own default:

> Save to `docs/work/2026-09-02-mobile-menu/shaping.md`. Don't use default paths.

**If a point stays vague** (a requirement nobody can decide, an alternative that won't close), invoke `grill-me` on that point before moving on. It's a tool for tightening, not a phase.

**If an unknown is technical** (how a library behaves, what a piece of code really does, whether a platform limit holds), it's a spike: a `spike-<topic>.md` with questions and outcomes, done before the plan of the slice that depends on it. A plan is not written on top of a guess.

**If a phase isn't needed**, say so and skip: *"The affordances here are three calls to an existing endpoint: skipping the breadboard."* Never silently.

### `phase: impact`, once, on `slices.md`

The slices against the real code, before the first plan. Two subagents in parallel, both with `ultrathink` in the prompt: one with the common lenses, one with the detected stack's lenses (`lenses.md`). On a one-slice work, one subagent with all of them. Packet: `slices.md` in full (here it is the object under review), the descriptions of `docs/decisions-log/` files that match the work's key words, the guidelines. The code they read themselves.

Not in session: whoever just ran the shaping is the worst head for seeing what breaks elsewhere.

Report in one message: findings ranked by severity, each as **what** · **where** (`file:line`) · **why it's a problem** · **recommended fix**; lenses that found nothing named as such; one question at the end: *"Apply the recommended fixes? Say which to skip."* Silence on a lens reads as "didn't run".

Approved corrections go into `slices.md`. If a correction splits or reorders slices, go back to `phase: slicing`.

On a one-slice work, impact is often the check that saves you: the twenty-line fix that breaks another page. Always propose it; the user may skip it.

## Step 4 — The slice loop

From here `phase: slice`. For each slice, in `slices.md` order, four steps and two stops. `step:` in `STATUS.md` says which.

**The slice packet**, built once per slice and placed verbatim at the top of every subagent prompt in it: the slice's section of `slices.md`; `lessons.md`; the sections of `docs/development-guidelines.md` that apply (tests, naming, placement, gate); the descriptions of matching decisions. `shaping.md` and `breadboard.md` only if the slice's section points to them.

### `step: plan`

Invoke `writing-plans` with the packet and this instruction:

> Save the plan to `docs/work/2026-09-02-mobile-menu/V2-plan.md`. **Not** in `docs/superpowers/plans/`. Task level: for each task, what it does, which files it touches, how it's verified, what done means. No minute-by-minute steps: the implementer reads the code. TDD where the `## Tests` section of the guidelines requires it, not elsewhere. Mark dependencies between tasks (`depends on: T1`) and mark `critical` the tasks that touch shared or risky code. Aim for under 100 lines.

Writing the plan surfaces deviations from the mandate: an affordance better moved to another slice, a file that doesn't exist, a mechanism the shape didn't foresee. Record them in `slices.md` under **"Deviations found while planning V<n>"** and carry on to the review without stopping.

### `step: review`

Right after the plan, one subagent, never in session: whoever just wrote the plan is the worst head for finding its contradictions. `ultrathink` only if the plan has more than five tasks. Packet plus the plan.

| Lens | Looks for |
|---|---|
| **Mandate fidelity** | The plan does things the slice doesn't call for; contradicts a shaping or breadboard choice; the Done criteria aren't covered by the tasks |
| **Ignored lessons** | A rule in `lessons.md` the plan doesn't follow; the same mistake already made and documented |
| **Existence** | The files, symbols and methods the plan names exist, and do what the plan assumes |
| **Guideline compliance** | Tests, naming, function size and code placement in the plan follow the guidelines |

**First stop.** One message: the plan in ten lines, the findings ranked with a recommended fix each, the deviations recorded, one question: *"Apply the recommended fixes and execute? Say which to skip."*

Approved fixes go into the plan in place. Reopen `writing-plans` only if the structure changes: tasks split, reordered or added.

### `step: execute`

`subagent-driven-development` on the plan, with the packet and these overrides stated in the instruction:

- task reviewers on a smaller model, unless the task is marked `critical`;
- tasks without pending dependencies dispatched in parallel;
- the final whole-branch review only if the plan has more than four tasks or touches files shared with other slices.

That skill runs without stopping between tasks and settles conflicts with rulings in its ledger: it stops only for its own four reasons (irreversible operations, security, side effects outside the worktree, a plan broken beyond guessing). Devflow doesn't interrupt it to fix the plan; the rulings are read at the close.

### `step: close`

1. Verify the slice's Done as written in `slices.md`, plus the gate: the `## Gate` section of the guidelines if present, else tests green, typecheck or lint green, build green. If the slice is a refactor, the Done is a regression checklist written before starting and run by hand before committing.
2. Lessons, in two places. The narrative under the slice in `slices.md`, as **"V<n> — done on <date>"**: what execution revealed, the rulings taken from the ledger. The rules, one line each, appended to `lessons.md`: *"before declaring something unused, grep all of `src`, value and setter, and say in the report where you looked."* A ruling that discarded a real alternative is a decision candidate (see `decisions-log.md`).
3. Tick the slice in `STATUS.md`, set `slice:` to the next one and `step:` to `plan`, add the Log line with wall-clock and cost.
4. Commit. **Second stop.** One message: what closed, the gate result, the new rules, the decision candidate if any with the question whether to record it, and: *"V3 closed and committed. Plan V4, or stop here?"*

A closed slice isn't reopened. If a later slice finds an earlier one was wrong, the fix goes into the current slice, stated in `slices.md`, or becomes a new slice at the end.

## Step 5 — Closing a definition phase

Applies to frame, shaping, breadboard, slicing and impact. Four moves, in order:

1. **Commit** the document just produced. Explicit `git add` on the touched files, never `-A` or `.`: the working tree may hold unrelated work. Imperative messages, in the language the repo already uses.
2. **Update `STATUS.md`**: `phase:`, `updated:`, Log line with wall-clock and cost. After a verification the line states the outcome: *"09-02 — impact — 2 problems, fixed in V2 and V4 — 14 min — $2.10"*.
3. **Decision candidate** in the same report, when the criterion in `decisions-log.md` applies: a real alternative discarded, a known problem deferred on purpose, a behaviour that will surprise whoever reads the code. Propose `docs/decisions-log/YYYY-MM-DD-<slug>.md`; never write it unasked.
4. **Stop and ask** before the next phase.

## Step 6 — Exit

When the last slice is closed and the user confirms the work is complete, run the closing sequence. Each step asks before running; the user may stop at any point.

1. **Close the work.** `phase: done`, `status: closed`, final Log line, commit.
2. **Docs.** Ask, then invoke `devflow-docs`: changelog entry and `.version`, committed on the branch.
3. **Archive.** Ask, then invoke `devflow-archive`: the work folder moves to `docs/work/archive/`, committed on the branch.
4. **Report.** Where the work lived, phases done and skipped (with why), slice count, what the verifications found, version assigned, total wall-clock and cost from the Log. Then say it plainly: the branch is ready to merge into `main`. Devflow doesn't merge or push.

Code, changelog, version and archived work land on `main` in one changeset. If the merge review asks for changes that need the work's documents, move them back with `git mv`: they're plain files in git.

## The short path

**A bugfix is a one-slice work.** Same skill: the visible-outcome test sends it straight to slicing (`slices.md` with V1 and its Done), impact if it touches more than one file, then the loop once. No frame, shaping, breadboard.

**A small project doesn't need every phase.** State the path in the opening message: *"I read this as technical work in three slices: skipping frame, shaping and breadboard, doing slicing and impact, then the loop."*

## The full lifecycle

| Moment | Skill | Owner |
|---|---|---|
| Opening, definition, slice loop | `devflow` | this repo |
| A slice's plan | `writing-plans` | superpowers |
| A plan's execution | `subagent-driven-development` | superpowers |
| Changelog and version | `devflow-docs` | this repo |
| Archiving | `devflow-archive` | this repo |

`shaping`, `breadboarding`, `framing-doc`, `brainstorming`, `grill-me` aren't in the table because they aren't moments: they're tools this skill picks up when needed.
