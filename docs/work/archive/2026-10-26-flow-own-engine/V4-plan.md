---
work: flow-own-engine
slice: V4
tags: [plan, flow-own-engine]
description: "Plan for V4: the project profile (stacks, test level with sensitive areas, merge style) checked at every start and asked once; a per-work test raise; personal settings declared as userConfig."
---

# V4 — Project profile · plan

**Mandate**: [`slices.md` § V4](slices.md#v4--project-profile). **Spike**: [`spike-personal-settings.md`](spike-personal-settings.md), § Runtime check (encoding chosen). **Guidelines**: [`docs/development-guidelines.md`](../../../development-guidelines.md). **Lessons**: [`lessons.md`](lessons.md).

**Execution rules**: executors on `sonnet`; reviewers on `opus` for `critical` tasks, `sonnet` otherwise; current checkout on `work/flow-own-engine`; check the tree before re-dispatching a failed executor; demos headless on throwaway repos, flags as an array, two turns with `--resume <session_id>` where a question must be asked before the answer.

**The profile, decided here:**
- **Pieces**: `stacks` and `merge` in the configuration file; the test level and the sensitive areas in `## Tests` of `docs/development-guidelines.md`.
- **Configuration file**: `.flow.yml`, or `.devflow.yml` when that is the one in use; the profile writes into the file in use, never creates `.flow.yml` beside a `.devflow.yml`.
- **`stacks`**: a flow list, `stacks: [astro, node]`. An existing `stack: <name>` reads as `[<name>]` and isn't asked again; the profile never rewrites it (V8 converts).
- **Detection**: each stack's signal is checked on its own (`rails`, `astro`, `react`); `node` only when `package.json` exists and no other JS stack matched; `generic` only when nothing matched. Lenses are taken per stack.
- **Test levels**: `none` (no tests required); `essential` (tests required for code in the declared sensitive areas only); `full` (TDD on new code). `## Tests` opens with two lines the profile reads and writes: `Level: <none | essential | full>` and `Sensitive areas: <path or concept>, …` (empty allowed with `none` and `full`).
- **Proposals**: level `essential` when a test runner is configured, else `none`. A runner is configured when: a test dev-dependency (`vitest`, `jest`, `mocha`, `@playwright/test`, `cypress`) in `package.json`, or a `scripts.test` other than npm's stub (`echo "Error: no test specified" && exit 1`); `spec/` with `rspec` in the `Gemfile`, or `test/` with `minitest`; `pytest` configured (`pytest.ini`, `[tool.pytest]` in `pyproject.toml`). Areas proposed from paths that look sensitive (auth, payments, billing, migrations, data import/export). Merge `local`, or `pr` when the repo has a remote and `.github/pull_request_template.md` or `.github/workflows/`.
- **When it asks**: at every start, after the dependency check, before opening or resuming. Before asking, the pieces are also looked up on open `work/*` branches (`git show <branch>:<file>`), since an unmerged profile lives there. Only missing pieces are asked, in one message with a proposal each. In a first run, Step 0's questions (root, guidelines, project lenses) go in the same message. Nothing present is asked again.
- **When it writes**: never on the default branch. A new work: the profile's answers are written with the home, on `work/<slug>` after Step 2, and committed there (`Record the project profile`). A resume: after the switch to the work's branch. Asking writes nothing.
- **What it writes**: the configuration file extended with only the missing keys; `## Tests` with its two lines added to an existing guidelines file, or a guidelines file holding only `## Tests` when there is none and the user accepts it. Step 0's offer of the full template stays an offer, and a declined template is never created.
- **Raise**: at opening, if the request touches a sensitive area (by path or concept), propose a level for this work; on a yes, `tests: <level>` goes in its `STATUS.md`; the project's `## Tests` is untouched. A work without `tests:` uses the project level. In V4 the effective level goes in the slice packet only; the prompts that obey it are V6.
- **`userConfig`** in `.claude-plugin/plugin.json`: `model_top`, `model_mid` (model aliases or IDs for the two tiers, read in V6) and `stack_presets` (`stack=skill` pairs, read in V5): plain strings, no `default`, no `required`, no `options`, no `multiple`. A skill treats an empty value, or one still reading `${user_config.`, as unset.

## Tasks

### T1 — Profile in `/flow:dev` · `critical`
- **What**: in `skills/dev/SKILL.md`: a new section **Profile** (the bullets above, as instructions: where each piece lives, how to read it, including from `work/*` branches, how to propose, one message, when and where it writes, commit with explicit paths); "On start" runs its questions before finding open works; Step 0 folds its questions into the profile's message and its writes into the profile's write; Conventions table: the Stack row becomes `Stacks` with the detection rules above, and the lenses row takes lenses per stack; the `.flow.yml` key list gains `stacks` and notes `stack` read as a one-item list; the sentence saying `.flow.yml` is written only at Step 0 becomes "the profile"; Step 1 gains the raise check (sensitive areas → proposed level → `tests:` on a yes); the slice packet names the work's effective test level (`tests:` or the project's).
- **Files**: `skills/dev/SKILL.md`.
- **Verified**: read-through against this plan's profile bullets and the V4 mandate; `rg -n "stack:" skills/dev/SKILL.md </dev/null` shows only the legacy-read sentence; `claude plugin validate .`.
- **Done**: every bullet of "The profile" has one place in the skill.

