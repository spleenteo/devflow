---
name: devflow-archive
description: Use to archive a devflow work that is finished and already recorded in the changelog. Triggers include "/devflow-archive", "archive the work X", "put X away". Never archives on its own initiative.
---

# Devflow Archive

Moves a finished work to `docs/work/archive/` and repairs its references. Runs on the work's branch, after `devflow-docs` and before the merge, so the archived folder lands on `main` together with the code. Invoked on its own or from devflow's closing sequence, always after the user confirms. Paths assume the default root; with `root` in `.devflow.yml`, substitute it for `docs`.

## Why

A closed work keeps taking up context in every session that explores `docs/work/`: slices, plans, status notes describing decisions already taken and code already written. Its outcome lives elsewhere, in the changelog and the decisions, and reread today it confuses more than it helps.

`docs/work/archive/` is walled: the project's `.claude/settings.json` denies `Read` and `Grep` on that path. Not a convention to respect, a closed door. To reopen it, remove the `deny` by hand, on purpose.

## What it does NOT do

| Doesn't | Why |
|---|---|
| Archive on its own initiative | Only the user knows whether a work is finished or merely paused |
| Archive an `open` work | If the frontmatter doesn't say `closed`, ask first |
| Delete anything | Archiving is moving; history stays in git |
| Touch `docs/decisions-log/` | Decisions outlive the work that produced them |
| Read inside `archive/` | It can't: the `deny` prevents it |
| Touch `CLAUDE.md` | The only project file outside `docs/` it touches is `.claude/settings.json`, and only with the permission from Step 0 |

---

## Step 0 — First time in a repo: the wall

```bash
grep -n "docs/work/archive" .claude/settings.json 2>/dev/null
```

If absent, propose adding the `deny`, and wait for a yes:

```json
{
  "permissions": {
    "deny": [
      "Read(./docs/work/archive/**)",
      "Grep(./docs/work/archive/**)"
    ]
  }
}
```

If `settings.json` exists, append the two lines to the `deny` array without touching the rest. If the user declines the wall, archive anyway: the folder stays readable, and the report says so. The wall takes effect from the next session.

Also create `docs/work/archived.md` if missing:

```markdown
---
tags: [work, archive, index]
description: "Index of the works archived in docs/work/archive/, a folder Claude doesn't read. This file lives outside it and is the only trace those works existed."
---

# Archived works

> `docs/work/archive/` holds finished works. Claude doesn't read it: `.claude/settings.json` denies `Read` and `Grep` on that path. This file lives outside and says where each work's outcome is. Updated by `/devflow-archive`.

| Work | Closed | What it did | Where the outcome is |
|---|---|---|---|
```

## Step 1 — Pick the work

If the user didn't name it, list the candidates:

```bash
for f in docs/work/*/STATUS.md; do
  printf "%-32s %s  %s\n" "$(basename $(dirname $f))" "$(grep -m1 '^status:' $f)" "$(grep -m1 '^phase:' $f)"
done
```

Only works with `status: closed` and `phase: done` are candidates. If the user points at a different one, say so and ask for confirmation: they may have forgotten to update the frontmatter, or the work isn't finished. A work without `STATUS.md` isn't archived blindly: ask what it holds.

## Step 2 — Check the outcome is recorded elsewhere

Archiving is safe only if what needs knowing is already outside.

- **In the changelog**: `rg "<slug>" docs/CHANGELOG.md`. If the work doesn't appear, its outcome is recorded nowhere: flag it and propose `/devflow-docs` first.
- **In the decisions**: `rg -l "<slug>" docs/decisions-log/ 2>/dev/null`. They stay out of the archive and are the memory of the why.

If either is missing, don't block: report what's missing and ask whether to archive anyway.

## Step 3 — Census of inbound links

```bash
grep -rn "work/<dir>/" --include="*.md" docs README.md .claude 2>/dev/null
```

Every link is updated to the new path: `work/<dir>/` becomes `work/archive/<dir>/`. They stay correct for a human opening the file; only Claude can't follow them. If the count is high, say so before proceeding.

## Step 4 — Mark and move

Before moving, add to the `STATUS.md` frontmatter:

```yaml
archived: YYYY-MM-DD
```

Write it first: once moved and the session closed, that file is out of reach. Then:

```bash
mkdir -p docs/work/archive
git mv docs/work/<dir> docs/work/archive/<dir>
```

Always `git mv`, never `mv`: the rename stays readable in history.

## Step 5 — Fix links, both directions

**Inbound.** Rewrite the references found in Step 3, then check none remain on the old path:

```bash
grep -rn "work/<dir>/" --include="*.md" docs README.md .claude 2>/dev/null | grep -v "archive/"
```

Must return zero lines.

**Outbound, the ones that get forgotten.** Archived files moved one level down: their relative links to the rest of `docs/` need one more `../`. Don't blindly replace `../` with `../../`: a pattern containing the other doubles levels that were already right. For each broken link, try adding a single level and apply only if the file then exists.

**Between two archived works, one level less.** If an already archived work pointed at the one being archived now, its link had an extra `../` to leave `archive/`: remove it now. Same rule: try, check the file exists, then apply.

## Step 6 — Update the index

`docs/work/archived.md` lives outside the walled folder, so it stays readable. Add a row:

```markdown
| `<slug>` | <closing date> | <one sentence on what it did> | <changelog entries> · <n> decisions |
```

One row only: anything more belongs in the changelog or a decision.

## Step 7 — Commit and report

```bash
git status --short
git add docs/work docs/work/archived.md <files with updated links> [.claude/settings.json]
git commit -m "Archive the <slug> work"
```

In the final report: which work, how many links updated, where its trace remains (changelog entries and decisions), whether the wall is active, and the notice that from now on that content isn't readable in session.

---

## Rereading an archived work

Don't ask Claude to bypass the `deny`: it can't, and that's the point. Two options:

1. **Open the file by hand**: the archive is plain text in git, any editor opens it.
2. **Temporarily remove the rule** from `.claude/settings.json`, restart the session, do what's needed, put it back.

If an archived work becomes active again, take the second route followed by `git mv` back: the archive isn't a grave, it's a high shelf.
