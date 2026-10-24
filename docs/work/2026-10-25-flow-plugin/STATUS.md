---
status: open
phase: slicing
slice: null
step: null
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

- [ ] (defined during slicing)

## Log

<!-- date — step — done — remaining — wall-clock — cost -->
- 10-25 — opening — home, guidelines, briefs saved — spike, slicing — 1 h 5 min (brief review included) — n/a
