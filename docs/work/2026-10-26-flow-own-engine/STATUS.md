---
status: open
phase: slice
slice: V3
step: execute
work: flow-own-engine
stack: generic
updated: 2026-10-26
tags: [work, flow-own-engine]
description: "Flow plans and runs its own work, owns its memory and the project profile, and drops superpowers"
---

# Status — Flow's own engine

> Update at the **end of every session**: done, remaining, blockers.

**Entry**: product, decided on 2026-10-26 because the outcome "depends": seven themes, each changing what a user of the plugin sees in a different place. Frame written from a brainstorming dialogue held in session (no transcript file).

## Slices

- [x] V1 Work layer
- [x] V2 `flow:docs`
- [ ] V3 Decision format
- [ ] V4 Project profile
- [ ] V5 Stack presets
- [ ] V6 Engine
- [ ] V7 Widen and narrow
- [ ] V8 Upgrade and documentation

## Log

<!-- date — step — done — remaining — wall-clock — cost -->

- 2026-10-26 — frame — brainstorming in session, frame written — builder check, then shaping — n/a — n/a
- 2026-10-26 — frame — builder check: 5 questions, 2 answered by the owner, 3 settled as calls; frame approved — shaping, spikes 2-4 — n/a — n/a
- 2026-10-26 — shaping — R0–R8, shape A selected; 3 spikes (fork verified at runtime); release: one, v0.2.0; presets: skills, opinionated, replaceable; fidelity check: 8 findings applied — breadboard skipped, slicing next — n/a — n/a
- 2026-10-26 — slicing — 8 slices; fidelity check: 9 findings applied — impact — n/a — n/a
- 2026-10-26 — impact — 2 subagents (common lenses, repo lenses): 18 problems after dedup, all fixed in slices.md, no reordering — V1 plan — n/a — n/a
- 2026-10-26 — V1 close — work layer shipped (shared/work.md; dev, project, archive point to it); 5 headless demos + check 6 green; Gate green within narrowing; T1 written in session after 2 executor failures — V2 plan — n/a — n/a
- 2026-10-26 — V2 close — flow:docs shipped (fork: changelog, version, search); /flow:changelog an entry point; conductors send requests; 6 headless demos green; Gate green within narrowing; 2 fix rounds from task reviews — V3 plan — n/a — n/a
