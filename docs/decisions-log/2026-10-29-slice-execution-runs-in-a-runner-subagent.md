---
kind: decision
status: active
superseded_by: null
work: lean-conductor
area: engine
touches: [skills/dev/SKILL.md, shared/work.md, agents/]
description: "A slice's execution runs in one foreground subagent, flow:slice-runner; the main session keeps stops, STATUS.md and commits. No /clear, no /compact."
---

# A slice's execution runs in a runner subagent, not in the main session

**Date**: 2026-10-29

## The decision

In /flow:dev, a slice's execution (dispatching executors and task reviewers, fix rounds, rulings, the ledger, the final review, the gate and the drafted lessons of the close) runs inside one foreground subagent, flow:slice-runner, which returns one short summary to the main session; the main session keeps the stops, STATUS.md and the commits. When nested subagents are off (CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1) the loop runs in the main session as before. The user is never asked to run /clear.

## Context

A real work's main session averaged 167k of context over 270 calls and grew by about 55k per slice; most of the growth during a slice was agent reports, dispatch packets and ledger bookkeeping. The earlier decision of the same day discarded moving the loop into a subagent on the false premise that a subagent cannot dispatch subagents; Claude Code allows it up to three layers by default (code.claude.com/docs/en/sub-agents, "Let subagents spawn their own subagents").

## Alternatives discarded

- **/clear and /flow:dev resume at every slice close**: only the user can run /clear, it loses what lives only in the conversation, and it empties the context instead of keeping it from growing.
- **/compact at every slice close**: a user command too; after compaction only the first ~5,000 tokens of an invoked skill are re-attached, so the conductor rereads its own instructions.
- **Keeping the loop in the main session and only trimming what it carries (packet by path, short returns)**: saves about 35-50k tokens of a 250k peak, against a fresh context per slice.

## Consequences

The runner's own context grows during the slice and is discarded at its end. Permission prompts of nested subagents surface in the main session. Exceptional stops (irreversible step, security, side effect outside the checkout, broken plan) return from the runner and the conductor dispatches it again after the user's answer, resuming from the ledger. Machines with nesting off get the old behaviour.

## Reopen when

Claude Code changes or removes nested subagents, or a measured work shows the runner costing more than the context it saves.

## References

- [slices](../work/2026-10-29-lean-conductor/slices.md)
- [baseline](../work/2026-10-29-lean-conductor/baseline.md)

## Status log

- 2026-10-29 — recorded
