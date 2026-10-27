---
tags: [work, design-flow, frame]
description: "Frame of the design-flow work: give Flow a design loop that lives in files, reuses the project's design system and stays independent of the design tool."
---

## The criterion

- **Problem**: Flow doesn't know design is a step: the user slips it in by hand, with no convention for where design files live or how they relate.
- **Outcome**: when a work touches a UI or needs an artifact, or on demand with no work open, Flow proposes the medium that fits: for static artifacts, a design step that finds the project's design system in `docs/design/`, draws from its components and promotes approved new ones into it; for interactive or exploratory ones, a Claude artifact.
- **Less about**: keeping design and code aligned automatically, bootstrapping a design system from code, mandatory exports, or anything tied to Pen beyond its adapter.
- **Measure**: on a second feature in the test bed, the design step reuses components promoted by the first, without starting over.

## Where this comes from

The user already runs the loop by hand: on a product feature, shaping described a search interface, Claude drew it in Pen, the user corrected the requirements by looking at it, the plan was executed, and the Pen file later fed the docs' screenshots. Flow's own landing page went through the same loop. The full account, the recon on Pen and the settled answers are in [brainstorm.md](brainstorm.md).

## What the first release holds

- A tool-agnostic `/flow:design` skill that owns the loop: discovery, reuse, promotion on approval, choice of medium, consent at every change of direction.
- A replaceable adapter, `flow:design-pen`, resolved through the presets chain with `design` as its key; the project names its tool with `design: <tool>` in `.flow.yml`. Recorded in [the decision](../../../decisions-log/2026-10-27-design-is-agnostic-skill-plus-tool-adapter.md).
- An optional `design` phase in `/flow:dev`, between shaping (or breadboard) and slicing, offered only when the work touches a UI; corrected requirements go back into `shaping.md`.
- In `/flow:project`, no fixed phase: the conductor proposes `/flow:design` for a slice when its context calls for an artifact.
- `docs/design/` as the only place for design files, from the repo root or the project's home; an index in `docs/design/README.md` plus a note inside each file; a README template shipped by Flow; stray design files found on first run are proposed for a move.
- The medium is proposed with its reason: a Claude artifact for interactive or exploratory work, a design file for static artifacts.

## Rules that hold throughout

- Nothing is deleted unless the user asks.
- Every change of direction (design to code, code to design) is proposed and approved.
- Exports happen only on request, and are checked by the file's existence.

## Test bed

A small project of the user's, where anything can be tried; a richer product of theirs later. Flow's own `docs/design/flow_home-page.pen` is left as it is.

## Left for later works

- Bootstrap of a design system from existing code (tokens and components), offered as its own step.
- Alignment between design and code: what "aligned" means (tokens only, tokens and component list, each component's look and props), who detects drift, and whether a light check runs at slice close. Until then, alignment is the developers' and designers' job, possibly stated in the project's `CLAUDE.md` by the user.

## Left to the builder

The operations every adapter must expose, and the contents of the README template.
