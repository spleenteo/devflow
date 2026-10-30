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
- A new agent, `flow:slice-runner`, dispatched once per slice after the first stop's yes. It runs `step: execute` as `skills/dev/SKILL.md` describes it today (order, dispatches, statuses, reviews, fix rounds, rulings, the ledger, the final review) and the close's moves 1 and 2 (gate, servers, the slice narrative and the `lessons.md` lines drafted from the ledger). It returns one short summary: status, the slice's commits, the gate result, the rulings, a decision candidate if any, Done items it could not run as `pending: <item>`.
- The runner runs in the background: with fork mode on, the default from Claude Code v2.1.302, Claude can't wait for a subagent in an interactive session (code.claude.com/docs/en/sub-agents, "Run subagents in foreground or background", "Turn fork mode off"). The conductor says so in one line, ends its turn and touches nothing in the checkout or the work folder until the runner's notification arrives. A `/flow:dev` that finds `step: execute` with a runner still running never dispatches a second one.
- The runner's instruction holds everything it can't see in the conversation: the path of the slice packet, written to `<work dir>/V<n>-packet.md` at dispatch so a resumed or compacted runner can reload it; the expanded absolute paths of `skills/dev/SKILL.md` § step: execute and § step: close, of `shared/work.md` § Agents and of the agents folder (`executor.md`, `plan-reviewer.md` for a promoted tier); the plan, the ledger and the work folder; the model rules (a model the user asked for in this session, the tier preferences); whether the final review runs (decided by the conductor, which knows the other slices); what the user said at the first stop beyond the plan's fixes; the list of agents it may dispatch (`flow:executor`, `flow:task-reviewer`), stated in the prompt since `tools:` can't restrict `Agent` in a subagent.
- Who writes what. The conductor: the plan's approved fixes (before the dispatch), `step: execute` in `STATUS.md` (before the dispatch), `STATUS.md` and the commit of the close, the narrative and lessons into `slices.md` and `lessons.md` from the runner's draft. The runner: the ledger, from its first lines and the `printenv` line, plus `Final review: <done | skipped>`, `Gate: <result>` and a `## Close draft` block (narrative, lessons, decision candidate) at its end.
- Exceptional stops (an irreversible step, a security matter, a side effect outside the checkout, a plan broken beyond guessing) return from the runner as a status with the question. The conductor asks the user and dispatches the runner again with the answer, which the runner writes as a `Ruling:` line before going on, resuming from the ledger.
- A runner that fails or is interrupted: the conductor stops the nested agents still running (`/tasks`), runs `git status --short`, and dispatches the runner again under the ledger's resume rules.
- After the runner returns, the conductor runs `lsof -nP -iTCP -sTCP:LISTEN` and stops what the slice left running, and has the `pending:` Done items run with the user before the close commit.
- The fallback: when the runner can't dispatch (`Agent` withheld at the depth limit, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`, a denied or failing first dispatch), it returns at once with a status that says so, and the conductor runs the loop in the main session as today. Said to the user in one line.
- The planner returns, with the plan's path and its deviation lines, the plan in at most ten lines for the first stop and a `Files:` line (the union of the tasks' files) for the review's decision lookup; it also writes both into the plan's header, so a resume at `step: review` finds them. The conductor doesn't read the plan.
- The resume reload table (`skills/dev/SKILL.md` § On start), per `phase:` and `step:`, holds what the next step reads, both columns and the explanation under them. Known gaps: `shaping.md` (or `breadboard.md`) at `phase: slicing`, `slices.md` in full at `phase: impact`, `docs/impact-lenses.md` and the decisions matched by `files:` for the packet at `step: plan`. A resume at `step: execute` dispatches the runner; at `step: close` it reads the ledger's `## Close draft`, with no runner.
- `shared/work.md` § Agents: the runner in the roles table and the Tiers paragraph, nesting, background running and the fallback, the facts linked to code.claude.com (nested subagents and their depth, fork mode, `SendMessage` from a subagent and its loading through ToolSearch), and the ledger bullets that say "written by the conductor" and "the conductor runs `printenv`".
- The documents that change with it: `skills/dev/SKILL.md` (the reload table, step: execute and close, the lifecycle table), `agents/planner.md` § What you return, `README.md` (lines 86–89), `docs/architecture.md` (the diagram, lines 131, 133 and the agents list).
- `/flow:project` has no agent-run execute loop: unchanged except its reload table, if it shares the gaps; the plan says.

**Out.**
- Asking the user to run `/clear` or `/compact`.
- Moving the plan, the plan review or impact into the runner: the user reads their output at the stops.
- Changing what executors and task reviewers do, or the ledger's two-writes rule (V3).
- Shortening what the user reads at the stops.

**Done.** In a throwaway repo loaded with the edited plugin, default settings (fork mode on), a work with a slice of three tasks runs from the first stop's yes to the second stop:
- the main session's transcript holds one `Agent` call to `flow:slice-runner` for the slice and no executor or task-reviewer dispatch, report or ledger write;
- the main session's context grows by less than 10k between the first and the second stop;
- the ledger is complete, with its close draft, and the slice is committed;
- a Bash command needing approval inside an executor reaches the user;
- the same run with `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` falls back to the loop in the main session and says so;
- a planted irreversible step returns from the runner as a stop, and the runner dispatched again after the answer finishes the slice.

