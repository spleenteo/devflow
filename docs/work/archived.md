---
tags: [work, archive, index]
description: "Index of the works archived in docs/work/archive/, a folder Claude doesn't read. This file lives outside it and is the only trace those works existed."
---

# Archived works

> `docs/work/archive/` holds finished works. Claude doesn't read it: `.claude/settings.json` denies `Read` and `Grep` on that path. This file lives outside and says where each work's outcome is. Updated by `/flow:archive`.

| Work | Closed | What it did | Where the outcome is |
|---|---|---|---|
| `flow-plugin` | 2026-10-25 | Turned the four personal skills into the `flow` Claude Code plugin, installable from GitHub, with soft dependencies, project impact lenses and architecture docs | `docs/CHANGELOG.md` v0.1.0 · 3 decisions |
| `flow-own-engine` | 2026-10-26 | Made Flow plan and run its own work, own its memory and the project profile, and drop superpowers | `docs/CHANGELOG.md` v0.2.0 · 5 decisions |
| `design-flow` | 2026-10-27 | Added `/flow:design`, an agnostic design skill with a swappable tool adapter (Pen first), a design phase in `/flow:dev` and design rows in `/flow:project` plans | `docs/CHANGELOG.md` v0.3.0 · 2 decisions |
| `lean-conductor` | 2026-10-30 | Cut the context the main session carries through a work: each slice runs in a slice-runner subagent, design screens are checked by a screen-checker out of the session, and bookkeeping takes fewer writes | `docs/CHANGELOG.md` v0.4.0 · 2 decisions |
