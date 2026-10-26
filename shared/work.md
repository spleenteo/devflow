# The work

The shared definition of a work's home, state, close and archive, read by `/flow:dev` and `/flow:project`. It is not a skill: the conductors say *when* each of these things happens, this file says *how*. Two layouts, and every rule below names the one it applies to:

- **repo**: a code repository; works live in `<root>/work/`, where `<root>` is `docs` unless `.flow.yml` sets `root`. Used by `/flow:dev`.
- **project**: a folder the user names when opening a project, never a code repo's `docs/`. Used by `/flow:project`.

Configuration (repo) lives in `.flow.yml` at the repository root; if it's absent and a `.devflow.yml` exists, read that instead: same keys. Keys this file uses: `root`, `merge` (`local` | `pr`, default `local`).

## Home

### Creating the home

**repo.** A work's home is a dated folder, and a branch in the current checkout:

```bash
base=$(git branch --show-current)
git switch -c work/<slug>
mkdir -p <root>/work/$(date +%Y-%m-%d)-<slug>
```

Record `$base` as `base:` in `STATUS.md`: the close needs it to find the merge target in a repo without a remote. A git worktree only when the user asks for one (two works in parallel, a busy checkout); never by default. The user's dev server, editor and browser see the work as it is.

**project.** The home is the folder the user named; inside a documents vault, propose `<vault>/<Name>/`. Create it with `mkdir -p "<home>"` and touch nothing outside it. A slice too big for one plan becomes a sub-project: `S<n>-<slug>/` inside the home, with its own `STATUS.md` and `parent:` set.

### Finding open works

**repo.** A work's `STATUS.md` lives on its branch, so the checkout alone doesn't show works opened elsewhere. Look in both places:

```bash
rg "^phase:" docs/work/*/STATUS.md 2>/dev/null
for b in $(git for-each-ref --format='%(refname:short)' 'refs/heads/work/*'); do
  git ls-tree -r --name-only "$b" -- docs/work | grep '/STATUS.md$' | grep -v '/archive/' |
    while read -r f; do printf '%s  %s  %s\n' "$b" "$f" "$(git show "$b:$f" | grep -m1 '^phase:')"; done
done
```

A work whose `phase:` isn't `done` and whose branch isn't the current one: say so, and offer `git switch work/<slug>` before reloading anything. With uncommitted changes in the checkout, ask first.

**project.** `rg "^phase:" <home>/STATUS.md <home>/*/STATUS.md 2>/dev/null`.

## `STATUS.md`

The work's state. Update it at the end of every session, and set `updated:` on every write.

**repo:**

```markdown
---
status: open
phase: <frame | shaping | breadboard | slicing | impact | slice | done>
slice: null
step: null
work: <slug>
stack: <detected>
base: <branch the work was cut from>
updated: YYYY-MM-DD
tags: [work, <slug>]
description: "<what the user wants to build, in their words>"
---

# Status — <Readable name>

> Update at the **end of every session**: done, remaining, blockers.

**Entry**: <product | technical>, decided on <date> because <visible-outcome test answer>.

## Slices

- [ ] (defined during slicing)

## Log

<!-- date — step — done — remaining — wall-clock — cost -->
```

**project:**

```markdown
---
status: open
phase: <frame | shaping | slicing | reality | slice | done>
slice: null
step: null
project: <name>
parent: null
appetite: "<time>, <money>"
updated: YYYY-MM-DD
tags: [project, <name>]
description: "<what the user wants to achieve>"
---

# Status — <Project name>

> Update at the **end of every session**: done, remaining, blockers.

**Entry**: <frame | shaping | slicing>, decided on <date> because <visible-outcome test answer>.

## Slices

- [ ] (defined during slicing)

## Log

<!-- date — slice — what happened — spent (time, money) — remaining — blockers -->
```

**Both.** `work:` (repo) or `project:` (project) is the bare name; the date lives in the folder name. `phase:` says where the work is; when it's `slice`, `slice:` and `step:` say which slice and where in it (`plan`, `review`, `execute`, `close`). `phase:` moves when a definition phase closes, together with `updated:` and a Log line. Without these three fields an interrupted work shows up the next morning as finished, or as never started. After a verification, the Log line states the outcome: *"09-02 — impact — 2 problems, fixed in V2 and V4 — 14 min — $2.10"*.

## `slices.md` and `lessons.md`

