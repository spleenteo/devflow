---
work: lean-conductor
slice: V1
tests: none
updated: 2026-10-29
---

# V1 plan — The slice runs in a subagent

**Mandate**: [slices.md § V1](slices.md) · [decision](../../decisions-log/2026-10-29-slice-execution-runs-in-a-runner-subagent.md) · **Guidelines**: [Tests, Naming, Language, Commits, Gate](../../development-guidelines.md) · **Lessons**: none yet · **Execution rules**: [executor.md](../../../agents/executor.md)

**Summary**
1. New agent `agents/slice-runner.md` (top tier) runs the loop and close moves 1–2 as drafts, returns `DONE | STOP | NO_NESTING`.
2. `shared/work.md` § Agents: the runner, nesting, fork mode, fallback; the ledger tail (`Final review:`, `Gate:`, `## Close draft`) defined there once.
3. `skills/dev/SKILL.md`: reload table per phase and step (four gaps closed, no second runner); plan and review use the planner's Summary and Files; execute writes `step: execute`, a packet file, dispatches the runner once and waits; fallback runs `#### The loop` in session.
4. The planner returns and writes a Summary and a `Files:` line. `/flow:project` gets its two reload gaps fixed.
5. `README.md` and `docs/architecture.md` follow. The Done runs at the close, by the conductor with the user, in three throwaway runs.

**Files**: agents/slice-runner.md, agents/planner.md, shared/work.md, skills/dev/SKILL.md, skills/project/SKILL.md, README.md, docs/architecture.md

## The slice, decided here

- Runner on the top tier, `model: opus`, `effort: medium`: rulings need the top model; most turns are mechanical dispatches.
- `step: execute` is committed with the plan's fixes before the dispatch, so a resume in another session finds it on the branch. The packet file is committed at the close with the ledger.
- No `step: close` write: a ledger holding `## Close draft` sends a resume straight to the close. The in-session fallback writes the same draft, so resume behaves the same either way.
- `/flow:project` shares two gaps (`shaping.md` at `phase: slicing`; `slices.md` in full and `shaping.md` at `phase: reality`); only its reload table changes.

## Tasks

### T1 — The slice-runner agent · critical
- **What**: create `agents/slice-runner.md` in the shape of `agents/executor.md`. Frontmatter: `name: slice-runner`, the `description:` the other agents share, `tools: Agent, Read, Grep, Glob, Bash, Edit, Write, ToolSearch, SendMessage, TaskStop`, `model: opus`, `effort: medium`. Sections: § What comes in the instruction (the fields below); § What you do, only the runner's own moves: if `Agent` is not among your tools, or your first dispatch is denied or fails, return `NO_NESTING` at once; read the `Packet:` file and put it verbatim on top of every dispatch; read the `Skill:` sections and follow `#### The loop` and close moves 1–2 as written there, the ledger in the format of `Work reference:` § Agents › Ledger; an `Answer:` other than `none` is written as a `Ruling:` line before going on; a stop of the four kinds returns `STOP`; use `TaskStop` on a hung executor before dispatching a fresh one; Done items you can't run go in `Pending:`. § What you never do: touch `STATUS.md`, `slices.md` or `lessons.md`; commit; dispatch any agent but `flow:executor` and `flow:task-reviewer` (`Agent(type)` is ignored in a subagent, so the prompt says it); ask the user. § What you return: the format below.
- **Files**: `agents/slice-runner.md`
- **Verified**: `claude plugin validate .` passes with only the guideline's expected warnings; `rg -n 'NO_NESTING' agents/slice-runner.md` matches in § What you do and § What you return; `rg -n 'Close draft' agents/slice-runner.md` → no match (the tail lives in work.md).
- **Done**: a fresh subagent can run a slice from its instruction alone.
- **Interfaces**: produces, for T5 and T7. Instruction, one field per line, absolute paths: `Packet: <work dir>/V<n>-packet.md` · `Skill: <skills/dev/SKILL.md>, § step: execute › The loop and § step: close moves 1–2` · `Work reference: <shared/work.md> § Agents` · `Agents: <agents folder>` (`executor.md`; `plan-reviewer.md` for a promoted tier) · `Plan: <path>` · `Ledger: <path>` · `Work dir: <path>` · `Models: <request in session | top=<x>, mid=<y> | none>` · `Final review: run | skip` · `User at first stop: <text | none>` · `Answer: <answer to a previous STOP | none>`. Return, under 25 lines: `Status: DONE | STOP | NO_NESTING` · `Commits: <sha subject>, one per line` · `Gate: <result>` · `Final review: done | skipped` · `Rulings: <one per line | none>` · `Decision candidate: <gist | none>` · `Pending: <pending: <Done item>, one per line | none>` · `Question: <STOP only: the step, why it stops, the options>`.

