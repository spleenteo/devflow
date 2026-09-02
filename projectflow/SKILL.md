---
name: projectflow
description: Use when planning and running a project that isn't software, where people do the work over weeks or months. A renovation, a client engagement, a strategy, a personal plan. Triggers include "/projectflow", "let's plan X", "open the project X", "resume X", "next slice of X". Lives in a folder, never in a code repo; a slice that turns out to be software hands off to devflow.
---

# Projectflow

Runs a project from idea to done, one slice at a time, when the executor is people rather than code.

Same skeleton as `devflow`: the high-level plan is the slice list produced by shaping; each slice's action plan is written right before it starts, after the previous one is closed, because the world changes between slices and a plan written months earlier ignores it. What changes: the home is a folder, execution happens in the world and the skill records it, verification checks reality (money, time, people, permissions) instead of code.

## Why

`brainstorming`, `grill-me`, `framing-doc`, `shaping` and `kickoff-doc` are thinking tools. They don't know each other, don't know where the project lives, and carry no state across weeks. A project that spans months needs three things on disk: where we are, what was decided and why, what the last slice taught. This skill keeps the thread and invokes each tool at the right moment, telling it where to write.

## What it does NOT do

| Doesn't | Why |
|---|---|
| Write all action plans up front | A slice's plan is written when that slice is next |
| Execute anything | People do. It records what happened, and asks |
| Run past a stop | Two stops per slice: after the reviewed plan, after the close |
| Apply corrections on its own | Verifications report in one ranked message with a recommendation per finding; the user decides with one answer |
| Write code or run `devflow` itself | A slice that is software becomes a `devflow` work in its repo; projectflow keeps the Done |
| Touch files outside the project's home | It writes only inside the folder chosen at opening |

**The rule that matters most**: a long session where the skill barrels ahead is worse than no skill. At the two stops of every slice, return to the user.

## Conventions

| What | Convention |
|---|---|
| Home | Inside a Maestro instance: `<documents_path>/<Project name>/`. Elsewhere: the folder the user names at opening. Never a code repo's `docs/` |
| Files | `STATUS.md`, `frame.md`, `shaping.md`, `kickoff.md`, `slices.md`, `lessons.md`, `S<n>-plan.md`, `constraints.md`, `decisions/`, `report.md` |
| Constraints | `constraints.md`: appetite, non-negotiables, people and roles, calendar. Template in `constraints.template.md` next to this skill |
| Decisions | `decisions/YYYY-MM-DD-<slug>.md`. Criterion and format in `decisions.md` next to this skill |
| Sub-projects | A slice too big for one plan becomes `S<n>-<slug>/` inside the home, with its own `STATUS.md` (`parent:` set) and its own slices |

Slices are at most nine per level. More than nine means the level is wrong: group them, and open sub-projects when their turn comes.

## Project memory

Before writing anything new, search the home and its siblings: `rg -il "<keywords>" <home>/.. --glob '*/STATUS.md' --glob '*/decisions/*.md' --glob '*/lessons.md'`. A neighbouring project may hold a decision or a lesson about the same supplier, the same person, the same constraint. Read only what matches.

## Cost discipline

Few subagents here: two at the reality check, one per plan review. The cost is the user's time. Three rules:

1. **Two stops per slice.** After the reviewed plan, after the close. Plan and review run back to back.
2. **One message per verification.** Findings ranked by severity, each with a recommended action, one question at the end.
3. **Packets, not documents.** A subagent gets the slice's section of `slices.md`, `lessons.md`, `constraints.md`, the matching decisions, and the plan. Not `shaping.md` unless the slice's section points to it.

## On start: open or resume

```bash
rg "^phase:" <home>/STATUS.md <home>/*/STATUS.md 2>/dev/null
```

- No `STATUS.md` → new project (Step 1).
- `phase:` other than `done` → say so and ask:

> "`Cerbaia` is at slice **S3**, step **execute**, last log 2026-08-28. Resume there, or open a new project?"

Resuming means reading `STATUS.md`, `lessons.md` and the current slice's plan. Don't reread closed phases.

## Step 1 — Opening

One message, seven questions, each with the answer projectflow proposes from what it already knows. The user corrects what's wrong and answers what's missing.

1. **What do you want to achieve?** In the user's words. Becomes `description` in the frontmatter.
2. **Name?** The folder name. Check it doesn't exist.
3. **Where does it live?** Inside a Maestro instance, propose `<documents_path>/<Name>/`; elsewhere, ask for the folder.
4. **Appetite.** How much time and how much money, as a box, not an estimate: *"three months and 20k, then we stop and look."* Becomes `appetite:` in the frontmatter and the first section of `constraints.md`.
5. **Who's involved?** People and roles: who does, who decides, who must be asked. Goes into `constraints.md`.
6. **Source material?** Call transcripts, notes, messages, documents. If yes, the frame starts from them with `framing-doc`.
7. **The visible-outcome test.** *Can you already say in one sentence what will be true when this is done, without answering "it depends"?* **Yes** → skip to slicing. **No** → start from the frame; and if the problem itself isn't clear, the frame uses `brainstorming` as the dialogue technique. State your reading rather than asking cold.

