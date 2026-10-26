---
kind: decision
status: active
superseded_by: null
work: flow-own-engine
area: workflow
touches: [shared/work.md, skills/dev, skills/project]
description: "A work runs on work/<slug> in the current checkout and closes with a local merge after an ok; no worktree unless asked, a PR only on request or by rule."
---

# A work runs on a branch in the current checkout and closes with a local merge

**Date**: 2026-10-26

## The decision

Step 2 creates `work/<slug>` in the main checkout; a worktree only when the user asks. The close proposes a local merge into the main branch and runs it after an ok; a PR only on request or with `merge: pr` in `.flow.yml`. Push and tag always need an ok.

## Context

The previous engine created a worktree per plan. A worktree hides the dev servers agents start from the user's editor and browser, and bringing the work back to the main checkout is a chore. The user's own dev server, editor and browser should see the work in progress as it is.

## Alternatives discarded

- **A worktree per plan (superpowers' default)**: hides the work from the user's tools and adds a merge-back step.
- **A PR as the default close**: a ceremony for a work that one person merges locally; kept as an option.

## Consequences

Parallel works or a busy checkout need an explicit request for a worktree. Existing worktrees are left as they are. Executors don't start background servers: they report folder, port and URL and stop at step end.

## Reopen when

Several people or agents routinely work on the same checkout at once, or most projects declare `merge: pr`.

## References

- [frame](../work/archive/2026-10-26-flow-own-engine/frame.md) (Branches, commits, merge)
- [shaping](../work/archive/2026-10-26-flow-own-engine/shaping.md) (R5, A4)
- [slices](../work/archive/2026-10-26-flow-own-engine/slices.md) (V1)

## Status log

- 2026-10-26 — recorded
