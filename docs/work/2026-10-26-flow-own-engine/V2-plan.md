---
work: flow-own-engine
slice: V2
tags: [plan, flow-own-engine]
description: "Plan for V2: the forked flow:docs skill owns changelog, version and memory search; /flow:changelog becomes an entry point; the conductors ask, then send self-contained requests."
---

# V2 — `flow:docs` · plan

**Mandate**: [`slices.md` § V2](slices.md#v2--flowdocs). **Guidelines**: [`docs/development-guidelines.md`](../../development-guidelines.md) (Tests, Naming, Language, Commits, Gate). **Lessons**: [`lessons.md`](lessons.md). **Spike**: [`spike-skill-context.md`](spike-skill-context.md) (fork mechanics, runtime test).

**Execution rules for this slice** (the new engine arrives in V6): executors on the mid tier (`sonnet`), reviewers on the most capable (`opus`) for tasks marked `critical`, `sonnet` otherwise; current checkout on `work/flow-own-engine`, no worktree; before re-dispatching a failed executor, check the tree; verification by running the plugin on throwaway repos in the session scratchpad.

**The request contract** (used by T1–T3, defined in T1). A request to `flow:docs` is one line of `key: value` pairs, self-contained, because the fork sees no history:

- `op`: `changelog-propose` | `changelog-write` | `search` | `descriptions`;
- always: `layout` (`repo` | `project`), `dir`: the absolute repo root (repo), or the absolute folder that holds the sibling projects (project);
- `changelog-propose`: `work` (slug), `base` (branch to diff against), `release` (`one`, or the slugs of a split), `current` (version, when the version file is missing);
- `changelog-write`: the same, plus per release the confirmed `level` (`minor` | `patch` | `major`, `major` only when the user confirmed it explicitly) and `title`, as the user saw them;
- `search`: `keywords` (comma-separated); `descriptions`: `keywords`, returns the `description:` line of each matching decision.

The fork never asks. A missing field returns `NEEDS: <field>` and writes nothing. It returns one line per release, or for `search` and `descriptions` at most ten `path — excerpt` lines.

## Tasks

### T1 — Write `flow:docs` · `critical`
- **What**: `skills/docs/SKILL.md`. Frontmatter: `name: docs`; `description` narrow ("Called only by Flow's conductors and `/flow:changelog` with a self-contained request; never invoked directly for general documentation work"); `context: fork`, `agent: general-purpose`, `background: false`, `model: sonnet`, `user-invocable: false`. Body: the request contract above; config (`.flow.yml` keys `root`, `changelog`, `version_file`, the `.devflow.yml` fallback sentence, allowed by the narrowing); then the operations:
  - `changelog-propose`: today's `/flow:changelog` Steps 1–2 without the questions: `git log <base>..HEAD`, `git diff <base>..HEAD --stat`, the changelog's existing entries, the version file or `current`, the work's `STATUS.md` and the "V<n> — done on" sections of `slices.md`; the MINOR/PATCH rule; never proposes MAJOR: a work that looks major returns `major? <reason>` and the conductor asks. Returns per release `<level> → <version>: <title> — <one-clause reason>`; writes nothing.
  - `changelog-write`: Steps 3–5 (entry format and rules, the confirmed `title`, the version file, commit with explicit paths, never `--amend`). Returns per release `Recorded v<version> — <title> — <sha>; missing decisions: <none | list>; manual after merge: <none | list>`.
  - `search`: repo: `rg -il` over the changelog, `<root>/decisions-log/`, `<root>/work/archived.md`, never `<root>/work/archive/`; project: under `dir`, `*/STATUS.md`, `*/decisions/*.md`, `*/lessons.md`. Read only matching files; return the matches. `descriptions`: the same over decisions only, returning their `description:` lines.
  - "Relation to archiving" kept. "What it does NOT do" kept, plus "Ask the user anything" and "Write decisions (until V3)".
- **Files**: `skills/docs/SKILL.md` (new).
- **Verified**: `claude plugin validate .`; read-through against today's `skills/changelog/SKILL.md`: every rule of Steps 1–6 has an owner (here, or the conductor's report), none invented, every question removed.
- **Done**: the skill exists; no rule of the old changelog is lost.

