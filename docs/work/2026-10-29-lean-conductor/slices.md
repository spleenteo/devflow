---
shaping: true
---

# Lean conductor — Slices

Technical work: no frame, no shaping. The mandate is [STATUS.md](STATUS.md) and the numbers are in [baseline.md](baseline.md): the main session averaged 167k of context over 270 calls, and grew by about 55k per slice until auto-compact fired at 296k.

The growth is diffuse. The part the conductor controls: the slice packet pasted into every dispatch (68k chars of `Agent` inputs), the agents' reports (105k chars), plans read and edited in session (44k chars), screenshots (9 reads), bookkeeping calls. Most of it happens while a slice executes. The rest is the work itself (reading code, the design tool, git) and stays.

Not in this work:
- the 48k at the first call (the user's installed plugins; Flow's share is covered by the decision of 2026-10-26 on stack presets);
- the conductor's reads of `shared/work.md` and `SKILL.md` (84k chars in the baseline): they happen mostly at opening and close, outside the runner; a candidate for a later work;
- a restart with `/clear` at every slice close: discarded, see the decision of 2026-10-29 on the slice runner;
- keeping `measure/` readable after the archive: the scripts are walled with the work folder; whoever runs the next comparison copies them out first.

## V1 — The slice runs in a subagent

Decision: [2026-10-29-slice-execution-runs-in-a-runner-subagent](../../decisions-log/2026-10-29-slice-execution-runs-in-a-runner-subagent.md). It supersedes the decision that kept the loop in the main session on a false premise.

**In.**
- A new agent, `flow:slice-runner`, dispatched in the foreground once per slice after the first stop's yes. It runs `step: execute` as `skills/dev/SKILL.md` describes it today (order, dispatches, statuses, reviews, fix rounds, rulings, the ledger, the final review) and the close's moves 1 and 2 (gate, servers, the slice narrative and the `lessons.md` lines drafted from the ledger). It returns one short summary: status, the slice's commits, the gate result, the rulings, the drafted lessons, a decision candidate if any.
- The main session keeps the stops, `STATUS.md`, the commits of the close and the questions to the user. It never sees an executor's or a task reviewer's report.
- Exceptional stops (an irreversible step, a security matter, a side effect outside the checkout, a plan broken beyond guessing) return from the runner as a status with the question; after the user's answer the conductor dispatches the runner again, which resumes from the ledger.
- The fallback: when the runner can't dispatch (nesting off with `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`, or `Agent` missing from its tools), it returns at once with a status that says so, and the conductor runs the loop in the main session as today. Said to the user in one line.
- The model rules of `shared/work.md` § Agents travel to the runner: a model the user asked for in this session and the tier preferences are passed in its instruction, since the runner can't see the conversation.
- The planner returns, with the plan's path and its deviation lines, the plan in at most ten lines for the first stop and a `Files:` line (the union of the tasks' files) for the review's decision lookup. The conductor doesn't read the plan.
- The resume reload table (`skills/dev/SKILL.md` § On start), per `phase:` and `step:`, holds what the next step reads, both columns and the explanation under them. Known gaps: `shaping.md` (or `breadboard.md`) at `phase: slicing`, `slices.md` in full at `phase: impact`, `docs/impact-lenses.md` and the decisions matched by `files:` for the packet at `step: plan`. A resume at `step: execute` dispatches the runner.
- `shared/work.md` § Agents: the runner in the roles table and the Tiers paragraph, nesting and the fallback, and the facts it relies on linked to code.claude.com (nested subagents and their depth; permission prompts of nested and background subagents).
- `/flow:project` has no agent-run execute loop: unchanged except its reload table, if it shares the gaps; the plan says.
- `README.md` and `docs/architecture.md` say what changed.

**Out.**
- Asking the user to run `/clear` or `/compact`.
- Moving the plan, the plan review or impact into the runner: the user reads their output at the stops.
- Changing what executors and task reviewers do, or the ledger's format (V3).
- Shortening what the user reads at the stops.

**Done.** In a throwaway repo loaded with the edited plugin, a work with a slice of three tasks runs from the first stop's yes to the second stop:
- the main session's transcript holds one `Agent` call to `flow:slice-runner` for the slice and no executor or task-reviewer dispatch, report or ledger write;
- the main session's context grows by less than 10k between the first and the second stop;
- the ledger is complete and the slice is committed;
- the same run with `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` falls back to the loop in the main session and says so;
- a planted irreversible step returns from the runner as a stop, and the runner dispatched again after the answer finishes the slice.

