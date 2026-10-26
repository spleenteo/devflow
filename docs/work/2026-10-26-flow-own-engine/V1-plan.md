---
work: flow-own-engine
slice: V1
tags: [plan, flow-own-engine]
description: "Plan for V1, the work layer: one shared reference for the work's home, state, close and archive, used by dev and project; branch in the main checkout, local merge."
---

# V1 — Work layer · plan

**Mandate**: [`slices.md` § V1](slices.md#v1--work-layer). **Guidelines**: [`docs/development-guidelines.md`](../../development-guidelines.md) (Tests, Naming, Language, Commits, Gate). No `lessons.md` yet.

**Execution rules for this slice** (the new engine arrives in V6): executors on the mid tier (`sonnet`), reviewers on the most capable (`opus`) for tasks marked `critical`; no worktree, current checkout on `work/flow-own-engine`; no test framework, verification by running the plugin on throwaway repos outside this repo.

## Tasks

### T1 — Write the shared work reference · `critical`
- **What**: create `shared/work.md` at the plugin root. Sections, each saying which layout it applies to (**repo**: `<root>/work/` in a code repo, default root `docs`; **project**: the home folder `/flow:project` opens):
  - *Layouts and home*: where a work lives in each layout; repo: `mkdir <root>/work/YYYY-MM-DD-<slug>` plus `git switch -c work/<slug>` in the current checkout, recording the branch it was cut from as `base:` in `STATUS.md`; a worktree only when the user asks; project: the home folder.
  - *`STATUS.md`*: the two frontmatter variants (repo: `status, phase, slice, step, work, stack, base, updated, tags, description`; project: adds `project, parent, appetite`, no `work, stack`), the body, the Log line formats; what `phase`/`slice`/`step` mean and when each changes; `updated:` on every write.
  - *`slices.md` and `lessons.md`*: In/Out/Done/Gotchas per slice; "Deviations found while planning"; "V<n> — done on <date>" narrative; one rule per line in `lessons.md`, created at the first close.
  - *Close of a work* (repo): mark closed; changelog (`/flow:changelog`) and archive, each after asking; then the merge. Target: `git symbolic-ref refs/remotes/origin/HEAD` with `refs/remotes/origin/` stripped; else the work's `base:`; else `init.defaultBranch` only if `git rev-parse --verify` finds it; else ask. `git switch <target>` before merging; `merge` key in `.flow.yml`: `local` (default) proposes `git merge --no-ff work/<slug>` into it and runs it after an ok; `pr` proposes a PR instead; the user's request overrides either; push and tag always need their own ok; the branch is deleted only on request.
  - *Close of a project* (project): `report.md`, then the archive offer.
  - *Archive*: repo procedure = today's `skills/archive/SKILL.md` Steps 0–7 verbatim in substance; project procedure = move the home to the sibling `<home>/../archive/` (`git mv` if the folder is in git, else `mv`), `archived: YYYY-MM-DD` written first, no wall, no `archived.md` unless the folder is a git repo (then the index lives at `<home>/../archived.md`), `report.md` stays inside.
- **Files**: `shared/work.md` (new).
- **Verified**: read-through against the V1 mandate and the current texts of `dev` Steps 2/4-close/6, `project` Steps 2/4-close/6, `archive`; every rule moved, none invented; each path names its layout.
- **Done**: the file exists and holds every rule above, in English, without project names.

### T2 — `dev` reads the reference · `critical` · depends on: T1
- **What**: in `skills/dev/SKILL.md` replace the `STATUS.md` template and home creation (Step 2), the bookkeeping in `step: close` (tick, Log, lessons placement) and Step 6 with pointers to `${CLAUDE_PLUGIN_ROOT}/shared/work.md` sections, keeping *when* each happens. Conventions table: a row for the work reference, cited as `${CLAUDE_PLUGIN_ROOT}/shared/work.md` with the in-repo link `[shared/work.md](../../shared/work.md)` as `dependencies.md` already is; `.flow.yml` keys gain `merge` (`local` | `pr`). "What it does NOT do": add a row "Merge, push or tag without an ok"; Step 6.4's "This skill doesn't merge or push" and the following sentence that assumes a merge review are rewritten for the local merge. `step: execute` gains the override: current checkout on `work/<slug>`, no worktree (until V6). The resume reload list stays here.
- **Files**: `skills/dev/SKILL.md`.
- **Verified**: `rg -n "status: open|git mv|archived.md|Doesn't merge|doesn't merge" skills/dev/SKILL.md` finds nothing but pointers; read-through: every step still says when to act.
- **Done**: dev's flow reads the same as before except the new branch, merge and override rules.

### T3 — `project` reads the reference · depends on: T1
- **What**: in `skills/project/SKILL.md` replace the `STATUS.md` template (Step 2), the close bookkeeping and Step 6's archive offer with pointers to `shared/work.md` (same citation form as T2); keep `constraints.md`, appetite and the reload list here.
- **Files**: `skills/project/SKILL.md`.
- **Verified**: `rg -n "status: open|archive/" skills/project/SKILL.md` finds only pointers.
- **Done**: as T2, for `project`.

### T4 — `/flow:archive` becomes an entry point · depends on: T1
- **What**: `skills/archive/SKILL.md` keeps its frontmatter (description widened to `/flow:project` homes) and a short body: pick the layout, follow `shared/work.md` § Archive, report. The `.devflow.yml` fallback sentence moves to `shared/work.md` (allowed by the Gate narrowing).
- **Files**: `skills/archive/SKILL.md`.
- **Verified**: the body is under 25 lines; no procedure step left in it.
- **Done**: archiving rules exist in one file only.

### T5 — Demonstrate and gate · depends on: T2, T3, T4
- **What**: on throwaway repos in the session scratchpad, headless (`claude -p "<prompt>" --plugin-dir /Users/spleenteo/Sites/me/devflow --dangerously-skip-permissions --output-format stream-json --verbose`), with prompts that state the user's answers and consent up front:
  1. repo, default branch `master`: `/flow:dev` opens technical work `hello` → branch `work/hello`, `git worktree list` shows one entry, `STATUS.md` as the reference;
  2. same repo, a work prepared with its last slice ticked, `phase: slice`, and a changelog entry; the prompt says the work is complete: the close merges into `master` after the stated ok, no push;
  3. same with `merge: pr` in `.flow.yml`: a PR is proposed, nothing merged;
  4. `/flow:archive hello` on a second closed work, with a doc linking into its folder beforehand: moved under `docs/work/archive/`, that link fixed, `archived.md` row, wall proposed;
  5. plain folder: `/flow:project` opens `Garden`; closed, archived to the sibling `archive/`.
  6. `rg -n "^status: open|git mv docs/work" skills/ shared/` matches only `shared/work.md`.
  Then the Gate with the narrowing in `slices.md`.
- **Files**: none in the repo (scratchpad only).
- **Verified**: each outcome checked with `git`/`ls`/`rg` after the run; the stream JSON kept in the scratchpad.
- **Done**: all six outcomes as stated, Gate green.

## Order

T1 → T2, T3, T4 (in parallel) → T5. One commit per task, explicit paths.
