# Work 2 — Revise the decisions-log format

Second work in this repo, opened after Work 1 (the `flow` plugin) is merged and tagged. Revise the
decisions-log format: `decisions-log.md` next to the `dev` skill, and the points in the `dev`,
`changelog` and `archive` skills that read or write it. Everything is in English, and nothing in the
repo names the project the evidence below comes from: the format is for anyone.

> Before opening, check the names used here (skill folders, `.flow.yml`) against what Work 1 shipped.

## Evidence: one production project, 134 decisions in three months

- the log doubles as the list of deferred problems: `status: open/closed` and a `closed_by`
  with mixed values (commits, paths);
- 11 decisions edited after being written (`## Update of …`), despite the superseding rule;
- headings with variants (five ways of saying "alternatives discarded");
- 283 distinct tags, 162 used only once;
- 60 of 134 decisions with no reference to the code;
- median of 69 lines, descriptions of 289 characters at the median; 20 decisions in a single work;
- 6 design or audit documents saved as decisions.

Two of its practices to adopt: a `## Reopen when` section, and "the decision, in one line".

## What I want

1. Two kinds:
   - `kind: decision`: `status: active → superseded`, `superseded_by: <file>`;
   - `kind: deferral`: `status: open → resolved`, `resolved_by: <work slug>` (`rg <slug> docs/CHANGELOG.md`
     finds the release; a status-log line may add the commit later).
2. The body is never edited. The only later edits are the frontmatter status fields and dated lines
   under `## Status log` (this replaces today's "add one line under the title" when superseding).
3. Fixed, mandatory headings, in this order:
   `## The decision` (one line) · `## Context` · `## Alternatives discarded` (decision) or
   `## Why deferred` (deferral) · `## Consequences` · `## Reopen when` · `## References` · `## Status log`.
4. `touches:` (paths and symbols). The "Memory and debt" impact lens and the plan review look for the
   plan's files inside the decisions' `touches:`, as well as by key words: this changes the rule that
   builds the packet's "matching decisions", today a key-word `rg`.
5. `area:` from a vocabulary the project declares in `.flow.yml` (or in the log's README); it replaces
   free tags.
6. `description:` at most 160 characters; body roughly under 40 lines; analyses go in documents
   linked from `## References`.
7. In the writing criterion, the test "does the choice outlive the work?": if not, it goes in
   `slices.md` or `lessons.md`.
8. A `decisions-check` script (Bash and awk only) in `scripts/` next to the skill. The `dev` skill runs
   it as `${CLAUDE_SKILL_DIR}/scripts/decisions-check <dir>` before committing a decision. On request
   it copies the script into the project (`docs/decisions-log/check.sh`, with a version header), so a
   project's `## Gate` and CI call a project-owned path; the skill warns when the copy is older than
   its own. Files without `kind:` are legacy: skipped and counted, so an old log doesn't fail the gate.
9. A migration note for projects that already have a log in the old format.

`project`'s `decisions.md` gets the same kinds, status log, headings and `## Reopen when`; no
`touches:` (there's no code) and `area:` optional.

## Out of scope

Databases, semantic indexes, migrating any existing project's log (each project does its own).

## Constraints

Dedicated branch; no merge and no tag without explicit approval. Ships as `v0.2.0` (a user-visible
format change).

Entry: technical, straight to slicing. Expected slices: the format (with `project`'s `decisions.md`),
the readers (`touches:`, `area:`, packet rule, changelog and archive references), the script last.
