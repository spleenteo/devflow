---
name: project
description: Use when planning and running a project that isn't software, where people do the work over weeks or months. A renovation, a client engagement, a strategy, a personal plan. Triggers include "/flow:project", "let's plan X", "open the project X", "resume X", "next slice of X". Lives in a folder, never in a code repo; a slice that turns out to be software hands off to /flow:dev.
---

# Flow: project

Running `/flow:project` is the user's explicit choice of process: inside it no other process skill applies (brainstorming, grilling, planning, plan execution, test-driven development or worktree skills, from any plugin or personal). Name `flow:brainstorm` and `flow:grill` by their qualified names.

Runs a project from idea to done, one slice at a time, when the executor is people rather than code.

Same skeleton as `/flow:dev`: the high-level plan is the slice list produced by shaping; each slice's action plan is written right before it starts, after the previous one is closed, because the world changes between slices and a plan written months earlier ignores it. What changes: the home is a folder, execution happens in the world and the skill records it, verification checks reality (money, time, people, permissions) instead of code.

## Why

`framing-doc` (`shaping-skills:framing-doc`), `shaping` (`shaping-skills:shaping`) and `kickoff-doc` (`shaping-skills:kickoff-doc`) are thinking tools, and Flow's own `flow:brainstorm` and `flow:grill` join them for a problem that isn't clear. They don't know each other, don't know where the project lives, and carry no state across weeks. A project that spans months needs three things on disk: where we are, what was decided and why, what the last slice taught. This skill keeps the thread and invokes each tool at the right moment, telling it where to write.

## What it does NOT do

| Doesn't | Why |
|---|---|
| Write all action plans up front | A slice's plan is written when that slice is next |
| Execute anything | People do. It records what happened, and asks |
| Run past a stop | Two stops per slice: after the reviewed plan, after the close |
| Apply corrections on its own | Verifications report in one ranked message with a recommendation per finding; the user decides with one answer |
| Write code or run `/flow:dev` itself | A slice that is software becomes a `/flow:dev` work in its repo; this skill keeps the Done |
| Touch files outside the project's home | It writes only inside the folder chosen at opening |
| Install its dependencies | It prints the commands from `dependencies.md`; the user runs them |

**The rule that matters most**: a long session where the skill barrels ahead is worse than no skill. At the two stops of every slice, return to the user.

## Conventions

| What | Convention |
|---|---|
| Home | The folder the user names at opening, never a code repo's `docs/` |
| Work reference | Home, `STATUS.md`, slice bookkeeping, close and archive for the **project** layout: `${CLAUDE_PLUGIN_ROOT}/shared/work.md` (in the repo: [shared/work.md](../../shared/work.md)), called "the work reference" below |
| Files | `STATUS.md`, `brainstorm.md`, `frame.md`, `shaping.md`, `kickoff.md`, `slices.md`, `lessons.md`, `S<n>-plan.md`, `constraints.md`, `decisions/`, `report.md`, `docs/design/` (design files and their index, in the top home, the one with `parent: null`, written by `/flow:design`) |
| Constraints | `constraints.md`: appetite, non-negotiables, people and roles, calendar. Template in `${CLAUDE_SKILL_DIR}/constraints.template.md` |
| Decisions | `decisions/YYYY-MM-DD-<slug>.md`. Proposed here, written by `flow:docs` on a yes. Criterion and requests: the work reference, § Decisions |
| Sub-projects | A slice too big for one plan becomes a sub-project: the work reference, § Home |

Slices are at most nine per level. More than nine means the level is wrong: group them, and open sub-projects when their turn comes.

## Project memory

Before writing anything new, search the home and its siblings through `flow:docs`: invoke the Skill tool with skill `flow:docs` and args one line, self-contained, since the fork sees no conversation:

```
op: search, layout: project, dir: <absolute folder holding the projects>, keywords: <k1>, <k2>
```

`dir` is the parent of the home; at Step 1, before the home exists, the parent of the folder proposed for question 3 (the documents vault, say). A neighbouring project may hold a decision or a lesson about the same supplier, the same person, the same constraint. It returns at most ten `path — excerpt` lines, or `none`; read only the files they name.