Before sending the message, check the project memory with the key words of the request and flag what it finds.

## Step 2 — Create the home

```bash
mkdir -p "<home>"
```

With `STATUS.md` inside:

```markdown
---
status: open
phase: <frame | shaping | slicing | reality | slice | done>
slice: null
step: null
project: <name>
parent: null
appetite: "<time>, <money>"
updated: YYYY-MM-DD
tags: [project, <name>]
description: "<answer to question 1>"
---

# Status — <Project name>

> Update at the **end of every session**: done, remaining, blockers.

**Entry**: <frame | shaping | slicing>, decided on <date> because <visible-outcome test answer>.

## Slices

- [ ] (defined during slicing)

## Log

<!-- date — slice — what happened — spent (time, money) — remaining — blockers -->
```

And `constraints.md` from the template, filled with the answers to questions 4 and 5. It's the file every plan and review reads: keep it short and true.

`lessons.md` is created at the first slice close: one rule per line.

## Step 3 — Define: from problem to slices

For each phase: invoke the tool telling it where to save, update `phase:`, stop. These phases are dialogues; the stops are natural.

| `phase:` | When | Tool | Produces |
|---|---|---|---|
| `frame` | The problem isn't defined yet | `framing-doc` with source material, else `brainstorming` | `frame.md` |
| `shaping` | Several ways with different outcomes | `shaping`, with the appetite as a hard constraint on every shape | `shaping.md` |
| `kickoff` | The people who will execute meet to agree on the shape | `kickoff-doc` on the call's transcript | `kickoff.md` |
| `slicing` | Always, even with one slice | `shaping` (slicing section) | `slices.md` |
| `reality` | Always, after slicing | Two subagents (below) | Corrections in `slices.md` |

`breadboarding` is not in the table: it maps places and affordances of a system. Use it only when the project *is* a system (a service process, a workflow between people and tools), and say so.

