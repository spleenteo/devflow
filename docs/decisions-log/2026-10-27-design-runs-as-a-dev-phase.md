---
kind: decision
status: active
superseded_by: null
work: design-flow
area: workflow
touches: [skills/dev, skills/design]
description: "Inside /flow:dev, /flow:design is a tracked phase (phase: design) called by the conductor; the conductors do not merely suggest it."
---

# /flow:design runs as a phase of /flow:dev

**Date**: 2026-10-27

## The decision

When /flow:design runs inside a /flow:dev work it is a phase of that work: `phase: design` in STATUS.md, between shaping (or breadboard) and slicing, offered only when the work touches a UI; /flow:design is called with the criterion and the path, returns the files touched and the requirement corrections, and the conductor writes them into shaping.md and commits. By hand, /flow:design is the same skill, writes and doesn't commit.

## Context

/flow:design must be usable on its own, by /flow:project and inside /flow:dev. The open question was whether /flow:dev should track the design step or only suggest it.

## Alternatives discarded

- The conductors only suggest /flow:design and step aside: an interrupted session loses the design step (no phase in STATUS.md), /flow:design would write into the work's shaping.md behind the conductor, and the branch switch reminder for open design files sits outside the conductor.

## Consequences

/flow:dev gains a Step 3 row and /flow:design needs a called mode alongside the by-hand one, like flow:brainstorm and flow:grill. Two modes to keep in step.

## Reopen when

/flow:design grows a state of its own that a work's STATUS.md can't hold.

## References

- [shaping](../work/2026-10-27-design-flow/shaping.md)

## Status log

- 2026-10-27 — recorded
