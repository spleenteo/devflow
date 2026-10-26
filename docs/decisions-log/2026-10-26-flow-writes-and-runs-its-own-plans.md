---
kind: decision
status: active
superseded_by: null
work: flow-own-engine
area: engine
touches: [dependencies.md, skills/dev, skills/project, agents]
description: "Flow writes, reviews and runs slice plans with its own prompts and agents; superpowers leaves dependencies.md. Rules worth keeping are absorbed with credit."
---

# Flow writes and runs its own plans; superpowers is no longer a dependency

**Date**: 2026-10-26

## The decision

Flow's own plan instructions, executor and task-reviewer prompts and one agent per role replace superpowers' `writing-plans` and `subagent-driven-development`; `superpowers` leaves `dependencies.md`.

## Context

Flow delegated planning and execution to superpowers, whose defaults (TDD on everything, full suites per task, a worktree per plan, its own paths) fought the project. Recent models already do much of what it did, but a few rules were worth keeping: the fresh-head plan review, a reviewer per task, reports on file, a ledger that survives compaction. Flow had to either keep overriding the defaults or own the engine.

## Alternatives discarded

- **Keep superpowers and override its defaults in Flow's instructions**: Flow was already fighting the defaults instead of replacing them, and the plan and review prompts stayed outside its control.
- **Rebuild all of superpowers' execution machinery**: ledger, review packages and fix-round caps were left to the model unless they proved their cost; only the rules above were absorbed (open question in the frame, settled in the shaping).

## Consequences

Rules taken from superpowers credit the source and its MIT licence. Flow owns the prompts, so test policy, commit rules and the server rule can be written once. Model and effort are set per agent in `agents/`. Brainstorming and grilling must be ported before `superpowers` can leave `dependencies.md`.

## Reopen when

A kind of work appears where Flow's own plan, review or execution measurably fails and superpowers' version handles it, or superpowers ships a change that makes it a better fit than maintaining these prompts.

## References

- [frame](../work/2026-10-26-flow-own-engine/frame.md)
- [shaping](../work/2026-10-26-flow-own-engine/shaping.md) (R0, A3)
- [slices](../work/2026-10-26-flow-own-engine/slices.md) (V6, V7)

## Status log

- 2026-10-26 — recorded