### T2 — Templates and `userConfig` · depends on: T1
- **What**: `shared/work.md` STATUS template (repo): `stack:` → `stacks: [<detected>]`, plus `tests: <level, only when raised>` with one line saying it overrides the project level for this work. `skills/dev/development-guidelines.template.md` becomes the short form: `## References` (external guides and skills this project follows), `## Tests` (the two profile lines, then framework, command, what a good test is), `## Gate` (commands), `## Deviations` (where this project departs from its references); delete the rest. `.claude-plugin/plugin.json` gains `userConfig` with the three options, each with `type: string`, `title`, `description` (the description of `stack_presets` gives the pair format).
- **Files**: `shared/work.md`, `skills/dev/development-guidelines.template.md`, `.claude-plugin/plugin.json`.
- **Verified**: `claude plugin validate .` passes with `userConfig` declared; a headless run of a copy of the plugin in the scratchpad, with a scratch skill printing `${user_config.model_mid}` and `--settings` setting it, renders the value (nothing scratch is added to this repo); the template has the four sections.
- **Done**: as verified.

### T3 — Demonstrate and gate · depends on: T1, T2
- **What**: headless on throwaway repos:
  1. a Node repo with `vitest` in `devDependencies`, a remote-less git repo, no `docs/`, no `.flow.yml`: turn 1 `/flow:dev` asking to open a work, the prompt leaving the profile unanswered and saying to stop at the first message → one message asks stacks, test level (with proposed areas), merge style and Step 0's questions; `git status` and the file tree show nothing written. Turn 2 (`--resume`) accepts every proposal and the opening answers, and says to stop after the home is created → on `work/<slug>`: `.flow.yml` with `stacks` and `merge`, the guidelines file with only `## Tests` and its two lines, committed there; the default branch has no new commit. Turn 3, a fresh run on the same branch, asking to resume and stop at the resume summary → its result text asks nothing about stacks, tests or merge.
  2. a repo whose guidelines already carry `Level:` and `Sensitive areas:`, no configuration file: asked only stacks and merge (result text checked for the absence of a test question).
  3. the repo from 1, with `src/auth/` declared sensitive at `essential`: opening a work "change how passwords are reset", the prompt not naming tests or areas and stopping after the opening message → a raise is proposed; turn 2 accepts → `tests: full` in that work's `STATUS.md`; `## Tests` unchanged. Negative: opening "change the footer colour" in a fresh run → no raise proposed.
  4. a repo with `.flow.yml` holding `stack: astro` and nothing else: the stack isn't asked; test level and merge are; after the write `stack: astro` is untouched and no `stacks:` key was added.
  5. a repo with `.devflow.yml` holding `root: notes`: the profile writes into `.devflow.yml`, no `.flow.yml` appears, `root` is still honoured.
  Then the Gate with the narrowing.
- **Files**: none in the repo.
- **Verified**: `git`, `cat`, `jq` over the stream JSON (questions in the result text, files written per turn).
- **Done**: five outcomes as stated, Gate green.

## Order

T1 → T2 → T3. One commit per task, explicit paths.

## Deviations from the mandate

- **The test level lives in two profile lines at the top of `## Tests`** (`Level:`, `Sensitive areas:`), so the profile can read and write it without parsing prose.
- **`userConfig` declares the V5 and V6 options now** (`stack_presets`, `model_top`, `model_mid`), unread until those slices; no defaults, since the runtime check showed defaults aren't substituted.
- **The profile is `/flow:dev`'s only**: `/flow:project` has no stacks, tests or merge.
- **The profile writes only on a work branch**: asked at start, written with the home or after the switch, read from open `work/*` branches too, so it is never committed to the default branch and not asked again while unmerged.
- **Step 0 folds into the profile**: one first-run message, one write.
- **Stale prose left for V8**: `README.md` (`stack:`, "writes it in one case only"), `docs/architecture.md` (configuration keys); the spike's original Outcome is superseded by its runtime check.
- **Unverified, for V6 and the release**: `${user_config.*}` substitution in an installed plugin (observed only through `--settings`), and whether an update opens the configuration dialog for users who never configured.
