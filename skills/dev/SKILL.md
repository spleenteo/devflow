---
name: dev
description: Use when opening a development work in a repo, resuming an interrupted one, or moving to the next slice. Triggers include "/flow:dev", "open the work X", "resume X", "next slice", "where were we on X". Stack-agnostic; needs nothing in the project's CLAUDE.md.
---

# Flow: dev

Running `/flow:dev` is the user's explicit choice of process: inside it no other process skill applies (brainstorming, grilling, planning, plan execution, test-driven development or worktree skills, from any plugin or personal). Name `flow:brainstorm`, `flow:grill` and `flow:design` by their qualified names.

Runs a development work from idea to code, one slice at a time.

The high-level plan is the slice list, produced by shaping. The detailed plan of each slice is written right before executing it, after the previous slice is closed: executing slice N teaches things the plan of N+1 must contain, and a plan written weeks earlier ignores them.

## Why

The skills that do the actual work (`shaping` (`shaping-skills:shaping`), `breadboarding` (`shaping-skills:breadboarding`), `framing-doc` (`shaping-skills:framing-doc`)) come from outside, don't know each other and don't know the repo's paths: `shaping` saves wherever it lands. For a problem that isn't clear, Flow brings its own dialogue, `flow:brainstorm` then `flow:grill`, and this skill tells each where to write. Without a conductor, every work restarts the debate about which phases apply and where files go, state is lost when the session ends, and the return to the user between steps disappears.

This skill keeps the thread: it opens the work's home, picks the path, invokes each tool at the right moment telling it where to write and what to read, records progress on disk, and has plans verified by someone else before executing.

## What it does NOT do

| Doesn't | Why |
|---|---|
| Write all plans up front | A slice's plan is written when that slice is next |
| Run past a stop | Two stops per slice: after the reviewed plan, after the close. It commits and asks before going on |
| Skip steps silently | When it skips one, it says which and why |
| Apply corrections on its own | Verifications report in one ranked message with a recommendation per finding; the user decides with one answer |
| Pass whole documents to subagents | Each subagent gets a context packet: what it needs, nothing else |
| Touch `CLAUDE.md` or write config on its own | The configuration file has two writers: the profile, to record what the user answered, on the work's branch; and the upgrade, on its own branch, after an ok (the work reference, § Upgrade) |
| Write the changelog, the version or the archive itself | Changelog and version go through `flow:docs` (the work reference, § Closing a work, step 2); archiving through `/flow:archive`. Both in the closing sequence (Step 6), each after asking |
| Merge, push or tag without an ok | Each is proposed and waits for its own yes (Step 6) |
| Install its dependencies | It prints the commands from `dependencies.md`; the user runs them |

**The rule that matters most**: a long session where the skill barrels ahead is worse than no skill. At the two stops of every slice, return to the user.

## Conventions, no configuration

