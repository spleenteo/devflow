---
name: devflow
description: Use when opening a development work in a repo, resuming an interrupted one, or moving to the next slice. Triggers include "/devflow", "open the work X", "resume X", "next slice", "where were we on X". Stack-agnostic; needs nothing in the project's CLAUDE.md.
---

# Devflow

Runs a development work from idea to code, one slice at a time.

The high-level plan is the slice list, produced by shaping. The detailed plan of each slice is written right before executing it, after the previous slice is closed: executing slice N teaches things the plan of N+1 must contain, and a plan written weeks earlier ignores them.

## Why

The skills that do the actual work (`shaping`, `breadboarding`, `framing-doc`, `writing-plans`, `subagent-driven-development`) come from outside, don't know each other and don't know the repo's paths: `writing-plans` saves to `docs/superpowers/plans/`, `brainstorming` to `docs/superpowers/specs/`, `shaping` wherever it lands. Without a conductor, every work restarts the debate about which phases apply and where files go, state is lost when the session ends, and the return to the user between steps disappears.

This skill keeps the thread: it opens the work's home, picks the path, invokes each tool at the right moment telling it where to write, records progress on disk, and has plans verified by someone else before executing.

## What it does NOT do

| Doesn't | Why |
|---|---|
| Write all plans up front | A slice's plan is written when that slice is next |
| Decide a step is finished | It closes, commits, stops and asks before the next one |
| Skip steps silently | When it skips one, it says which and why |
| Apply corrections on its own | Verifications propose, one at a time; the user decides |
| Touch `CLAUDE.md` or write config on its own | `.devflow.yml` is written only to record a layout the user chose at first run (Step 0) |
| Write the changelog or archive itself | It invokes `devflow-docs` and `devflow-archive` in the closing sequence (Step 6), each after asking |

**The rule that matters most**: a long session where the skill barrels ahead is worse than no skill. Between steps, always return to the user.

## Conventions, no configuration

| What | Convention | Detection |
|---|---|---|
| Root | `docs/` | Everything devflow writes lives under it: `docs/work/`, `docs/decisions-log/`, `docs/development-guidelines.md`. Checked at first run (Step 0) |
| Stack | `rails`, `astro`, `react`, `node`, `generic` | `Gemfile` + `config/application.rb` → rails; `astro.config.*` → astro; `package.json` with `react` in dependencies → react; `package.json` without → node; else generic |
| Guidelines | `docs/development-guidelines.md` | Read if present; passed to every plan, review and execution. Template in `development-guidelines.template.md` next to this skill |
| Decisions | `docs/decisions-log/` | Read by impact and review; written on request at the close of a step. Format in `decisions-log.md` next to this skill |
| Impact lenses | Per stack, in `lenses.md` next to this skill | Chosen from the detected stack |

A project can override the defaults with `.devflow.yml` at its root: keys `root`, `stack`, `changelog`, `version_file`. Read if present. The skill writes it in one case only: Step 0, to record a non-default root the user chose. Paths in this document assume the default root.

## Step 0 — First run in a repo

Runs once: when there is no `docs/work/` and no `.devflow.yml`.

```bash
ls -d docs docs/work docs/decisions-log docs/development-guidelines.md .devflow.yml 2>/dev/null
```

**`docs/` doesn't exist** → create `docs/work/` and say so in one line.

