# Baseline — main-session context in a real work

Measured on 2026-10-29 from the transcript of one complete `/flow:dev` work in an app project (Flow v0.3.0): opening, shaping, a design phase, slicing, impact, three slices, changelog, archive, merge. About 3 hours of active work over two days.

The scripts in `measure/` read a session transcript (`~/.claude/projects/<project>/<session>.jsonl`) and its `subagents/` folder. Run them with `python3 -I measure/<script>.py <transcript>`. Each assistant message is counted once by `message.id`: the transcript repeats `usage` on every content block, and summing the lines overcounts by about 1.7×.

## Main session

| | Value |
|---|---|
| API calls | 270 |
| Context at the first call | 48k |
| Mean context per call | 167k |
| Peak context | 296k |
| Cache reads | 44.5 M |
| Cache writes | 0.65 M |
| Auto-compactions | 2 (232k → 78k, 296k → 88k) |

Cache reads are about 55–60% of the main session's cost, more than its output.

The context grew across the slices without ever dropping: 132k at the start of V1, 296k during V3, when auto-compact fired. The work's state was on disk the whole time.

## Where the context came from

| Source | Calls | Size in the transcript | Note |
|---|---|---|---|
| Screenshots read in session | 9 | about 13k tokens each | Read during the design phase; stayed until the next compaction |
| Bash on `STATUS.md` and plans | 66 | 61k chars | Mostly one-line `sed` or `python` edits; each call rereads the whole context |
| Bash reading the plugin's own files | 18 | 84k chars | `sed -n` ranges of `shared/work.md` and `SKILL.md` files |
| Bash on the design tool | 35 | 50k chars | |
| git | 21 | 25k chars | |

## What the conductor added to the session

Over the whole work, in transcript characters:

| Item | Count | Size |
|---|---|---|
| `Agent` inputs (the slice packet pasted into every dispatch) | 24 | 68k |
| Agent reports, as task notifications | 23 | 79k |
| Agent reports, returned in line | 24 | 26k |
| Plans read or edited in session | 26 | 44k |

Bookkeeping during execute: about 18 ledger writes for about 12 tasks, plus 2 to 4 writes on plans, `slices.md` and `STATUS.md` around each stop.

The image estimate above comes from the context jumps between calls, not from `usage` deltas per image; it is checked in V2.

## Subagents

29 subagents, about 200 calls, about 6.5 M cache reads. Executors ran on the mid tier with 30–40k of context and 3–11 calls each. One plan review took 23 calls and 1 M of cache reads. No problem found here.

## Out of scope

The 48k at the first call are mostly the user's installed plugins and skills listing, not Flow. Flow's own share (the shipped presets in the listing) is covered by the decision of 2026-10-26 on stack presets.