**Both.** `slices.md` is the high-level plan. Per slice: what's in, what's out, how it's demonstrated (the **Done**), known gotchas. Every slice ends in something you can see, run or verify; a slice with no visible outcome is a horizontal layer, not a slice. While planning a slice, deviations from its mandate go under **"Deviations found while planning <id>"**. At its close, the narrative goes under the slice as **"<id> — done on <date>"**: what execution revealed (repo: the rulings taken; project: what happened, what surprised, what it cost). Slices are named `V<n>` (repo) or `S<n>` (project); at most nine per level in a project.

`lessons.md` is created at the first slice close: one rule per line, the digest every later subagent reads instead of `slices.md` in full.

**Closing a slice, the bookkeeping.** Tick the slice in `STATUS.md`, set `slice:` to the next one and `step:` to `plan`, add the Log line. A closed slice isn't reopened: if a later slice finds an earlier one was wrong, the fix goes into the current slice, stated in `slices.md`, or becomes a new slice at the end (project: if the appetite allows).

**Commits.** repo: commit at each phase close and slice close, with explicit `git add <paths>`, never `-A` or `.`. project: the same when the home is under version control; in a plain folder the files are the record.

## Closing a work

**repo.** When the last slice is closed and the user confirms the work is complete. Each step asks before running; the user may stop at any point.

1. **Close.** `phase: done`, `status: closed`, final Log line, commit.
2. **Changelog.** Entry and `.version`, committed on the branch. The rules (level, entry format, version, commit) belong to `flow:docs`, a forked skill that never asks anything: this step is where the questions are asked and the requests sent. The close of `/flow:dev` and `/flow:changelog` both follow it. In order:
   1. Show `git status --short`, so the user sees what the commit will and won't hold.
   2. The version file missing (`.version` at the repo root, or `version_file` in `.flow.yml`): ask the current version, suggesting `0.1.0` if nothing has been released and `1.0.0` if the product is in production. The answer goes into the requests as `current`.
   3. The branch holds works unrelated to this one: ask whether they ship as one release or two. Two means one slug per release.
   4. Propose. Invoke the Skill tool with skill `flow:docs` and args one line of `key: value` pairs, self-contained, since the fork sees no conversation:

      ```
      op: changelog-propose, layout: repo, dir: <absolute repo root>, work: <slug>, base: <base branch>, release: one, current: <version>
      ```

      `release` is `one`, or the slugs of the split, comma-separated; `current` only when the version file is missing. It writes nothing and returns one line per release: `<level> → <version>: <title> — <reason>`.
   5. Show those lines and wait for objections. On a `major? …` line, ask: a product generation is the user's call, never the skill's. Adjust level or title as the user says.
   6. Write. Same skill, `op: changelog-write` (with `layout`, `dir`, `work`, `base`, `release`, and `current` when sent before), plus `level: <minor | patch | major>` and `title: "<title>"` per release, in the order of `release` and as the user saw them (with a split: `level: minor, patch`, `title: "First" | "Second"`). `major` only if the user confirmed it.
   7. Handle the answer. `NEEDS: <field>`: ask the user for it and resend the request. `FAILED: <reason>`: report it and stop; nothing was written.
   8. Report each returned line `Recorded v<version> — <title> — <sha>; missing decisions: …; manual after merge: …`: the version recorded, the decisions the work took that no file records, the manual steps for after the merge. Say that `/flow:archive` comes next.
