---
name: changelog
description: Use to run by hand the changelog and version step for a finished `/flow:dev` work: record it in the changelog and bump the version. Triggers include "/flow:changelog", "write the changelog", "bump the version". The rules for the entry and the version live in `flow:docs`. Never runs on its own initiative.
---

# Flow: changelog

Records a finished `/flow:dev` work in the changelog and bumps the version, on the work's branch before the merge.

## When it runs

By hand, on the user's request. The close of `/flow:dev` follows the same step itself, so this entry point exists for running it separately. Never on its own initiative: if a work looks finished, say so in one line and stop.

## Procedure

When an older configuration file is present (the work reference, § Upgrade, names it), even beside `.flow.yml`, stop and point to `/flow:dev`, which upgrades it. Otherwise:

Follow `${CLAUDE_PLUGIN_ROOT}/shared/work.md` (in the repo: [shared/work.md](../../shared/work.md)) § Closing a work (repo), step 2, in full: ask the questions it lists, then send the requests it describes to `flow:docs`.

Nothing else of its own: the entry format, the version rule and the commit are `flow:docs`'s, the flow is the reference's.
