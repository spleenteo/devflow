---
status: open
phase: slice
slice: V1
step: plan
work: flow-plugin
stack: generic
updated: 2026-10-25
tags: [work, flow-plugin]
description: "Turn the skill set into the `flow` Claude Code plugin (/flow:dev, /flow:project, /flow:changelog, /flow:archive), installable from GitHub, with project impact lenses, architecture docs and a first tag."
---

# Status — Flow plugin

> Update at the **end of every session**: done, remaining, blockers.

**Entry**: technical, decided on 2026-10-25 because the outcome is clear in one sentence: users install the plugin, call `/flow:dev` and `/flow:project`, and project lenses are read. Frame, shaping and breadboard skipped: the shape is decided in [`brief.md`](brief.md), and its open points are settled by the spike.

**Deviation**: the spike (`spike-plugin-loading.md`) runs before slicing, not inside the slice loop, because the slicing itself depends on its outcomes (layout, names, pinning, dependencies).

**Where it runs**: worktree `../devflow-flow` on `chore/convert-to-plugin`; the main checkout stays on `main`, so the symlinks in `~/.claude/skills/` keep serving the current conductor until the migration, after the merge.

Source material: [`brief.md`](brief.md); the review of both briefs, [`../../briefs/2026-10-25-review-of-both-briefs.md`](../../briefs/2026-10-25-review-of-both-briefs.md) (written against an earlier draft of the brief).

## Slices

- [ ] V1 — The plugin skeleton
- [ ] V2 — The rename inside the skills
- [ ] V3 — Soft dependencies
- [ ] V4 — Project impact lenses
- [ ] V5 — Architecture documentation
- [ ] V6 — README, migration, release discipline

## Log

<!-- date — step — done — remaining — wall-clock — cost -->
- 10-25 — opening — home, guidelines, briefs saved — spike, slicing — 1 h 5 min (brief review included) — n/a
- 10-25 — spike — names, shaping-skills entry, validate verified; soft dependencies and no-ref pinning decided from the docs, authenticated test skipped by choice — slicing — 45 min — n/a
- 10-25 — slicing — six slices; fidelity check skipped (no frame) — impact — 15 min — n/a
- 10-25 — impact — 2 subagents: 2 blockers (Gate unreachable before V6, grep misses old names), 6 major, 12 minor; all applied to slices.md and the guidelines; personal names scrubbed from docs/; 2 decisions recorded — V1 plan — 25 min — n/a
