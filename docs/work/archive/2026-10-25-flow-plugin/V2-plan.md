# V2 — The rename inside the skills: Implementation Plan

> **For agentic workers:** run with `subagent-driven-development`, task by task. Absolute paths always (the shell resets its cwd). Worktree: `/Users/spleenteo/Sites/me/devflow-flow`. Never touch `/Users/spleenteo/Sites/me/devflow` or `~/.claude/`. Read `docs/work/2026-10-25-flow-plugin/lessons.md` first.

**Goal:** the four skills speak of themselves as the `flow` plugin: names, triggers, cross-references, config, supporting-file paths, no personal names.

**Spec:** `slices.md` § V2 (with its deviations); `docs/development-guidelines.md`; `lessons.md`. Review of the first draft applied.

## Global Constraints

- Self-reference: "this skill" or `/flow:<name>`; the family is "the flow". Headings: `# Flow: dev`, `# Flow: project`, `# Flow: changelog`, `# Flow: archive`. `## Relation to devflow` → `## Relation to /flow:dev`. Every other mention of a sibling skill (`devflow`, `projectflow`, `devflow-docs`, `devflow-archive`, in prose or in tables, including the lifecycle table's Skill column) becomes `/flow:<name>`.
- Triggers in `description:`: `/flow:dev`, `/flow:project`, `/flow:changelog`, `/flow:archive` replace the slash names; the natural-language triggers stay, except "update docs", dropped from `changelog`.
- Config fallback sentence, verbatim, in `dev`, `changelog`, `archive`: *"Configuration lives in `.flow.yml` at the project root. If it's absent and a `.devflow.yml` exists, read that instead: same keys."* Only `dev` adds: *"When it reads `.devflow.yml`, say so once in the session and suggest renaming it."*
- Supporting files: `${CLAUDE_SKILL_DIR}/<file>` (dev: `lenses.md`, `decisions-log.md`, `development-guidelines.template.md`; project: `constraints.template.md`, `decisions.md`). Where a subagent receives one, the packet says "pass the expanded absolute path".
- Dependency skills, plugin form in brackets at their first mention in each skill, bare afterwards — unless T0 rules otherwise:

  | Bare | Plugin form |
  |---|---|
  | `brainstorming`, `writing-plans`, `subagent-driven-development` | `superpowers:<name>` |
  | `shaping`, `breadboarding`, `framing-doc`, `kickoff-doc` | `shaping-skills:<name>` |
  | `grill-me` | none (stays bare) |
- Lifecycle table Owner column: "the `flow` plugin" instead of "this repo"; external ones keep their owner.
- Nothing else in the text changes: no new behaviour (V3, V4), no rewording beyond the rename.
- English; explicit `git add`; trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`; print hashes with `git rev-parse --short HEAD`.

**Allowed old-name matches after V2** (recorded as a deviation in `slices.md`; the Gate comment lists them): the fallback sentence in `dev`, `changelog`, `archive`; `dev`'s notice; Step 0's condition and `ls` in `dev`; the old-phrase notes ("devflow work … merged") in `dev` and `project`; `spleenteo/devflow`.

## Review Focus

1. A trigger list that loses a phrase users type today ("open the work X", "resume X", "next slice").
2. Step 0 rerunning on a repo that has only `.devflow.yml`: its condition and `ls` must name both files.
3. Old phrase "devflow work `<slug>` merged" in existing project plans must still be recognised by `project`.
4. A subagent that reads a raw `SKILL.md` sees `${CLAUDE_SKILL_DIR}` unexpanded: packets pass the expanded path, never "read SKILL.md".

---

### Task 0: How a session resolves dependency names

Before any text changes. Scratch: `S=/private/tmp/claude-501/-Users-spleenteo-Sites-me-devflow/6710ec3a-a9a2-4f23-8f29-504e326894bb/scratchpad/v2`; repo `$S/repo` (`git init`) with `.claude/settings.local.json`: `skillOverrides` `"off"` for `devflow`, `devflow-docs`, `devflow-archive`, `projectflow`, `brainstorming`, `writing-plans`, `subagent-driven-development`. Owner's configuration, `claude -p "<prompt>" --output-format stream-json --verbose` from `$S/repo`; read the JSON events.

1. Is `superpowers:writing-plans` in the `init` event's `skills` array, and bare `writing-plans` absent?
2. Prompt "Invoke the writing-plans skill, then stop without doing anything else." → which skill does the Skill `tool_use` name?

**Ruling it produces** (in the report): if (1) yes and (2) names `superpowers:writing-plans`, the bracket wording above stands; if (2) fails, every dependency is cited by its plugin form in full (bare name in brackets for personal installs). Either way, update the guidelines' Naming rule to match and commit it with the report's one-line outcome ("Settle how skills cite their dependencies").

### Task 1: `dev` and its supporting files (critical)

Depends on: T0. **Files:** `skills/dev/SKILL.md`, `skills/dev/decisions-log.md`, `skills/dev/development-guidelines.template.md`.

Apply the Global Constraints and T0's ruling. Specifics: `.devflow.yml` → `.flow.yml` throughout, plus the fallback sentence and notice at the Conventions paragraph (`:43`); Step 0 (`:72`, `:75`): "no `docs/work/`, no `.flow.yml` and no `.devflow.yml`", `ls` lists both; the non-default root option becomes a top-level `flow/` folder with `.flow.yml` `root: flow`; closing sequence invokes `/flow:changelog` and `/flow:archive`; `:304` names `/flow:project` and gives the plan-row phrase as *"flow:dev work `<slug>` merged"*, noting that the older *"devflow work … merged"* means the same. `decisions-log.md:71-72` reader table → `/flow:changelog`, `/flow:archive`; `:16` → "`/flow:dev` asks". Template `:3` → "`/flow:dev` passes this file…".

**Verify:** `rg -n -i '\bdevflow\b|devflow-(docs|archive)|projectflow|\.devflow\.yml' /Users/spleenteo/Sites/me/devflow-flow/skills/dev </dev/null` prints exactly: the fallback sentence, the notice, Step 0's condition, Step 0's `ls`, the old-phrase note. `rg -n 'next to this skill' /Users/spleenteo/Sites/me/devflow-flow/skills/dev </dev/null` prints nothing.
**Done:** committed ("Rename the dev skill's text to the flow plugin").

### Task 2: `project` and `decisions.md` (critical)

Depends on: T1. **Files:** `skills/project/SKILL.md`, `skills/project/decisions.md`.

Apply the Global Constraints and T0's ruling. Specifics: Home row (`:33`) and opening question 3 (`:80`): the folder the user names at opening; inside a documents vault, propose `<vault>/<Name>/`; no tool name, no path variable. Resume example (`:62`): an invented project name (`Kitchen-renovation`). Hand-off (`:24`, `:216`, `:244`): a software action is *"flow:dev work `<slug>` in `<repo>` merged"*, opened with `/flow:dev`; rows written as *"devflow work … merged"* are read the same. Self-references (`:10`, `:24`, `:76`, `:280`) per the Global Constraints. `## Relation to /flow:dev`. `decisions.md:14` → "`/flow:project` asks".

**Verify:** the same grep on `/Users/spleenteo/Sites/me/devflow-flow/skills/project` prints only the old-phrase note; the personal tool, path variable and project name cited in `slices.md` (V2 Done) appear nowhere in `skills/project`; a read-through confirms `project`'s hand-off phrase and Relation section match `dev:304`.
**Done:** committed ("Rename the project skill's text to the flow plugin").

### Task 3: `changelog` and `archive`

Depends on: T1. **Files:** `skills/changelog/SKILL.md`, `skills/archive/SKILL.md`.

Apply the Global Constraints. Specifics: changelog `:3` triggers without "update docs"; `:16-17` and `:25` name `/flow:dev`; `:27`, `:128`, `:132` → `/flow:changelog`, `/flow:archive`; `:37` the fallback sentence. Archive `:3`, `:8`, `:82` likewise; `:60` the `archived.md` header text says "Updated by `/flow:archive`"; the fallback sentence where it reads `root` (`:8`).

**Verify:** the grep on both folders prints only the two fallback sentences.
**Done:** committed ("Rename the changelog and archive skills' text").

### Task 4: Demonstrate V2's Done

Depends on: T1–T3. Verification only. Same scratch repo as T0 (overrides still on). Runs add `--plugin-dir /Users/spleenteo/Sites/me/devflow-flow`.

1. Prompt "Open the work rename-test in this repo. Stop right after loading the skill, before writing any file." → the `init` event's `skills` contains `flow:dev` and not `devflow`; the Skill `tool_use` names `flow:dev`; the loaded skill text (next events; if not in the stream, the session's transcript `.jsonl` under `~/.claude/projects/`, read-only) contains `/flow:changelog`, `/flow:archive`, and an absolute path ending in `skills/dev/lenses.md` that exists (`test -e`). Check `git -C $S/repo status` shows no file written.
2. Gate from the repo root with V2's narrowing (README, install.sh excluded): validate; old-name grep prints only the allowed matches listed above; link check empty.

**Done:** outputs in the task report, then into the close narrative.
