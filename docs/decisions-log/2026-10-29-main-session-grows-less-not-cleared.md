---
kind: decision
status: superseded
superseded_by: 2026-10-29-slice-execution-runs-in-a-runner-subagent.md
work: lean-conductor
area: engine
touches: [skills/dev/SKILL.md, shared/work.md, agents/]
description: "The /flow:dev conductor keeps context low by growing less, not by asking for /clear at every slice close; a new session is only suggested at a natural pause."
---

# The main session grows less instead of being cleared at every slice

**Date**: 2026-10-29

## The decision

To keep the /flow:dev main session's context low, the conductor makes it grow less (slice packet on disk passed by path, short agent returns with full reports on disk, the planner's ten-line summary, fewer bookkeeping writes); it does not ask the user to run /clear at every slice close. A new session is suggested only at a natural pause, after the stop's question is answered.

## Context

A real work's main session averaged 167k of context over 270 calls and grew by about 55k per slice to 296k, where auto-compact fired; cache reads were the largest cost. The work's state was on disk the whole time, so a restart at each slice close looked like the biggest lever.

## Alternatives discarded

- **/clear and /flow:dev resume at every slice close**: only the user can run /clear, so it adds a command at every slice; it loses what lives only in the conversation (an open question at the stop, a model requested for the session, a session-only test level); it empties the context instead of making it grow less.
- **/compact at every slice close**: also a user command, keeps about 80-90k, and after compaction only the start of an invoked skill is re-attached, so the conductor rereads its own instructions.
- **Moving the execute loop into a subagent**: a subagent cannot dispatch other subagents.

## Consequences

The saving is smaller than a restart's: the conductor-controlled share is about 60-70k tokens of a 250k peak; the rest is the work itself. Watch the per-slice growth in the next real work against the baseline.

## Reopen when

Claude Code lets a skill clear or compact the session itself, or a measured work still grows past 200k with the V1 changes in place.

## References

- docs/work/archive/2026-10-29-lean-conductor/slices.md
- docs/work/archive/2026-10-29-lean-conductor/baseline.md

## Status log

- 2026-10-29 — recorded
- 2026-10-29 — It discarded running the execute loop in a subagent on a false premise (subagents can dispatch subagents by default); the new decision does exactly that.
