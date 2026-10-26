---
kind: decision
status: active
superseded_by: null
work: flow-own-engine
area: engine
touches: [skills/dev, agents, dependencies.md]
description: "One commit per task under atomic-commits' criteria, written once in Flow's executor prompt; the plugin is not a dependency and superpowers' commit default goes."
---

# Atomic-commit criteria are Flow's own rules, not a dependency

**Date**: 2026-10-26

## The decision

The executor makes one commit per task: tests per the level and the build green, the app working, no dead code, one kind of work (refactor, feature, cleanup). The criteria come from thoughtbot's atomic-commits, credited, and are written only in the executor prompt.

## Context

The owner first wanted atomic-commits as a dependency for commits. Flow now owns its executor prompts, so the criteria can live there, next to the test policy, instead of in a second plugin.

## Alternatives discarded

- **Depend on atomic-commits**: its PR-size hook targets a PR per about 200 lines, a flow that doesn't apply to local merges, and it adds another dependency to report.
- **Keep superpowers' per-task commit default**: it goes with superpowers and ignores the test level.

## Consequences

Commit rules have one place to edit. Updates to atomic-commits are not followed automatically.

## Reopen when

The workflow moves to a PR per small unit of change, making atomic-commits' hook fit, or its criteria change substantially.

## References

- [frame](../work/archive/2026-10-26-flow-own-engine/frame.md) (Commits)
- [shaping](../work/archive/2026-10-26-flow-own-engine/shaping.md) (R5.4)
- [slices](../work/archive/2026-10-26-flow-own-engine/slices.md) (V6)

## Status log

- 2026-10-26 — recorded