## Cost discipline

Few subagents here: two at the reality check, one per plan review. The cost is the user's time. The top tier runs the reality check, the reviews and the fidelity check, where a missed hole costs most. Three rules:

1. **Two stops per slice.** After the reviewed plan, after the close. Plan and review run back to back.
2. **One message per verification.** Findings ranked by severity, each with a recommended action, one question at the end.
3. **Packets, not documents.** A subagent gets the slice's section of `slices.md`, `lessons.md`, `constraints.md`, the matching decisions, and the plan. Not `shaping.md` unless the slice's section points to it.

## Models

Flow's agents are in `${CLAUDE_PLUGIN_ROOT}/agents/` (dispatched as `flow:<name>`). Preference for the top tier: `${user_config.model_top}`; for the mid tier: `${user_config.model_mid}`. A value that is empty, or begins with `${`, is unset. Which model each dispatch takes, the dispatch contract and the ledger: the work reference, § Agents (`${CLAUDE_PLUGIN_ROOT}/shared/work.md`).

## Dependencies

Runs first, on every invocation: before anything else in this skill and before any file is written. The skills this one hands work to are listed in `${CLAUDE_PLUGIN_ROOT}/dependencies.md` (in the repo: [dependencies.md](../../dependencies.md)). Read it and compare it with the skills listed in the session: a dependency is present when a listed skill has its name, or its segment after `:` equals it.

