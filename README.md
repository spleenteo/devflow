# devflow

Claude Code skills that run a piece of work from idea to done, one slice at a time. Two conductors on one skeleton:

- **`devflow`** for software: the executor is code, written by subagents in a repo.
- **`projectflow`** for everything else: the executor is people, over weeks or months, in a folder.

Shaping produces the slices. The detailed plan of each slice is written right before it starts, so it carries what the previous slices taught. Plans are reviewed by a fresh head, and the flow returns to you at two points per slice. State lives on disk: a work resumes from where it stopped, days later, in a new session.

`devflow` works with any stack and adds nothing to your project's `CLAUDE.md`. `projectflow` lives in a folder of your choice, outside any code repo.

## Install

```bash
npx skills add spleenteo/devflow -g
```

That installs `devflow`, `devflow-docs`, `devflow-archive` and `projectflow`. Then the skills they invoke:

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

`install.sh` symlinks the four skills into `~/.claude/skills/` (so `git pull` updates them), checks every dependency, and asks before installing a missing one or updating an existing one.

```bash
./install.sh --check   # report only
./install.sh --yes     # no prompts
```

## Usage

Open Claude Code inside the project and type:

```
/devflow
```

**First run in a repo.** If `docs/` doesn't exist, devflow creates `docs/work/`. If it does, devflow says what it will add inside it (`work/`, `decisions-log/`, `development-guidelines.md`, `CHANGELOG.md`), reports collisions, and asks whether to keep `docs/` (recommended) or use a top-level `devflow/` folder (discouraged: documentation ends up in two places). It then offers to create `docs/development-guidelines.md` from a template.

**Opening.** One message with five questions and the answers devflow proposes: what to build, a code name, source material, whether the outcome is already clear in one sentence (technical work skips to slicing; product work starts from the frame), whether the problem is clear. Previous developments in the same area, found in the project memory, are flagged in the same message. Then `docs/work/<date>-<slug>/STATUS.md` is created and the path is declared.

**Definition.** Each phase writes one document in the work's folder, commits, and stops:

| Phase | Document | What happens |
|---|---|---|
| frame | `frame.md` | The problem worth solving, from dialogue or transcripts |
| shaping | `shaping.md` | Requirements, solution options, fit check |
| breadboard | `breadboard.md` | Parts and wiring |
| slicing | `slices.md` | The slices: scope, Done criteria, gotchas |
| impact | corrections in `slices.md` | Two subagents read the slices and the real code, one with the common lenses and one with the stack's, and report in one ranked message with a recommended fix per finding |

**Slice loop.** For each slice, in order, with two stops:

1. `plan`: `writing-plans` writes `V<n>-plan.md` at task level (what, files, verification, done; dependencies and `critical` marks) from the slice, the guidelines and `lessons.md`. Deviations from the mandate are recorded in `slices.md`.
2. `review`: a subagent checks the plan: mandate fidelity, ignored lessons, existence of what the plan names, guideline compliance. **First stop**: the plan in ten lines, the findings ranked with a recommended fix each, one question.
3. `execute`: `subagent-driven-development` runs the plan, one subagent per task with a review each; task reviewers on a smaller model unless the task is `critical`; independent tasks in parallel.
4. `close`: the gate is green, the narrative goes under the slice in `slices.md` and the rules into `lessons.md`, `STATUS.md` logs wall-clock and cost, commit. **Second stop**: "V3 closed. Plan V4, or stop here?"

**Resume.** `/devflow` again, or "resume mobile-menu". The skill reads `STATUS.md` and offers to continue from `phase`, `slice` and `step`.

**Bugfix.** Same skill, short path: one slice, impact if it touches more than one file, the loop once.

**Cost.** Every subagent in a slice gets the same context packet (slice section, `lessons.md`, the guideline sections that apply) placed verbatim at the top of its prompt, so identical prefixes hit the prompt cache. `ultrathink` only at impact and on plans with more than five tasks. Each `STATUS.md` Log line records wall-clock and cost, so tuning is a comparison.

**Close.** When the last slice is closed and you confirm the work is complete, devflow runs the closing sequence, asking before each step:

1. `devflow-docs`: changelog entry and `.version`, committed on the branch.
2. `devflow-archive`: the work folder moves to `docs/work/archive/`, committed on the branch.
3. The branch is ready to merge into `main`. Devflow doesn't merge or push.

Code, changelog, version and archived work land on `main` in one changeset. Both skills can also be invoked on their own:

```
/devflow-docs
/devflow-archive
```

## Projectflow

For a project that isn't software: a renovation, a client engagement, a strategy, a personal plan. Open Claude Code anywhere and type:

```
/projectflow
```

