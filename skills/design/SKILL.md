---
name: design
description: "Flow's design step, run by Flow's conductors, or by hand with /flow:design. Sets up the project's docs/design/ folder and its index, and proposes the medium for a work's design step."
---

# Flow: design

Running a `/flow:` skill is the user's explicit choice of process: inside it no other process skill applies (brainstorming, grilling, planning, plan execution, test-driven development or worktree skills, from any plugin or personal). The design adapter is named by its qualified name.

This skill holds the project's design files in one place, keeps an index of them, and proposes the medium that fits what the user needs to see: a Claude artifact or a design file. This version runs by hand only. It writes, never commits, and says so.

## Place

Design files live in `docs/design/` at the repo root (`git rev-parse --show-toplevel`). `root` in `.flow.yml` does not move it: `root` governs Flow's own folders, not the project's design files. Outside a repo, say that this skill works in repos only and stop.

## Adapter

The design tool is `design: <tool>` in `.flow.yml`. Its adapter is a skill, resolved first hit wins:

1. `presets:` in `.flow.yml`, the pair `design=<skill>`;
2. `${user_config.stack_presets}`, the pair `design=<skill>` (same comma-separated pairs; empty, or still beginning with `${`, means unset);
3. the shipped adapter, from a list fixed here, never looked up in the skill listing: `pen` → `flow:design-pen`.

Only the resolved skill is invoked, with the Skill tool by its qualified name, never by path.

Artifacts only (see § Medium), and the message says which case holds, when:

- `.flow.yml` has no `design:`: no adapter;
- the tool has no mapping and no shipped adapter: say so, and never fall back to the shipped one;
- the mapped skill is not in the session: say so, and never fall back to the shipped one;
- the adapter's `## Requires` is not met in the session.

Once a skill resolves, read its `## Requires` before anything else.

**The contract.** Every adapter fills these sections, in this order:

- `## Requires`: the tools the adapter needs, how to detect them, and what to say when they are missing.
- `## Files`: the file extensions, how a file's role (library or area) is told, how files import each other, the note a file carries about itself, and how to read a file for the index.
- `## Operations`: how to draw, compose from a library and promote components.
- `## Cautions`: what can go wrong with the tool's files, and how to avoid it.

## First use

When an adapter resolves and its requirement is met, search the repo for files with the adapter's extensions (its `## Files`), outside `docs/design/`, `.git/` and `node_modules/`. Also check whether `docs/design/README.md` exists. Without an adapter, only the index check applies.

Send one message with:

- the moves, each from → to, if any file was found;
- the caution to save and close those files in the design tool first;
- the offer to create the index from `${CLAUDE_SKILL_DIR}/design-index.template.md` (a missing `README.md`), with a row per file: role from the adapter's naming rule; contents and imports read as the adapter's `## Files` says when its requirement is met, else asked in the same message.

Nothing moves and nothing is written before an ok. A declined index is not created. Move with `git mv` when the file is tracked, `mv` otherwise. File names in the index are code spans, never Markdown links.

## Medium

Propose one medium with its reason; the user confirms or changes it.

- **Interactive or exploratory** (a flow to click through, an idea to try out): a Claude artifact.
- **Static** (a page, a screen, a deck): a design file.

Artifacts only in the four cases of § Adapter.

**A Claude artifact** is produced with the session's artifact tool when one is available. Its source is always also saved as one self-contained HTML file (inline CSS and script, no external fetch) under `docs/design/`, with a name agreed with the user, and gets an index row with the role `artifact`, so it does not stay closed inside Claude. With no artifact tool, the HTML file alone.

**A design file** follows the adapter's `## Operations`. When that section says drawing is not described, say so and stop after the medium choice.

## Exit

This skill writes and never commits. Say so, and list the files written or moved, so the user can review and commit them.
