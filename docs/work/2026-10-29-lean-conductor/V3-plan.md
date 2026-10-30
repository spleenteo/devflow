---
work: lean-conductor
slice: V3
tests: none
updated: 2026-10-30
---

# V3 plan — Bookkeeping in fewer writes

**Mandate**: [slices.md § V3](slices.md) · decision: [slice runner](../../decisions-log/2026-10-29-slice-execution-runs-in-a-runner-subagent.md) · **Guidelines**: [Tests, Naming, Language, Commits, Gate](../../development-guidelines.md) · **Lessons**: [lessons.md](lessons.md) · **Execution rules**: [executor.md](../../../agents/executor.md)

**Summary**
1. `shared/work.md` § Agents › Ledger: the head in one write, two writes per task, rulings at once, the tail in one write; same line shapes, so old ledgers resume as before. § Closing a slice: `STATUS.md`, `slices.md`, `lessons.md` and the commit in one chained call.
2. `skills/dev/SKILL.md`: plan fixes in one call; the loop's writes and resume rule (fix commits included); close moves 3–4 in one call; Step 5 updates `STATUS.md` and commits in one call.
3. `agents/slice-runner.md` follows the ledger's writes; `skills/project/SKILL.md` gets the same close order.
4. `README.md:88` and `docs/architecture.md:132–133` say so; `measure/bash_kinds.py` counts bookkeeping calls (`Bash`, `Edit`, `Write` writing under `docs/work/`, git first).

**Files**: shared/work.md, skills/dev/SKILL.md, agents/slice-runner.md, skills/project/SKILL.md, README.md, docs/architecture.md, docs/work/2026-10-29-lean-conductor/measure/bash_kinds.py

## The slice, decided here

- The ledger's line shapes don't change (`- <task> · <agent> · <model> · <outcome> · <commits>`, `- T<n>: complete`, `Ruling:`). Only when they are written does, so old one-line-per-dispatch ledgers resume under the same rule, with no format detection.
- Write 1 of a task happens at the first executor return that carries commits: that line and its report, plus any earlier returns of the task, which are held until then. Write 2 holds every later line (reviews, fix dispatches and their reports) and `- T<n>: complete`, when the task passes. A task reopened after `complete` gets one more write when it passes again.
- Rulings are written at once, each as its own write: a split (T4a/T4b), a ruling on findings, and the answer to a `STOP`. A resume must not take a decision again. Before a `STOP` returns, the runner writes the lines it holds in one write.
- The trade-off: a task resumed between its two writes is reviewed from round 1. Review verdicts and low findings not yet written are lost.
- Because review and fix lines wait for write 2, a resume can find fix commits the ledger doesn't list. The resume rule also reviews the commits after the task's ledger commits whose subject is `Fix review findings on T<n>:`. The fix instruction names that subject (V2 lesson).
- The tail is one write: the final review and its fix round, `pending:`, `Final review:`, `Gate:`, `## Close draft`. In the Done count it is the second stop's write.
- Plan fixes go in in one call: one `Edit` when they sit in one passage, else one Bash call that applies every replacement and writes nothing unless each one matches exactly once. This is an inline call, not a helper script (Out).
- A one-call close chains its steps with `&&` (or runs under `set -e`), so it commits only when every write succeeded. Recovery: `git status --short` and `git diff --stat` on the three files, then finish the missing writes, then commit.
- In `bash_kinds.py`, git is classified first, as the mandate says, so the conductor's one-call close counts as git. The Done counts bookkeeping on the runner's transcript, which never commits. The conductor's close is checked by its own grep.

## Tasks

### T1 — shared/work.md: ledger writes and slice-close bookkeeping · critical
- **What**: in § Agents › **Ledger** (line 204 on):
  - Bullet 1 becomes "The head, in one write: first line `# Ledger — V<n>`, second line the result of `printenv CLAUDE_CODE_SUBAGENT_MODEL_FORCE CLAUDE_CODE_SUBAGENT_MODEL`, run once at the start of execute."
  - Bullet 2 ("One line per dispatch, written once…") becomes "Two writes per task. At the first executor return that carries commits: its line `- <task> · <agent> · <model> · <outcome> · <commits>` and its report, with any earlier return of the task held until then. When the task passes: every later line of the task in order (each review, each fix dispatch with its report), then `- T<n>: complete`. A task reopened after `complete` gets one more write when it passes again. Before a `STOP` returns, the lines held so far go in one write." Keep the model sentence.
  - Bullet 3: "`Ruling: <what> — <why> — <cost if wrong>`, written at once as its own write: a ruling on findings, a split (`T4a`/`T4b`), and the user's answer to a `STOP`, written when the runner is dispatched again."
  - Resume bullet, added: "A task with commits and no `complete` is reviewed again: its commits in the ledger, plus the later commits whose subject is `Fix review findings on T<n>:`. A task resumed between its two writes is reviewed from round 1, and review verdicts and low findings not yet written are lost. Ledgers written one line per dispatch have the same lines and resume the same way."
  - Tail bullet: "At the end, in one write and in this order: the final review's lines and its fix round; any `pending: <Done item>` lines…" (the rest stays).
