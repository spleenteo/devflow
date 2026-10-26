---
work: flow-own-engine
slice: V8
tags: [plan, flow-own-engine]
description: "Plan for V8: one upgrade step for old traces, the old-name fallbacks removed, the Naming rule and the Gate updated, README and architecture rewritten to the new shape."
---

# V8 — Upgrade and documentation · plan

**Mandate**: [`slices.md` § V8](slices.md#v8--upgrade-and-documentation). **Guidelines**: [`docs/development-guidelines.md`](../../development-guidelines.md). **Lessons**: [`lessons.md`](lessons.md). **Builds on**: every V1–V7 narrative in `slices.md` (what README and architecture must now describe).

**Execution rules**: executors on `sonnet`; reviewers on `opus` for `critical` tasks, `sonnet` otherwise; current checkout on `work/flow-own-engine`; parallel executors commit with the pathspec form; demos headless on throwaway repos, flags as an array, `--resume` turns with every answer written out. The Gate narrowing ends with this slice: T4 runs the Gate without it.

**The upgrade, decided here:**
- **Where**: `shared/work.md` § Upgrade, both layouts. **An upgrade is a run of its own**: when old traces are found, the start says so and offers the upgrade, and nothing else happens in that run (no profile, no Step 0, no work opened or resumed). The next run starts on the upgraded state.
- **When** (repo): `/flow:dev` checks right after the dependency check, before the profile. `/flow:changelog`, `/flow:archive` and `flow:docs` don't upgrade: when the configuration they find isn't `.flow.yml` but an older file named in § Upgrade, they stop and point to `/flow:dev` (`flow:docs` answers `FAILED: old configuration, run /flow:dev to upgrade`). **Project**: `/flow:project` checks on resume, once the home is known, the home and its sub-projects.
- **Old traces, repo**, looked for on the default branch (`git show <default>:<file>`): `.devflow.yml` (renamed to `.flow.yml`; when both exist, `.flow.yml` wins on conflicting keys, the missing keys move into it, the old file is removed); `stack: <name>` (becomes `stacks: [<name>]`, dropped when `stacks:` is already there); a `docs/work/archived.md` under the root in use whose header cites `/devflow-archive` (that line rewritten to `/flow:archive`); a guidelines file under the root whose opening says "Devflow passes this file" (that sentence rewritten to `/flow:dev`). **Pointed at, never edited**, each as `<file>:<line> — <new name>` or a removal command: `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md` lines naming the old skills or the old file; `Skill(...)` entries for the old skills in `.claude/settings.json`; project-scope copies of the old skills under `.claude/skills/`; open `work/*` branches still carrying an old file (to be refreshed from the default branch after the upgrade merges). **Project**: rows reading "devflow work … merged" in the home's and sub-projects' `slices.md` and `S<n>-plan.md` (rewritten to "flow:dev work … merged").
- **Asking**: one message: each change as `file — what changes`, then the pointed-at lines, then one question. A dirty tree: say so and ask to commit or stash first (never stash). Nothing is written before the ok.
- **Writing, repo**: on the ok, cut `flow-upgrade` from the default branch (not under `work/`, so no scan takes it for a work), one commit `Upgrade to Flow's current conventions` with explicit paths, switch back to the starting branch. Then propose merging it into the default branch locally (its own ok, as Step 6 merges); push stays the user's. An existing `flow-upgrade` branch means the upgrade is pending: say so, propose the merge, never cut it again. **Project**: rewritten in place, committed only when the home is under version control.
- **Declined**: the run stops there, opening and resuming nothing; the message says the old configuration is no longer read and the upgrade will be offered again next time.
- **Fallbacks removed** (A8.2): every sentence reading the old file or "devflow work … merged" outside § Upgrade (`skills/dev/SKILL.md` lines 49, 100, 137, 140, 351 and the "What it does NOT do" configuration row, which now also names the upgrade; `skills/project/SKILL.md`; `skills/docs/SKILL.md`; `shared/work.md:8`; `install.sh:23`; `docs/architecture.md`). Step 0's condition says "no configuration file" without naming the old one. dev stops reading `stack:` (the upgrade converts it); `install.sh` keeps reading it, so a repo not yet upgraded still gets its rows.

**The documents, decided here:**
- **Naming** (guidelines): user-invocable skills as `/flow:<skill>`; skills that aren't (`flow:docs`, `flow:stack-<name>`) and agents (`flow:planner`, …) as `flow:<name>`, no slash; dependency skills by bare name with the plugin form at first mention, example `shaping` (`shaping-skills:shaping`).
- **Gate** (guidelines): the old-name grep's allowed matches become `shared/work.md` § Upgrade and README § Upgrading from an older Flow, named in its comment; the link check loses any README exclusion; the "while a work is in progress" sentence stays. The Naming rule's checked sentence is kept only if still true.
- **README**: Install; Use in a project; Usage (`/flow:dev`, `/flow:project`, `/flow:brainstorm`, `/flow:grill`, `/flow:changelog`, `/flow:archive`); How a work runs (definition path, the slice loop on Flow's agents, tiers, the ledger); Profile and stack presets (shipped `astro`, `datocms`, `rails`; mapping your own); What lands in a project; Project lenses; Plan review lenses; Configuration (`.flow.yml` keys `root`, `stacks`, `merge`, `changelog`, `version_file`, `areas`, `presets`; the plugin options `model_top`, `model_mid`, `stack_presets`, set from the plugin's configuration or `pluginConfigs` in settings, with no claim about when the dialog opens; `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` with `CLAUDE_CODE_SUBAGENT_MODEL`, and `CLAUDE_CODE_EFFORT_LEVEL`, which override models and effort); `install.sh` (checks the dependencies for the current repo); Upgrading from an older Flow (old skills removed, then the upgrade step; superpowers may stay installed: inside a Flow run its process skills don't apply, outside it they behave as before); Develop; Update; Uninstall; Credits ([CREDITS.md](../../../CREDITS.md)); License. No "doesn't merge" (it merges locally after an ok).
- **architecture.md**: Distribution unchanged in substance; the lifecycle and its Mermaid blocks redrawn (brainstorm → grill → frame; plan, review, execute and impact on agents; `flow:docs`; presets); What a project holds (configuration keys, `brainstorm.md`, the ledger, decisions format); Where the plugin ends (dependencies now `shaping-skills` and per-stack optionals); the "doesn't merge" text and the `merge` node of the lifecycle diagram fixed (local merge after an ok, `pr` when configured); the section the `#project-memory` link points to describes search through `flow:docs`. Every Mermaid block renders with `npx -y @mermaid-js/mermaid-cli` and is read as an image.
- **dependencies.md**: checked against the new shape; no superpowers.

## Tasks

### T1 — The upgrade step and the fallbacks · `critical`
- **What**: `shared/work.md` § Upgrade per "The upgrade"; dev and project run it where "When" says; the three other entry points stop and point to `/flow:dev`; Step 0's condition; every fallback removed per "Fallbacks removed"; `install.sh:23` says it reads `.flow.yml` only.
- **Files**: `shared/work.md`, `skills/dev/SKILL.md`, `skills/project/SKILL.md`, `skills/docs/SKILL.md`, `skills/changelog/SKILL.md`, `skills/archive/SKILL.md`, `install.sh`.
- **Verified**: `rg -n -i 'devflow' skills shared install.sh </dev/null` → only § Upgrade; `bash -n install.sh`; `claude plugin validate .`.
- **Done**: as verified.

### T2 — Naming and Gate · depends on: T1
- **What**: `docs/development-guidelines.md` per "Naming" and "Gate".
- **Files**: `docs/development-guidelines.md`.
- **Verified**: the Gate's old-name grep, run as written, prints only lines in the allowed places (README's section arrives in T3: before it, README's current matches are expected).
- **Done**: as decided.

### T3 — README, architecture, dependencies · `critical` · depends on: T1
- **What**: per "README", "architecture.md", "dependencies.md". Facts come from the skills and agents as they are now, not from memory of earlier versions.
- **Files**: `README.md`, `docs/architecture.md`, `dependencies.md`.
- **Verified**: each Mermaid block rendered to PNG in the scratchpad and read; the Gate's link check prints nothing; every claim about Claude Code behaviour linked or verified (guidelines § Tests).
- **Done**: as verified.

### T4 — Demonstrate and gate · depends on: T2, T3
- **What**: headless, `--max-budget-usd 10` per run, prompts pre-answering every question.
  1. A throwaway repo on `main`, committed, with `.devflow.yml` (`root: notes`, `stack: astro`), `notes/work/archived.md` citing `/devflow-archive`, a `CLAUDE.md` naming `/devflow`, `astro.config.mjs`. Turn 1 `/flow:dev` "stop at your first message" → the change list, the `CLAUDE.md` line pointed at, one question; nothing written; no profile question. Turn 2 "ok, upgrade; don't merge" → one commit on `flow-upgrade`: `.flow.yml` with `root: notes` and `stacks: [astro]`, no old file, the archived header rewritten; `main` and `CLAUDE.md` untouched; the checkout back on `main`.
  2. The same repo after turn 1, a fresh run declining → nothing written, no work opened, the message as decided.
  3. A repo with both files (`.flow.yml` `merge: pr`; `.devflow.yml` `merge: local`, `changelog: notes/log.md`) → the change list shows `merge: pr` kept and `changelog` moved.
  4. `/flow:changelog` in the repo of 1 before the upgrade → stops and points to `/flow:dev`.
  5. A folder of projects, a home with a sub-project, each with a "devflow work `x` in `repo` merged" row, not under git: `/flow:project` resume → both rewrites proposed; on ok, both rows read "flow:dev work …".
  Then the Gate, without the narrowing; the Mermaid PNGs read.
- **Files**: none in the repo.
- **Verified**: `git`, `cat`, `jq` over the stream JSON.
- **Done**: outcomes as stated, Gate green, Mermaid blocks read.

## Order

T1 → T2 and T3 (separate files) → T4. One commit per task, pathspec form.

## Deviations from the mandate

- **The Gate's old-name grep also allows README § Upgrading from an older Flow**: a user upgrading needs the old command names to remove them.
- **`install.sh` still reads `stack:`**: a repo not yet upgraded keeps its per-stack rows; `stack:` is not an old name.
- **An upgrade is a run of its own**, committed on `flow-upgrade` (outside `work/`), merged locally after its own ok: no work is opened or resumed on old state.
- **Declining stops the run**: the fallbacks are gone, so nothing runs on an unread configuration.
- **The entry points other than the conductors don't upgrade**: they stop and point to `/flow:dev`.
- **Open work branches are pointed at, not rewritten**: they pick the upgrade up from the default branch.