### T2 — The planner returns a Summary and a Files line
- **What**: in `agents/planner.md`, § What you do step 2: the header also holds **Summary** (at most ten lines) and **Files** (the union of the tasks' Files); § What you return becomes `Plan: <path>`, `Summary:` (at most ten lines), `Files: <comma-separated paths>`, `Deviations:`.
- **Files**: `agents/planner.md`
- **Verified**: `rg -n '^Summary:|^Files:' agents/planner.md` matches in § What you return; `rg -n '\*\*Summary\*\*' agents/planner.md` matches in § What you do.
- **Interfaces**: produces the return fields `Summary:` and `Files:` and the header labels **Summary**, **Files** for T4b.

### T3 — shared/work.md § Agents
- **What**: roles table row `Slice runner | flow:slice-runner | top | A slice's execution and the close's drafts (/flow:dev)`; the Tiers paragraph names it. A **Nesting** paragraph: subagents nest three layers by default, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` turns it off ([nested subagents](https://code.claude.com/docs/en/sub-agents#let-subagents-spawn-their-own-subagents), [env vars](https://code.claude.com/docs/en/env-vars)); with fork mode on, the default, the runner runs in the background and Claude can't wait for it ([foreground or background](https://code.claude.com/docs/en/sub-agents#run-subagents-in-foreground-or-background), [fork mode](https://code.claude.com/docs/en/sub-agents#turn-fork-mode-on-or-off)); permission prompts of background and nested subagents surface in the main session ([background subagents](https://code.claude.com/docs/en/sub-agents#tools-permissions-and-results-of-background-subagents)); a subagent can resume another with `SendMessage` ([resume subagents](https://code.claude.com/docs/en/sub-agents#resume-subagents)), when deferred loaded through `ToolSearch`, and stop one with `TaskStop` ([tools reference](https://code.claude.com/docs/en/tools-reference)); when the runner can't dispatch, the conductor runs the loop in session. Ledger: "written by the slice runner (the conductor in the fallback)"; "the runner runs `printenv`"; new bullets for the tail, in this order at the end: `Final review: <done | skipped>`, `Gate: <result>`, then `## Close draft` with `Narrative: <text>`, `Lessons:` (one rule per line), `Decision candidate: <gist | none>`. The one-line-per-dispatch rule stays (V3).
- **Files**: `shared/work.md`
- **Verified**: `rg -n 'slice-runner|SPAWN_DEPTH|## Close draft' shared/work.md` matches in the table, Nesting and Ledger; `rg -n 'written by the conductor|the conductor runs .printenv' shared/work.md` → no match.
- **Interfaces**: produces § Agents › Ledger, the tail format T1 and T5 cite.

### T4a — dev SKILL: reload table by phase and step
- **What**: in `skills/dev/SKILL.md` § On start: "the current slice's plan" and "at `step: execute`, the slice's ledger" leave Always; a table **By phase and step**: design → `shaping.md`, `docs/design/README.md`; slicing → `shaping.md`, or `breadboard.md` when breadboarding slices; impact → `slices.md` in full; plan → `docs/impact-lenses.md` and the decisions matched by `files:`; review → the plan's header only; execute → `rg -n '^## Close draft' <ledger>`: a match goes to the close, no runner; else the runner, and in a new session the resume message also asks whether another session still runs the slice (never a second runner); close → the ledger's `## Close draft`. The Never column says "except" for `shaping.md` and `breadboard.md`; the explanation under the tables says why each row holds what the next step reads.
- **Files**: `skills/dev/SKILL.md`
- **Verified**: `rg -n 'By phase and step|another session still runs|\^## Close draft' skills/dev/SKILL.md` matches in § On start.

### T4b — dev SKILL: Summary and Files, tiers, lifecycle · depends on: T4a
- **What**: § step: plan: the instruction asks for **Summary** and **Files** in the plan's header; the return has `Summary:` and `Files:`; the conductor doesn't read the plan. § step: review: the decisions lookup uses `files:` from `Files:`; the first stop shows the Summary; approved fixes are applied reading only the plan lines the findings point to. Cost discipline rule 5 adds the slice runner to the top tier; the lifecycle row "A plan's execution" reads `flow:slice-runner`, dispatching `flow:executor` and `flow:task-reviewer`.
- **Files**: `skills/dev/SKILL.md`
- **Verified**: `rg -n 'Summary:|slice-runner' skills/dev/SKILL.md` matches in § step: plan, rule 5 and the lifecycle table.

### T5 — dev SKILL: execute through the runner, close from its draft · critical · depends on: T1, T3, T4b
- **What**: § step: execute, conductor moves in order: write `step: execute` and `updated:` in `STATUS.md` and commit it with the plan's fixes (`Start executing V<n>`); decide `Final review:` without reading the plan: `run` when `rg -c '^### T' <plan>` is above 4, or a path of the plan's `Files:` line appears in another slice's section of `slices.md`; write `<work dir>/V<n>-packet.md`, the packet verbatim; dispatch `flow:slice-runner` once with T1's instruction fields (top tier by § Agents); say one line, end the turn, touch nothing in the checkout or work folder until the notification. Returns, by T1's format: `DONE` → close; `STOP` → ask the user, dispatch again with `Answer:`; `NO_NESTING`, or the dispatch denied or failing → one line to the user, the conductor runs `#### The loop` itself; failed or interrupted → `TaskStop` the nested agents still running (or the user from `/tasks`), `git status --short`, dispatch again. The current opening paragraph (`git status --short`, the `printenv` line, complete tasks never re-dispatched, commits without `complete` reviewed, uncommitted leftovers to a fresh executor) becomes the first move of **#### The loop**, followed by the current bullets; the loop runs in the runner, or in session in the fallback; there the Stops bullet returns `STOP`. § step: close: moves 1–2 end in the ledger tail of the work reference § Agents › Ledger (the fallback writes it too); the conductor then runs `lsof -nP -iTCP -sTCP:LISTEN` and stops leftovers, runs each `pending:` item with the user, copies Narrative and Lessons from `## Close draft` into `slices.md` and `lessons.md`, then moves 3–4 with the ledger and the packet file in the commit.
- **Files**: `skills/dev/SKILL.md`
- **Verified**: `rg -n 'V<n>-packet.md|NO_NESTING|pending:|Close draft' skills/dev/SKILL.md` matches in § step: execute and § step: close; `awk '/^#### The loop/,/^### .step: close/' skills/dev/SKILL.md | rg -c printenv` → 1 or more; `awk '/^### .step: execute/,/^#### The loop/' skills/dev/SKILL.md | rg -c printenv` → 0.
- **Interfaces**: consumes T1's instruction and return, T3's ledger tail; produces `#### The loop` and close moves 1–2, which T1's `Skill:` field names.

### T6 — project SKILL: reload gaps
- **What**: `skills/project/SKILL.md` § On start, under the table: "At `phase: slicing` it also reloads `shaping.md`; at `phase: reality`, `slices.md` in full and `shaping.md`." The Never column says "except" for `shaping.md`.
- **Files**: `skills/project/SKILL.md`
- **Verified**: `rg -n 'phase: reality., .slices.md. in full' skills/project/SKILL.md` → 1 match.

### T7 — README and architecture · depends on: T3, T5
- **What**: `README.md`: lines 86–89 (slice loop: the runner in the background; tiers: runner top; ledger written by the runner; resume per phase and step); file tree (lines 133–134) adds `V1-packet.md`. `docs/architecture.md`: diagram node `exec` (line 97) names `flow:slice-runner`; line 131 resume per phase and step; line 133 slice loop; file table (line 187) adds `V1-packet.md`; agents node (line 214) adds `slice-runner`.
- **Files**: `README.md`, `docs/architecture.md`
- **Verified**: `rg -n 'V1-packet.md' README.md docs/architecture.md` → README tree, architecture file table; `rg -n 'phase and step' README.md docs/architecture.md` → README resume line, architecture line 131; `rg -n 'slice-runner' README.md docs/architecture.md` → README slice loop, tiers, ledger; architecture lines 97, 133, 214; the Gate's link check prints nothing.

## Order

T1, T2, T3, T4a, T6 in parallel (disjoint files). T4b after T4a. T5 after T1, T3, T4b. T7 after T3, T5.

## Done check at close (the conductor with the user; no executor, no commit)

Per run, a fixture in `$(mktemp -d)/demo`: `git init`, a README commit, branch `legacy`; on `work/demo`: `.flow.yml` (`stacks: [generic]`), `docs/development-guidelines.md` (`Level: none`; Gate `test -f notes/a.md && test -f notes/b.md && test -f notes/c.md`), `docs/work/2026-10-29-demo/STATUS.md` at `phase: slice`, `slice: V1`, `step: plan`, `slices.md` V1 "three files under `notes/`, one task each; T2 also runs `python3 -c 'print(1)' > notes/check.txt`", committed. First `rg -n 'python3' ~/.claude/settings.json .claude/settings*.json`: no allow rule may cover it. The user runs `claude --plugin-dir /Users/spleenteo/Sites/me/flow`, `/flow:dev`, resume, yes at the first stop. Run A: default settings. Run B: prefixed `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`. Run C: V1 adds "T3 also runs `git branch -D legacy`".

With `T` the newest `~/.claude/projects/<key>/*.jsonl` of the run. A: `grep -o '"subagent_type":"flow:[a-z-]*"' "$T" | sort | uniq -c` → one `slice-runner`, no `executor` or `task-reviewer`; `grep -E '"name":"(Write|Edit|Bash)"' "$T" | grep -c V1-ledger` → 0; `python3 -I -c 'import json,sys;s=set();[print(d["timestamp"][11:19],sum(d["message"]["usage"].get(k,0) for k in("input_tokens","cache_read_input_tokens","cache_creation_input_tokens"))) or s.add(d["message"]["id"]) for d in map(json.loads,open(sys.argv[1])) if d.get("type")=="assistant" and d["message"].get("id") not in s]' "$T"` → context at the second stop minus context at the yes < 10k; `rg -n '^## Close draft' docs/work/2026-10-29-demo/V1-ledger.md` matches and `git log` shows the slice committed; the `python3` prompt reached the user. B: the one-line fallback message and `flow:executor` dispatches in `$T`. C: the runner returns `STOP` on the deletion; after the answer the ledger has the `Ruling:` line and the slice is committed. Results go in the V1 narrative.

## Deviations from the mandate

- The conductor reads the plan lines review findings point to, to apply the fixes in place: "doesn't read the plan" holds for the plan in full.
- The Done's work starts from a hand-made fixture at `step: plan`, not from an opening: the Done measures from the first stop's yes.
- A runner left over from another session can't be seen from a new one: the resume message asks the user instead.
