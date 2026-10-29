---
tags: [work, lean-conductor, plan]
description: "Plan of V1 of the lean-conductor work: the slice packet on disk passed by path, short agent returns with reports on disk, the planner's ten-line summary, a resume table per phase and step, a fresh-session line at a natural pause, the session facts linked to the docs."
---

# V1 — The main session grows less

**Mandate**: [slices.md § V1](slices.md); numbers in [baseline.md](baseline.md); [the decision](../../decisions-log/2026-10-29-main-session-grows-less-not-cleared.md). **Guidelines**: [development-guidelines.md](../../development-guidelines.md) (Tests, Naming, Language, Commits, Gate). **Lessons**: none yet. **Execution rules**: [executor.md](../../../agents/executor.md); test level `none`. Don't pre-empt V2 (`skills/design*`) or V3 (ledger write cadence, the `One line per dispatch` bullet of `shared/work.md` § Agents, close order, `measure/bash_kinds.py`).

## The slice, decided here

- The packet file is `<work dir>/V<n>-packet.md`, opening with `# Slice packet — V<n>`, written once at the start of `step: plan` (reused as is when it exists on resume). Every dispatch of the slice opens with the same line, `Read the slice packet first: <absolute path>.`, then the role's instruction. Extra decisions found at review go in the reviewer's instruction, never into the file.
- Packets outside a slice (impact, fidelity check, builder check, everything in `/flow:project`) stay inline: each is dispatched once or twice with different contents, so a file saves no reread.
- Reports on disk: `<work dir>/V<n>-reports/T<n>-<round>-executor.md` and `T<n>-<round>-review.md` (final review: `final-<round>-review.md`), round 1 to 3, path named in each instruction or SendMessage. The task reviewer gets the executor's report as that path, so it reads what the executor wrote, never a copy; if the file is missing (resume from another checkout) it gets the ledger's copy and is told so.
- Packet and reports are working files: not committed, removed at the close before its commit. They are rebuilt from committed files, the ledger keeps every return, and a committed packet copies guideline text whose relative links break a link-check gate from the work folder (this repo's own).
- Returns: executor `Status`, `Commits`, `Tests`, `Servers`, `Concerns`, `Report: <path>` (under 1,500 chars, `Files` and narration go in the report); task reviewer `Spec`, `Quality`, one line per finding `<severity> · <file:line> · <what>`, `Report: <path>` (fixes in the report); planner `Plan`, `Summary` (at most ten lines, for the first stop), `Deviations`. Impact and plan-reviewer keep their full return: the user reads it at the stop.
- The fresh-session line is said only when the answer at the second stop is to stop here: going on stays in the same session, otherwise the line recurs at every slice. It names, rather than records, a model asked for in this session and a session-only test level: both are session-scoped by definition, and a `STATUS.md` key would change that.
- Claude Code facts, linked: `/clear` and `/compact` ([commands](https://code.claude.com/docs/en/commands#all-commands)); `/compact` can't run through the Skill tool ([restrict skill access](https://code.claude.com/docs/en/skills#restrict-claudes-skill-access)); re-attached skills, first 5,000 tokens each, 25,000 in all ([skill content lifecycle](https://code.claude.com/docs/en/skills#skill-content-lifecycle)); auto-compaction works as `/compact` ([what survives compaction](https://code.claude.com/docs/en/context-window#what-survives-compaction)). Undocumented, verified in T9: `/clear` writes a new transcript file, compaction keeps the same one.

## Tasks

### T1 — Work reference: dispatch, reports, sessions (critical)
- **What**: In § Agents, replace **Dispatch contract** with the prefix line, the working files and the inline rule outside a slice, as decided above; add **Reports on disk** (paths, who writes, who reads, the missing-file fallback, removal at close); in the ledger bullet `Each agent's report is appended…`, the return goes under its line as returned, plus the report's path. Add `## Sessions` after § Agents (both layouts): the four linked facts and the two transcript facts; Flow never runs `/clear` or `/compact` nor asks for them as a step; the fresh-session line, *"Stopping here: another day, resume in a new session with `/flow:dev`"* (`/flow:project` in that layout), plus the model or session-only test level it names.
- **Files**: `shared/work.md`.
- **Verified**: `rg -c 'Read the slice packet first' shared/work.md` ≥ 1; `rg -n '^## Sessions' shared/work.md` one line; `rg -o 'code.claude.com/docs/en/(commands#all-commands|skills#restrict-claudes-skill-access|skills#skill-content-lifecycle|context-window#what-survives-compaction)' shared/work.md | sort -u | wc -l` prints 4; `rg -n 'One line per dispatch' shared/work.md` unchanged from `git show HEAD:shared/work.md`.
- **Done**: committed, `Pass the slice packet by path and keep reports on disk`.
- **Interfaces**: produces § Sessions and § Agents' **Reports on disk**, cited by T3, T6 and T7.

### T2 — /flow:dev resume table per phase and step (critical)
- **What**: In § On start, keep the always-reloaded set (`STATUS.md`, criterion, applying guidelines, `lessons.md`, decision descriptions) and add a table `phase:` / `step:` → also reloaded: `frame` → `brainstorm.md` when present; `design` → `shaping.md`, `docs/design/README.md`; `slicing` → `shaping.md`, or `breadboard.md` when present; `impact` → `slices.md` in full; `step: plan` → the packet's path when it exists, else what builds it (the slice's section, `docs/impact-lenses.md`, decisions matched by `files:` the slice's files, the presets' `## Rules`, `shaping.md`/`breadboard.md` only when pointed to) and the previous plan's path; `review` → the plan (the planner's summary died with the session), the packet path; `execute` → the plan, the ledger, the packet path; `close` → the slice's section, the ledger. Unlisted phases add nothing. Never reloaded: the current exceptions rewritten to match, plus `V<n>-reports/`. One sentence under it: each row holds what the next step reads, so a resume costs one read per document.
- **Files**: `skills/dev/SKILL.md`.
- **Verified**: `rg -n "impact-lenses.md|slices.md. in full|breadboard.md" skills/dev/SKILL.md` shows the new rows inside § On start; `claude plugin validate .` passes with the guidelines' expected warnings.
- **Done**: committed, `Reload what the next step reads on resume`.
- **Interfaces**: produces the row names T3 cites (packet rebuilt "as at `step: plan`").

### T3 — /flow:dev slice loop on the packet file (critical, depends on: T1, T2)
- **What**: Cost discipline rule 2 becomes **Same packet, by path** (one write, one prefix line, cache). Step 4: the packet paragraph writes `V<n>-packet.md` with its heading; `step: plan` dispatches with the line and states the planner's return; `step: review` puts new decision descriptions in the reviewer's instruction; **First stop** shows the planner's `Summary` as returned, never reading the plan; `step: execute`: the packet and `V<n>-reports/` aren't leftovers, the executor and reviewer instructions name report paths, the review gets the executor's report path (replacing "verbatim, never the ledger's trimmed copy"), fix rounds pass the review report's path, the final review uses the line; `step: close` move 4 removes the working files before the commit, and after the second stop's answer is acted on and committed, the fresh-session line of `shared/work.md` § Sessions.
- **Files**: `skills/dev/SKILL.md`.
- **Verified**: `rg -n 'placed verbatim|packet verbatim|packet on top' skills/dev/SKILL.md` prints nothing; `rg -c 'Read the slice packet first|V<n>-reports' skills/dev/SKILL.md` ≥ 2; `rg -n '§ Sessions' skills/dev/SKILL.md` ≥ 1; `claude plugin validate .` passes as above.
- **Done**: committed, `Run the slice loop on the packet file`.

### T4 — Planner, plan reviewer, impact
- **What**: In each `## What comes in the packet`: when the prompt opens with `Read the slice packet first: <path>`, read that file before anything else. `planner.md` § What you return: `Plan:`, `Summary:` (at most ten lines: what the slice builds, the tasks in order, what is critical, how the Done is shown), `Deviations:`; under 2,000 chars.
- **Files**: `agents/planner.md`, `agents/plan-reviewer.md`, `agents/impact.md`.
- **Verified**: `rg -c 'Read the slice packet first' agents/planner.md agents/plan-reviewer.md agents/impact.md` prints 1 per file; `rg -n '^Summary:' agents/planner.md` one line; `claude plugin validate .` passes as above.
- **Done**: committed, `Have the planner return its plan in ten lines`.

### T5 — Executor and task reviewer: reports on disk (critical)
- **What**: Both read the packet line as in T4. `executor.md`: writes its full report (the current six fields plus what it did, under 40 lines) to the path the instruction names, an exception to "outside the task's Files", never committed; returns the six lines decided above. `task-reviewer.md`: `Write` added to `tools`; the executor's report arrives as a path, still a claim; writes findings with fixes to its report path (its only write); returns verdicts, finding lines and `Report:`.
- **Files**: `agents/executor.md`, `agents/task-reviewer.md`.
- **Verified**: `rg -n '^tools:.*Write' agents/task-reviewer.md` one line; `rg -n '^Report:' agents/executor.md agents/task-reviewer.md` one per file; `rg -n 'claim' agents/task-reviewer.md` still matches; `claude plugin validate .` passes as above.
- **Done**: committed, `Keep the executor's and reviewer's reports on disk`.

### T6 — /flow:project: resume table and the fresh-session line (depends on: T1)
- **What**: § On start: same structure as T2; rows `frame` → `brainstorm.md`; `slicing` → `shaping.md`; `reality` → `slices.md` in full, `shaping.md` when present; `step: plan` → the slice's section; `review`, `execute` → the plan; `close` → the slice's section, the plan. Step 4 **Second stop**: the line of `shared/work.md` § Sessions, project layout. Packets stay inline (no change).
- **Files**: `skills/project/SKILL.md`.
- **Verified**: `rg -n '§ Sessions' skills/project/SKILL.md` ≥ 1; `rg -n 'step: execute|step: close' skills/project/SKILL.md` shows the new rows in § On start; `claude plugin validate .` passes as above.
- **Done**: committed, `Reload what the next step reads in /flow:project`.

### T7 — README and architecture (depends on: T1–T6)
- **What**: `README.md` line 86 (packet by path, short returns, the line when you stop) and 89 (resume per phase and step); `docs/architecture.md` line 131 (same), line 133 first sentence only (packet written once, passed by path), line 187 (working files `V<n>-packet.md`, `V<n>-reports/`, removed at the close).
- **Files**: `README.md`, `docs/architecture.md`.
- **Verified**: `rg -n 'V<n>-packet.md|by path' README.md docs/architecture.md` ≥ 3 lines; `rg -n 'put at the top of every prompt' docs/architecture.md` prints nothing.
- **Done**: committed, `Describe the leaner conductor in the docs`.

### T8 — Transcript check for the Done
- **What**: `measure/v1_checks.py <transcript.jsonl>`, same style as `big_results.py`: (A) FAIL for an `Agent` input holding `# Slice packet — `, or a `flow:planner`/`flow:executor`/`flow:task-reviewer` input not starting with `Read the slice packet first: `; (B) FAIL for an `Agent` result over 2,000 text chars unless `flow:impact` or `flow:plan-reviewer`; `<task-notification>` user messages over 2,000 printed as CHECK with 100 chars; (C) FAIL for a non-`Agent` tool input holding `-plan.md` between a `flow:planner` result and the next human message. Prints `PASS A/B/C` or the FAIL lines; exit 1 on a FAIL.
- **Files**: `docs/work/2026-10-29-lean-conductor/measure/v1_checks.py` (new).
- **Verified**: `python3 -I -m py_compile` on it exits 0; on a three-line fixture written in `mktemp -d` (an `Agent` call to `flow:executor` whose prompt holds `# Slice packet — V1`) it prints `FAIL A` and exits 1.
- **Done**: committed, `Add the V1 transcript check`.

### T9 — Throwaway run, with the user (depends on: T1–T8)
- **What**: the conductor prepares `d=$(mktemp -d)/lean-v1-demo`: `git init -b main`, `src/greet.sh`, guidelines with `Level: none` and a `## Gate` of `sh -n src/greet.sh`, `docs/impact-lenses.md` with one lens, a decision touching `src/greet.sh` per `skills/docs/decisions.md`; first commit. The user runs `claude --plugin-dir /Users/spleenteo/Sites/me/flow` there and `/flow:dev` for a technical work of three tiny slices; V1 and V2 run through their closes; at V2's second stop the answer is to stop. Then the conductor runs `python3 -I` T8's script on `ls -t ~/.claude/projects/*lean-v1-demo*/*.jsonl | head -1`. The user opens a new session, `/flow:dev`: the resume names V3 `step: plan` in five lines; `V3-packet.md` holds the slice section, the level and guidelines, the decision, the lenses. Last, the user runs `/compact` then `/clear`; the conductor counts the `.jsonl` files and `compact_boundary` lines.
- **Files**: none in the repo (results go to the close narrative).
- **Verified**: T8 prints `PASS A`, `PASS B`, `PASS C`; the V2 stop shows the fresh-session line; after `/compact` the file count is unchanged and one `compact_boundary` appears, after `/clear` one more file.
- **Done**: results reported to the conductor for the close; a contradicted fact goes back to T1 as a finding.

## Order

T1, T2, T4, T5, T8 in parallel (separate files). Then T3 (after T1, T2, same file as T2) and T6 (after T1), in parallel. Then T7. T9 last, run by the conductor with the user in an interactive session.

## Deviations from the mandate

- Packet and reports are not committed: removed at the close, since a committed packet breaks this repo's link-check gate and both are rebuilt from committed files.
- Docs beyond the lines named: `docs/architecture.md` line 133 (packet sentence only; its ledger part stays for V3) and line 187, which V1 makes stale.
- The throwaway work has three slices: two run through their closes, the third is where the resume and the planner's packet are checked.