3. **Archive.** `/flow:archive`, following [Archive, repo](#archive-repo), committed on the branch.
4. **Merge.** Find the target:
   1. `git symbolic-ref refs/remotes/origin/HEAD`, with `refs/remotes/origin/` stripped;
   2. else the work's `base:`;
   3. else `init.defaultBranch`, only if `git rev-parse --verify <name>` finds it;
   4. else ask.

   With `merge: local` (the default), propose the merge and run it after an ok:

   ```bash
   git switch <target>
   git merge --no-ff work/<slug>
   ```

   With `merge: pr`, propose a pull request instead and merge nothing. A request from the user overrides either. Push and tag each need their own ok. The branch is deleted only on request.
5. **Report.** The conductor reports the work as its own exit step says, including what was merged, pushed or tagged, or that nothing was.

Code, changelog, version and archived work land on the target in one changeset. If something after the close needs the work's documents, move them back with `git mv`: they're plain files in git.

**project.** When the last slice is closed and the user confirms the project is complete:

1. `phase: done`, `status: closed`, final Log line.
2. Write `report.md`: what was done, time and money spent against the appetite, the decisions taken (linked), the lessons, what was left out and why. Written for someone who reads it in a year.
3. Offer to archive, following [Archive, project](#archive-project). Never on your own initiative.

## Archive

Archiving moves a finished work out of the way; it deletes nothing. Never on your own initiative, never an `open` work: if the frontmatter doesn't say `status: closed` and `phase: done`, say so and ask, since the user may have forgotten the frontmatter or the work isn't finished. A folder without `STATUS.md` isn't archived blindly: ask what it holds.

### Archive, repo

A closed work keeps taking up context in every session that explores `<root>/work/`. Its outcome lives in the changelog and the decisions. `<root>/work/archive/` is walled: the project's `.claude/settings.json` denies `Read` and `Grep` on it. Runs on the work's branch, after the changelog and before the merge, so the archived folder lands with the code. The paths in the examples use the default root `docs`; with `root` in `.flow.yml`, substitute it. It doesn't touch `<root>/decisions-log/` (decisions outlive the work) or `CLAUDE.md`; the only file outside `<root>/` it touches is `.claude/settings.json`, with permission.

**0. First time in a repo: the wall.** `grep -n "<root>/work/archive" .claude/settings.json 2>/dev/null`. If absent, propose adding the `deny`, and wait for a yes:

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

If `settings.json` exists, append the two lines to the `deny` array without touching the rest. If the user declines, archive anyway: the folder stays readable, and the report says so. The wall takes effect from the next session. Also create `<root>/work/archived.md` if missing:

```markdown
---
tags: [work, archive, index]
description: "Index of the works archived in docs/work/archive/, a folder Claude doesn't read. This file lives outside it and is the only trace those works existed."
---

# Archived works

> `docs/work/archive/` holds finished works. Claude doesn't read it: `.claude/settings.json` denies `Read` and `Grep` on that path. This file lives outside and says where each work's outcome is. Updated by `/flow:archive`.

| Work | Closed | What it did | Where the outcome is |
|---|---|---|---|
```

**1. Pick the work.** If the user didn't name it, list the candidates:

```bash
for f in docs/work/*/STATUS.md; do
  printf "%-32s %s  %s\n" "$(basename $(dirname $f))" "$(grep -m1 '^status:' $f)" "$(grep -m1 '^phase:' $f)"
done
```

**2. Check the outcome is recorded elsewhere.** `rg "<slug>" <root>/CHANGELOG.md`: if absent, the outcome is recorded nowhere; flag it and propose `/flow:changelog` first. `rg -l "<slug>" <root>/decisions-log/ 2>/dev/null`: the decisions stay out of the archive. If either is missing, don't block: report it and ask whether to archive anyway.

**3. Census of inbound links.** `grep -rn "work/<dir>/" --include="*.md" docs README.md .claude 2>/dev/null`. Each becomes `work/archive/<dir>/`. If the count is high, say so before proceeding.

**4. Mark and move.** Add `archived: YYYY-MM-DD` to the `STATUS.md` frontmatter first: once moved, the file is out of reach. Then:

```bash
mkdir -p docs/work/archive
git mv docs/work/<dir> docs/work/archive/<dir>
```

Always `git mv`, never `mv`: the rename stays readable in history.

**5. Fix links, both directions.** *Inbound*: rewrite the references from step 3; `grep -rn "work/<dir>/" --include="*.md" docs README.md .claude 2>/dev/null | grep -v "archive/"` must return nothing. *Outbound*: the archived files moved one level down, so their relative links into `<root>/` need one more `../`. Don't replace `../` with `../../` blindly: for each broken link, add a single level and apply only if the file then exists. *Between archived works*: a link from an already archived work to this one had an extra `../`; remove it, with the same try-and-check.

**6. Update the index.** One row in `<root>/work/archived.md`, nothing more:

```markdown
| `<slug>` | <closing date> | <one sentence on what it did> | <changelog entries> · <n> decisions |
```

**7. Commit and report.**

```bash
git status --short
git add docs/work docs/work/archived.md <files with updated links> [.claude/settings.json]
git commit -m "Archive the <slug> work"
```

Report: which work, how many links updated, where its trace remains, whether the wall is active, and that its content isn't readable in session from now on.

**Rereading an archived work.** Don't ask Claude to bypass the `deny`. Open the file by hand, or remove the rule from `.claude/settings.json`, restart the session, and put it back afterwards. A work that becomes active again goes back with `git mv`: the archive is a high shelf, not a grave.


### Archive, project

1. Write `archived: YYYY-MM-DD` in the home's `STATUS.md` first.
2. Move the home to the sibling `<home>/../archive/<name>/`: `git mv` if the folder is in a git repo, else `mv`. `report.md` stays inside.
3. No wall. No `archived.md`, unless the parent folder is a git repo: then add the same one-row entry to `<home>/../archived.md`, creating it with the header above (paths adjusted).
4. Report where it went.
