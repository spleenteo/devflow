# devflow

Claude Code skills that run a development work from idea to code, one slice at a time.

Shaping produces the slices. The detailed plan of each slice is written right before executing it, so it carries what the previous slices taught. Plans are reviewed by independent subagents, execution is delegated task by task, and every step returns to you before the next one starts. State lives in the repo: a work resumes from where it stopped, days later, in a new session.

Works with any stack. Adds nothing to your project's `CLAUDE.md`.

## Install

```bash
npx skills add spleenteo/devflow -g
```

Then the skills devflow invokes:

```bash
npx skills add rjs/shaping-skills -g -s shaping -s breadboarding -s framing-doc
npx skills add mattpocock/skills -g -s grill-me
claude plugin install superpowers@claude-plugins-official
```

Check: open Claude Code in any directory and type `/devflow`.

### From a clone

```bash
git clone https://github.com/spleenteo/devflow.git
cd devflow && ./install.sh
```

`install.sh` symlinks the three skills into `~/.claude/skills/` (so `git pull` updates them), checks every dependency, and asks before installing a missing one or updating an existing one.

```bash
./install.sh --check   # report only
./install.sh --yes     # no prompts
```

## Usage

Open Claude Code inside the project and type:

```
/devflow
```

**Opening.** Five questions, one at a time: what to build, a code name, source material, whether the outcome is already clear in one sentence (technical work skips to slicing; product work starts from the frame), whether the problem is clear. Then `docs/work/<date>-<slug>/STATUS.md` is created and the path is declared.

**Definition.** Each phase writes one document in the work's folder, commits, and stops:

| Phase | Document | What happens |
|---|---|---|
| frame | `frame.md` | The problem worth solving, from dialogue or transcripts |
| shaping | `shaping.md` | Requirements, solution options, fit check |
| breadboard | `breadboard.md` | Parts and wiring |
| slicing | `slices.md` | The slices: scope, Done criteria, gotchas |
| impact | corrections in `slices.md` | Subagents read the slices and the real code, one lens each, and report problems one at a time |

**Slice loop.** For each slice, in order:

1. `plan`: `writing-plans` writes `V<n>-plan.md` from the slice, the shaping and the lessons of closed slices. Deviations from the mandate are recorded in `slices.md`.
2. `review`: a subagent checks the plan against the documents: mandate fidelity, ignored lessons, existence of what the plan names.
3. `execute`: `subagent-driven-development` runs the plan, one subagent per task with a review each.
4. `close`: Done criteria verified, lessons written under the slice in `slices.md`, `STATUS.md` updated, commit. Then: "V3 closed. Plan V4, or stop here?"

**Resume.** `/devflow` again, or "resume mobile-menu". The skill reads `STATUS.md` and offers to continue from `phase`, `slice` and `step`.

**Bugfix.** Same skill, short path: one slice, impact if it touches more than one file, the loop once.

**Close.**

```
/devflow-docs      # before the merge: changelog entry and version bump
/devflow-archive   # after the merge: moves the work to docs/work/archive/
```

## What lands in the repo

```
CHANGELOG.md
docs/work/
  archived.md
  2026-09-02-mobile-menu/
    STATUS.md
    shaping.md
    slices.md
    spike-view-transitions.md
    V1-plan.md
    V2-plan.md
  archive/
    2026-08-20-list-filter/
```

Markdown only, versioned with the code. On the first archive, `devflow-archive` offers to add a `deny` on `docs/work/archive/**` to `.claude/settings.json`, so closed works stop consuming context. You can decline.

## Skills

| Skill | Role |
|---|---|
| `devflow` | Conductor: opening, definition phases, slice loop |
| `devflow-docs` | Changelog entry and version bump |
| `devflow-archive` | Archive a closed work, repair links |

Impact lenses per stack (Rails, Astro, React, Node, generic): [`devflow/lenses.md`](devflow/lenses.md).

## Configuration

None required. Defaults: `docs/work/` for works, `CHANGELOG.md` for the changelog, `package.json` for the version, stack detected from `Gemfile`, `astro.config.*` or `package.json`.

Optional `.devflow.yml` at the project root:

```yaml
work_dir: docs/work
stack: astro            # rails | astro | react | node | generic
changelog: CHANGELOG.md
version_file: package.json
```

The skills read it if present and never write it.

## Dependencies

devflow conducts; the work is done by other skills, installed once at user level.

| Skill | Used for | Source |
|---|---|---|
| `shaping`, `breadboarding`, `framing-doc` | Frame, shaping, breadboard, slicing | [rjs/shaping-skills](https://github.com/rjs/shaping-skills) |
| `grill-me` | Tightening a vague point | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `brainstorming`, `writing-plans`, `subagent-driven-development` | Frame dialogue, slice plans, execution | [obra/superpowers](https://github.com/obra/superpowers), as a Claude Code plugin |

A missing dependency doesn't block start-up: devflow reports it when the phase that needs it arrives. The behaviour described here matches superpowers 6.3.

## Update

```bash
npx skills update devflow devflow-docs devflow-archive -g   # npx install
git -C <clone> pull                                          # clone install
```

## Uninstall

```bash
npx skills remove devflow devflow-docs devflow-archive
# or, for a clone: rm ~/.claude/skills/devflow{,-docs,-archive}
```

Projects are untouched: `docs/work/` is plain markdown.
