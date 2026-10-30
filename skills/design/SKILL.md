---
name: design
description: "Flow's design step, run by Flow's conductors, or by hand with /flow:design. Sets up the project's docs/design/ folder and its index, proposes the medium for a work's design step, composes from the project's design system and promotes approved components into it."
---

# Flow: design

Running a `/flow:` skill is the user's explicit choice of process: inside it no other process skill applies (brainstorming, grilling, planning, plan execution, test-driven development or worktree skills, from any plugin or personal). The design adapter is named by its qualified name.

This skill holds the project's design files in one place, keeps an index of them, and proposes the medium that fits what the user needs to see: a Claude artifact or a design file. It has two modes, called by `/flow:dev`'s design phase or by hand (typed, or from a `/flow:project` plan row); it writes and never commits in either, and says so.

## Called

Called mode is told apart by its args: the Skill tool `flow:design` with args holding the `## The criterion` block verbatim (when the work has one), then `Shaping: <absolute path of shaping.md>` and `Screens: <the screens to draw, comma-separated>`. A `Shaping:` line means called; none means by hand.

Called, the skill runs Place, Adapter, First use, Medium, Compose, Check, Promote and Safety unchanged, every consent step still asked of the user (it runs in the conductor's session). It reads `shaping.md` and never writes it; it writes only under `docs/design/` and the check's scratch folder, and never commits.

A requirement correction is anything the design shows wrong, missing or unneeded in `shaping.md`, collected as one line: `<requirement id, or new> — <the correction> — <what in the design showed it>`. When a criterion was passed, each also names the criterion line it serves, and one that serves none is reported as such; with no criterion, no anchor. They are returned as **Requirement corrections**, beside **Files touched** (see § Exit).

## Models

Flow's agents are in `${CLAUDE_PLUGIN_ROOT}/agents/` (dispatched as `flow:<name>`). Preference for the mid tier: `${user_config.model_mid}`. A value that is empty, or begins with `${`, is unset. Which model each dispatch takes and the dispatch contract: the work reference, § Agents (`${CLAUDE_PLUGIN_ROOT}/shared/work.md`).

## Place

Design files live in `<base>/docs/design/`. The base, first hit wins:

1. By hand, `Home: "<absolute path>"` in the args (quoted: vault paths hold spaces).
2. By hand, the working directory, when its `STATUS.md` has a `project:` line.
3. The repo root, `git rev-parse --show-toplevel`.

Called mode (`Shaping:`) skips 1 and 2 and uses the repo root: `/flow:dev` runs in a repo. A folder from 1 or 2 is a project home only when `grep -m1 '^project:' <dir>/STATUS.md` finds the line; a named folder without it: say so and stop. From a project home, walk up while its `parent:` isn't `null` (a sub-project sits inside its parent's folder, so up is the folder above, checked again the same way; a folder above without it: say so and stop) and use that top home as the base: one design system per project. None found: ask for a project home or a repo; still none: say that this skill works in a repo or a project home, and stop.

`root` in `.flow.yml` does not move the base: `root` governs Flow's own folders, not the project's design files. Every `docs/design/` path below is relative to the base.

## Adapter

The design tool is `design: <tool>`, read from `.flow.yml` in a repo, or from the top home's `STATUS.md` in a project home (sub-projects don't carry it). Its adapter is a skill, resolved first hit wins:

