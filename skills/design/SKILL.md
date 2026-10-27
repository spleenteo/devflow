---
name: design
description: "Flow's design step, run by Flow's conductors, or by hand with /flow:design. Sets up the project's docs/design/ folder and its index, proposes the medium for a work's design step, composes from the project's design system and promotes approved components into it."
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
- `## Operations`: eight subsections, cited below as "the adapter's <Name>":
  - `### Session`: the rules for working on a file (one file and one change per call, what to do after a failure, how aliases are read);
  - `### Open`: open a file and read its frames and its imports;
  - `### List`: list a library's components and tokens;
  - `### Import`: add a library import to an area file;
  - `### Compose`: compose a screen from the listed components and tokens;
  - `### Promote`: promote a local component into a library, in the tool's steps;
  - `### Note`: write the in-file note;
  - `### Export`: export nodes to a folder.
- `## Cautions`: what can go wrong with the tool's files, and how to avoid it.

## First use

When an adapter resolves, read its `## Cautions` and search the repo for files with the adapter's extensions (its `## Files`), outside `docs/design/`, `.git/` and `node_modules/`. Also check whether `docs/design/README.md` exists. Without an adapter, only the index check applies.

Send one message with:

- the moves, each from → to, if any file was found;
- the caution to save and close those files in the design tool first, and the adapter's `## Cautions` that apply to the listed moves;
- the offer to create the index from `${CLAUDE_SKILL_DIR}/design-index.template.md` when `README.md` is missing, or, when it exists, the rows proposed for the moved files; a row per file: role from the adapter's naming rule; contents and imports read as the adapter's `## Files` says when its requirement is met, else asked in the same message.

The index (its text and its rows) is written in the language of the repo's `docs/` documents, whatever language the conversation is in; the template is English, so translate its text when the folder is not. The same goes for in-file notes.

Nothing moves and nothing is written before an ok. A declined index is not created. Move with `git mv` when the file is tracked, `mv` otherwise. File names in the index are code spans, never Markdown links.

## Medium

Propose one medium with its reason; the user confirms or changes it.

- **Interactive or exploratory** (a flow to click through, an idea to try out): a Claude artifact.
- **Static** (a page, a screen, a deck): a design file.

Artifacts only in the four cases of § Adapter.

**A Claude artifact** is produced with the session's artifact tool when one is available. Its source is always also saved as one self-contained HTML file (inline CSS and script, no external fetch) under `docs/design/`, with a name agreed with the user, and gets an index row with the role `artifact`, so it does not stay closed inside Claude. With no artifact tool, the HTML file alone.

**A design file** follows § Compose. When the adapter's `## Operations` says drawing is not described, say so and stop after the medium choice.

## Compose

1. Read `docs/design/README.md`. Missing: § First use's offer runs first.
2. Pick the file from the index's area rows. Name the file and why, and let the user confirm. No area fits: propose a new area file (name agreed), created through the adapter with the library import and a note, plus its index row.
3. Run the adapter's Open on it, then the adapter's List on the library. When the library is not imported, run the adapter's Import.
4. Compose through the adapter's Compose, from the listed components and tokens only.
5. For each element no component fits, propose a new one (name, what it is, why none fits). Build it locally only on an ok.
6. Ask whether the screen is approved.
7. After each change, update the file's note through the adapter's Note and its index row (contents, imports), both in the folder's language.

One logical change per call. After a failed call, re-read the nodes before anything else; never resend the same snippet.

## Promote

After the screen is approved, ask per new local component whether to promote it into the design system, naming the target library: the one library row if there is one, otherwise ask which.

On an ok, run the adapter's Promote. Then update the library's row (contents gains the component), the area's row (imports names the library) and both notes through the adapter's Note, in the folder's language.

Promotion is never atomic: the tool works on one file at a time. If the second step fails, the library holds the component and the area file still has its local copy. Say so, and offer to finish with the second step only, after re-reading both files. Never retry blindly, and never re-run the first step: it would duplicate the component.

## Safety

- **No deletion unasked.** No file, frame or component is deleted unless the user asks. The removal of the local copy in a promotion is part of the move the user approved; moves at first use are not deletions.
- **Direction.** This skill draws and never edits code. Building a screen in code, or redrawing what the code does, is proposed in one line with what would change, and done only on an ok. By hand with code to write, propose `/flow:dev`. Every change of direction needs the user's consent.
- **Exports only on request.** Through the adapter's Export, to a folder the user names (asked when not given). Check each path it returns with `test -f`; a missing file is reported as failed.

## Exit

This skill writes and never commits. Say so, and list the files written or moved, so the user can review and commit them.
