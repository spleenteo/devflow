---
status: closed
phase: done
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

- [x] V1 — The plugin skeleton
- [x] V2 — The rename inside the skills
- [x] V3 — Soft dependencies
- [x] V4 — Project impact lenses
- [x] V5 — Architecture documentation
- [x] V6 — README, migration, release discipline

## Log

<!-- date — step — done — remaining — wall-clock — cost -->
- 10-25 — opening — home, guidelines, briefs saved — spike, slicing — 1 h 5 min (brief review included) — n/a
- 10-25 — spike — names, shaping-skills entry, validate verified; soft dependencies and no-ref pinning decided from the docs, authenticated test skipped by choice — slicing — 45 min — n/a
- 10-25 — slicing — six slices; fidelity check skipped (no frame) — impact — 15 min — n/a
- 10-25 — impact — 2 subagents: 2 blockers (Gate unreachable before V6, grep misses old names), 6 major, 12 minor; all applied to slices.md and the guidelines; personal names scrubbed from docs/; 2 decisions recorded — V1 plan — 25 min — n/a
- 10-25 — V1 — skeleton: manifests, skills under skills/, link check; isolated install, session demo and Gate green; 5 lessons — V2 plan — 40 min — n/a
- 10-25 — V2 — rename inside the skills: four skills speak as `flow:*`, `.flow.yml` with `.devflow.yml` fallback, `${CLAUDE_SKILL_DIR}` paths, dependency naming settled by T0; demo and Gate green; 2 lessons — V3 plan — n/a (spans a context reset) — n/a
- 10-25 — V3 — soft dependencies: dependencies.md, start and phase checks in dev and project, install.sh as a checker; grill-me dropped on the owner's call; demo and Gate green; 2 lessons — V4 plan — n/a — n/a
- 10-25 — V4 — project impact lenses: template, lenses.md section, dev reads them at impact, in the slice packet and as the fifth review row; trap demo with and without the file; Gate green; 2 lessons — V5 plan — n/a — n/a
- 10-25 — V5 — architecture.md with four Mermaid diagrams, every Claude Code claim linked; Releases in the guidelines; by-eye check and review fixes; Gate green; 2 lessons — V6 plan — n/a — n/a
- 10-25 — V6 — README rewritten, migration in six points, Gate over the whole repo; install from a served git URL demonstrated; review fixes; 2 lessons — closing sequence (changelog, archive), merge on approval — n/a — n/a
- 10-25 — close — repository references renamed to spleenteo/flow on the owner's request; work closed — changelog, archive, then merge, GitHub rename and tag on approval — n/a — n/a