- In § `slices.md` and `lessons.md`, **Closing a slice, the bookkeeping**, after "add the Log line." add: "These edits, the narrative into `slices.md`, the rules into `lessons.md` and the commit go in one call, chained with `&&` so it commits only when every write succeeded (project: the commit only when the home is under version control). If the call stops before the commit: `git status --short` and `git diff --stat` on the three files, then finish the missing writes, then commit."
- **Commits** (repo): "commit at each phase close and slice close, `STATUS.md` updated first and in the same commit, with explicit `git add <paths>`…".
- **Files**: `shared/work.md`
- **Verified**: `rg -n 'Two writes per task|The head, in one write|in one write and in this order|Fix review findings on T<n>:' shared/work.md` → 4 lines, all in § Agents; `rg -n 'answer to a `STOP`|reviewed from round 1' shared/work.md` → 2 matches in § Agents; `rg -n 'One line per dispatch' shared/work.md` → no match; `rg -n 'go in one call|updated first' shared/work.md` → 2 matches in § `slices.md` and `lessons.md`.
- **Interfaces**: produces § Agents › Ledger's writes (head, two per task, rulings at once, tail), the resume rule and the chained one-call close. T2, T3 and T4 cite them as "§ Agents › Ledger" and "§ `slices.md` and `lessons.md`".

### T2 — dev SKILL: plan fixes, loop, close, Step 5 · critical
- **What**: in `skills/dev/SKILL.md`:
  1. Line 300 becomes: "Approved fixes go into the plan in place, in one call, reading only the plan lines the findings point to: one `Edit` when they fall in one passage, else one Bash call that applies every replacement and writes nothing unless each matches exactly once; never one call per finding."
  2. `#### The loop` (line 320): "keep the ledger … in the format and writes of § Agents › Ledger (the head in one write, two writes per task, rulings at once, the tail in one write): run the `printenv` line and write the head now, unless the ledger already has it." "Commits in the ledger without `complete` → review those commits" gains: "and the task's fix commits after them (`git log --format='%h %s' <the task's first sha>..HEAD`, subjects `Fix review findings on T<n>:`), in ledgers of either format".
  3. **Status**: the split's `Ruling:` line is "written at once". **Findings**: "The fix instruction names the commit subject `Fix review findings on T<n>: <what>`."; "a ruling and on" gets "(written at once)"; "Then `- T<n>: complete`, in the task's second write (a reopened task: one more write when it passes again)." **Stops**: "in the runner, it writes the ledger lines it holds in one write and returns `STOP` with the question".
  4. § step: close: "Then the conductor, before move 3:" keeps `lsof` and the `pending:` items and drops the copying. Move 3 becomes: "In one call, chained with `&&`: `Narrative:` into `slices.md` under the slice, as **"V<n> — done on <date>"**; `Lessons:` into `lessons.md`; `STATUS.md` as the work reference says (§ `slices.md` and `lessons.md`, closing a slice), with wall-clock and cost in the Log line; `git add` of the three, the ledger and the packet file; the commit. If the call stops before the commit: `git status --short` and `git diff --stat` on the three files, then finish the missing writes, then commit." Move 4 is the **Second stop** paragraph, without "Commit, the ledger and the packet file with it."
  5. Step 5: moves 2 and 3 swap. Move 2: "**Update `STATUS.md`**: …" (text unchanged). Move 3: "**Commit** the document just produced with `STATUS.md`; moves 2 and 3 are one call, chained with `&&`. Explicit `git add` …". The design sentence loses "runs move 3 first and".
