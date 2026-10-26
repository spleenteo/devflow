---
kind: decision
status: active
superseded_by: null
work: flow-own-engine
area: release
touches: [.version, .claude-plugin/plugin.json, dependencies.md]
description: "flow-own-engine ships as one release, v0.2.0, from one branch with one merge; several releases of one work each are ruled out."
---

# flow-own-engine ships as one release, v0.2.0

**Date**: 2026-10-26

## The decision

The work's slices land in dependency order on one branch, with one merge and one version, v0.2.0.

## Context

Projects declare the marketplace without a ref, so `main` is the release. A half state must never reach it: for example, superpowers removed from `dependencies.md` before the engine that replaces it exists.

## Alternatives discarded

- **Several releases, one work each**: any intermediate release would be a half state on `main`, installed by every project.

## Consequences

Works in progress under v0.1.0 continue on the new engine from the next slice's plan. Nothing of the work is usable by others until the merge.

## Reopen when

The work splits into parts that are each usable and consistent alone, or the branch lives long enough that merging main into it becomes costly.

## References

- [shaping](../work/2026-10-26-flow-own-engine/shaping.md) (Release)
- [slices](../work/2026-10-26-flow-own-engine/slices.md)

## Status log

- 2026-10-26 — recorded