**`slices.md` is the high-level plan.** Per slice: what's in, what's out, the **Done** as something observable in the world (a document signed, a room usable, a client's yes, a delivery received), the known gotchas, and its order. Order by what unlocks or de-risks the rest first, then by dependency. A slice with no observable outcome is a phase, not a slice.

**The path instruction is mandatory on every invocation.** Without it, the tool uses its own default:

> Save to `<home>/shaping.md`. Don't use default paths.

**If a point stays vague** (a requirement nobody can decide, an alternative that won't close), invoke `grill-me` on that point before moving on.

**If an unknown is factual** (does the permit apply, what does the supplier charge, is the person available), it's a spike: a `spike-<topic>.md` with questions and answers, done before the plan that depends on it. A plan is not written on top of a guess.

**If a phase isn't needed**, say so and skip. Never silently.

### `phase: reality`, once, on `slices.md`

The slices against the world, before the first plan. Two subagents in parallel, both with `ultrathink` in the prompt. Packet: `slices.md` in full, `constraints.md`, `shaping.md` if it exists, the matching decisions.

| Subagent | Lenses |
|---|---|
| **Resources** | **Money**: cost per slice against the appetite; what's unpriced; when payments fall. **Time**: durations, lead times of third parties, seasons and holidays, hard dates. **People**: who does each slice, availability, who must say yes and hasn't yet. **Permissions and rules**: permits, contracts, warranties, insurance, legal constraints |
| **Sequence** | **Dependencies and reversibility**: what must happen before what; what can't be undone; where the point of no return sits and what must be certain before it. **Existence**: the suppliers, documents, budgets, tools and people the slices name exist and are reachable. **Pre-mortem**: it's six months later and the project failed; the three most likely reasons, each with the slice it hits and the cheapest check to run now |

On a one-slice project, one subagent with all the lenses.

Report in one message: findings ranked by severity, each as **what** · **where** (slice) · **why it's a problem** · **recommended fix**; lenses that found nothing named as such; one question at the end: *"Apply the recommended fixes? Say which to skip."*

Approved corrections go into `slices.md`. If a correction splits or reorders slices, go back to `phase: slicing`. If it changes the appetite, the user decides and `constraints.md` records it.

## Step 4 — The slice loop

From here `phase: slice`. For each slice, in `slices.md` order, four steps and two stops. `step:` in `STATUS.md` says which.

**The slice packet**, built once per slice and placed verbatim at the top of every subagent prompt in it: the slice's section of `slices.md`; `lessons.md`; `constraints.md`; the matching decisions.

### `step: plan`

Written in session with the user: the plan needs what only they know (who, when, how much). Save to `<home>/S<n>-plan.md`, under sixty lines:

```markdown
# S3 — <Slice name> · action plan

**Done when**: <the observable outcome, copied from slices.md>
**Budget for this slice**: <time>, <money>

| # | Action | Who | When | Needs | Cost | Done when |
|---|---|---|---|---|---|---|
| 1 | ... | ... | ... | ... | ... | ... |

## Risks for this slice
<from the reality check, plus what the previous slices taught>

## To settle before starting
<open questions; grill-me on each if they don't close in dialogue>
```

An action that is software is written as *"devflow work `<slug>` in `<repo>` merged"*, and that work is opened in its repo with `devflow` when its turn comes. A slice that needs its own plan of several slices becomes a sub-project: `S<n>-<slug>/` with its own `STATUS.md` and `parent:` set; the parent slice's Done becomes "sub-project done".

Writing the plan surfaces deviations from the mandate: an action that belongs to another slice, a Done that can't be observed, a cost the appetite doesn't cover. Record them in `slices.md` under **"Deviations found while planning S<n>"** and carry on to the review without stopping.

### `step: review`

Right after the plan, one subagent, never in session: whoever just wrote the plan is the worst head for finding its holes. `ultrathink` only if the slice crosses a point of no return or has more than eight actions. Packet plus the plan.

| Lens | Looks for |
|---|---|
| **Mandate fidelity** | Actions the slice doesn't call for; a Done not covered by the actions; a contradiction with the shape |
| **Ignored lessons** | A rule in `lessons.md` the plan doesn't follow |
| **Availability** | The people, suppliers, documents and money the plan names exist and are available in the window |
| **Constraints** | Appetite, calendar, non-negotiables from `constraints.md`; the point of no return placed after the checks it needs |

**First stop.** One message: the plan's table, the findings ranked with a recommended fix each, the deviations recorded, one question: *"Apply the recommended fixes and start? Say which to skip."*

Approved fixes go into the plan in place.

### `step: execute`

People act; the skill records. The user reports as things happen: *"actions 1 to 3 done, the plumber postponed to the 12th, the quote came in at 4k instead of 3k."* The skill:

- updates the plan's rows (done, blocked, changed) and the Log line in `STATUS.md` with what was spent;
- writes surprises under the slice in `slices.md` as they come, not at the end;
- proposes a decision when a real alternative is discarded on the spot (*"you chose the local supplier over the cheaper one: record why?"*);
- flags when the slice's budget or the appetite is about to be exceeded, before it happens.

If an action is a `devflow` work, it's run in its repo in its own session; here it's a row that closes when that work is merged.

### `step: close`

1. Verify the Done as written in `slices.md`, with evidence the user names: the document, the photo, the invoice, the confirmation. Record what it cost in time and money against the slice's budget.
2. Lessons, in two places. The narrative under the slice in `slices.md`, as **"S<n> — done on <date>"**: what happened, what surprised, what it cost. The rules, one line each, appended to `lessons.md`: *"ask the supplier for the lead time in writing before the slice that depends on it starts."*
3. Tick the slice in `STATUS.md`, set `slice:` to the next one and `step:` to `plan`, add the Log line.
4. **Second stop.** One message: what closed, the evidence, spent against budget and against the appetite so far, the new rules, the decision candidate if any with the question whether to record it, and: *"S3 closed. Plan S4, or stop here?"*

A closed slice isn't reopened. If a later slice finds an earlier one was wrong, the fix goes into the current slice, stated in `slices.md`, or becomes a new slice at the end, if the appetite allows.

## Step 5 — Closing a definition phase

Applies to frame, shaping, kickoff, slicing and reality. Three moves:

1. **Update `STATUS.md`**: `phase:`, `updated:`, Log line.
2. **Decision candidate** in the same report, when the criterion in `decisions.md` applies: a real alternative discarded, a known problem deferred on purpose, a choice that will surprise whoever reads the plan later. Propose `decisions/YYYY-MM-DD-<slug>.md`; never write it unasked.
3. **Stop and ask** before the next phase.

If the home is under version control, commit at each of these points, with explicit paths. If it's a plain folder (a vault, a shared drive), the files are the record.

## Step 6 — Exit

When the last slice is closed and the user confirms the project is complete:

1. `phase: done`, `status: closed`, final Log line.
2. Write `report.md`: what was done, time and money spent against the appetite, the decisions taken (linked), the lessons, what was left out and why. Written for someone who reads it in a year.
3. Offer to move the folder to `<home>/../archive/`. Never on its own initiative.

## The short path

**A small project is a one-slice project.** Same skill: the visible-outcome test sends it straight to slicing (`slices.md` with S1 and its Done), the reality check if money or third parties are involved, then the loop once.

## Relation to devflow

Same skeleton, kept in sync by hand: opening, home and state, definition phases, slicing as the high-level plan, just-in-time detail, review by a fresh head, close with lessons, decisions, memory. Different in the middle: here people execute, plans are actions, verification is reality. A slice that is software leaves this flow at its action row and comes back when the `devflow` work is merged.