**Opening.** One message with seven questions and proposed answers: what to achieve, a name, where it lives (inside a Maestro instance, `<documents_path>/<Name>/`; elsewhere, a folder you name), the appetite (time and money as a box, with a stop when it's reached), who's involved, source material, whether the outcome is already clear in one sentence.

**Definition.** `frame.md` from dialogue or transcripts (`framing-doc`), `shaping.md` with the appetite as a hard constraint, `kickoff.md` from the call with the people who will execute (`kickoff-doc`), `slices.md` with at most nine slices per level, each ending in something observable in the world. Then a reality check by two subagents: money, time, people, permissions; dependencies and points of no return, existence of what the slices name, and a pre-mortem.

**Slice loop**, two stops per slice:

1. `plan`: an action table written with you (who, when, needs, cost, done when), under sixty lines.
2. `review`: a fresh head checks fidelity, ignored lessons, availability, constraints. First stop.
3. `execute`: people act; you report; the skill updates the plan, logs what was spent, records surprises and proposes decisions as they happen.
4. `close`: the Done verified with evidence, spent against budget, lessons into `lessons.md`. Second stop.

**Handoffs.** An action that is software is written as "devflow work `<slug>` merged" and run with `devflow` in its repo. A slice that needs its own slices becomes a sub-project folder with its own `STATUS.md`.

**Exit.** `report.md`: what was done, spent against the appetite, decisions, lessons, what was left out. Then, if you want, the folder moves to an `archive/` next to it.

```
<Project>/
  STATUS.md
  constraints.md
  frame.md
  shaping.md
  slices.md
  lessons.md
  S1-plan.md
  S2-plan.md
  S3-plumbing/          # a sub-project
    STATUS.md
    slices.md
  decisions/
    2026-09-10-local-supplier-over-cheaper.md
  report.md
```

`devflow` and `projectflow` share their skeleton by design and are kept in sync by hand: a change to one is a question for the other.

## What lands in the repo (devflow)

```
.version
docs/
  CHANGELOG.md
  development-guidelines.md
  decisions-log/
    2026-09-03-server-side-locale-detection.md
  work/
    archived.md
    2026-09-02-mobile-menu/
      STATUS.md
      shaping.md
      slices.md
      lessons.md
      spike-view-transitions.md
      V1-plan.md
      V2-plan.md
    archive/
      2026-08-20-list-filter/
```

Markdown only, versioned with the code. `docs/` is the project's memory: what shipped (`CHANGELOG.md`, `work/archived.md`), why (`decisions-log/`), how code is written here (`development-guidelines.md`). Devflow searches it at the opening of every work and reads what matches. `.version` holds the application version, one line, at the root; `package.json` is left alone, its version tracks the package. On the first archive, `devflow-archive` offers to add a `deny` on `docs/work/archive/**` to `.claude/settings.json`, so closed works stop consuming context. You can decline.

## Skills

| Skill | Role |
|---|---|
| `devflow` | Conductor: opening, definition phases, slice loop |
| `devflow-docs` | Changelog entry and version bump |
| `devflow-archive` | Archive a closed work, repair links |
| `projectflow` | Conductor for projects that aren't software: appetite, reality check, action plans, people as executors |

Impact lenses per stack (Rails, Astro, React, Node, generic): [`devflow/lenses.md`](devflow/lenses.md).

## Development guidelines

`docs/development-guidelines.md` is where you write the rules plans and code must follow: how tests are written, naming, how functions are split, where code goes, what a commit contains, and the `## Gate` (the commands that must be green before a slice closes). Devflow passes it to every plan, review and execution; the review checks compliance. Template: [`devflow/development-guidelines.template.md`](devflow/development-guidelines.template.md). Keep it short and checkable.

## Decisions log

`docs/decisions-log/` keeps the *why*: one dated file per decision, with context, the decision, the alternatives discarded and the consequences. Written only when a real alternative was discarded, a known problem was deferred on purpose, or the behaviour will surprise whoever reads the code. Devflow proposes one at the close of every step and never writes it unasked. Decisions outlive works: archiving leaves them in place, and the changelog links them. Format and criterion: [`devflow/decisions-log.md`](devflow/decisions-log.md).

## Configuration

None required. Defaults: `docs/` as the root for work, decisions, guidelines and changelog; `.version` at the repo root; stack detected from `Gemfile`, `astro.config.*` or `package.json`.

Optional `.devflow.yml` at the project root:

```yaml
root: docs              # where work/, decisions-log/ and development-guidelines.md live
stack: astro            # rails | astro | react | node | generic
changelog: docs/CHANGELOG.md
version_file: .version
```

The skills read it if present. Devflow writes it in one case only: when you choose a non-default root at first run.

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
npx skills update devflow devflow-docs devflow-archive projectflow -g   # npx install
git -C <clone> pull                                          # clone install
```

## Uninstall

```bash
npx skills remove devflow devflow-docs devflow-archive projectflow
# or, for a clone: rm ~/.claude/skills/{devflow,devflow-docs,devflow-archive,projectflow}
```

Projects are untouched: `docs/work/` is plain markdown.

## License

[MIT](LICENSE)
