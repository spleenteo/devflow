---
shaping: true
---

# Lean conductor — Slices

Technical work: no frame, no shaping. The mandate is [STATUS.md](STATUS.md) and the numbers are in [baseline.md](baseline.md): the main session averaged 167k of context over 270 calls, and grew by about 55k per slice until auto-compact fired at 296k.

The growth is diffuse. The part the conductor controls: the slice packet pasted into every dispatch (68k chars of `Agent` inputs), the agents' reports (105k chars), plans read and edited in session (44k chars), screenshots (9 reads), bookkeeping calls. The rest is the work itself (reading code, the design tool, git) and stays.

Not in this work:
- the 48k at the first call (the user's installed plugins; Flow's share is covered by the decision of 2026-10-26 on stack presets);
- the conductor's reads of `shared/work.md` and `SKILL.md`, already targeted `grep` and `sed -n` ranges;
- a restart with `/clear` at every slice close: discarded at impact. It asks the user for a command at every slice, loses what lives only in the conversation, and empties the context instead of making it grow less;
- keeping `measure/` readable after the archive: the scripts are walled with the work folder; whoever runs the next comparison copies them out first.

## V1 — The main session grows less

**In.**
- The slice packet is written once per slice to `<work dir>/V<n>-packet.md`, and every dispatch carries its path with "read it first" instead of the text. Rule 2 of Cost discipline and the dispatch contract in `shared/work.md` § Agents change with it; the prompt prefix stays identical across the slice's dispatches.
- The planner returns, with the plan's path and its deviation lines, the plan in ten lines the first stop shows. The conductor doesn't read the plan to summarise it.
- Agent returns hold what the conductor decides on: status, commits, findings, concerns. The full report goes on disk where the next reader needs it (the task reviewer gets the executor's report verbatim today; the plan says how it gets it from disk). Applies to `executor.md`, `task-reviewer.md`, `plan-reviewer.md`, `impact.md`, `planner.md` as each fits.
- A fresh session at a natural pause: at the second stop, once its question is answered and the answer committed, one line says that a work resumed another day is best resumed in a new session with `/flow:dev`. Never at every slice as a step.
- Before that line, session-only state goes to disk: a model the user asked for in this session (`shared/work.md` § Agents, rule 1) and a test level held for this session only (`skills/dev/SKILL.md` § Profile) are recorded in `STATUS.md`, or named in the line.
- The resume reload table (`skills/dev/SKILL.md` § On start), per `phase:` and `step:`, holds what the next step reads: both columns may change, and the explanation under them. Known gaps: `shaping.md` (or `breadboard.md`) at `phase: slicing`, `slices.md` in full at `phase: impact`, `docs/impact-lenses.md` and the decisions matched by `files:` for the packet at `step: plan`.
- What Claude Code does on `/clear`, `/compact` and auto-compaction (a new transcript or not; how much of an invoked skill is re-attached after compaction; that only the user can run them), linked to the official docs page in `shared/work.md`, or verified in this slice.
- `/flow:project` gets the same changes where it shares the skeleton (its reload table, its second stop, its packets), or the plan says why not.
- `README.md` (lines 86, 89) and `docs/architecture.md` (line 131) say what changed.

**Out.**
- Running `/clear` or `/compact` for the user.
- Moving the execute loop into a subagent: a subagent can't dispatch other subagents, so the loop stays in the main session.
- Shortening what the user reads at the stops.

**Done.** In a throwaway repo, a work with two small slices runs through both closes. In its transcript (`measure/`):
- no `Agent` input carries the packet text, only its path;
- no agent return over 2,000 chars, except the impact and plan-review reports the user reads at the stops;
- the main session doesn't read the plan between the planner's return and the first stop.

Then the session is closed, a new one runs `/flow:dev`, and the resume opens at the next step with the right five-line summary; the planner's packet is complete.

**Gotchas.**
- The packet on disk is a new file per slice: it is committed with the slice, or the plan says why not.
- Reports kept short must still let the task reviewer distrust the executor's report: the verbatim report has to reach it.

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
- The ledger: two writes per task, one when the executor returns (dispatch line and its report, with commits), one when the task passes (review lines, rulings, `complete`). Today about one write per dispatch and per review. The resume rule ("commits in the ledger without `complete` → review those commits") keeps working on both the new ledgers and those written one line per dispatch. `shared/work.md:203` changes with it.
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