**Gotchas.**
- Fix rounds continue the same executor with `SendMessage`: a subagent can, once it has loaded the tool through ToolSearch, so the runner's tools include both; else the existing fallback (a fresh executor with the findings).
- The runner's own context grows through the slice: a long slice could compact inside it. The packet file and the ledger are what let it go on.
- The runner is a judgement role (it rules on blocked tasks and findings): its tier is decided in the plan.

**Deviations found while planning V1**
- To apply review fixes, the conductor reads only the plan lines the findings point to; "doesn't read the plan" holds for the plan in full.
- The Done runs from a hand-made fixture already at `step: plan`, not a full opening: the Done is measured from the first stop's yes.
- A new session can't see a runner still running from another session, so its resume message asks the user.

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
- The plan's review fixes go into the plan in one write, never one `sed` per finding (the conductor, before dispatching the runner); the runner opens the ledger with its `printenv` line in one write.
- Closing a phase or a slice: `STATUS.md`, `slices.md`, `lessons.md` and the commit in one call. Step 5 updates `STATUS.md` before the commit for every phase, as the design phase already does, in both conductors.
- `/flow:project` gets the same close order; it has no ledger.
- `README.md` (line 88) and `docs/architecture.md` (line 133) say what changed.
- `measure/bash_kinds.py` counts a bookkeeping call as a `Bash`, `Edit` or `Write` call that writes under the work folder, git classified first.

**Out.**
- Dropping the ledger or the per-task report: it is the memory a resume at `step: execute` needs, and it outlives compaction.
- A helper script for the bookkeeping.

**Done.** In a throwaway repo, a slice with three tasks runs through execute and close; the fixed `bash_kinds.py`, given a path, counts on the runner's transcript (under the session's `subagents/` folder; checked where nested transcripts land) at most two bookkeeping calls per task, one to open the ledger and one per stop. Baseline: about 18 ledger writes for about 12 tasks, plus the writes around the stops (see `baseline.md`). A ledger in the old format, at `step: execute` with a task committed and not complete, still resumes into a review.

**Gotchas.**
- A single call writing several files and committing can trip Claude Code's approval check on a heredoc, or fail between the writes and the commit. Verify in the run; if it does, the rule says two calls.

**V1 — done.** Ran in the main session (the runner it builds didn't exist yet). 7 tasks, 4 rounds of final-review fixes; gate green. Done run A in a throwaway repo, with auto mode on: one `Agent` call to `flow:slice-runner`; the three executors and three task reviewers ran nested at depth 2; the ledger complete with its close draft, written by the runner only; the slice committed. Context between the stops: 82k → 93k (11k, over the 10k bound). The runner's part was about 2k (1k at dispatch, 1k at return); the rest was the stop's exchange (about 2k), the plan's review fixes (about 4k: a 30-line read and three `sed` calls, V3's subject) and the close (about 3k). The bound measured more than V1 changes; against about 55k per slice in the baseline, the execution's share is gone.
- pending: Bash approval reaching the user from a nested executor (run A had auto mode on).
- pending: the fallback with `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` (run B, not run).
- pending: an irreversible step returning from the runner as a stop (run C, not run).

**V2 — done.** Five tasks, four in parallel (T1, T2, T4, T5), then T3 after T1. Every task passed its first review. The check lives in `/flow:design` § Check, so `/flow:project` and `/flow:dev`'s design phase reach it with no change of their own. The pen adapter routes it through Export (no ninth contract operation), and its Cautions name `TakeScreenshot` and `browser` `return-screenshot`/`cdp` as the calls that put images in the session. Two reviewers each sent a second, different report after their first one had been logged. T3's top-tier review raised two mediums after T3 was marked complete: § Check said "step 6" inside its own five-step list, and called mode still said it writes only under `docs/design/`. The final review raised three: the user wasn't shown the pass/fail lines, plus those same two. T3 was reopened and they went into one fix round, f99cb59. The fix executor's first report named two commits that don't exist. That round left two new mediums (an "or" that still let a fixed fail vanish, and a broken Safety sentence), fixed in round 2, a44be8f, together with the final review's fallback for an adapter without the check export. A final-review low on design-pen § Export quoted a sentence that isn't there. The Done needs the Pen app and the user, so its four items are pending for the close. Done, in a throwaway repo with the Pen app and `--permission-mode default`: zero `image` blocks in the main session's tool results over two rounds; two `flow:screen-checker` dispatches; no `.png` in the fixture, the export went to a `mktemp -d` folder under `/var/folders`; the checker read its image with no error and no prompt. Round 1: `Sign in: pass`. Round 2, the planted 120 px label: `fail`, the label wrapping to four lines and the button at 100 px; the conductor left the defect, since the user asked for it. One image, 1280×800 at `{scale:1}`: about 2.8k tokens (the checker's context 3.2k → 6.0k), not the baseline's 13k, corrected in `baseline.md`. The checker added a paragraph of prose after `No defects.`; with the open low ("fix the defects it names" leaves no way to keep one), a candidate for later.
