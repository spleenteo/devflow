---
work: flow-own-engine
slice: V3
tags: [plan, flow-own-engine]
description: "Plan for V3: one decision format for both layouts inside flow:docs, a Bash and awk check script, search by touches:, and this work's five decisions recorded in it."
---

# V3 — Decision format · plan

**Mandate**: [`slices.md` § V3](slices.md#v3--decision-format). **Source**: the brief [`docs/briefs/2026-10-25-decisions-log.md`](../../../briefs/2026-10-25-decisions-log.md) (its evidence and project names stay out of the repo). **Guidelines**: [`docs/development-guidelines.md`](../../../development-guidelines.md). **Lessons**: [`lessons.md`](lessons.md). **Builds on**: `skills/docs/SKILL.md` (V2's request contract).

**Execution rules**: executors on `sonnet`; reviewers on `opus` for `critical` tasks, `sonnet` otherwise; current checkout on `work/flow-own-engine`; check the tree before re-dispatching a failed executor; demos on throwaway repos in the session scratchpad, flags passed as an array.

**The format, decided here** (T1 writes it down):
- `# <Title: the decision as a statement>`, then `**Date**: YYYY-MM-DD`; the file name carries the same date.
- Frontmatter: `kind` (`decision` | `deferral`); `status` (`active` → `superseded`, or `open` → `resolved`); `superseded_by` (file) or `resolved_by` (work slug); `work` (repo; `null` for a decision taken outside a work) or `project` + `slice` (project); `area`; `touches` (repo only: paths and symbols, a non-empty list); `description` (≤ 160 characters, quoted).
- Lists (`touches`, and `areas` in `.flow.yml`) in flow form only: `[a, b]`. The check rejects block lists.
- Headings, all present, in order: `## The decision` (one line), `## Context`, `## Alternatives discarded` (decision) or `## Why deferred` (deferral), `## Consequences`, `## Reopen when`, `## References`, `## Status log`. Body roughly under 40 lines; analyses go in linked documents.
- The body is never edited after writing: later changes are the frontmatter status fields and dated lines under `## Status log`.
- `area` comes from `areas:` in `.flow.yml` when the project declares one; otherwise free, one kebab-case word. Optional in the project layout.
- A file without `kind:` is legacy: read as before, skipped by the check and counted. A status change on a legacy file appends a `## Status log` section if missing and adds no `kind:`.

## Tasks

### T1 — Format and check script · `critical`
- **What**: `skills/docs/decisions.md`: the format above for both layouts (path `<root>/decisions-log/YYYY-MM-DD-<slug>.md` in a repo, `<home>/decisions/YYYY-MM-DD-<slug>.md` in a project), one template per kind, superseding and resolving through the status log, legacy files, a short migration note (old files stay as they are; a project converts them on its own, if ever). `skills/docs/scripts/decisions-check` (Bash and awk only, mode `100755`, header line `# decisions-check v1`): `decisions-check [--project] [--areas a,b,c] <dir>` checks every `*.md` with `kind:` in `<dir>` (skipping `README.md`, `check.sh`): frontmatter keys and values by kind and status, `description` length in characters (BSD awk counts bytes: drop UTF-8 continuation bytes, `gsub(/[\200-\277]/,"")`, and the surrounding quotes before `length`), `area` against `--areas` when given, `touches` a non-empty flow list unless `--project`, block lists rejected, headings present and in order, `## The decision` one non-empty line; body over 40 lines is a warning. Prints `file: problem` per error, then `checked N, legacy M, errors K, warnings W`; exit 1 when K > 0.
- **Files**: `skills/docs/decisions.md`, `skills/docs/scripts/decisions-check` (new).
- **Verified**: on scratchpad fixtures: a valid decision, a valid deferral, a description of exactly 160 characters with em dashes (passes) and one of 161 (fails), one fixture per error class, a block-list `touches`, a legacy file → each error reported once, legacy counted, exit codes right; `bash -n`; run with `/bin/bash` 3.2 and `/usr/bin/awk`; `git ls-files -s` shows `100755`; `claude plugin validate .`.
- **Done**: format and script exist; fixtures behave as stated.

### T2 — `flow:docs` writes and checks decisions · `critical` · depends on: T1
- **What**: in `skills/docs/SKILL.md`:
  - The format file read through `${CLAUDE_SKILL_DIR}/decisions.md`, the script run as `bash ${CLAUDE_SKILL_DIR}/scripts/decisions-check` (substituted in the text; never from env).
  - Contract text updated: the request is the `ARGUMENTS:` text, a header line of `key: value` pairs, followed for `decision-write` by note lines; `keywords` or `files` (at least one) for `search` and `descriptions`; Configuration table gains `areas`; frontmatter `description` mentions decisions; the "Write decisions" row leaves "What it does NOT do".
  - In the project layout, `project` names the home folder and decisions live in `<dir>/<project>/decisions/`; `decision-write`, `decision-status` and `decision-check` need `project` there; `files:` is ignored in that layout (no `touches:`).
  - New ops:
    - `decision-write`: header fields `kind`, `slug`, `work` (repo) or `project` + `slice` (project); then labelled note lines (`decision:`, `context:`, `alternatives:` or `why-deferred:`, `consequences:`, `reopen-when:`, `references:`, `touches:`, `area:`), one line per item, a label repeated for several items. Writes the file in the format, runs the check on it (with `--areas` from `.flow.yml`, `--project` in the project layout), fixes what it reports, commits it alone with the pathspec form (repo, or a project home under git). Returns `Recorded <path> — <commit sha | not committed> — check: <summary line>` or `NEEDS:`/`FAILED:`.
    - `decision-status`: `file`, `status`, `superseded_by` or `resolved_by`, `note` → updates the frontmatter, appends `- YYYY-MM-DD — <note>` under `## Status log` (adding the section to a legacy file), commits. Never touches the body.
    - `decision-check`: runs the script over the layout's decisions folder; with `install: yes`, copies it to `<root>/decisions-log/check.sh` (repo) keeping its version header; when a copy exists with an older header, the return line says so.
  - `search` and `descriptions` accept `files: <path>, <path>`: a decision matches when one of its `touches:` entries equals a file or is a parent directory of it, compared by whole path segments (`src/menu` matches `src/menu/Item.tsx`, not `src/menu-old/x`); a path that appears only in the body doesn't count as a `files` match. Key words and files combine.
  - The changelog's Decision bullet: decisions found with `rg -l '^work: <slug>$' <root>/decisions-log/`.
- **Files**: `skills/docs/SKILL.md`.
- **Verified**: `claude plugin validate .`; read-through against the contract and `decisions.md`; one direct runtime check on a throwaway repo: a two-line `decision-write` request run headless through a caller prompt, the fork's Bash calls (messages with `parent_tool_use_id`) show the absolute script path, and the file passes the check.
- **Done**: the five changes in place; substitution and multi-line request confirmed at runtime.

### T3 — Conductors propose, `flow:docs` writes · depends on: T2
- **What**:
  - `shared/work.md`: new section **Decisions** (both layouts): when to propose one (a real alternative discarded, a problem deferred on purpose, a behaviour that will surprise, an outside constraint) and the test "does the choice outlive the work? if not, it goes in `slices.md` or `lessons.md`"; propose, never write unasked; on a yes, send `decision-write` with the notes; superseding or resolving through `decision-status`; when the user asks to check the log or to copy the check into the project (for its own Gate or CI), send `decision-check`, with `install: yes` for the copy.
  - `skills/dev/SKILL.md`: Conventions row Decisions → the reference § Decisions, written by `flow:docs`; the `.flow.yml` key list gains `areas`; Step 4 close and Step 5 decision-candidate lines point there; the impact packet and the plan review get matching decisions through `descriptions` with `files:` (the slice's or plan's files) as well as key words; the "Memory and debt" lens in `skills/dev/lenses.md` names `touches:`.
  - `skills/project/SKILL.md`: Conventions row and Step 5 point to the reference § Decisions.
  - `git rm skills/dev/decisions-log.md skills/project/decisions.md`.
- **Files**: `shared/work.md`, `skills/dev/SKILL.md`, `skills/dev/lenses.md`, `skills/project/SKILL.md`, the two removed files.
- **Verified**: `rg -n "decisions-log\.md|decisions\.md" skills shared </dev/null` finds only `skills/docs/`; `claude plugin validate .`; read-through of the three conductors' decision passages against `shared/work.md`.
- **Done**: the decision rules exist once (format in `flow:docs`, criterion in the reference).

### T4 — This work's five decisions · depends on: T1
- **What**: five files in `docs/decisions-log/`, dated 2026-10-26, `work: flow-own-engine`, in the new format, sourced from `frame.md`, `shaping.md` and `slices.md` of this work: superpowers leaves (Flow writes and runs its own plans); a work runs on `work/<slug>` in the current checkout and closes with a local merge; stack presets are opinionated skills a project can replace, never merge; atomic-commits' criteria are absorbed, not a dependency; flow-own-engine ships as one release, v0.2.0. `area` from a small vocabulary declared in this repo's `.flow.yml` (`areas: [engine, workflow, presets, release]`; create `.flow.yml` with that key only).
- **Files**: five decision files, `.flow.yml` (new).
- **Verified**: `bash skills/docs/scripts/decisions-check --areas engine,workflow,presets,release docs/decisions-log` → `checked 5, legacy 3, errors 0`.
- **Done**: as verified; no personal project or tool names.

### T5 — Demonstrate and gate · depends on: T2, T3, T4
- **What**: headless (`claude -p` with `--plugin-dir /Users/spleenteo/Sites/me/devflow --dangerously-skip-permissions --output-format stream-json --verbose`, as an array). The fork's work is checked only in messages that carry `parent_tool_use_id`.
  1. a repo on `work/<slug>` with `STATUS.md` at `phase: slice`, `step: close`, and a slice narrative holding a ruling that discarded an alternative, touching `src/menu/`. First turn: `/flow:dev`, close the slice, stop at the decision candidate → `git status` shows no decision file. Second turn (`--resume`): yes → a file in `docs/decisions-log/` through `flow:docs`; the fork ran the script (its Bash call with the absolute path); `git show --name-only HEAD` lists only that file.
  2. same repo, a direct request through a caller prompt: `op: search, files: src/menu/Item.tsx` finds it; `files: src/menu-old/x.ts` doesn't; a path present only in its body doesn't match.
  3. a folder of projects, one home at a step close, prompt accepting a decision candidate → `<home>/decisions/` file through `flow:docs`, project variant, check passing with `--project`.
  4. `decision-status` superseding the file from 1 → frontmatter and a status-log line changed, body identical (`git diff`).
  5. `decision-check` with `install: yes` → `docs/decisions-log/check.sh` with the header; lower its header to `v0` and run `decision-check` again → the return line says the copy is older.
  Then the Gate with the narrowing (link check excludes `README.md` from V3 on).
- **Files**: none in the repo.
- **Verified**: `git`, `cat`, the script, `jq` over the stream JSON.
- **Done**: five outcomes as stated, Gate green.

## Order

T1 → T2 and T4 (parallel, separate files) → T3 → T5. One commit per task, explicit paths.

## Deviations from the mandate

- **`area` vocabulary lives in `.flow.yml` (`areas:`) only**, not in a log README: one place, read by the check through `--areas`. V4's profile may ask for it.
- **This repo gets a `.flow.yml`** with only `areas:`, to dogfood the vocabulary.
- **`decision-write` takes a multi-line request**: a header line, then the conductor's notes; the format stays in `flow:docs`.
- **Stale prose left for V8**: `docs/architecture.md` (decisions-log rows, `${CLAUDE_SKILL_DIR}` note) and `README.md:117` still describe the old files; no link breaks outside `README.md`.
