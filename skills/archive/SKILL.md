---
name: archive
description: Use to archive a finished work: a `/flow:dev` work already recorded in the changelog, or a closed `/flow:project` home. Triggers include "/flow:archive", "archive the work X", "archive the project X", "put X away". Never archives on its own initiative.
---

# Flow: archive

Moves a finished work or project home out of the way and repairs what pointed at it. Nothing is deleted. Invoked on its own or from the closing sequence of `/flow:dev` or `/flow:project`, always after the user confirms.

## Layout

- A repo with `<root>/work/` (default root `docs`): repo layout.
- A project home whose `STATUS.md` carries `project:`: project layout.

If neither fits, ask the user which it is.

## Procedure

Follow `${CLAUDE_PLUGIN_ROOT}/shared/work.md` (in the repo: [shared/work.md](../../shared/work.md)) § Archive for the chosen layout: Archive, repo or Archive, project. Report as that section says.
