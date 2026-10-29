---
work: lean-conductor
slice: V1
tests: none
updated: 2026-10-29
---

# V1 plan — The slice runs in a subagent

**Mandate**: [slices.md § V1](slices.md) · [decision](../../decisions-log/2026-10-29-slice-execution-runs-in-a-runner-subagent.md) · **Guidelines**: [Tests, Naming, Language, Commits, Gate](../../development-guidelines.md) · **Lessons**: none yet · **Execution rules**: [executor.md](../../../agents/executor.md)

**Summary**
1. New agent `agents/slice-runner.md` (top tier): runs execute and the close's drafts, returns `DONE | STOP | NO_NESTING`.
2. `skills/dev/SKILL.md`: the conductor writes a packet file, dispatches the runner once, waits for its notification; fallback runs the loop in session.
3. The reload table becomes per phase and step and closes the four known gaps; `/flow:project` gets the same fix (it shares two).
4. The planner returns and writes a ten-line summary and a `Files:` line; the conductor never reads the plan in full.
5. `shared/work.md` § Agents, `README.md`, `docs/architecture.md` describe the runner, nesting, fork mode and the fallback.
6. T8, run by the conductor with the user: three throwaway runs (runner, depth 1, planted irreversible step).

**Files**: agents/slice-runner.md, agents/planner.md, shared/work.md, skills/dev/SKILL.md, skills/project/SKILL.md, README.md, docs/architecture.md

## The slice, decided here