- **Files**: `skills/dev/SKILL.md`
- **Verified**: `rg -n 'never one call per finding|two writes per task|Fix review findings on T<n>|lines it holds|written at once' skills/dev/SKILL.md` → lines 300 and 320, Status, Findings, Stops; `rg -n 'runs move 3 first|copies `Narrative:`|^4\. Commit, the ledger' skills/dev/SKILL.md` → no match; `rg -n '^2\. \*\*Update `STATUS|^3\. \*\*Commit\*\* the document' skills/dev/SKILL.md` → 2 matches, Update first; `rg -n 'moves 2 and 3 are one call' skills/dev/SKILL.md` → 1; `claude plugin validate .` passes with the guideline's expected warnings only.

### T3 — slice-runner: the ledger's writes
- **What**: in `agents/slice-runner.md` § What you do. Item 3: "write the ledger in its format" becomes "write the ledger in its format and writes: the head in one write, two writes per task, rulings at once, the tail in one write". Item 4: "…as a `Ruling:` line, in its own write, before going on". Item 5: "…returns `STOP`, after writing the ledger lines it holds in one write."
- **Files**: `agents/slice-runner.md`
- **Verified**: `rg -n 'two writes per task|lines it holds|in its own write, before going on' agents/slice-runner.md` → 3 matches; `claude plugin validate .` passes.

### T4 — project SKILL: the same close order
- **What**: `skills/project/SKILL.md` § step: close, move 3 gains: "Moves 2 and 3 are one call: the narrative, the rules and `STATUS.md`, with the commit (the design files of the slice's `/flow:design` rows in it) when the home is under version control, chained with `&&`." Step 5, move 2: "**Update `STATUS.md`**: `phase:`, `updated:`, Log line; when the home is under version control, commit it with the document just produced, in one call (explicit `git add`)."
- **Files**: `skills/project/SKILL.md`
- **Verified**: `rg -n '\bone call\b' skills/project/SKILL.md` → 2 matches, in § step: close and Step 5 move 2; `claude plugin validate .` passes.

### T5 — README and architecture
- **What**: `README.md:88` becomes "**The ledger.** During execution `docs/work/<dir>/V<n>-ledger.md` is written by `flow:slice-runner`, two writes per task (when the executor first returns commits, when the task passes), and records every dispatch (task, agent, model, outcome, commits) and which tasks are complete. A resumed work doesn't dispatch a complete task again. A phase or a slice closes with `STATUS.md`, its documents and the commit in one call." `docs/architecture.md:132`: "fidelity check against the frame's criterion, commit, `STATUS.md`, decision candidate, stop" becomes "fidelity check against the frame's criterion, `STATUS.md` and the commit in one call, decision candidate, stop". `docs/architecture.md:133`: "recorded in the ledger the runner writes" becomes "…, two writes per task"; "copies the draft and commits" becomes "copies the draft, updates `STATUS.md` and commits in one call".
- **Files**: `README.md`, `docs/architecture.md`
- **Verified**: `rg -n 'two writes per task' README.md docs/architecture.md` → README:88 and architecture:133; `rg -n 'commit, `STATUS.md`, decision' docs/architecture.md` → no match; the Gate's link check prints nothing.

### T6 — bash_kinds.py counts bookkeeping calls
- **What**: in `docs/work/2026-10-29-lean-conductor/measure/bash_kinds.py`, map `tool_use` ids for `Bash`, `Edit` and `Write`.
  - `Edit`/`Write` whose `input.file_path` contains `docs/work/` → `bookkeeping (writes under docs/work)`; any other `Edit`/`Write` → `edits elsewhere`.
  - A `Bash` command is a work write when it holds one of: a redirection `>`/`>>` to a path holding `docs/work/` (not `2>`/`&>`); `tee` with such a path; `sed -i`/`perl -i` naming one; `.write(`/`write_text(` with `docs/work/` in the command.
  - Order for `Bash`: `\bgit\b` → git; then a work write → bookkeeping; then `plugins/cache` → plugin reads; then `docs/work`/`STATUS.md` → `work reads`; then pencil, build/test and other, as today.
  - The output keeps one line per kind and ends with `bookkeeping calls: <n>`. A comment on top gives the usage: `python3 -I bash_kinds.py <transcript.jsonl>`.