1. `presets:` (in `.flow.yml` in a repo; in the top home's `STATUS.md` in a project home), the pair `design=<skill>`;
2. `${user_config.stack_presets}`, the pair `design=<skill>` (same comma-separated pairs; empty, or still beginning with `${`, means unset);
3. the shipped adapter, from a list fixed here, never looked up in the skill listing: `pen` → `flow:design-pen`.

Only the resolved skill is invoked, with the Skill tool by its qualified name, never by path.

Artifacts only (see § Medium), and the message says which case holds, when:

- no `design:` where the base keeps it (`.flow.yml` in a repo, the top home's `STATUS.md`): no adapter;
- the tool has no mapping and no shipped adapter: say so, and never fall back to the shipped one;
- the mapped skill is not in the session: say so, and never fall back to the shipped one;
- the adapter's `## Requires` is not met in the session.

Once a skill resolves, read its `## Requires` before anything else.

**The contract.** Every adapter fills these sections, in this order:

- `## Requires`: the tools the adapter needs, how to detect them, and what to say when they are missing.
- `## Files`: the file extensions, how a file's role (library or area) is told, how files import each other, the note a file carries about itself, and how to read a file for the index.
- `## Operations`: eight subsections, cited below as "the adapter's <Name>":
  - `### Session`: the rules for working on a file (one file and one change per call, what to do after a failure, how aliases are read);
  - `### Open`: open a file and read its frames and its imports, or create a new one;
  - `### List`: list a library's components and tokens;
  - `### Import`: add a library import to an area file;
  - `### Compose`: compose a screen from the listed components and tokens;
  - `### Promote`: promote a local component into a library, in the tool's steps;
  - `### Note`: write the in-file note;
  - `### Export`: export nodes to a folder; also the check export of § Check (PNG, to a scratch folder outside the base).
- `## Cautions`: what can go wrong with the tool's files, and how to avoid it; and every tool or call that returns an image into the session.

## First use

When an adapter resolves, read its `## Cautions` and search the base for files with the adapter's extensions (its `## Files`), outside `docs/design/`, `.git/` and `node_modules/`. Also check whether `docs/design/README.md` exists. Without an adapter, only the index check applies.

Send one message with:

- the moves, each from → to, if any file was found;
- the caution to save and close those files in the design tool first, and the adapter's `## Cautions` that apply to the listed moves;
- the offer to create the index from `${CLAUDE_SKILL_DIR}/design-index.template.md` when `README.md` is missing, or, when it exists, the rows proposed for the moved files; a row per file: role from the adapter's naming rule; contents and imports read as the adapter's `## Files` says when its requirement is met, else asked in the same message.

The index (its text and its rows) is written in the language of the repo's `docs/` documents, or the home's documents, whatever language the conversation is in; the template is English, so translate its text when the folder is not. The same goes for in-file notes.

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
2. Pick the file from the index's area rows. Name the file and why, and let the user confirm. No area fits: propose a new area file (name agreed), created through the adapter's Open, with the library import and a note, plus its index row.
3. Run the adapter's Open on the file. When a library is not imported, run the adapter's Import. Then run the adapter's List on the libraries the area file imports.
4. Compose through the adapter's Compose, from the listed components and tokens only.
5. For each element no component fits, propose a new one (name, what it is, why none fits). Build it locally only on an ok.
6. Run § Check on the screens changed in this round, then ask whether the screen is approved.
7. After each change, update the file's note through the adapter's Note and its index row (contents, imports), both in the folder's language.

Every call follows the adapter's Session.

## Check

The main session never receives an image, by `Read` or by any tool result: never read an exported image unless the user asks to look at it, and never call a tool the adapter's `## Cautions` name as returning one.

Once per round of edits, for design files only:

1. Make the folder with `mktemp -d` at the first check of the run and reuse it afterwards.
2. Export the round's screens through the adapter's Export as PNG to it.
3. Check each path with `test -f`; a missing one is reported as failed and left out of the dispatch.
4. Dispatch `flow:screen-checker` (mid tier, see § Models). Its packet: the criterion block when there is one; then per screen its absolute PNG path and what it must show (the requirement lines, or the user's request by hand); then what to check. When the dispatch runs in the background, say one line, end the turn, and touch neither the design file nor the folder until the notification arrives.
5. Fix the defects it names, then at § Compose step 6 show the user the screens' pass/fail lines, one each, including those fixed in session. An `unreadable` screen is reported to the user in one line at § Compose step 6, never counted as a pass.

The folder is outside the base and never committed. With no `Agent` tool in the session: skip the check and say so in one line. When the adapter's Export doesn't name the check export, skip the check the same way.

## Promote

After the screen is approved, ask per new local component whether to promote it into the design system, naming the target library: one library row: that one; several: ask which; none: say so and stop.

On an ok, run the adapter's Promote. Then update the library's row (contents gains the component), the area's row (imports names the library) and both notes through the adapter's Note, in the folder's language.

Promotion is never atomic: the tool works on one file at a time. If the second step fails, the library holds the component and the area file still has its local copy. Say so, and offer to finish with the second step only, after re-reading both files. Never retry blindly, and never re-run the first step: it would duplicate the component.

## Safety

- **No deletion unasked.** No file, frame or component is deleted or replaced unless the user asks. The removal of the local copy in a promotion is part of the move the user approved; moves at first use are not deletions.
- **Direction.** This skill draws and never edits code. Building a screen in code, or redrawing what the code does, is proposed in one line with what would change, and done only on an ok. By hand with code to write, propose `/flow:dev`; called, say the code belongs to the work's later slices. Every change of direction needs the user's consent.
- **Exports only on request, except the check export of § Check.** On request: through the adapter's Export, to a folder the user names (asked when not given). Check each path it returns with `test -f`; a missing file is reported as failed.

## Exit

Called, return two lists and say the caller commits: **Files touched** (every path written or moved under `docs/design/`, the index included; design files or the artifact's HTML source) and **Requirement corrections** (lines as in § Called, or `none`). Code to write is the work's later slices: say so in one line, never propose it as `/flow:dev`.

By hand, this skill writes and never commits. Say so, and list the files written or moved. In a repo, the user reviews and commits them. In a project home, they ride the slice's close commit when the home is under version control and a slice is open; in a plain folder the files are the record.