### T3 — Conductors send requests · `critical` · depends on: T1
- **What**:
  - `shared/work.md` § Closing a work (repo), step 2 Changelog, is the one place for the flow: show `git status --short`; version file missing (`.version`, or `version_file` in `.flow.yml`) → ask the current version (suggest `0.1.0` unreleased, `1.0.0` in production); unrelated works on the branch → one release or two; `flow:docs` `changelog-propose`; show the proposal, wait for objections, ask on `major?`; `changelog-write` with the confirmed level and title; report its line, the manual steps, and that `/flow:archive` comes next.
  - `skills/dev/SKILL.md`: Project memory sends `flow:docs` `search`, and gains a line: when the user asks what the project knows about something, search and report; Step 1's memory check the same; the resume reload (`:118`), the impact packet (`:193`) and the slice packet (`:207`) get decision descriptions through `descriptions`; Conventions row Changelog names `flow:docs`, row Decisions keeps writing in dev until V3; Step 6 step 2 points to the reference; "What it does NOT do" and the lifecycle table name `flow:docs` for changelog and version. Reading a known file by path stays in the conductor.
  - `skills/project/SKILL.md`: Project memory and Step 1's check send `flow:docs` `search` with `layout: project` and `dir` the folder holding the projects.
  - Every request is invoked with the Skill tool under the qualified name `flow:docs`.
- **Files**: `shared/work.md`, `skills/dev/SKILL.md`, `skills/project/SKILL.md`.
- **Verified**: `rg -n "rg -il" skills/dev skills/project shared` finds nothing; `rg -n "op: " skills/dev skills/project shared` shows every request with `layout` and `dir`.
- **Done**: no conductor holds a changelog rule or a memory-search command.

### T2 — `/flow:changelog` becomes an entry point · depends on: T1, T3
- **What**: `skills/changelog/SKILL.md` keeps a widened frontmatter description and a body under 30 lines: run by hand; follow `shared/work.md` § Closing a work, step 2; nothing else of its own.
- **Files**: `skills/changelog/SKILL.md`.
- **Verified**: under 30 lines; `rg -n -i "minor|patch|can do something|## v" skills/changelog/SKILL.md` finds nothing.
- **Done**: changelog rules exist in `flow:docs` only, the flow in `shared/work.md` only.

### T4 — Demonstrate and gate · depends on: T2, T3
- **What**: headless on throwaway repos in the scratchpad (`claude -p "<prompt>" --plugin-dir /Users/spleenteo/Sites/me/devflow --dangerously-skip-permissions --output-format stream-json --verbose`), prompts pre-answering every question except where stated and saying where to stop. "Ready to close" means: on `work/<slug>`, `STATUS.md` with `phase: slice`, its only slice ticked, `base:` set, `.version` `0.3.0`.
  1. a repo ready to close: the close (changelog step only) writes the entry and `.version` through `flow:docs`; in the stream JSON the messages without `parent_tool_use_id` hold the returned line and none of a marker phrase from `flow:docs`' body;
  2. a repo with two changelog entries and one decision: "what do we know about <X>" from `/flow:dev` returns them through `flow:docs`;
  3. `/flow:changelog` by hand on the repo from 1 at a later commit: same entry shape, through `flow:docs`;
  4. a repo ready to close with no `.version`, the version left unanswered: the run stops at the version question; no `flow:docs` call precedes it; a second run with the answer sends a request carrying `current:`;
  5. scenario 1 with `.claude/skills/docs/SKILL.md` in the throwaway repo, described broadly as updating docs and the changelog: the Skill call's name is `flow:docs`;
  6. a folder of sibling projects, one with a lesson naming a supplier: `/flow:project` opening a new project with that supplier's name finds it through `flow:docs`.
  Then the Gate with the narrowing. `background: false` outside headless mode stays unverified (`-p` waits anyway): recorded in the close narrative, for an interactive check by the user.
- **Files**: none in the repo.
- **Verified**: each outcome checked with `git`, `cat`, `jq` over the kept stream JSON.
- **Done**: six outcomes as stated, Gate green.

## Order

T1 → T3 → T2 → T4. One commit per task, explicit paths.

## Deviations from the mandate

- **The project layout writes nothing in V2.** A project has no changelog; its only writes are decisions, which arrive in V3. The Done's "finds and writes in the project layout" is met by search here (scenario 6) and by a project-layout decision in V3's Done.
- **Two calls for the changelog.** The fork never asks, but the user must be able to object to the level: `changelog-propose` returns the level and the conductor shows it before `changelog-write`. The level rule stays in `flow:docs` only.
- **The flow lives in `shared/work.md`**, followed by the conductor's close and by `/flow:changelog`, so it exists once.
- **`flow:docs` is cited without the slash**, unlike the Naming rule's `/flow:<skill>`: it is not user-invocable, so it has no slash command. V8 updates the Naming rule.
