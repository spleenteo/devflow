---
name: devflow-docs
description: Use when a work run with devflow is finished and about to land on main. Triggers include "/devflow-docs", "update docs", "write the changelog", "bump the version". Records the changelog entry and the version; touches neither the code nor the work's documents.
---

# Devflow Docs

Records a finished work in `docs/CHANGELOG.md`, before it lands on `main`.

## What it does NOT do

Binding list. If you feel like doing one of these, don't.

| Doesn't | Why | Where it lives instead |
|---|---|---|
| Touch `docs/work/` | `STATUS.md` and `slices.md` are closed by `devflow` during the work | The slice loop |
| Create files in `docs/decisions-log/` | A decision is written when taken, not when summarised | `devflow`, closing each step |
| Describe migrations, backfills, secrets | The changelog says what changed, not what to do in production | The slice's plan and `STATUS.md` |
| Publish anything outward | Landing pages, public release notes, posts: the user decides | Outside the repo |
| Propose a major version | A product generation is a human decision | Step 2 |
| Use `git add -A` or `git add .` | The working tree may hold unrelated work | Step 5 |

## When it runs

On explicit invocation, or from devflow's closing sequence after the user has confirmed the work is complete. Never on its own: if at the end of a session the work looks finished, say so in one line and stop. The user knows whether it's done or continues tomorrow.

> "The work looks finished: update the changelog? (`/devflow-docs`)"

## Conventions

| What | Where | If missing |
|---|---|---|
| Changelog | `docs/CHANGELOG.md` | Created, with a two-line intro and the first entry. An existing `docs/CHANGELOG.md` is adopted as is |
| Version | `.version` at the repo root: one line, e.g. `1.4.2` | Created in Step 4, after asking the user for the current version |
| Decisions | `docs/decisions-log/` | The "Decision" bullet is omitted |

A `.devflow.yml` at the root with `changelog` and `version_file` overrides the first two (a changelog under another name, say `docs/change-log.md`, goes there); `root` moves `docs/`. Read if present, never created here.

`package.json` is not touched: its `version` tracks the package, not the application.

**Language**: that of the existing changelog entries. For a new changelog, that of the rest of `docs/`.

---

## Step 1 — Understand what was done

```bash
git log main..HEAD --format="%h %ad %s" --date=short
git diff main..HEAD --stat
git status --short
```

Read the changelog: existing entries set tone and detail. Read `.version` for the current number; if the file is missing, ask the user what the current version is (suggest `0.1.0` for a project not yet released, `1.0.0` for one in production). Read the work's `STATUS.md` and `slices.md` in `docs/work/`: the "V<n> — done on" sections say what really happened.

If the branch holds unrelated works, don't force them into one entry: ask whether they are one release or two. If it's unclear what to document, ask: *"Which work should I record?"*

## Step 2 — Compute the version

Not a negotiation: a rule. Apply it and state the result.

| Level | Criterion |
|---|---|
| **MAJOR** `X.0.0` | A product generation. Never propose it. If the work looks major, ask and stop |
| **MINOR** `x.Y.0` | The user **can do something they couldn't before**: new view, field, filter, command, visibly different behaviour |
| **PATCH** `x.y.Z` | Everything else: bug fixes, security, refactors, stack upgrades, performance, infrastructure, docs |

The criterion is **what changes for the product's users**, not how much code moved: a refactor touching fifty files is a patch; a new filter touching six is a minor. Below 1.0 the same rule applies.

State it without asking permission, leaving room to object:

> "Recording as **patch** → 1.10.1: the work fixes three defects but doesn't change what the user can do. Say if you see it differently."

## Step 3 — Write the entry

At the top of the changelog, after the intro block and before the first `## v`.

### Format

```markdown
## vX.Y.Z — YYYY-MM-DD — Short title

One or two sentences: what changes and why it was done.

- **Label**: plain-language sentence.
- **Label**: plain-language sentence.
- **Work**: `<slug>`
- **Decision**: [readable slug](docs/decisions-log/YYYY-MM-DD-slug.md)

---
```

### Rules

- **Date**: the merge date, `YYYY-MM-DD`, not when the work started.
- **Title**: says what changed for the reader, not the branch name. *"The calendar no longer crashes"*, not *"fix/calendar-null-technician"*.
- **Bullets**: a bold label naming the concept, then a plain sentence. No commit list: forty commits still make four bullets.
- **Work**: the work's slug in `docs/work/`. It's the hook that survives archiving: `rg "<slug>" docs/CHANGELOG.md` must find the entry.
- **Decision**: links to the `docs/decisions-log/` files that explain why. Check the file exists before linking. If the work took decisions no file records, flag it in the final report: a decision is missing, but this skill doesn't write it. Omit the bullet if the repo has no `decisions-log/`.
- **No "files changed" section**: this is a register, not a diff.
- **No operational instructions**: migrations, backfills and secrets don't go here.
- **No emoji**, unless the feature itself uses one.

## Step 4 — Bump the version

Write the number computed in Step 2 to `.version`, nothing else in the file, newline-terminated. Create the file if missing. It's the only place the application version lives.

## Step 5 — Commit

```bash
git status --short                      # show it to the user first
git add docs/CHANGELOG.md .version      # ONLY the touched files, explicitly
git commit -m "Record vX.Y.Z in the changelog"
```

- Never `git add -A` or `git add .`.
- Never `--amend`: if the commit was pushed, rewriting it does more harm than good.
- Imperative message, in the language the repo's history already uses.
- The commit goes on the work's branch, before the merge: docs and code land on `main` in the same changeset. The archive commit follows it, on the same branch.

## Step 6 — Final report

Briefly:

- version assigned and why that level;
- title of the entry written;
- missing decisions: choices made during the work that no file explains;
- what remains to be done by hand after the merge, if the plan says so (backfills, secrets, migrations), as a reminder in the report and never in the changelog;
- a reminder that the work's `STATUS.md` must say `status: closed`, and that the next step, on the same branch, is `/devflow-archive`.

## Relation to archiving

The changelog entry is what survives archiving: when `/devflow-archive` moves a work to `docs/work/archive/`, its content becomes unreadable in session and only the changelog and the decisions remain. Write the entry for someone who will read it when the rest is gone: it must stand on its own.
