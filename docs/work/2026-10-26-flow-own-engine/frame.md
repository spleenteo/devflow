---
work: flow-own-engine
tags: [frame, flow-own-engine]
description: "Frame for the revision that gives Flow its own planning and execution engine, a single owner for project memory, a project profile (stack, tests, guidelines) and an upgrade path from the old skills."
---

# Frame — Flow's own engine

## The criterion

- **Problem**: Flow delegates planning, execution and ideation to a third-party plugin whose defaults (exhaustive tests, worktrees, its own paths) fight the project, and its own rules about documents are duplicated across the conductors.
- **Outcome**: a user opens a work and Flow asks, up front, what it can't infer (stack, test level, merge style), then plans and runs the work itself with the right model per role, in the user's own checkout, writing memory through one owner.
- **Less about**: imposing the plugin's framework presets on anyone who prefers their own; replacing shaping-skills; bulk-migrating existing projects.
- **Measure**: a decision about tests, models, branches or documents is taken once, in one named place, and every later agent reads it from there instead of applying a default.

## Source

The owner's requests, given in one session on 2026-10-25/26 and translated from Italian. No transcript file exists; the decisions below are the playback the owner confirmed point by point.

> I want to revisit how `flow:dev` handles documentation. Maybe a dedicated skill that both `flow:dev` and `flow:project` can use the same way.
>
> I've read references to devflow somewhere, and they must not be there any more: we need a way to upgrade the projects that use devflow today.
>
> I'd like a new `flow:grill` skill, strongly inspired by mattpocock's `grilling`, revising some parts to fit Flow's philosophy.
>
> How can the development-guidelines template work if Flow ships as a plugin and the user doesn't know its contents? How can it give guidance based on the framework in use? Can it point to external references (e.g. thoughtbot's skills for Rails patterns)?
>
> I want to use thoughtbot's atomic-commits as a dependency for commits.
>
> `flow:dev` should first ask what kind of project this is (rails, astro, rust, react, nextjs…), deducing it when it can. Based on that it loads the relevant guidelines, if any. It should also ask the level of testing: superpowers generates very large suites, sometimes useless, slow and token-hungry. On some web projects there is little or nothing to test.
>
> I'm starting to doubt superpowers. It served well, but recent models used well already do what it does; some of its rules are good. I plan complex work with the most capable models and run clear plans with a mid-tier model: Flow should pick models per agent on its own, and the user can ask explicitly. `ultrathink` isn't something Claude can trigger on its own, so where it's cited it's wrong; Flow could decide by itself when to raise the effort, probably in plans and reviews.

Asked what was worth keeping from superpowers: *"plan reviews were useful, tests excessive: hundreds of tests run even on projects with very little code."* On a recent content site built with Astro, tests had to be stopped by hand: *"fine, but I'd like it to ask me first."*

## Problem

1. **The engine isn't Flow's.** `writing-plans` and `subagent-driven-development` write and run the plans. Their prompts mandate TDD by default, ask reviewers whether tests are "comprehensive", run full suites per task, and create a git worktree per plan. A worktree hides the dev servers agents start, and bringing the work back to the main checkout is a chore. Flow's instructions fight these defaults instead of replacing them.
2. **`ultrathink` in subagent prompts is not a reliable control.** The Agent tool takes an explicit `model` and `effort`, which a skill may request; Flow doesn't use them except for task reviewers.
3. **Nothing is asked up front.** Stack detection exists only to pick impact lenses; test level, merge style and guidelines are never asked, so the defaults of the external skills win.
4. **The guidelines template is empty and invisible.** A plugin user meets it only if they accept the Step 0 offer, and it carries no stack knowledge. Writing guidelines for every framework inside the plugin would be wasted (no team uses them all) and would impose the plugin author's opinions on everyone.
5. **Documentation rules are duplicated.** `dev` and `project` each describe decisions (two near-identical formats, "kept in sync by hand"), archiving (a skill for `dev`, inline for `project`) and memory search. The pending decisions-log revision (`docs/briefs/2026-10-25-decisions-log.md`) would have to be applied twice.
6. **Old names linger.** The skills read `.devflow.yml` and "devflow work … merged" as silent fallbacks; projects still carry the old traces and nothing converts them.
7. **Narrowing has no tool.** Flow's rule for a vague point is "one question at a time"; ideation (`brainstorming`) widens, and no Flow tool narrows.

## Outcome

### Engine

- Flow writes and runs slice plans with its own rules and prompts. superpowers leaves `dependencies.md` entirely; `shaping-skills` stays.
- Rules worth keeping from superpowers are absorbed as Flow's own, with source and MIT licence credited: the fresh-head review of a plan, a reviewer per task, reports written to files, a ledger that survives compaction.
- **Models per role, chosen by Flow, overridable by the user.** Planning, plan review and impact on the most capable tier; executing a clear plan on a mid tier; task reviewers mid tier, most capable for tasks marked `critical`. The user can impose a model for a step or a whole work ("run everything on the most capable"). The Agent tool's `model` option carries it.
- **Effort instead of `ultrathink`.** Every `ultrathink` mention goes. Flow sets the Agent tool's `effort`: high at impact, plan writing and plan review; default at execution.