| What | Convention | Detection |
|---|---|---|
| Root | `docs/` | Everything this skill writes lives under it: `docs/work/`, `docs/decisions-log/`, `docs/development-guidelines.md`, `docs/CHANGELOG.md`. Asked at first run (Step 0) |
| Stacks | `rails`, `astro`, `datocms`, `react`, `node`, `generic`; a project can have several | Each signal checked on its own: `Gemfile` + `config/application.rb` → rails; `astro.config.*` → astro; `package.json` depending on `@datocms/cda-client`, `@datocms/astro`, `react-datocms`, `vue-datocms`, `@datocms/svelte`, `datocms-structured-text-utils` or `@datocms/cli` → datocms (a `datocms.config.json` alone doesn't count; it adds to the others, as in `[astro, datocms]`); `package.json` with `react` in dependencies → react. `node` only when `package.json` exists and no other JS stack matched, `datocms` included; `generic` only when nothing matched. Confirmed in the profile |
| Guidelines | `docs/development-guidelines.md` | Read if present; its relevant sections go into every context packet. Template in `${CLAUDE_SKILL_DIR}/development-guidelines.template.md` |
| Decisions | `docs/decisions-log/` | Read by impact and review; proposed here at the close of a step, written by `flow:docs` on a yes. Criterion and requests: the work reference, § Decisions |
| Changelog | `docs/CHANGELOG.md` | Written by `flow:docs`; searched at opening. An existing one is adopted, not replaced |
| Work reference | `${CLAUDE_PLUGIN_ROOT}/shared/work.md` (in the repo: [shared/work.md](../../shared/work.md)) | The how of a work's home, `STATUS.md`, slice-close bookkeeping, close, merge and archive. This skill says when; the reference says how. Read it when a step points to it |
| Impact lenses | Common lenses in `${CLAUDE_SKILL_DIR}/common-lenses.md`, always; plus each resolved preset's `## Lenses` (Profile, § Presets); the stacks without a preset in the same file | The common lenses and the preset lenses of each of the project's stacks |
| Project lenses | `docs/impact-lenses.md` | Read if present by impact and every plan review, on top of the common and stack lenses. Template in `${CLAUDE_SKILL_DIR}/impact-lenses.template.md` |

Configuration lives in `.flow.yml` at the project root. A project can override the defaults with `.flow.yml`: keys `root`, `stacks` (a flow list: `stacks: [astro, node]`; an older `stack: <name>` is converted by the upgrade, the work reference § Upgrade), `changelog`, `version_file`, `merge` (`local` | `pr`, default `local`), `areas` (the area words a decision may carry, as a flow list: `areas: [engine, ui]`), `presets` (per stack or `design`, a flow list of `stack=skill` pairs: `presets: [astro=my-stacks:astro, design=my-tools:design-x]`; see Profile, § Presets), `design` (the design tool `/flow:design` uses: `design: pen`). Read if present. The skill writes it only through the profile (below), on the work's branch, or through the upgrade (the work reference, § Upgrade). Paths in this document assume the default root. `.version` stays at the repo root: one line, read by tools.

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

1. **Context packets, not documents.** A subagent gets the slice's section of `slices.md`, `lessons.md`, the guideline sections that apply to it, the resolved presets' `## Rules`, the project lenses when `docs/impact-lenses.md` exists, and its own task or plan. Not `slices.md` in full, not `shaping.md` or `breadboard.md` unless the slice's section points to them.
2. **Same packet, same position.** Within a slice, the packet is one verbatim text placed at the top of every subagent prompt, with the specific instruction after it. Identical prefixes hit the prompt cache.
3. **Two stops per slice.** After the reviewed plan, and after the close. Plan and review run back to back.
4. **One message per verification.** Findings ranked by severity, each with a recommended action, one question at the end. Never one finding at a time.
5. **Model and effort by role.** Top tier for the planner, the plan review, the slice runner, impact and the fidelity check; mid tier for executors and task reviews, except a `critical` task's. Tasks without dependencies dispatched in parallel. Tiers and precedence: the work reference, § Agents.

And measure: every Log line in `STATUS.md` carries wall-clock and cost (from `/cost`), so the next tuning is a comparison, not an opinion.

## Models

Flow's agents are in `${CLAUDE_PLUGIN_ROOT}/agents/` (dispatched as `flow:<name>`). Preference for the top tier: `${user_config.model_top}`; for the mid tier: `${user_config.model_mid}`. A value that is empty, or begins with `${`, is unset. Which model each dispatch takes, the dispatch contract and the ledger: the work reference, § Agents (`${CLAUDE_PLUGIN_ROOT}/shared/work.md`).

## Dependencies

Runs first, on every invocation: before anything else in this skill and before any file is written. The skills this one hands work to are listed in `${CLAUDE_PLUGIN_ROOT}/dependencies.md` (in the repo: [dependencies.md](../../dependencies.md)). Read it and compare it with the skills listed in the session: a dependency is present when a listed skill has its name, or its segment after `:` equals it. Rows whose Need is `optional (<stack>)` are checked only when `<stack>` is one of the project's stacks, read through the profile (the configuration file, else detection), so they show up only in a project of that stack.

If any are missing, report them in one message, required first, then optional. For each: the install commands from `dependencies.md` at user and project scope and the phase that needs it (from this skill's tables). Never install anything, and don't block the start: the check at each phase stops it if needed.

At a phase or step that invokes a dependency, check again: if a required one isn't listed, stop that phase and give its commands from `dependencies.md`; don't do its job without it.

## Upgrade check

Runs right after the dependency check, before the profile. Look on the default branch for the old traces the work reference, § Upgrade, lists. When there are some, follow that section: one message, one question, and the run ends there. **An upgrade is a run of its own**: no profile, no Step 0, no work opened or resumed. The next run starts on the upgraded state. Nothing found on the default branch: go on to the profile.

## Profile

The project's profile is three things the conductor must know and never guess: the `stacks`, the `merge` style and the test level. It runs on every invocation. **The order is fixed**: dependency check → upgrade check → read the profile and find the open works → one message (the missing profile pieces, Step 0's questions on a first run, and resume-or-new, or Step 1's questions) → on a resume, § Upgrade, Resume on an old file (stops before any write) → the writes, on the work's branch. Nothing is written before the answers.

| Piece | Lives in |
|---|---|
| `stacks`, `merge` | the configuration file, `.flow.yml` |
| Test level, sensitive areas | `## Tests` of the guidelines, opening with two lines: `Level: <none \| essential \| full>` and `Sensitive areas: <path or concept>, …` (empty allowed with `none` and `full`) |

`none`: no tests required. `essential`: tests required for code in the sensitive areas only. `full`: TDD on new code.

**Presets.** A stack can have a preset: a skill holding opinionated `## Rules`, `## Lenses`, `## Tests` (level and sensitive areas), `## Gate` (commands) and `## References`. Shipped: `astro`, `datocms`, `rails` (`flow:stack-<name>`), a list fixed here, never looked up in the skill listing. Resolved per stack, first hit wins: `presets:` in the configuration file; then `${user_config.stack_presets}` (same `stack=skill` pairs, comma-separated; empty, or still beginning with `${`, means unset); then `flow:stack-<name>` when the stack is shipped; else none. Only the resolved skill is invoked, with the Skill tool by its qualified name, never by path. A mapped skill that isn't in the session: say so and never use the shipped preset: a `react` or `node` stack uses its table from `common-lenses.md`, a shipped stack (`astro`, `datocms`, `rails`) has no table, so the `generic` rule applies (ad-hoc lenses), and it contributes no Rules, Tests or Gate. A stack with no preset (`react`, `node`, `generic`) uses its fallback lenses. A project that disagrees with a preset maps its own.

Presets are invoked at the proposal (Tests, Gate, References), at impact, and once per slice when the packet is built. With several: level = the highest proposed; areas = the union; gate = the union of commands, duplicates removed, each attributed to its preset; commands whose script or binary the repo lacks are dropped and named.

**Reading.** Look for each piece in the checkout, on the default branch (or the work's `base:`) and on every open `work/*` branch, all through `git show <branch>:<file>`: an unmerged profile lives on a branch. Ask only for a piece missing everywhere. `merge` has its default, `local`, but is still asked once, like the others. When sources disagree, the most recently committed wins, and the message says which.

**Proposing.** One proposal per missing piece:

- **Stacks**: the detection rule of the Conventions table, all matches listed.
- **Level**: the resolved presets' proposals merged as § Presets says, else `essential` when a test runner is configured, else `none`. Configured means: a test dev-dependency (`vitest`, `jest`, `mocha`, `@playwright/test`, `cypress`) in `package.json`, or a `scripts.test` other than npm's stub (`echo "Error: no test specified" && exit 1`); `spec/` with `rspec` in the `Gemfile`, or `test/` with `minitest`; `pytest` configured (`pytest.ini`, or `[tool.pytest]` in `pyproject.toml`). Areas: the presets' (merged), plus paths that look sensitive: auth, payments, billing, migrations, data import and export. The merged gate is shown in the same message as a proposal.
- **Merge**: `pr` when the repo has a remote and `.github/pull_request_template.md` or `.github/workflows/`, else `local`.

**Asking.** Only the missing pieces, in one message, each with its proposal; on a first run, Step 0's questions are in the same message. Asking writes nothing:

> "Before opening: **stacks** `[node]` (detected: `package.json`, no framework); **tests** `essential`, since `vitest` is configured, sensitive areas `src/auth/`, `src/billing/`; **merge** `local` (no remote). Also: keep `docs/` for the flow's folders, and write `docs/development-guidelines.md` as a draft from the presets (References, Tests, Gate)? Correct what's wrong."

**The draft.** With no guidelines file and resolved presets, the offer is a draft: `## References` from the presets' `## References`; `## Tests` with the two profile lines (merged level and areas); `## Gate` merged and pruned as § Presets says; the code's observed conventions where the presets are silent; `## Deviations` only when there is content. The user may choose only `## Tests`, or decline; the full empty template stays a separate offer. With an existing file, its missing sections (of the template's four) are proposed only when the profile is asking anyway or at Step 0, never a rewrite, and not again in that run once declined. Once the guidelines exist, the gate and the test level come only from them: presets are not read again for these (their Rules still travel in the packets).

Unanswered: a proposal counts as accepted, a file offer as declined, a Step 1 question is asked again. The level and areas need the guidelines file: if the user declines even the minimal one holding only `## Tests`, the level holds for this session only and is asked again at the next start (say so in the message).

**Writing.** Never on the default branch. A new work: with the home, on `work/<slug>` after Step 2. A resume: after the switch to the work's branch, or at once when already on it. A piece is written into the work branch when it is missing there, copied from where it was found. The configuration file gains the missing keys (a `root` chosen in Step 0 included). The two `## Tests` lines go at the start of an existing `## Tests`; the section is added only when absent, in the existing guidelines file or in a new file holding the accepted draft (or only `## Tests`), when there is none. The full template stays an offer; a declined file is never created. Commit with `git add` on the paths actually written (`.flow.yml`, the guidelines, `impact-lenses.md` if accepted, under the root in use):

```bash
git commit -m "Record the project profile"
```

**Raise.** At opening (Step 1), if the request touches a sensitive area (by path or concept), propose a level for this work in the same message. On a yes, `tests: <level>` goes in its `STATUS.md`; the project's `## Tests` stays as it is. A work without `tests:` uses the project level.

## Step 0 — First run in a repo

Step 0 only gathers answers, in the profile's message, and writes nothing: its writes happen with the profile's, on `work/<slug>`.

Runs once: when there is no `docs/work/`, no configuration file, looked up as the profile's Reading says (checkout, default branch, `work/*` branches), so it doesn't rerun while the first work is unmerged. A repo with no commits can't hold a branch: say the profile and the home need a first commit, and ask the user to make one (never make it).

```bash
ls -d docs docs/work docs/decisions-log docs/development-guidelines.md docs/impact-lenses.md docs/CHANGELOG.md .flow.yml 2>/dev/null
```

**`docs/` doesn't exist** → say that `docs/work/` will be created with the work's home, and ask the offers below.

**`docs/` exists** → it's already someone's namespace. Say what this skill will add inside it (`work/`, `decisions-log/`, `development-guidelines.md`, `CHANGELOG.md`, and optionally `impact-lenses.md`), report any collision (one of those paths already present with content this skill didn't write; an existing `CHANGELOG.md` is adopted, not a collision), and ask:

1. **Keep `docs/` (recommended).** The flow's folders sit next to the existing ones. If something collides, the user moves or renames it first: the flow never moves files it doesn't own.
2. **Use a top-level `flow/` folder (discouraged).** Documentation splits in two places, and readers look in `docs/` first. If chosen, `root: flow` goes into the configuration file with the profile's write, and the home is created under it.

Whether or not `docs/` exists, the message also holds: if `docs/development-guidelines.md` is missing, offer the draft from the resolved presets (Profile, § The draft), or only `## Tests`; the full form from `${CLAUDE_SKILL_DIR}/development-guidelines.template.md` is a separate offer. When it exists, only its missing sections are proposed. If `docs/impact-lenses.md` is missing, offer to create it from `${CLAUDE_SKILL_DIR}/impact-lenses.template.md`, under the chosen root: the project's own lenses, applied at impact and in every plan review. Accepted files are created with the profile's write; the user fills them in. Declined → not created: an empty template is worse than none.

## On start: open or resume

Order: `## Profile`; on a resume, § Upgrade, Resume on an old file, runs before any write. Find the open works as the work reference, § Finding open works, says: the current checkout and every `work/*` branch.

- No result → new work (Step 1, in the same message as the profile's questions).
- One or more works with `phase:` other than `done` → say so and ask, in the same message:

> "`2026-09-02-mobile-menu` is at slice **V3**, step **execute**. Resume there, or open a new work?"

Resuming reloads the **standing documents**, and nothing else:

| Always reloaded | Never reloaded |
|---|---|
| `STATUS.md`; the `## The criterion` block of `frame.md` when the work has one; the sections of `docs/development-guidelines.md` that apply; `lessons.md`; the `description:` line of the `docs/decisions-log/` files that match the work (`flow:docs`, `op: descriptions`, `layout: repo`, `dir`, `keywords` from the `description:` in `STATUS.md`) | `brainstorm.md`; `shaping.md` (except by the table below); `breadboard.md` (except by the table below); closed plans; `spike-*.md`; `frame.md` below its criterion |

**By phase and step**, on top of the always-reloaded row:

| Phase or step | Reloaded |
|---|---|
| design | `shaping.md`, `docs/design/README.md` |
| slicing | `shaping.md`, or `breadboard.md` when breadboarding slices |
| impact | `slices.md`, in full |
| plan | `docs/impact-lenses.md` and the decisions matched by the slice's `files:` |
| review | the plan's header only |
| execute | `rg -n '^## Close draft' <ledger>`: a match goes to the close, no runner; else, if a `flow:slice-runner` was dispatched earlier in this conversation and hasn't returned, wait for its notification and never dispatch again; else the runner (the ledger tells which tasks are complete, and they are never dispatched again), then § step: execute from move 2 (move 3 says when the packet is rebuilt). In a new session, the resume message also asks whether another session still runs the slice (the user can see it in `/tasks`): never a second runner |
| close | the ledger from `Final review:` on, with the `pending:` lines just before it: `Final review:`, `Gate:` and `## Close draft` |

A standing document is one that is still true. A closed phase is a debate that ended. Each row of the second table holds what the next step reads and nothing more: `shaping.md` or `breadboard.md` is what slicing cuts from, `slices.md` is what impact and the plan measure against, the lenses and matched decisions are what the planner weighs, the plan's header is what a review checks, the ledger is the only record of what the runner has done, and the close draft is the work already done, waiting to be confirmed. The frame belongs to the first kind: it carries the criterion every later document is measured against, and a work that resumes without it resumes on whatever was written last.

Open with what you reloaded, in five lines — work, phase and slice, cost so far from the Log, the criterion in the frame's own words, the blockers from the last Log line — then ask. The user has to be able to see that the frame is in the room.

## Step 1 — Opening

One message, five questions, each with the answer this skill proposes from what it already knows. The user corrects what's wrong and answers what's missing. If the request touches a sensitive area of the profile, the message also carries the raise (`## Profile`).

1. **What do you want to build?** In the user's words. Becomes `description` in the frontmatter.
2. **Code name?** Propose a short lowercase slug with hyphens, checked against `docs/work/` and `docs/work/archived.md`.
3. **Source material?** Call transcripts, threads, notes. If yes, the frame starts from them with `framing-doc`.
4. **The visible-outcome test.** *Can you already say in one sentence what changes for the product's users, without answering "it depends"?* **Yes** → technical work: skip to slicing. **No** → product work: start from the frame. State your reading: *"I read this as product work: describing the outcome I'd say 'it depends on which pages change'. If it's already defined for you, I'll skip to slicing."*
5. **If product work: is the problem already clear?** Yes → skip the frame, start from shaping. No → the definition path: `flow:brainstorm` (path `<work dir>/brainstorm.md`), then `flow:grill` (target `brainstorm.md`; `layout: repo`, `dir`, `work` and `area` (from `areas:` in the configuration file, else a free kebab-case word per the work reference § Decisions; no slice yet) for decision candidates), then the frame.

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
| `frame` | The problem isn't defined yet | `flow:brainstorm` → `flow:grill`, then `framing-doc` with source material, else this skill writes the frame from `brainstorm.md` | `brainstorm.md`, `frame.md` |
| `shaping` | Several solutions with different outcomes | `shaping` | `shaping.md` |
| `breadboard` | The work introduces places or affordances that don't exist yet. On existing code, skip by default and say so | `breadboarding` | `breadboard.md` |
| `design` | The work touches a UI, or an artifact fits; needs `shaping.md` | `/flow:design` (called) | Design files or the artifact's HTML source under `docs/design/`; corrections in `shaping.md` |
| `slicing` | Always, even with one slice | `shaping` (slicing section) or `breadboarding` | `slices.md` |
| `impact` | Always, after slicing | Two `flow:impact` agents (below) | Corrections in `slices.md` |

If the tool the row picks for the case at hand isn't listed in the session, stop that phase and give its commands from `dependencies.md`. Never swap in another tool for a missing `framing-doc`.

**The definition path.** A product work whose problem isn't clear runs `flow:brainstorm`, passing `<work dir>/brainstorm.md`; then `flow:grill` with that file as target; then the frame. With source material the frame is `framing-doc`, given `brainstorm.md` too. Without, this skill writes `frame.md` with the `## The criterion` block on top, built from `brainstorm.md` and the grill's answers, and carries the parked questions into its body. `brainstorm.md`, the grill's writes and the frame are committed on the work branch, and the `flow:grill` calls pass the decision fields as in Step 1, plus the `frame.md` path once the frame exists so the criterion anchor applies. Its early exits: on a clear request or a small change, go back to Step 1's question and treat the problem as clear (shaping, as that question says); on "skipped", run `flow:grill` with `brainstorm.md` created as its target, holding the request as given, then the frame.

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

**The design phase.** Offered at Step 5's stop of shaping (or breadboard) when the work touches a UI, read from `shaping.md` (requirements or parts naming a screen, page, form or component the user sees) and from `breadboard.md`'s places when present, or when an interactive flow is worth clicking through. Skipped, with the reason in the stop message, when nothing is seen or no `shaping.md` exists (`/flow:design` by hand stays available). The offer names the screens to pass and the medium `/flow:design` will propose by the rule of its § Medium (a Claude artifact for an interactive or exploratory need, or when `.flow.yml` has no `design:`; a design file through the tool for static screens with `design:` set), with the reason naming which case held; `/flow:design` still settles the medium with the user (an adapter that doesn't resolve turns it into an artifact there). When `docs/design/` holds files, the offer carries the reminder. When `docs/design/` holds files, ask the user to save and close them in the design tool first: a tool holding a file open can write its copy back over the switched branch. On the user's yes, `phase: design`, `updated:` and a Log line go into `STATUS.md`, committed alone (`Open the design phase`), before the call: an interrupted session resumes there, reloading `shaping.md` and `docs/design/README.md` and invoking `/flow:design` again. Invoke the Skill tool `flow:design` with args holding the `## The criterion` block verbatim (when the work has one), then `Shaping: <absolute path of shaping.md>` and `Screens: <the screens to draw, comma-separated>`. It returns **Files touched** and **Requirement corrections** and commits nothing. Write each correction into `shaping.md` in place (the requirement's row amended in the requirements table, and in the fit-check table when it has one; a new row for `new`), in the document's language; then close by Step 5: the corrected `shaping.md` goes through the fidelity check, and one commit (`Close the design phase`) holds `shaping.md`, the files touched and `STATUS.md` with `phase: slicing`, `updated:` and the Log line, so the branch never keeps `phase: design` once the phase is closed; stop.

**The path instruction is mandatory on every invocation.** Without it, the tool uses its own default:

> Save to `docs/work/2026-09-02-mobile-menu/shaping.md`. Don't use default paths.

**The criterion travels with every invocation.** `shaping`, `framing-doc`, `breadboarding` and `/flow:design` don't know the work: put the `## The criterion` block verbatim at the top of the prompt, above the path instruction, with the guideline sections that bear on it; for `/flow:design` the args are those of **The design phase** above, with no path instruction and the `Shaping:` line in its place. Without it a shape can contradict the frame, and the contradiction surfaces only when a human reads the finished document.

**If a point stays vague** (a requirement nobody can decide, an alternative that won't close), invoke `flow:grill` with the point and the document it belongs to as target (and the `frame.md` path, so the criterion anchor applies), passing the decision fields as in Step 1 with the current slice where one exists, and committing the target afterwards per the work reference, before moving on: it closes the point in rounds or the user parks it. It's tightening, not a phase.

**If an unknown is technical** (how a library behaves, what a piece of code really does, whether a platform limit holds), it's a spike: a `spike-<topic>.md` with questions and outcomes, done before the plan of the slice that depends on it. A plan is not written on top of a guess.

**If a phase isn't needed**, say so and skip: *"The affordances here are three calls to an existing endpoint: skipping the breadboard."* Never silently.

### `phase: impact`, once, on `slices.md`

The slices against the real code, before the first plan. First invoke each resolved preset (Profile, § Presets). Two `flow:impact` agents in parallel: one with the common lenses, one with the stack lenses and the project lenses, same report format. The common lenses are `${CLAUDE_SKILL_DIR}/common-lenses.md`: put its expanded absolute path in the packet, never the variable. The stack lenses are each resolved preset's `## Lenses` text, verbatim in the stack-lens packet, never a path into another plugin; for a stack with no preset, that stack's table from `common-lenses.md`, verbatim; for a shipped stack whose mapped preset is unavailable, ad-hoc lenses by the `generic` rule. The common-lens agent receives the project lenses in the packet but doesn't run them. On a one-slice work, one agent with all of them. Both packets also carry the presets' `## Rules`. Packet: `slices.md` in full (here it is the object under review), the descriptions of `docs/decisions-log/` files that match the work's key words and the files the slices name (`flow:docs`, `op: descriptions`, `layout: repo`, `dir`, `keywords`, `files`), the guidelines, and the contents of `docs/impact-lenses.md` verbatim when present. The code they read themselves.

Not in session: whoever just ran the shaping is the worst head for seeing what breaks elsewhere.

Report in one message: findings ranked by severity, each as **what** · **where** (`file:line`) · **why it's a problem** · **recommended fix**; lenses that found nothing named as such, project lenses included; when `docs/impact-lenses.md` is absent, one line "project lenses: none", not a finding; one question at the end: *"Apply the recommended fixes? Say which to skip."* Silence on a lens reads as "didn't run".

Approved corrections go into `slices.md`. If a correction splits or reorders slices, go back to `phase: slicing`.

On a one-slice work, impact is often the check that saves you: the twenty-line fix that breaks another page. Always propose it; the user may skip it.

## Step 4 — The slice loop

From here `phase: slice`. For each slice, in `slices.md` order, four steps and two stops. `step:` in `STATUS.md` says which.

**The slice packet**, built once per slice and placed verbatim at the top of every subagent prompt in it: the `## The criterion` block when the work has one; the slice's section of `slices.md`; `lessons.md`; the work's effective test level (`tests:` in `STATUS.md`, else the project's `Level:`) and the sections of `docs/development-guidelines.md` that apply (tests, naming, placement, gate); the descriptions of matching decisions (`flow:docs`, `op: descriptions`, `layout: repo`, `dir`, `keywords`, and `files:` the slice's files); the contents of `docs/impact-lenses.md` when present; the `## Rules` of each resolved preset (invoked once, when the packet is built). `shaping.md` and `breadboard.md` only if the slice's section points to them.

### `step: plan`

Dispatch `flow:planner` with the packet, the effective test level, the previous slice's plan path when there is one (a model for tone; the impact findings are already in `slices.md`), the expanded absolute path of `executor.md` in the agents folder (its test policy is the one the plan points to) and this instruction:

> Save the plan to `docs/work/2026-09-02-mobile-menu/V2-plan.md`. Test level: `<level>`. Mark dependencies between tasks (`depends on: T1`) and mark `critical` the tasks that touch shared or risky code. Put a **Summary** (at most ten lines) and a **Files** line (the union of the tasks' Files) in the plan's header.

Writing the plan surfaces deviations from the mandate: an affordance better moved to another slice, a file that doesn't exist, a mechanism the shape didn't foresee. The planner returns `Plan:`, `Summary:`, `Files:` and `Deviations:`; the conductor doesn't read the plan. Record the deviation lines in `slices.md` under **"Deviations found while planning V<n>"** (no heading when it returns `none`) and carry on to the review without stopping.

### `step: review`

Right after the plan, one `flow:plan-reviewer`, never in session: whoever just wrote the plan is the worst head for finding its contradictions. Dispatch it with the packet, the plan and the lens table below. The decisions in the packet match the plan too: ask `op: descriptions` again with `keywords` and `files:` taken from the planner's `Files:`, and add any new description.

| Lens | Looks for |
|---|---|
| **Mandate fidelity** | The plan does things the slice doesn't call for; contradicts a shaping or breadboard choice, or the frame's criterion; the Done criteria aren't covered by the tasks |
| **Ignored lessons** | A rule in `lessons.md` the plan doesn't follow; the same mistake already made and documented |
| **Existence** | The files, symbols and methods the plan names exist, and do what the plan assumes |
| **Guideline compliance** | Tests, naming, function size and code placement in the plan follow the guidelines |
| **Project lenses** | The project's own lenses from `docs/impact-lenses.md`, applied to the plan: what this change breaks in this project, not how its code is written. When the file is absent, one line "project lenses: none", not a finding |

**First stop.** One message: the planner's Summary, the findings ranked with a recommended fix each, the deviations recorded, one question: *"Apply the recommended fixes and execute? Say which to skip."*

Approved fixes go into the plan in place, reading only the plan lines the findings point to. If the structure changes (tasks split, reordered or added), send the planner back with the findings.

### `step: execute`

The conductor stays thin here: it hands the slice to `flow:slice-runner` and waits. Its moves, in order:

1. Write `step: execute` and `updated:` in `STATUS.md` and commit it with the plan's fixes (`Start executing V<n>`), so a resume in another session finds the step on the branch. No `step: close` is ever written: a ledger holding `## Close draft` sends a resume straight to the close.
2. Decide `Final review:` without reading the plan: `run` when `rg -c '^### T' <plan>` is above 4, or a path of the plan's `Files:` line (the planner's return, or on a resume `rg -n '^\*\*Files\*\*' <plan>`) appears in another slice's section of `slices.md`; else `skip`.
3. Write `<work dir>/V<n>-packet.md`, the slice packet verbatim. It is committed at the close with the ledger. On a resume at `step: execute`, move 1 doesn't run again, moves 2 and 4 run with the existing packet file, and this move runs only if the file is missing.
4. Dispatch `flow:slice-runner` once, on the top tier by § Agents, with one field per line, all paths expanded and absolute: `Packet: <work dir>/V<n>-packet.md` · `Skill: ${CLAUDE_SKILL_DIR}/SKILL.md, § step: execute › The loop and § step: close moves 1–2` · `Work reference: ${CLAUDE_PLUGIN_ROOT}/shared/work.md § Agents` · `Agents: ${CLAUDE_PLUGIN_ROOT}/agents/` · `Plan: <path>` · `Ledger: <path>` · `Work dir: <path>` · `Models: <the request made in session | top=<x>, mid=<y> from the Models paragraph | none>` · `Final review: run | skip` · `User at first stop: <what the user said | none>` · `Answer: <the user's answer to a previous STOP | none>`.
5. Say one line, for example *"V2 runs in the background in the slice runner; I'll pick it up when it reports. I won't touch the checkout meanwhile."*, end the turn, and touch nothing in the checkout or the work folder until the notification arrives.

The runner returns `Status:`, `Commits:`, `Gate:`, `Final review:`, `Rulings:`, `Decision candidate:`, `Pending:` and `Question:`:

- `DONE` → the close. A `Gate:` that isn't green: don't close; tell the user.
- `STOP` → put its `Question:` to the user, then dispatch again with `Answer:`.
- `NO_NESTING`, or the dispatch denied or erroring before the runner starts → one line to the user, and the conductor runs `#### The loop` itself, in session, then close moves 1–2 as drafts. The ledger already holds whatever the failed attempt left: keep it; the loop writes the head only if it is missing, never again.
- Failed or interrupted (a runner that dies partway included) → `TaskStop` the nested agents still running (or the user does it from `/tasks`), `git status --short`, dispatch again.

#### The loop

The loop runs in the runner, or in session in the fallback. First, check the tree (`git status --short`) and keep the ledger, `docs/work/<dir>/V<n>-ledger.md`, in the format of § Agents: run the `printenv` line now, unless the ledger already has its head. Tasks marked complete are never dispatched again. Commits in the ledger without `complete` → review those commits. Uncommitted leftovers of a task not complete → a fresh executor gets the file list and either finishes them or restores them; never discard silently, never reset. The loop runs without stopping between tasks:

- **Order.** A task with no pending dependency whose files are disjoint from the others' runs in parallel with them; tasks that share a file, or a build step that would see the other's half-written files, run one after another.
- **Dispatch `flow:executor`**: packet verbatim on top, the task text, the Interfaces of the tasks it depends on. Model by § Agents (mid tier).
- **Status.** `DONE` → review. `DONE_WITH_CONCERNS` → read the concerns, then review. `NEEDS_CONTEXT` → answer from the repo and the packet, and continue the same executor with SendMessage (fallback as under Findings). `BLOCKED` → more context; then the top tier; then the runner (or the conductor, in the fallback) splits the task, recording it in the ledger with a `Ruling:` line; else a ruling, or a stop.
- **Review** with `flow:task-reviewer`: packet on top, the task text, the executor's report verbatim (never the ledger's trimmed copy), the task's own commits (`git show <shas>`, from the report), never a BASE..HEAD range that parallel tasks share, and the expanded absolute path of `executor.md` in the agents folder (the Models paragraph), whose test policy, commit rules and server rule it checks against. Mid tier; top tier when the task is `critical`.
- **Findings.** Rounds 1 and 2 go back to the same executor with SendMessage (a deferred tool: load it first; when it can't be reached, a fresh executor with the findings and the commits), each followed by a review of the fix commits. Round 3 is a fresh executor on the top tier, then a top-tier review. After that, a ruling and on: `Ruling: <what> — <why> — <cost if wrong>`. A task passes when both verdicts are `pass` and no high or medium finding remains; low findings are logged in the ledger, not fixed. Then `- T<n>: complete`.
- **Stops** only for an irreversible step, a security matter, a side effect outside the checkout, a plan broken beyond guessing, a gate still red after its fix round: in the runner, it returns `STOP` with the question; in the fallback, the conductor asks the user. The loop doesn't stop to fix the plan; the rulings are read at the close.
- **Final review**, `flow:task-reviewer` on the top tier, with the slice packet, the plan as the task text, the slice's shas from the ledger and the `executor.md` path, only when the instruction says `Final review: run` (the conductor's rule above; in the fallback, the same rule). Its findings go to one fresh mid-tier executor, then one review; what remains is ruled.

### `step: close`

Moves 1–2 are drafts: the runner writes them (the conductor, in the fallback), and they end in the ledger tail of § Agents › Ledger. The runner never touches `slices.md` or `lessons.md`.

1. Verify the slice's Done as written in `slices.md`, plus the gate: the `## Gate` section of the guidelines if present, else tests green, typecheck or lint green, build green. Run the server checks the executors reported (`Servers:`), then stop what you started. The full suite runs here and only here, through the gate. The server rule binds this skill too: start no dev server or watcher unless a check needs one, stop whatever was started before moving on, and `lsof -nP -iTCP -sTCP:LISTEN` when in doubt. If the slice is a refactor, the Done is a regression checklist written before starting and run by hand before committing. A Done item that can't be run goes in the ledger as `pending: <Done item>`, one line each, just before `Final review:`. The ledger gets `Final review:` and `Gate:`. A gate that isn't green gets one fix round (a fresh executor with the failure, then a review) before the close draft is written; still red → `STOP` (the conductor asks the user, in the fallback).
2. Lessons, drafted in the ledger's `## Close draft`. `Narrative:` is what execution revealed, with the rulings read from the ledger, for the slice's **"V<n> — done on <date>"** entry in `slices.md`. `Lessons:` holds the rules, one line each, for `lessons.md`: *"before declaring something unused, grep all of `src`, value and setter, and say in the report where you looked."* A ruling that discarded a real alternative is the `Decision candidate:` (see the work reference, § Decisions).

Then the conductor, before move 3: runs `lsof -nP -iTCP -sTCP:LISTEN` and stops leftovers; runs each `pending:` item with the user; copies `Narrative:` into `slices.md` under the slice, as **"V<n> — done on <date>"**, and `Lessons:` into `lessons.md`.

3. Update `STATUS.md` as the work reference says (§ `slices.md` and `lessons.md`, closing a slice), with wall-clock and cost in the Log line.
4. Commit, the ledger and the packet file with it. **Second stop.** One message: what closed, the gate result, the new rules, the decision candidate if any with the question whether to record it, and: *"V3 closed and committed. Plan V4, or stop here?"*

A closed slice isn't reopened (rule in the same section).

## Step 5 — Closing a definition phase

Applies to frame, shaping, breadboard, design, slicing and impact. Five moves, in order:

1. **Fidelity check**, before the commit. For each requirement, shape or slice just produced: which line of the criterion does it serve? Whatever traces back to nothing is named in the report, with what it would take to keep it. On `shaping.md` and `slices.md` — the documents the rest of the work inherits — a `flow:plan-reviewer` runs it, with a packet of the criterion, the applicable guidelines and the document alone, plus this lens table:

   | Lens | Looks for |
   |---|---|
   | **Criterion fidelity** | Each requirement, shape or slice names the criterion line it serves; whatever traces to none is reported with what keeping it would take |

   On the others, in session. Skipped entirely on a work with no frame, and said so. At `design` the document checked is the corrected `shaping.md`, skipped when there were no corrections, and said so.
2. **Commit** the document just produced. Explicit `git add` on the touched files, never `-A` or `.`: the working tree may hold unrelated work. Imperative messages, in the language the repo already uses. The design phase runs move 3 first and commits `shaping.md`, the files `/flow:design` returned and `STATUS.md` (`phase: slicing`, `updated:`, Log line) in one commit.
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

**A bugfix is a one-slice work.** Same skill: the visible-outcome test sends it straight to slicing (`slices.md` with V1 and its Done), impact if it touches more than one file, then the loop once. No frame, shaping, breadboard or design.

**A small project doesn't need every phase.** State the path in the opening message: *"I read this as technical work in three slices: skipping frame, shaping, breadboard and design (`/flow:design`), doing slicing and impact, then the loop."*

## The full lifecycle

| Moment | Skill | Owner |
|---|---|---|
| Opening, definition, slice loop | `/flow:dev` | the `flow` plugin |
| A slice's plan, review and impact | Flow's agents (`flow:planner`, `flow:plan-reviewer`, `flow:impact`) | the `flow` plugin |
| A plan's execution | Flow's agent `flow:slice-runner`, dispatching `flow:executor` and `flow:task-reviewer` | the `flow` plugin |
| Changelog and version | `flow:docs` (by hand: `/flow:changelog`) | the `flow` plugin |
| Archiving | `/flow:archive` | the `flow` plugin |

`shaping`, `breadboarding`, `framing-doc`, `flow:brainstorm`, `flow:grill`, `/flow:design` aren't in the table because they aren't moments: they're tools this skill picks up when needed.

A work run with this skill can be one action of a `/flow:project` plan: the project's row says *"flow:dev work `<slug>` merged"*, this skill runs the work in its repo, and the row closes at the merge. The two skills share their skeleton and are kept in sync by hand.