- **Runner tier: top**, `model: opus`, `effort: medium`: it rules on blocked tasks and findings (needs the top model); most of its turns are mechanical dispatches, and high effort would multiply thinking on each.
- **Runner tools**: `Agent, Read, Grep, Glob, Bash, Edit, Write, ToolSearch, SendMessage, TaskStop`. All survive the background filter ([available tools](https://code.claude.com/docs/en/sub-agents#available-tools)); no `Skill`, no `AskUserQuestion` (removed from subagents anyway). Allowed dispatches (`flow:executor`, `flow:task-reviewer`) are stated in the prompt: `Agent(type)` is ignored in a subagent ([restrict which subagents](https://code.claude.com/docs/en/sub-agents#restrict-which-subagents-can-be-spawned)).
- **Runner instruction fields** (one per line, absolute paths): `Packet:` `<work dir>/V<n>-packet.md`; `Skill:` SKILL.md, sections `step: execute` § The loop and `step: close` moves 1–2; `Work reference:` shared/work.md § Agents; `Agents:` the agents folder; `Plan:`; `Ledger:`; `Work dir:`; `Models:` the user's request in session, top and mid preferences, or `none`; `Final review: run | skip`; `User at first stop:`; `Answer:` the user's answer to a previous STOP, or `none`.
- **Runner return** (under 25 lines): `Status: DONE | STOP | NO_NESTING`, `Commits:`, `Gate:`, `Final review: done | skipped`, `Rulings:`, `Decision candidate:`, `Pending:` (`pending: <Done item>` each), `Question:` (STOP only: the step, why, the options).
- **Ledger tail** written by the runner: `Final review: <done | skipped>`, `Gate: <result>`, then `## Close draft` with `Narrative:`, `Lessons:` (one rule per line), `Decision candidate:`.
- **No second runner**: in the same session the conductor knows its pending dispatch; a resume in a new session asks, in its one resume message, whether another session still runs the slice.
- **Close without a `step: close` write**: a resume at `step: execute` whose ledger holds `## Close draft` goes straight to the close, no runner; `step: close` still reads the draft.
- **The packet file** `V<n>-packet.md` is committed at the close with the ledger; `docs/architecture.md`'s file table names it.
- **Applying review fixes**: the conductor reads only the plan lines the findings point to (`Read` with offset), never the whole plan.
- **`/flow:project` shares two gaps**: `shaping.md` at `phase: slicing`; `slices.md` in full and `shaping.md` at `phase: reality`. Only its reload table changes.

## Tasks

### T1 — The slice-runner agent · critical
- **What**: create `agents/slice-runner.md` in the shape of `agents/executor.md`: frontmatter (`name: slice-runner`, the shared `description:`, tools, model, effort as decided), then § What comes in the instruction (the fields above), § What you do (check `Agent` is in your tools, else return `NO_NESTING` at once, as on a denied or failing first dispatch; read the packet file and the SKILL sections; open or resume the ledger as § The loop says; run the loop, packet verbatim on top of every dispatch; write an `Answer:` as a `Ruling:` line before going on; a stop of the four kinds returns `STOP`; run close moves 1–2 as drafts: gate, the Done items you can run, servers stopped, ledger tail), § What you never do (touch `STATUS.md`, `slices.md`, `lessons.md`; commit; dispatch any agent but the two named; ask the user), § What you return (the format above).
- **Files**: `agents/slice-runner.md`
- **Verified**: `claude plugin validate .` passes with only the guideline's expected warnings; `rg -n 'NO_NESTING|## Close draft|flow:task-reviewer' agents/slice-runner.md` matches in § What you do and § What you return.
- **Done**: an agent file a fresh subagent can follow with nothing but its instruction.
- **Interfaces**: produces the instruction fields, the return format and the ledger tail for T3, T5, T7.

### T2 — The planner returns a summary and a Files line
- **What**: in `agents/planner.md` § What you do step 2, the header also holds **Summary** (at most ten lines) and **Files** (the union of the tasks' Files); § What you return becomes `Plan:`, `Summary:`, `Files:`, `Deviations:`.
- **Files**: `agents/planner.md`
- **Verified**: `rg -n 'Summary|Files:' agents/planner.md` matches in both sections.
- **Done**: a resume at `step: review` finds both in the plan's header.

### T3 — shared/work.md § Agents
- **What**: roles table row `Slice runner | flow:slice-runner | top | A slice's execution and the close's drafts (/flow:dev)`; Tiers paragraph names it; a **Nesting** paragraph: subagents nest three layers by default and `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` turns it off ([nested subagents](https://code.claude.com/docs/en/sub-agents#let-subagents-spawn-their-own-subagents), [env vars](https://code.claude.com/docs/en/env-vars)); with fork mode on the runner runs in the background and Claude can't wait ([foreground or background](https://code.claude.com/docs/en/sub-agents#run-subagents-in-foreground-or-background), [fork mode](https://code.claude.com/docs/en/sub-agents#turn-fork-mode-on-or-off)); nested permission prompts surface in the main session; a subagent sends `SendMessage` ([resume subagents](https://code.claude.com/docs/en/sub-agents#resume-subagents)) after loading it through `ToolSearch` ([tools reference](https://code.claude.com/docs/en/tools-reference)); the fallback. Ledger bullets: written by the runner (the conductor in the fallback), the runner runs `printenv`, plus the tail lines and `## Close draft`. The two-writes rule stays (V3).
- **Files**: `shared/work.md`
- **Verified**: `rg -n 'slice-runner|SPAWN_DEPTH|Close draft' shared/work.md` matches in the table, Nesting and Ledger; `rg -n 'written by the conductor|the conductor runs .printenv' shared/work.md` → no match.
- **Done**: § Agents states every runner fact with its docs link.

### T4 — dev SKILL: reload table, plan, review, tiers, lifecycle
- **What**: in `skills/dev/SKILL.md`: § On start, the "current slice's plan" leaves Always; a second table **By phase and step** (design: `shaping.md`, `docs/design/README.md`; slicing: `shaping.md`, or `breadboard.md` when breadboarding slices; impact: `slices.md` in full; plan: `docs/impact-lenses.md` and the decisions matched by `files:`; review: the plan's header; execute: the ledger, then the runner, or the close when it holds `## Close draft`; close: the ledger's `## Close draft`); Never column and the explanation under it updated. § step: plan: the instruction asks for Summary and Files in the header, the return has them, the conductor doesn't read the plan. § step: review: the `files:` lookup uses `Files:`; the first stop uses the Summary; fixes read only the lines the findings point to. Cost discipline rule 5 and the lifecycle table add `flow:slice-runner`.
- **Files**: `skills/dev/SKILL.md`
- **Verified**: `rg -n 'By phase and step|Close draft|slice-runner' skills/dev/SKILL.md` matches in § On start, rule 5 and the lifecycle table; `claude plugin validate .` passes.
- **Done**: each `phase:`/`step:` row names what the next step reads.

### T5 — dev SKILL: execute through the runner, close from its draft · critical · depends on: T1, T4
- **What**: § step: execute opens with **Dispatch the runner**: write `V<n>-packet.md` (the packet verbatim), dispatch `flow:slice-runner` once with T1's fields (top tier by § Agents), say one line, end the turn, touch nothing in the checkout or work folder until the notification; no second runner. Then the returns: `DONE` → after-return; `STOP` → ask the user, dispatch again with `Answer:`; `NO_NESTING` or a denied or failing first dispatch → one line, the conductor runs § The loop itself; failed or interrupted → `TaskStop` the nested agents still running (or the user from `/tasks`), `git status --short`, dispatch again. The current bullets become **#### The loop**, run by the runner (by the conductor in the fallback), the Stops bullet returning `STOP` in the runner. § step: close: moves 1–2 are the runner's drafts; the conductor runs `lsof -nP -iTCP -sTCP:LISTEN` and stops leftovers, runs the `pending:` items with the user, copies narrative and lessons from `## Close draft`, then moves 3–4 with the packet file and the ledger in the commit. Fallback: moves 1–2 in session, as today.
- **Files**: `skills/dev/SKILL.md`
- **Verified**: `rg -n 'V<n>-packet.md|NO_NESTING|#### The loop|lsof -nP' skills/dev/SKILL.md` matches in § step: execute and § step: close; `claude plugin validate .` passes.
- **Done**: a read-through matches T1's fields, statuses and ledger tail word for word.
- **Interfaces**: consumes T1's contract; produces section names `#### The loop` and close moves 1–2 that T1's instruction points to.

### T6 — project SKILL: reload gaps
- **What**: `skills/project/SKILL.md` § On start: after the table, one line per gap: `phase: slicing` reloads `shaping.md`; `phase: reality` reloads `slices.md` in full and `shaping.md`; the Never column says "except".
- **Files**: `skills/project/SKILL.md`
- **Verified**: `rg -n 'phase: reality' skills/project/SKILL.md` matches in § On start.
- **Done**: no other section of the file changes (`git show --stat` lists one file).

### T7 — README and architecture · depends on: T3, T5
- **What**: `README.md` lines 86–89 (slice loop: runner in the background; tiers: runner top; ledger written by the runner; resume per phase and step). `docs/architecture.md`: diagram node `exec` (line 97) names `flow:slice-runner`; line 131 resume; line 133 slice loop; file table (line 187) adds `V1-packet.md`; agents node (line 214) adds `slice-runner`.
- **Files**: `README.md`, `docs/architecture.md`
- **Verified**: `rg -n 'slice-runner' README.md docs/architecture.md` matches at each named place; the Gate's link check prints nothing for both files.
- **Done**: no description of the loop left that puts executors in the main session.

### T8 — The Done in throwaway repos (conductor with the user, no executor, no commit) · depends on: T1–T7
- **What**: per run, a fixture in `$(mktemp -d)/demo`: `git init`, a README commit, branch `legacy`; on `work/demo`: `.flow.yml` (`stacks: [generic]`), `docs/development-guidelines.md` (`Level: none`; Gate `test -f notes/a.md && test -f notes/b.md && test -f notes/c.md`), `docs/work/2026-10-29-demo/STATUS.md` at `phase: slice`, `slice: V1`, `step: plan`, `slices.md` V1 "three files under `notes/`, one task each", committed. The user runs `claude --plugin-dir /Users/spleenteo/Sites/me/flow`, `/flow:dev`, resume, yes at the first stop. Run A: default settings. Run B: prefixed `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`. Run C: V1 adds "T3 also runs `git branch -D legacy`".
- **Verified**, with `T` the newest `~/.claude/projects/<key>/*.jsonl` of the run: A: `grep -o '"subagent_type":"flow:[a-z-]*"' "$T" | sort | uniq -c` → one `slice-runner`, no `executor` or `task-reviewer`; `grep '"name":"\(Write\|Edit\)"' "$T" | grep -c V1-ledger` → 0; `python3 -I -c 'import json,sys;s=set();[print(d["timestamp"][11:19],sum(d["message"]["usage"].get(k,0) for k in("input_tokens","cache_read_input_tokens","cache_creation_input_tokens"))) or s.add(d["message"]["id"]) for d in map(json.loads,open(sys.argv[1])) if d.get("type")=="assistant" and d["message"].get("id") not in s]' "$T"` → context at the second stop minus context at the yes < 10k; ledger holds `## Close draft`, `git log` shows the slice committed; an executor's Bash prompt reached the user. B: the one-line fallback message and `flow:executor` dispatches in `$T`. C: the runner returns `STOP` on the deletion; after the answer the ledger has the `Ruling:` line and the slice is committed.
- **Done**: the six Done bullets of slices.md § V1 checked; results go in the V1 narrative.

## Order

T1, T2, T3, T4, T6 in parallel (disjoint files). Then T5 (after T1, T4). Then T7 (after T3, T5). T8 at the close, after the gate.

## Deviations from the mandate

- The conductor reads the plan lines review findings point to, to apply the fixes in place: "doesn't read the plan" holds for the plan in full.
- The Done's work starts from a hand-made fixture at `step: plan`, not from an opening: the Done measures from the first stop's yes, and an opening adds nothing to it.
- A runner left over from another session can't be seen from a new one: the resume message asks the user instead.
