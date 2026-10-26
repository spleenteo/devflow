# Decision format

The format of a decision file, in both layouts. `flow:docs` writes and checks these files; the conductors propose them (the criterion for *when* to propose one is in the shared reference, `shared/work.md` § Decisions).

A decision log is the memory of *why*. It outlives the works and the slices, which get archived, and the code and the plans, which change. One file per decision, dated, never rewritten into something else.

## Kinds

- `decision`: a choice taken, with the alternatives it discarded. `status: active`, later `superseded`.
- `deferral`: a known problem left alone on purpose, with the reason and the condition for taking it up. `status: open`, later `resolved`.

## Where

| Layout | Path |
|---|---|
| repo | `<root>/decisions-log/YYYY-MM-DD-<slug>.md` |
| project | `<home>/decisions/YYYY-MM-DD-<slug>.md` |

The date is when the decision was taken; the file name carries the same date as the `**Date**` line. The slug names the decision, not the work. Decisions are written when taken, never in bulk at the end: by then the reason has faded.

## Frontmatter

| Key | Value |
|---|---|
| `kind` | `decision` or `deferral` |
| `status` | `active` or `superseded` (decision); `open` or `resolved` (deferral) |
| `superseded_by` | decision: `null` while active, the file name of the new decision once superseded |
| `resolved_by` | deferral: `null` while open, the slug of the work that resolved it |
| `work` | repo layout: the work's slug, or `null` for a decision taken outside a work |
| `project`, `slice` | project layout, instead of `work`: the project's name and `S<n>` (or `null`) |
| `area` | one kebab-case word. From `areas:` in `.flow.yml` when the project declares one, free otherwise. Required in the repo layout, optional in the project layout |
| `touches` | repo layout only: the paths and symbols the decision constrains, a non-empty list. A path matches a file it equals or contains; whole segments only |
| `description` | quoted, at most 160 characters: what was decided and what it rules out |

Lists are written in flow form only, `[a, b]`; block lists are rejected. A decision has no `resolved_by`, a deferral no `superseded_by`. A key outside this table (`tags:`, say) is allowed: the check warns and ignores it.

## Body

Headings, all present, in this order. Body roughly under 40 lines: analyses, audits and designs live in their own documents, linked from `## References`.

```markdown
## The decision          one line, the statement itself
## Context
## Alternatives discarded   (decision)  or  ## Why deferred   (deferral)
## Consequences
## Reopen when
## References
## Status log
```

- **The decision**: one line, concrete: names, numbers, paths.
- **Context**: what was on the table and what forced a choice. Two to five sentences.
- **Alternatives discarded**: one bullet per alternative, why it lost. Keep the reasons that turned out wrong too, marked as such: they explain the history. **Why deferred**: why the problem stays, what it costs meanwhile, where it will show up.
- **Consequences**: what it costs, what to watch, what becomes possible or impossible.
- **Reopen when**: the condition that makes the question worth asking again: a number crossed, a constraint lifted, a dependency released. "Never" is an answer.
- **References**: the work's `shaping.md` or `slices.md`, spikes, external docs, tickets, linked analyses.
- **Status log**: dated lines, one per status change, starting with the line that records the decision.

The title is `# <the decision as a statement>`, followed by `**Date**: YYYY-MM-DD`.

## Templates

Repo, decision:

```markdown
---
kind: decision
status: active
superseded_by: null
work: shop-exports
area: exports
touches: [src/exports, ExportQueue]
description: "Exports run through a queue, never inline; inline runs timed out past 5,000 rows."
---

# Exports run through a queue, never inline

**Date**: 2026-03-14

## The decision

Every export is enqueued and delivered by mail; no export runs in the request.

## Context

Inline exports timed out past 5,000 rows, and retries doubled the load.

## Alternatives discarded

- **Raise the request timeout**: hides the problem and ties up workers.

## Consequences

Users wait for a mail. The queue needs monitoring.

## Reopen when

The hosting platform allows long-running requests.

## References

- [shaping](../work/shop-exports/shaping.md)

## Status log

- 2026-03-14 — recorded
```

Repo, deferral: `kind: deferral`, `status: open`, `resolved_by: null`, the heading `## Why deferred` in place of `## Alternatives discarded`, and the status log opening with `- 2026-03-14 — recorded`. Everything else as above.

Project layout: the same, with `project: <name>` and `slice: S2` (or `null`) in place of `work`, and no `touches`. Its `area` is optional.

## Changing status

The body is never edited after writing. A decision is never edited into its opposite. Later changes are:

1. the frontmatter status fields (`status`, `superseded_by` or `resolved_by`);
2. a dated line under `## Status log`: `- YYYY-MM-DD — <note>`.

To supersede, write a new decision first, then mark the old one `superseded` with `superseded_by: <new file name>`. To resolve a deferral, set `resolved` and `resolved_by: <work slug>`; the slug finds the release in the changelog, and a later status-log line may add the commit. History stays readable: the question in six months is "why didn't we do X?", and the answer is often in a superseded file.

## The check

`scripts/decisions-check [--project] [--areas a,b,c] <dir>` checks every file with a `kind:` key against this format and prints `file: problem` per error, then `checked N, legacy M, errors K, warnings W` (exit 1 when K > 0). Beyond the frontmatter and headings it checks the title line, the `**Date**` line against the file name's date, and the file-name pattern; unknown keys, `touches` in the project layout and a body over 40 lines are warnings, not errors. A project may copy the script into its repo (`<root>/decisions-log/check.sh`, version header kept) to run it in its own Gate or CI.

## Legacy files

A file without `kind:` follows an older format. It is read as before, skipped by the check and counted as legacy. A status change on a legacy file appends a `## Status log` section if missing and adds no `kind:`.

## Migration

Old files stay as they are: nothing is rewritten. A project that wants its old log in this format converts it on its own, file by file, if ever; adding `kind:` and the headings makes a file subject to the check.

## Who reads it

| Reader | When |
|---|---|
| Impact lens "Memory and debt" (`/flow:dev`) | Before the first plan: does the work contradict or obsolete a decision? Looks by key words and by `touches:` |
| Plan review | Every plan: does it repeat a choice differently from a recorded decision? |
| Reality check (`/flow:project`) | Before the first plan |
| `/flow:changelog` | Links the work's decisions from the changelog entry |
| `/flow:archive` | Leaves them in place: they outlive the work |
