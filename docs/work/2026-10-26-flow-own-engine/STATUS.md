---
status: open
phase: slice
slice: V7
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
- [x] V3 Decision format
- [x] V4 Project profile
- [x] V5 Stack presets
- [x] V6 Engine
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
- 2026-10-26 — V3 close — decision format, check script, flow:docs decision ops, criterion in shared/work.md, 5 decisions recorded; 5 headless demos green; Gate green within narrowing; 3 fix rounds from task reviews — V4 plan — n/a — n/a
- 2026-10-26 — V4 close — profile (stacks, tests, merge) asked once, written on work branches; per-work raise; short guidelines template; userConfig declared after a runtime check; 5 headless demos green; Gate green within narrowing; 2 fix rounds — V5 plan (asks which stacks ship) — n/a — n/a
- 2026-10-26 — V5 close — presets astro, datocms, rails as skills; per-stack resolution (.flow.yml, userConfig, shipped); common lenses on their own; guidelines draft; per-stack dependency rows and install.sh filtering; 7 demos green (init listing check replaced by Skill results); Gate green within narrowing; 2 fix rounds — V6 plan; owner to review the presets' rules — n/a — n/a
- 2026-10-26 — V6 close — five agents (planner, plan-reviewer, impact, executor, task-reviewer) with model and effort; Flow's own plan, execution and review; § Agents and the ledger; test policy, commit and server rules once in the executor; no ultrathink; plan skills out of dependencies.md; CREDITS.md; 5 demos green plus one re-run after 3 demo fixes; Gate green within narrowing; 3 fix rounds — V7 plan — n/a — n/a