**Gotchas.**
- Fix rounds continue the same executor with `SendMessage`; check it is available to a subagent, else the runner uses the existing fallback (a fresh executor with the findings).
- The runner's own context grows through the slice: a long slice could compact inside it. The ledger is what lets it resume, so it stays on disk.
- Permission prompts of the executors surface in the main session through the runner: check they still reach the user in the foreground.
- The runner is a judgement role (it rules on blocked tasks and findings): its tier is decided in the plan.

## V2 — Screenshots checked out of the main session

**In.**
- In `/flow:design`, a rule for the conductor's own check of a drawn screen: export the screen as PNG to a `mktemp -d` folder outside the repo, never committed; dispatch a checker with the image path and what to check (layout, overlaps, text that doesn't fit, the screen against the requirement it draws); it returns a verdict in a few lines. The main session never receives an image, by `Read` or by any tool result.
- The two rules it contradicts are amended with an exception for this check: "Exports only on request" (`skills/design/SKILL.md:117`) and the adapter's Export and "Nothing temporary is ever written inside the base" (`skills/design-pen/SKILL.md:46`, `:92`). The adapter contract (`skills/design/SKILL.md` § adapter operations) gains the check export.
- A new agent, `flow:screen-checker`: mid tier, low effort, read-only (`Read`), one screen or a few per dispatch. Added to the agents table and the Tiers paragraph of `shared/work.md` § Agents and to `docs/architecture.md`; `/flow:design` gains a Models paragraph so the tier preference applies to it.
- The adapter's Cautions name any tool of the design tool that returns an image straight into the session.
- `/flow:project` runs `/flow:design` by hand, so the rule reaches it through the skill; nothing else changes there.

**Out.**
- Images the user pastes or asks Claude to look at.
- Downscaling images and reading them in session: a smaller image still stays for the rest of the session.
- Moving the whole drawing into a subagent: the design phase is a dialogue with the user.

**Done.** In a throwaway repo with the design adapter, one screen is drawn and checked:
- no tool result in the main session's transcript has an `image` content block;
- the checker's verdict names a defect planted on purpose;
- the read of the scratch folder from the subagent raises no prompt that blocks it;
- one image's real cost is measured from the `usage` deltas, and the baseline's "about 13k tokens each" is corrected in `baseline.md` and above if it differs.

**Gotchas.**
- In the baseline, the check ran after each edit of a screen (nine reads for four screens). One dispatch per round of edits must stay cheap, or the conductor will skip the check.

## V3 — Bookkeeping in fewer writes

**In.**
- The ledger, now written by the slice runner (V1): two writes per task, one when the executor returns (dispatch line and its report, with commits), one when the task passes (review lines, rulings, `complete`). Today about one write per dispatch and per review. The resume rule ("commits in the ledger without `complete` → review those commits") keeps working on both the new ledgers and those written one line per dispatch. The ledger bullet of `shared/work.md` § Agents ("One line per dispatch, written once…") changes with it.
- The `printenv` line and `step: execute` go in the write that opens the ledger, with the plan's review fixes when there are some: one write, never one `sed` per finding.
- Closing a phase or a slice: `STATUS.md`, `slices.md`, `lessons.md` and the commit in one call. Step 5 updates `STATUS.md` before the commit for every phase, as the design phase already does, in both conductors.
- `/flow:project` gets the same close order; it has no ledger.
- `README.md` (line 88) and `docs/architecture.md` (line 133) say what changed.
- `measure/bash_kinds.py` counts a bookkeeping call as a `Bash`, `Edit` or `Write` call that writes under the work folder, git classified first.

**Out.**
- Dropping the ledger or the per-task report: it is the memory a resume at `step: execute` needs, and it outlives compaction.
- A helper script for the bookkeeping.

**Done.** In a throwaway repo, a slice with three tasks runs through execute and close; the fixed `bash_kinds.py` counts at most two bookkeeping calls per task, one to open the ledger and one per stop. Baseline: about 18 ledger writes for about 12 tasks, plus the writes around the stops (see `baseline.md`). A ledger in the old format, at `step: execute` with a task committed and not complete, still resumes into a review.

**Gotchas.**
- A single call writing several files and committing can trip Claude Code's approval check on a heredoc, or fail between the writes and the commit. Verify in the run; if it does, the rule says two calls.