- **Files**: `docs/work/2026-10-29-lean-conductor/measure/bash_kinds.py`
- **Verified**: write a fixture `F=$(mktemp -d)/t.jsonl`. It holds one assistant line per call, `{"type":"assistant","message":{"content":[{"type":"tool_use","id":"aN","name":…,"input":…}]}}`, each followed by its user line, `{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"aN","content":"ok"}]}}`. The calls: a1 Bash `cat >> /x/docs/work/d/V1-ledger.md <<'EOF'\n- T1\nEOF`; a2 Edit `file_path: /x/docs/work/d/V1-ledger.md`; a3 Write `file_path: /x/src/app.js`; a4 Bash `git -C /x add docs/work/d/STATUS.md && git -C /x commit -m Close`; a5 Bash `sed -n 1,30p /x/docs/work/d/V1-plan.md 2>/dev/null`; a6 Bash `printf 'x\n' >> /x/docs/work/d/STATUS.md && git -C /x add docs/work/d/STATUS.md && git -C /x commit -m Close`; a7 Bash, the link-check command copied verbatim from `docs/development-guidelines.md` § Gate.

  Then `python3 -I docs/work/2026-10-29-lean-conductor/measure/bash_kinds.py "$F"` → bookkeeping 2, git 2, work reads 2 (a5, a7), edits elsewhere 1, last line `bookkeeping calls: 2`.

## Order

T1–T6 in parallel (disjoint files). The wording each task cites from T1 is fixed above. With six tasks, the final review runs.

## Done check at close (the conductor with the user)

The fixture is set up as in V1's Done, in `$(mktemp -d)/demo`, and committed: `.flow.yml`, guidelines at `Level: none` with the three-file Gate, and `docs/work/2026-10-29-demo/` at `phase: slice`, `slice: V1`, `step: plan`, with V1 being "three files under `notes/`, one task each". The user runs `claude --plugin-dir /Users/spleenteo/Sites/me/flow --permission-mode default`, then `/flow:dev`, and resumes. At the first stop the user asks for two fixes in different passages of the plan, then says yes. `T` is the newest `~/.claude/projects/<key>/*.jsonl`. `R` is the `agent-*.jsonl` beside the `.meta.json` holding `"agentType":"flow:slice-runner"`, found with `find "${T%.jsonl}" -name '*.meta.json'`. The narrative records where the nested executors' transcripts landed: under the runner's folder, or flat in `subagents/`.
- **Runner bookkeeping.** `python3 -I <repo>/docs/work/2026-10-29-lean-conductor/measure/bash_kinds.py "$R"` → `bookkeeping calls:` at most 8 plus the allowances below. The 8 are 2 per task × 3, 1 to open the ledger and 1 for the tail at the second stop. The allowances: 1 per `Ruling:` line in the ledger (`rg -c '^Ruling:'`), 1 per reopened task, and 2 per `STOP`. The ledger ends in `## Close draft`, and `git cat-file -t` on each ledger sha returns `commit`.
- **Plan fixes.** Between the yes and the runner dispatch, `T` holds exactly one `Bash` call that writes `V1-plan.md`, and no `Edit` on it.
- **Conductor's close.** `T` holds one `Bash` call that writes `slices.md`, `lessons.md` and `STATUS.md`, chained with `&&` up to `git commit`. Record which construct raised an approval prompt, if any: the heredoc, the redirection, `sed -i`, or the chain. Choose the split from it. When the heredoc is the cause, the files are written without one (`Edit`/`Write`, or a quoted script), then committed in a second call. The split goes into T1, T2 and T4's lines in a fix commit before the close commit, and the narrative names it.
- **Old ledger, two fixtures,** each the same repo at `step: execute` with `V1-plan.md`, `V1-packet.md`, and T1's commits `<sha1>` and `<sha2>` = `Fix review findings on T1: x`.
  - Old format: `- T1 · flow:executor · definition: sonnet · DONE · <sha1>`, `- T1 review · flow:task-reviewer · definition: sonnet · fail`, `- T1 fix 1 · flow:executor · definition: sonnet · DONE · <sha2>`, no `complete`.
  - New format: only T1's executor line with `<sha1>`. `<sha2>` is committed but not listed.
  - In both, after the resume, some `flow:task-reviewer` dispatch in the new `R` names T1 and holds both shas, and no `flow:executor` dispatch names T1.

## Deviations from the mandate

- The resume rule also reviews the fix commits after a task's ledger commits, found by their subject. With review lines waiting for write 2, the ledger can miss them.
- Rulings are written at once, each as its own write, not in the task's second write. A ruling is a decision that a resume must not take again. This adds one write per ruling to the count.
- `docs/architecture.md:132` (the Step 5 order) changes too, beside line 133.