**`docs/` exists** → it's already someone's namespace. Say what devflow will add inside it (`work/`, `decisions-log/`, `development-guidelines.md`), report any collision (one of those paths already present with content devflow didn't write), and ask:

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

Resuming means reading `STATUS.md`, `slices.md` and the current slice's plan. Don't reread closed phases in full.

## Step 1 — Opening questions

One at a time, in this order. Each answer determines the next question.

1. **What do you want to build?** In the user's words. Becomes `description` in the frontmatter.
2. **Code name?** A short lowercase slug with hyphens. Check it isn't taken, archive included:
   ```bash
   ls -d docs/work/*<slug>* 2>/dev/null
   grep -n "<slug>" docs/work/archived.md 2>/dev/null
   ```
3. **Source material?** Call transcripts, threads, notes. If yes, ask for paths: the frame starts from them with `framing-doc`.
4. **The visible-outcome test.** *Can you already say in one sentence what changes for the product's users, without answering "it depends"?* **Yes** → technical work: skip to slicing. **No** → product work: start from the frame. State your reading rather than asking cold: *"I read this as product work: describing the outcome I'd say 'it depends on which pages change'. If it's already defined for you, I'll skip to slicing."*
5. **If product work: is the problem already clear?** Yes → skip the frame, start from shaping. No → frame, using `brainstorming` as the dialogue technique.

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

<!-- date — done — remaining — blockers -->
```

`work:` is the bare slug; the date lives in the directory name. `phase:` says where the work is; when it's `slice`, `slice:` and `step:` say which slice and where in it. Without these three fields an interrupted work shows up the next morning as finished, or as never started.

## Step 3 — Define: from problem to slices

For each phase: invoke the tool telling it where to save, commit, update `phase:`, stop.

| `phase:` | When | Tool | Produces |
|---|---|---|---|
| `frame` | The problem isn't defined yet | `framing-doc` with source material, else `brainstorming` | `frame.md` |
| `shaping` | Several solutions with different outcomes | `shaping` | `shaping.md` |
| `breadboard` | Parts and their wiring aren't obvious; applies to architecture too, not only UI | `breadboarding` | `breadboard.md` |
| `slicing` | Always, even with one slice | `shaping` (slicing section) or `breadboarding` | `slices.md` |
| `impact` | Always, after slicing | Subagents, one lens each (below) | Corrections in `slices.md` |

**`slices.md` is the high-level plan.** Per slice: what's in, what's out, how it's demonstrated (the "Done"), known gotchas. It's the mandate every detailed plan must honor, and where closed slices leave lessons for the next ones. Every slice ends in something you can see or run; a slice with no visible outcome is a horizontal layer, not a slice.

**The path instruction is mandatory on every invocation.** Without it, the tool uses its own default:

> Save to `docs/work/2026-09-02-mobile-menu/shaping.md`. Don't use default paths.

> Save the plan to `docs/work/2026-09-02-mobile-menu/V2-plan.md`. **Not** in `docs/superpowers/plans/`.

**If a point stays vague** (a requirement nobody can decide, an alternative that won't close), invoke `grill-me` on that point before moving on. It's a tool for tightening, not a phase.

**If an unknown is technical** (how a library behaves, what a piece of code really does, whether a platform limit holds), it's a spike: a `spike-<topic>.md` with questions and outcomes, done before the plan of the slice that depends on it. A plan is not written on top of a guess.

**If a phase isn't needed**, say so and skip: *"The affordances here are three calls to an existing endpoint: skipping the breadboard."* Never silently.

### `phase: impact`, once, on `slices.md`

The slices against the real code, before the first plan. Subagents in parallel, one per lens, each with the word `ultrathink` in the prompt you pass. Lenses live in `lenses.md`: the common ones plus the detected stack's. Each subagent reads `slices.md`, `shaping.md` and `breadboard.md` if present, `docs/decisions-log/` and `docs/development-guidelines.md` if present, and the code the slices touch.

Not in session: whoever just ran the shaping is the worst head for seeing what breaks elsewhere.

One entry per problem, by severity: **what** · **where** (`file:line`) · **why it's a problem** · **proposed fix**. Presented one at a time, waiting for the answer. If a lens finds nothing, say so: silence reads as "didn't run".

Approved corrections go into `slices.md`. If a correction splits or reorders slices, go back to `phase: slicing`.

On a one-slice work, impact is often the check that saves you: the twenty-line fix that breaks another page. Always propose it; the user may skip it.

## Step 4 — The slice loop

From here `phase: slice`. For each slice, in `slices.md` order, four steps. `step:` in `STATUS.md` says which.

### `step: plan`

Invoke `writing-plans` with the slice's section of `slices.md`, `shaping.md` and `breadboard.md` if present, `docs/development-guidelines.md` if present (the plan's tests, naming and structure must follow it), and **the lessons left by closed slices**. Path: `V<n>-plan.md` in the work's home, with the explicit path instruction.

Writing the plan surfaces deviations from the mandate: an affordance better moved to another slice, a file that doesn't exist, a mechanism the shape didn't foresee. State them to the user and record them in `slices.md` under **"Deviations found while planning V<n>"**. The high-level document stays true.

### `step: review`

The plan against the documents, by a subagent with `ultrathink`, never in session: whoever just wrote the plan is the worst head for finding its contradictions. It reads the plan, `slices.md` in full, `shaping.md` and `breadboard.md`, the closed slices' lessons, and `docs/decisions-log/` and `docs/development-guidelines.md` if present.

| Lens | Looks for |
|---|---|
| **Mandate fidelity** | The plan does things the slice doesn't call for; contradicts a shaping or breadboard choice; the Done criteria aren't covered by the tasks |
| **Ignored lessons** | A rule written by a closed slice that the plan doesn't follow; the same mistake already made and documented |
| **Existence** | The files, symbols and methods the plan names exist, and do what the plan assumes |
| **Guideline compliance** | Tests, naming, function size and code placement in the plan follow `docs/development-guidelines.md`, if present |

With one plan, the lenses fit in one subagent. Corrections one at a time. Plans to correct go back through `writing-plans` with the inconsistency and the approved fix, plus a three-line statement of what changed: a regenerated plan is long, and a three-line fix shouldn't force a full reread.

### `step: execute`

`subagent-driven-development` on the plan, passing `docs/development-guidelines.md` if present: implementers and reviewers must follow it. One subagent per task, an independent review per task. That skill runs without stopping between tasks: that's how it works and it isn't changed here. The return to the user sits before (plan and review) and after (close).

If execution finds the plan wrong at a point the subagent's ruling can't cover: stop, fix the plan, restart from the interrupted task.

### `step: close`

1. Verify the slice's Done as written in `slices.md`, plus the gate: the `## Gate` section of `docs/development-guidelines.md` if present, else tests green, typecheck or lint green, build green. If the slice is a refactor, the Done is a regression checklist written before starting and run by hand before committing: a "look, nothing changed" demo proves nothing unless it's a list of things to try.
2. Write in `slices.md`, under the slice, a section **"V<n> — done on <date>"** with what execution revealed that matters for later slices. When a finding is a rule, phrase it as one: *"before declaring something unused, grep all of `src`, value and setter, and say in the report where you looked."*
3. Tick the slice in `STATUS.md`, set `slice:` to the next one and `step:` to `plan`, add a Log line.
4. Commit, stop, ask: *"V3 closed and committed. Write the plan for V4, or stop here?"*

A closed slice isn't reopened. If a later slice finds an earlier one was wrong, the fix goes into the current slice, stated in `slices.md`, or becomes a new slice at the end.

## Step 5 — Close every step

Applies to the definition phases and to the four loop steps. Four moves, in order:

1. **Commit** the document or code just produced. Explicit `git add` on the touched files, never `-A` or `.`: the working tree may hold unrelated work. Imperative messages, in the language the repo already uses.
2. **Update `STATUS.md`**: `phase:`, `slice:`, `step:`, `updated:`, Log line. After a verification the line states the outcome: *"09-02 — impact on slices.md: 2 problems, fixed in V2 and V4"*.
3. **Ask whether a choice should be recorded.** Apply the criterion in `decisions-log.md` next to this skill: a real alternative discarded, a known problem deferred on purpose, a behaviour that will surprise whoever reads the code. If it applies, propose `docs/decisions-log/YYYY-MM-DD-<slug>.md` in that format; never write it unasked. Now is the time: in two weeks the reason has faded.
4. **Stop and ask** before the next step.

## Step 6 — Exit

When the last slice is closed and the user confirms the work is complete, run the closing sequence. Each step asks before running; the user may stop at any point.

1. **Close the work.** `phase: done`, `status: closed`, final Log line, commit.
2. **Docs.** Ask, then invoke `devflow-docs`: changelog entry and `.version`, committed on the branch.
3. **Archive.** Ask, then invoke `devflow-archive`: the work folder moves to `docs/work/archive/`, committed on the branch.
4. **Report.** Where the work lived, phases done and skipped (with why), slice count, what the verifications found, version assigned. Then say it plainly: the branch is ready to merge into `main`. Devflow doesn't merge or push.

Code, changelog, version and archived work land on `main` in one changeset. If the merge review asks for changes that need the work's documents, move them back with `git mv`: they're plain files in git.

## The short path

**A bugfix is a one-slice work.** Same skill: the visible-outcome test sends it straight to slicing (`slices.md` with V1 and its Done), impact if it touches more than one file, then the loop once. No frame, shaping, breadboard.

**A small project doesn't need every phase.** State the path at opening: *"I read this as technical work in three slices: skipping frame, shaping and breadboard, doing slicing and impact, then the loop."*

## The full lifecycle

| Moment | Skill | Owner |
|---|---|---|
| Opening, definition, slice loop | `devflow` | this repo |
| A slice's plan | `writing-plans` | superpowers |
| A plan's execution | `subagent-driven-development` | superpowers |
| Changelog and version | `devflow-docs` | this repo |
| Archiving | `devflow-archive` | this repo |

`shaping`, `breadboarding`, `framing-doc`, `brainstorming`, `grill-me` aren't in the table because they aren't moments: they're tools this skill picks up when needed.