### Tests

- At the first run in a repo Flow asks the test level, with a proposal inferred from the project. Three levels:
  - **none**: no tests; the gate is build plus lint or typecheck;
  - **essential**: tests only on the areas the user declares sensitive (asked right after);
  - **full**: TDD on new code.
- The answer lives in the `## Tests` section of `docs/development-guidelines.md` and travels in every plan, executor and reviewer prompt, overriding any default. A content site gets "none" proposed.
- At the opening of a work, if the request touches something sensitive, Flow proposes raising the level **for that work only**; the choice is recorded in that work's `STATUS.md` (e.g. `tests: essential`, with the areas). The project's level doesn't change.
- Whatever the level, a task runs only the tests of the code it touched; the full suite runs once, at the slice's gate.

### Stack and guidelines

- Flow first establishes the stacks: inferred from the repo when it can, asked otherwise. A project can have several (a framework and a CMS, e.g. Astro and a headless CMS); each gets its own preset.
- **One preset per stack, loaded only for that stack.** Everything Flow knows about a framework lives in its own preset: its patterns and peculiarities, its impact lenses, the reference skills or official docs it points to (e.g. thoughtbot's `rails-patterns` and `testing-patterns` for Rails), the usual gate commands, the test level to propose. Nothing about other stacks is ever loaded. Today's `lenses.md`, which holds every stack in one file, is split: the common lenses stay as method for every stack; each stack's lenses move into that stack's preset.
- **The plugin ships opinionated presets for the stacks its owner uses**, not a catalogue of every framework: patterns and peculiarities are opinions, and a new project of those stacks gets the owner's rules immediately. A preset points to external skills for depth instead of restating them.
- **A custom preset replaces the shipped one entirely.** A user or small team who dislikes a preset maps that stack to their own (per project or per user); when a custom preset exists, the shipped one is ignored, not merged. Each stack of a project is replaced independently.
- Presets only seed the first draft of the guidelines: after that, the gate and the test level are what `docs/development-guidelines.md` says, so a personal preset never changes the team's gate.
- Skills a preset points to are optional dependencies tied to the stack: Flow reports them only in projects of that stack.
- **Project settings and personal settings are kept apart**, as Claude Code does with its own settings. Project settings are committed and shared with the team: stacks, test level and sensitive areas, merge style (in `.flow.yml` and `docs/development-guidelines.md`). Personal settings are never committed: model preferences (e.g. "always the most capable for me") and user-level preset mappings, in the plugin's user configuration (`userConfig`), stored in the user's settings and never in a repo. Personal wins over project only for personal keys; a personal file never changes what the team's gate requires.
- `docs/development-guidelines.md` becomes short and is drafted by Flow at first run, not offered as an empty template: the reference skills, the test level and sensitive areas, the gate commands, and only the project's own deviations. Existing conventions found in the code win over the preset. Where the file already exists, Flow proposes only the missing sections.

### Branches, commits, merge

- **Default: a branch `work/<slug>` in the main checkout, no worktree.** The user's dev server, editor and browser see the work in progress as is. A worktree only when the user asks (parallel works, busy checkout).
- **No hidden servers.** Flow doesn't start servers in the background on its own; if an agent must start one, Flow reports folder, port and URL and stops it when the step ends. Preferably it asks the user to start it where they usually do.
- **Commits.** One commit per task, meeting atomic-commits' criteria, absorbed as Flow's rules with credit: tests (per the level) and build green, the app in a working state, no dead code, one kind of work per commit (refactor, feature, cleanup). atomic-commits is not a dependency: its PR-size hook targets a PR-per-200-lines flow that doesn't apply here.
- **Merge.** At the close Flow proposes a local merge into `main` and runs it after the user's ok. A PR only when the user asks or the project declares it in `.flow.yml`. Push and tag still need an explicit ok.

### Documentation: three layers, one source each

| Layer | Owns | Form |
|---|---|---|
| **Conductors** (`dev`, `project`, future ones) | The phases and which tool to use in each | Skills |
| **Work** (shared) | The work's home, `STATUS.md` format, states and transitions, `slices.md`, `lessons.md`, archiving and the `archived.md` index | One reference file in the plugin, read by every conductor |
| **Docs** | Permanent memory: decisions, changelog, version; their formats, places and search | A skill `flow:docs`, run in its own context |

- Conductors ask `flow:docs` for what they need ("record this decision", "what do we know about X", "write the changelog for this work") and get back a short result; they no longer contain formats.
- `flow:changelog` becomes an operation of `flow:docs`; archiving moves to the work layer. Both stay invocable by hand.
- One decision format with variants for code and non-code projects, replacing `decisions-log.md` and `decisions.md`. The decisions-log revision brief is absorbed here: kinds `decision`/`deferral`, fixed headings, `## Reopen when`, `touches:`, `area:`, short descriptions, the "does it outlive the work?" test, the check script, legacy files skipped.
- The work layer is a reference rather than an agent because `STATUS.md` changes at every step; the docs layer is an agent because memory is written rarely and its formats shouldn't load into the conductor.
- Projects live in two layouts: `docs/` in a repo, the project folder for `flow:project`. The docs and work layers know both.

### Upgrade from the old skills

- At start, Flow recognises the old traces (`.devflow.yml`, `archived.md` header citing `/devflow-archive`, "devflow work … merged" rows) and proposes an upgrade in one message listing what would change; it runs after an ok and is committed on its own.
- The same step brings the project to this work's conventions: stacks and presets, test level, guidelines sections, merge rule.
- A project's `CLAUDE.md` is never edited: Flow points at the lines to fix.
- Decisions in the old format are not converted: read as legacy.
- Recognition replaces the fallbacks: the old names appear in one place only, the upgrade step. Done project by project, as each is reopened; no bulk tool.

### Ideation and narrowing

- **`flow:brainstorm`**, ported from superpowers' `brainstorming` (MIT, credited), widens. Changes:
  - it never executes: when a request is already clear and small it says so and **exits**, returning control to the caller;
  - it writes where the caller says (inside a work, the work's folder; standalone, it asks); no `.superpowers/`;
  - it **proposes** artifacts (Claude's Artifacts) when seeing helps, and the user decides; the local visual-companion server is dropped (it is exactly the hidden server above);
  - the builder check on a written document stays.
- **`flow:grill`**, from mattpocock's `grilling` (MIT, credited), narrows. Kept: the design tree, rounds that ask the whole frontier, numbered, each with a recommended answer worded so "yes" accepts it; facts found by a subagent, decisions left to the user; done when the frontier is empty. Added:
  - anchored on the frame's criterion when there is one;
  - writes its outcome where the caller says (the frame during definition; `slices.md` deviations inside a slice); a choice that discards a real alternative becomes a decision candidate for `flow:docs`;
  - the user can park a question: it goes to an open-questions list in the target document instead of blocking.
- The definition path becomes: brainstorm (widen) → grill (narrow) → frame. Inside a slice, a doubt is grilled on that point only, replacing the "one question at a time" rule. Both are usable standalone.
- This doesn't contradict the decision *grill-me is not a dependency*: `flow:grill` is Flow's own skill, not an external dependency.

## Goals, non-goals, anti-goals

- **Goals**: everything under Outcome.
- **Non-goals**: presets for stacks nobody here uses; merging a custom preset with the shipped one; replacing `shaping-skills`; bulk migration of projects; converting old decisions; changing `flow:project`'s reality checks beyond what the shared layers require.
- **Anti-goals** (failure even if it works): any agent adds tests the project didn't ask for; a dev server runs where the user can't reach it; the same document rule is written in two skills again; the plugin names any personal project or tool.

## Constraints

- Everything in the repo is in English; nothing names a personal project or tool.
- Dedicated branch `work/flow-own-engine`; no merge, push or tag without the owner's explicit ok.
- Ships as one or more releases, decided at slicing (likely v0.2.0 onward; all user-visible).
- `flow:dev` itself is unavailable in the session that runs this work until the plugin is installed: the method is followed by hand.

## Open questions, for shaping and spikes

1. **Release split**: one release or several (e.g. engine first, then memory, then profile)? The test level depends on the engine's prompts; `flow:docs` depends on nothing else.
2. **Spike — running a skill in its own context**: can a plugin skill run as a separate agent (frontmatter or an agent definition shipped by the plugin), and how does a conductor invoke it and read a short result?
3. **Spike — model and effort from a skill**: confirm that a skill's instruction to set `model` and `effort` on the Agent tool is honoured, and which values exist; how the user's override is expressed (per step, per work).
4. **Where personal settings and user-level presets live**, and their format: a file under the user's home, a git-ignored local file per project, or the plugin's own user configuration if Claude Code offers one (spike). Shared by a small team without a fork of the plugin.
5. **How much of superpowers' execution machinery to rebuild** (ledger, review packages, fix-round caps) versus leaving to the model.
6. **`flow:project`**: which of the new pieces it uses (brainstorm and grill yes; tests, stack and merge no).

## Calls made while writing the frame

Settled by the author after the builder check; the owner may overturn them.

- **Entry in a repo already on Flow.** Every start checks the project profile for missing pieces (stack, test level, merge style) and asks only for those, once: the answers go to disk, so the next start finds them and asks nothing. Not tied to the first run alone.
- **Works in progress under v0.1.0.** They continue on the new engine from the next slice's plan: plans are written just in time and closed ones aren't reread. A slice caught mid-execution finishes with whatever is installed. An existing worktree is left as it is.
- **Where the upgrade commit lands.** Never on `main`: it is the first commit of the branch of the work being opened, or of a branch `work/flow-upgrade` when the user only upgrades.

## Left to the builder

File names inside the plugin, the exact wording of prompts, the order of questions in the first-run message, which presets ship first (the owner's stacks).
