---
shaping: true
work: flow-own-engine
tags: [shaping, flow-own-engine]
description: "Requirements, the selected shape and its open parts for flow-own-engine; release split under discussion."
---

# Flow's own engine — Shaping

The criterion is in [`frame.md`](frame.md#the-criterion). Every requirement below traces to a section of the frame's Outcome.

## Requirements (R)

| ID | Requirement | Status |
|----|-------------|--------|
| **R0** | **Flow plans and runs a work by itself, with no dependency on superpowers** | Core goal |
| R0.1 | A slice plan is written and reviewed by a fresh head with Flow's own instructions | Must-have |
| R0.2 | Execution dispatches one executor per task and a reviewer per task, with reports on file and a ledger that survives compaction | Must-have |
| R0.3 | Rules taken from superpowers credit the source and its MIT licence | Must-have |
| **R1** | **What Flow can't infer is asked once and kept in one named place** | Core goal |
| R1.1 | Stack, test level with sensitive areas, and merge style are inferred when possible, else asked | Must-have |
| R1.2 | Every start asks only for the pieces of the profile still missing; nothing asked twice | Must-have |
| R1.3 | Project settings are committed and shared; personal settings are never committed and never change the team's gate | Must-have |
| **R2** | **No agent writes or runs more tests than the project asked for** | Core goal |
| R2.1 | Three levels: none, essential (declared areas), full (TDD on new code) | Must-have |
| R2.2 | A work can raise the level for itself at opening; the project's level is unchanged | Must-have |
| R2.3 | A task runs only the tests of the code it touched; the full suite runs once, at the slice gate | Must-have |
| **R3** | **Each subagent runs on a model and effort chosen for its role, and the user can override them** | Must-have |
| R3.1 | No `ultrathink` anywhere; effort is set explicitly where it pays (impact, plan, plan review) | Must-have |
| R3.2 | Model choice is expressed by tier, not by an ID that ages | Must-have |
| **R4** | **Knowledge about a framework is loaded only in projects of that framework** | Must-have |
| R4.1 | One file per stack: peculiarities, impact lenses, reference skills or docs, gate commands, proposed test level | Must-have |
| R4.2 | The plugin ships files only for stacks in use and no opinions of its author; a user or small team adds or replaces stack files without forking | Must-have |
| R4.3 | Skills a stack file points to are optional dependencies reported only in that stack's projects | Must-have |
| R4.4 | `docs/development-guidelines.md` is drafted by Flow, short: references, test level, gate, project deviations; existing code conventions win | Must-have |
| **R5** | **The work happens where the user already looks** | Must-have |
| R5.1 | A work is a branch in the main checkout; a worktree only on request | Must-have |
| R5.2 | No server runs where the user can't reach it; if one is started, its folder, port and URL are reported and it is stopped | Must-have |
| R5.3 | The close proposes a local merge and runs it after an ok; a PR only on request or by project rule; push and tag need an ok | Must-have |
| R5.4 | One commit per task meeting the atomic-commit criteria (green, working, no dead code, one kind of work) | Must-have |
| **R6** | **Every rule about a document is written in exactly one place** | Core goal |
| R6.1 | The work's state (home, `STATUS.md`, transitions, `slices.md`, `lessons.md`, archive, `archived.md`) has one shared definition read by every conductor | Must-have |
| R6.2 | Permanent memory (decisions, changelog, version, search) has one owner the conductors ask, without loading its formats | Must-have |
| R6.3 | One decision format for code and non-code projects, with the contents of the decisions-log brief | Must-have |
| R6.4 | Both layouts are served: `docs/` in a repo, the project folder for non-software projects | Must-have |
| **R7** | **Flow has its own tools to widen and to narrow** | Must-have |
| R7.1 | Widening never executes: a clear, small request exits back to the caller | Must-have |
| R7.2 | Both write where the caller says; nothing under a third-party path | Must-have |
| R7.3 | Visual aids are proposed and the user decides; no local server | Must-have |
| R7.4 | Narrowing asks the whole frontier per round with recommendations, anchors on the criterion, lets the user park a question | Must-have |
| R7.5 | Both usable standalone and inside a work | Must-have |
| **R8** | **A project used with the old skills is upgraded when reopened, with consent** | Must-have |
| R8.1 | Old traces recognised in one place only; no silent fallbacks elsewhere in the plugin | Must-have |
| R8.2 | One message lists the changes; runs after an ok; committed on a branch, never on `main` | Must-have |
| R8.3 | A project's `CLAUDE.md` is never edited; old-format decisions are read as legacy | Must-have |

Cross-cutting, from the frame's constraints: everything in English; nothing names a personal project or tool.

## A: Flow's own engine, in three layers

The shape the frame already describes. Parts flagged ⚠️ wait on a spike.

| Part | Mechanism | Flag |
|------|-----------|:----:|
| **A1** | **Project profile** | |
| A1.1 | At every start the conductor reads `.flow.yml` (stack, merge style) and the `## Tests` section of the guidelines; for each missing piece it infers a proposal and asks, all in one message; answers written back to those files | |
| A1.2 | 🟡 Personal settings declared as `userConfig` in `plugin.json`: prompted at install, stored in the user's settings (never in a repo), read by skills as `${user_config.KEY}`. Model preferences live here | |
| A1.3 | At opening, the work's request is checked against the sensitive areas; a raise is proposed and written as `tests:` in the work's `STATUS.md` | |
| **A2** | **Stack files** | |
| A2.1 | `stacks/<name>.md` in the plugin, one per stack in use; the common lenses become their own file; `lenses.md` is removed | |
| A2.2 | 🟡 Where stack knowledge comes from and how a user replaces it: see A2.2-A / A2.2-B below | ⚠️ |
| A2.3 | First-run draft of `docs/development-guidelines.md` from the resolved stack file, the repo's observed conventions and the profile answers | |
| A2.4 | `dependencies.md` gains per-stack optional rows; the start check reports only the current stack's | |
| **A3** | **Engine** | |
| A3.1 | Plan instructions owned by Flow (task level, files, verification, done, dependencies, `critical`), replacing `writing-plans` | |
| A3.2 | Executor and task-reviewer prompts owned by Flow, with the slice packet, the test policy and the commit rules; ledger and reports in the work folder | |
| A3.3 | 🟡 One plugin agent per role in `agents/` (planner, plan reviewer, impact, executor, task reviewer), each with `model` as an alias (`opus`, `sonnet`, `fable`) and `effort` in its frontmatter. A user preference (A1.2) or an explicit request is passed as the per-call `model`, which wins over the definition; `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` remains the user's global lever | |
| A3.4 | Test policy text injected in executor and reviewer prompts: level, areas, focused runs only; full suite at the gate | |
| A3.5 | `superpowers` removed from `dependencies.md`; every reference to its skills removed | |
| **A4** | **Branch, server and merge** | |
| A4.1 | Step 2 creates `work/<slug>` in the current checkout; a worktree only when the user asks | |
| A4.2 | Server rule in executor prompts: don't start servers; if needed, report folder, port, URL and stop at step end | |
| A4.3 | Closing sequence: local merge after an ok; `merge: pr` in `.flow.yml` or the user's request switches to a PR | |
| **A5** | **Work layer** | |
| A5.1 | One reference file in the plugin holding home, `STATUS.md` format and transitions, `slices.md`, `lessons.md`, archive and `archived.md`; both conductors read it | |
| A5.2 | Archiving moves from `flow:archive` into the work layer; `/flow:archive` stays as a thin entry point | |
| **A6** | **`flow:docs`** | |
| A6.1 | 🟡 `flow:docs` with `context: fork` and `background: false`; a conductor invokes it through the Skill tool with a self-contained request and receives a one-line result (runtime test in the spike) | |
| A6.2 | Unified decision format (kinds, fixed headings, `## Reopen when`, `touches:`, `area:`, status log), variant without `touches:` for non-code projects; check script | |
| A6.3 | Changelog and version operations moved in from `flow:changelog`; `/flow:changelog` stays as a thin entry point | |
| A6.4 | Memory search by key words and by `touches:` against the plan's files | |
| **A7** | **Widen and narrow** | |
| A7.1 | `flow:brainstorm`, ported from superpowers' `brainstorming`: exit instead of execute, caller's path, artifacts proposed, builder check kept | |
| A7.2 | `flow:grill`, from `grilling`: frontier rounds, criterion anchor, caller's target, parked questions list | |
| A7.3 | `dev` and `project` definition path: brainstorm → grill → frame; inside a slice, grill on the doubt | |
| **A8** | **Upgrade** | |
| A8.1 | One upgrade step in the work layer: recognises old traces, lists changes, runs after an ok, commits on the work's branch or `work/flow-upgrade` | |
| A8.2 | The fallback sentences for `.devflow.yml` and "devflow work … merged" are removed from every skill | |

### A2.2: where stack knowledge lives

| Alt | Mechanism |
|-----|-----------|
| **A2.2-A** | Markdown files. The plugin ships `stacks/<name>.md`; `userConfig` holds the path of a user folder (e.g. a git repo shared by the team) whose `<name>.md` replaces the plugin's; `.flow.yml` can name a project file. Read with the Read tool, outside the working directory |
| **A2.2-B** | Skills. Each stack is a skill (the plugin ships `flow:stack-<name>` for stacks in use); `userConfig` and `.flow.yml` can map a stack to another skill, e.g. one in the user's own plugin. Flow invokes the resolved skill by name; nothing else about other stacks is loaded beyond the skill listing |

| Req | Requirement | Status | A2.2-A | A2.2-B |
|-----|-------------|--------|--------|--------|
| R4.1 | One file per stack: peculiarities, impact lenses, reference skills or docs, gate commands, proposed test level | Must-have | ✅ | ✅ |
| R4.2 | The plugin ships files only for stacks in use and no opinions of its author; a user or small team adds or replaces stack files without forking | Must-have | ✅ | ✅ |
| R1.3 | Project settings are committed and shared; personal settings are never committed and never change the team's gate | Must-have | ✅ | ✅ |
| R1.2 | Every start asks only for the pieces of the profile still missing; nothing asked twice | Must-have | ❌ | ✅ |

**Notes:**
- A2.2-A fails R1.2: reading a folder outside the working directory can prompt for permission on every start, unless the user adds an allow rule (spike: personal settings, S3-Q4).
- A2.2-B: a stack skill can also preload or point to external skills (e.g. thoughtbot's), and a team shares it the way it shares any plugin. Cost: each shipped stack adds one line to the skill listing.

### Fit check: R × A

| Req | Requirement | Status | A |
|-----|-------------|--------|---|
| R0 | Flow plans and runs a work by itself, with no dependency on superpowers | Core goal | ✅ |
| R1 | What Flow can't infer is asked once and kept in one named place | Core goal | ❌ |
| R2 | No agent writes or runs more tests than the project asked for | Core goal | ✅ |
| R3 | Each subagent runs on a model and effort chosen for its role, and the user can override them | Must-have | 🟡 ✅ |
| R4 | Knowledge about a framework is loaded only in projects of that framework | Must-have | ❌ |
| R5 | The work happens where the user already looks | Must-have | ✅ |
| R6 | Every rule about a document is written in exactly one place | Core goal | 🟡 ✅ |
| R7 | Flow has its own tools to widen and to narrow | Must-have | ✅ |
| R8 | A project used with the old skills is upgraded when reopened, with consent | Must-have | ✅ |

**Notes:**
- 🟡 R1, R4 fail on A2.2 only: the choice between A2.2-A and A2.2-B is open.

## Release

🟡 Decided 2026-10-26: **one release, v0.2.0**, one branch, slices in dependency order, one merge. `main` is the release (projects declare the marketplace without a ref), so no half state may reach it, e.g. superpowers removed before the engine replaces it. Discarded: several releases, one work each.

## Spikes

- [`spike-skill-context.md`](spike-skill-context.md) — A6.1
- [`spike-model-effort.md`](spike-model-effort.md) — A3.3
- [`spike-personal-settings.md`](spike-personal-settings.md) — A1.2, A2.2