If any are missing, report them in one message, required first, then optional. For each: the install commands from `dependencies.md` at user and project scope and the phase that needs it (from this skill's tables). Never install anything, and don't block the start: the check at each phase stops it if needed.

At a phase or step that invokes a dependency, check again: if a required one isn't listed, stop that phase and give its commands from `dependencies.md`; don't do its job without it.

## On start: open or resume

The dependency check (`## Dependencies`) has already run. Once the home is known, check it and its sub-projects for old traces as the work reference, § Upgrade, says. When there are some, follow that section: one message, one question, and the run ends there, opening or resuming nothing.

```bash
rg "^phase:" <home>/STATUS.md <home>/*/STATUS.md 2>/dev/null
```

- No `STATUS.md` → new project (Step 1).
- `phase:` other than `done` → say so and ask:

> "`Kitchen-renovation` is at slice **S3**, step **execute**, last log 2026-08-28. Resume there, or open a new project?"

Resuming reloads the **standing documents**, and nothing else:

| Always reloaded | Never reloaded |
|---|---|
| `STATUS.md`; `constraints.md`; the `## The criterion` block of `frame.md`; `lessons.md`; the `description:` line of each file in `decisions/`; the current slice's plan | `brainstorm.md`; `shaping.md`; `kickoff.md`; closed plans; `spike-*.md`; `frame.md` below its criterion |

A standing document is one that is still true. A closed phase is a debate that ended. The frame belongs to the first kind: it carries the criterion every later document is measured against, and a project that resumes without it resumes on whatever was written last, which is usually a detail.

Open with what you reloaded, in five lines — project, phase and slice, spent against appetite, the criterion in the frame's own words, the blockers from the last Log line — then ask. The user has to be able to see that the frame is in the room.

## Step 1 — Opening

One message, seven questions, each with the answer this skill proposes from what it already knows. The user corrects what's wrong and answers what's missing.

1. **What do you want to achieve?** In the user's words. Becomes `description` in the frontmatter.
2. **Name?** The folder name. Check it doesn't exist.
3. **Where does it live?** Ask for the folder; inside a documents vault, propose `<vault>/<Name>/`.
4. **Appetite.** How much time and how much money, as a box, not an estimate: *"three months and 20k, then we stop and look."* Becomes `appetite:` in the frontmatter and the first section of `constraints.md`.
5. **Who's involved?** People and roles: who does, who decides, who must be asked. Goes into `constraints.md`.
6. **Source material?** Call transcripts, notes, messages, documents. If yes, the frame starts from them with `framing-doc`.
7. **The visible-outcome test.** *Can you already say in one sentence what will be true when this is done, without answering "it depends"?* **Yes** → skip to slicing. **No** → start from the frame; and if the problem itself isn't clear, the definition path: `flow:brainstorm` (path `<home>/brainstorm.md`), then `flow:grill` (target `brainstorm.md`; `layout: project`, `dir`, `project`, `slice: null` (no slice before slicing) and `area` (from `areas:` in the configuration file, else a free kebab-case word per the work reference § Decisions) for decision candidates), then the frame. State your reading rather than asking cold.

Before sending the message, check the project memory with the key words of the request (`flow:docs`, `op: search`, `layout: project`, `dir` the parent of the folder proposed for question 3) and flag what it finds.

## Step 2 — Create the home

```bash
mkdir -p "<home>"
```

With `STATUS.md` inside, from the work reference, § `STATUS.md` (project): `appetite:` from question 4, `description:` from question 1, **Entry** from question 7.

And `constraints.md` from the template, filled with the answers to questions 4 and 5. It's the file every plan and review reads: keep it short and true.

`lessons.md` is created at the first slice close (the work reference, § `slices.md` and `lessons.md`).

## Step 3 — Define: from problem to slices

For each phase: invoke the tool telling it where to save, update `phase:`, stop. These phases are dialogues; the stops are natural.

| `phase:` | When | Tool | Produces |
|---|---|---|---|
| `frame` | The problem isn't defined yet | `flow:brainstorm` → `flow:grill`, then `framing-doc` with source material, else this skill writes the frame from `brainstorm.md` | `brainstorm.md`, `frame.md` |
| `shaping` | Several ways with different outcomes | `shaping`, with the appetite as a hard constraint on every shape | `shaping.md` |
| `kickoff` | The people who will execute meet to agree on the shape | `kickoff-doc` on the call's transcript | `kickoff.md` |
| `slicing` | Always, even with one slice | `shaping` (slicing section) | `slices.md` |
| `reality` | Always, after slicing | `flow:impact`, two, or one (below) | Corrections in `slices.md` |

If the tool the row picks for the case at hand isn't listed in the session (`kickoff-doc` included), stop that phase and give its commands from `dependencies.md`. Never swap in another tool for a missing `framing-doc`.

**The definition path.** A problem that isn't clear runs `flow:brainstorm`, passing `<home>/brainstorm.md`; then `flow:grill` with that file as target; then the frame. With source material the frame is `framing-doc`, given `brainstorm.md` too. Without, this skill writes `frame.md` with the `## The criterion` block on top, built from `brainstorm.md` and the grill's answers, and carries the parked questions into its body. All of them are committed in the home only when it is under version control (the work reference § Commits); else the files are the record. The `flow:grill` calls pass the decision fields as in Step 1, plus the `frame.md` path once the frame exists so the criterion anchor applies. Its early exits: on a clear request or a small change, go back to Step 1's question and treat the problem as clear (slicing or shaping, as that question says); on "skipped", run `flow:grill` with `brainstorm.md` created as its target, holding the request as given, then the frame.

### The criterion

`frame.md` opens, right under the frontmatter, with a block of at most ten lines:

```markdown
## The criterion

- **Problem**: <one sentence>
- **Outcome**: <observable in the world, one sentence>
- **Less about**: <what this is explicitly not, named while it is still tempting>
- **Measure**: <what tells us a document is serving this>
```

Everything else in the frame is body: sources, transcripts, numbers, the history of the reasoning. The block is the part that travels — on resume, into every definition phase, into every slice packet — so it has to survive being read alone. Keep source material out of it, and when a transcript already exists as a file, link it instead of copying it in.

A frame written before this convention gets the block added at the top of its next update, built from what it already says and confirmed with the user.

`breadboarding` (`shaping-skills:breadboarding`) is not in the table: it maps places and affordances of a system. Use it only when the project *is* a system (a service process, a workflow between people and tools), and say so.

**`slices.md` is the high-level plan.** Per slice: what's in, what's out, the **Done** as something observable in the world (a document signed, a room usable, a client's yes, a delivery received), the known gotchas, and its order. Order by what unlocks or de-risks the rest first, then by dependency. A slice with no observable outcome is a phase, not a slice.

**The path instruction is mandatory on every invocation.** Without it, the tool uses its own default:

> Save to `<home>/shaping.md`. Don't use default paths.

**The criterion travels with every invocation.** `shaping`, `framing-doc` and `kickoff-doc` don't know the project: put the `## The criterion` block and `constraints.md` verbatim at the top of the prompt, above the path instruction. Without them a shape can contradict the frame, and the contradiction surfaces only when a human reads the finished document.

**If a point stays vague** (a requirement nobody can decide, an alternative that won't close), invoke `flow:grill` with the point and the document it belongs to as target (and the `frame.md` path, so the criterion anchor applies), passing the decision fields as in Step 1 with the current slice, and committing the target afterwards per the work reference, before moving on: it closes the point in rounds or the user parks it.

**If an unknown is factual** (does the permit apply, what does the supplier charge, is the person available), it's a spike: a `spike-<topic>.md` with questions and answers, done before the plan that depends on it. A plan is not written on top of a guess.

**If a phase isn't needed**, say so and skip. Never silently.

### `phase: reality`, once, on `slices.md`

The slices against the world, before the first plan. Two `flow:impact` dispatches in parallel, each with its lenses from the table in the packet. Packet: `slices.md` in full, `constraints.md`, `shaping.md` if it exists, the matching decisions. The Pre-mortem lens is the exception to evidence-only: hypotheses allowed, each with the slice it hits and the cheapest check to run now.

| Dispatch | Lenses |
|---|---|
| **Resources** | **Money**: cost per slice against the appetite; what's unpriced; when payments fall. **Time**: durations, lead times of third parties, seasons and holidays, hard dates. **People**: who does each slice, availability, who must say yes and hasn't yet. **Permissions and rules**: permits, contracts, warranties, insurance, legal constraints |
| **Sequence** | **Dependencies and reversibility**: what must happen before what; what can't be undone; where the point of no return sits and what must be certain before it. **Existence**: the suppliers, documents, budgets, tools and people the slices name exist and are reachable. **Pre-mortem**: it's six months later and the project failed; the three most likely reasons, each with the slice it hits and the cheapest check to run now |

On a one-slice project, one `flow:impact` with all the lenses.

Report in one message: findings ranked by severity, each as **what** · **where** (slice) · **why it's a problem** · **recommended fix**; lenses that found nothing named as such; one question at the end: *"Apply the recommended fixes? Say which to skip."*

Approved corrections go into `slices.md`. If a correction splits or reorders slices, go back to `phase: slicing`. If it changes the appetite, the user decides and `constraints.md` records it.

## Step 4 — The slice loop

From here `phase: slice`. For each slice, in `slices.md` order, four steps and two stops. `step:` in `STATUS.md` says which.

**The slice packet**, built once per slice and placed verbatim at the top of every subagent prompt in it: the `## The criterion` block; the slice's section of `slices.md`; `lessons.md`; `constraints.md`; the matching decisions.

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
<open questions; settle them with `flow:grill`, target this plan, `frame.md` path and decision fields passed>
```

An action that is software is written as *"flow:dev work `<slug>` in `<repo>` merged"*, and that work is opened in its repo with `/flow:dev` when its turn comes. A slice that needs its own plan of several slices becomes a sub-project (the work reference, § Home); the parent slice's Done becomes "sub-project done".

**Design actions.** An action is written *"/flow:design: <artifact>"* only when the slice's section of `slices.md` or the action's Done calls for something people will look at (a deck, a page, a poster, a flyer, a flow to click through); never for actions done in the world (calls, meetings, payments, permits). Who: the user. Done when: the user approves the artifact. While writing the plan, read `design:` from the top home's `STATUS.md` (a sub-project walks up `parent:` until it is `null`) and name the medium by `/flow:design`'s § Medium: a Claude artifact for an interactive or exploratory need, or when the top home has no `design:`; a design file through the tool for a static artifact with `design:` set. Write the medium, its reason (naming which case held) and the line to type in the row's Needs cell, and repeat them at the plan's stop; the line carries the top home's path: `/flow:design Home: "<absolute top home path>" <the artifact, in a few words>`. `/flow:design` confirms the medium when run. The line has no shaping argument, so `/flow:design` runs by hand: the user types it, in this session or another, like a `/flow:dev` row.

Writing the plan surfaces deviations from the mandate: an action that belongs to another slice, a Done that can't be observed, a cost the appetite doesn't cover. Record them in `slices.md` under **"Deviations found while planning S<n>"** and carry on to the review without stopping.

### `step: review`

Right after the plan, one `flow:plan-reviewer`, never in session: whoever just wrote the plan is the worst head for finding its holes. Packet, the plan as the object and the lens table below.

| Lens | Looks for |
|---|---|
| **Mandate fidelity** | Actions the slice doesn't call for; a Done not covered by the actions; a contradiction with the shape or with the frame's criterion |
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

If an action is a `/flow:dev` work, it's run in its repo in its own session; here it's a row that closes when that work is merged.

A *"/flow:design: <artifact>"* row closes when the user reports the artifact approved. Its files are under the top home's `docs/design/`, and ride the slice's close commit when the home is under version control (the work reference § Commits); in a plain folder the files are the record.

### `step: close`

1. Verify the Done as written in `slices.md`, with evidence the user names: the document, the photo, the invoice, the confirmation. Record what it cost in time and money against the slice's budget.
2. Lessons, in two places. The narrative under the slice in `slices.md`, as **"S<n> — done on <date>"**: what happened, what surprised, what it cost. The rules, one line each, appended to `lessons.md`: *"ask the supplier for the lead time in writing before the slice that depends on it starts."*
3. Tick the slice, set the next `slice:` and `step: plan`, add the Log line (the work reference, § `slices.md` and `lessons.md`).
4. **Second stop.** One message: what closed, the evidence, spent against budget and against the appetite so far, the new rules, the decision candidate if any with the question whether to record it, and: *"S3 closed. Plan S4, or stop here?"*

A closed slice isn't reopened; if a later slice finds it was wrong, the fix goes forward, within the appetite (same section).

## Step 5 — Closing a definition phase

Applies to frame, shaping, kickoff, slicing and reality. Four moves, in order:

1. **Fidelity check**, before anything is reported. For each requirement, shape or slice just produced: which line of the criterion does it serve? Whatever traces back to nothing is named in the report, with what it would take to keep it. On `shaping.md` and `slices.md` — the documents the rest of the project inherits, and the ones the client reads — a `flow:plan-reviewer` runs it, with a packet of the criterion (standing in for the mandate), `constraints.md`, the document alone and this lens table. On the others, in session. 
   | Lens | Looks for |
   |---|---|
   | **Criterion fidelity** | Each requirement, shape or slice names the criterion line it serves; whatever traces to none is reported with what keeping it would take |

   The frame phase checks itself differently: that the criterion block exists and that the body doesn't contradict it.
2. **Update `STATUS.md`**: `phase:`, `updated:`, Log line.
3. **Decision candidate** in the same report, when the work reference, § Decisions, says so: a real alternative discarded, a known problem deferred on purpose, a choice that will surprise whoever reads the plan later. Propose it; never write it unasked, and on a yes send the `decision-write` request that section shows.
4. **Stop and ask** before the next phase.

Commit at each of these points as the work reference says (§ `slices.md` and `lessons.md`, Commits).

## Step 6 — Exit

When the last slice is closed and the user confirms the project is complete, follow the work reference, § Closing a work (project): close, `report.md`, then offer the archive (§ Archive, project). Never archive on your own initiative.

## The short path

**A small project is a one-slice project.** Same skill: the visible-outcome test sends it straight to slicing (`slices.md` with S1 and its Done), the reality check if money or third parties are involved, then the loop once.

## Relation to /flow:dev

Same skeleton, kept in sync by hand: opening, home and state, definition phases, slicing as the high-level plan, just-in-time detail, review by a fresh head, close with lessons, decisions, memory. Different in the middle: here people execute, plans are actions, verification is reality. A slice that is software leaves this flow at its action row and comes back when the `/flow:dev` work is merged.
