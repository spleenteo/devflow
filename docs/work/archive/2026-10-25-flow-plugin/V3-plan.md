# V3 — Soft dependencies: Implementation Plan

> **For agentic workers:** run with `subagent-driven-development`, task by task. Absolute paths always (the shell resets its cwd). Worktree: `/Users/spleenteo/Sites/me/devflow-flow`. Never touch `/Users/spleenteo/Sites/me/devflow` or `~/.claude/` (reading is fine). Read `docs/work/2026-10-25-flow-plugin/lessons.md` first.

**Goal:** the plugin declares what it needs in one file, both conductors check it at start and at the phase that needs it, and never install anything.

**Spec:** `slices.md` § V3; decision `docs/decisions-log/2026-10-25-soft-dependencies.md`; `docs/development-guidelines.md`; `lessons.md`.

## Global Constraints

- No `dependencies` field in `plugin.json`. Nothing in the plugin installs: it prints commands.
- Dependencies (name → plugin form → required/optional → who needs it):

  | Source | Install as | Skills | Need | Used by |
  |---|---|---|---|---|
  | superpowers | `superpowers@claude-plugins-official` | `brainstorming` | required | frame, both flows |
  | | | `writing-plans`, `subagent-driven-development` | required | `dev` slice loop |
  | shaping-skills | `shaping-skills@flow` | `shaping`, `breadboarding`, `framing-doc` | required for the definition phases | both flows |
  | | | `kickoff-doc` | required for its phase | `project` only |
  | Matt Pocock's skills | `mattpocock-skills@mattpocock` (marketplace `mattpocock/skills`), or the single skill with `npx skills add mattpocock/skills -s grill-me` | `grill-me` | optional | both flows |
- A dependency is present when a skill listed in the session has its name, or its segment after `:` equals it (`superpowers:writing-plans` and a personal `writing-plans` both count).
- Install commands, both scopes, flags checked against `claude plugin install --help` and `claude plugin marketplace add --help`: user scope `--scope user`, project scope `--scope project` (shared with the team). Where the marketplace isn't known by default, a `claude plugin marketplace add <source>` line comes first, with the same `--scope`: `flow` from `spleenteo/devflow`, `mattpocock` from `mattpocock/skills`. `grill-me` shows the plugin route at both scopes plus the `npx` alternative. Where each scope writes (project: `.claude/settings.json`; `npx` without `-g`: the project's skills folder) is either linked to the docs page that says it or verified in T4.
- The `shaping-skills` hook stays unwired (V1 note: opt-in upstream, needs `jq`, interrupts every edit of a `shaping: true` file); `dependencies.md` says so and links the upstream setup.
- English; explicit `git add`; trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`; print hashes with `git rev-parse --short HEAD`.

## Review Focus

0. A fresh repo: the dependency check runs before `dev`'s Step 0, so nothing is created before the report.
1. A user with every dependency as a personal skill (bare names, no plugin): nothing is reported missing.
2. A start whose first phase doesn't need the missing dependency (resume at `execute` without `grill-me`): the report is one message and the work goes on.
3. A missing required dependency at the phase that needs it: stop that phase with the commands, don't improvise its job.
4. `${CLAUDE_PLUGIN_ROOT}` unexpanded in loaded skill text: T4 checks it in the Skill tool result of the stream-json, not in the model's prose; if it doesn't expand, T2's fix is `${CLAUDE_SKILL_DIR}/../../dependencies.md`.

---

### Task 1: `dependencies.md`

**Files:** create `dependencies.md` at the repo root (the plugin root).

One table per the Global Constraints, then per source: what it provides, install at user scope, install at project scope, and the notes (shaping-skills: the hook not wired and why, upstream link `https://github.com/rjs/shaping-skills`; grill-me: the plugin route brings 27 skills, the `npx` route one, `-g` for user scope). A closing line: how the conductors use this file (start check, phase check, never install).

Also: the Naming rule in `docs/development-guidelines.md` says `grill-me` stays bare because the presence rule covers both installs, not because it has no plugin.

**Verify:** every command's flags exist in the `--help` output; `claude plugin validate .` passes as before; link check green.
**Done:** committed with `V3-plan.md`, the `slices.md` deviations and `STATUS.md` ("Declare the plugin's dependencies").

### Task 2: The start and phase checks in `dev` and `project` (critical)

Depends on: T1. **Files:** `skills/dev/SKILL.md`, `skills/project/SKILL.md`.

Same section in both; the phase checks differ per skill:

- A section `## Dependencies`, placed before `## Step 0` in `dev` and before `## On start: open or resume` in `project`. It runs first on every invocation, before Step 0 and before anything is written: the list lives in `${CLAUDE_PLUGIN_ROOT}/dependencies.md` (also a relative Markdown link `../../dependencies.md`, for readers of the repo). Read it, compare with the skills listed in the session (presence rule above). Missing ones: one message, required first, each with its two install commands and the phase that needs it; never install; don't block a start whose next phase doesn't need what's missing.
- `## On start` (and Step 0 in `dev`): one line, the dependency check has already run.
- The phase check, one sentence where a phase invokes a dependency: if it isn't listed, stop that phase and give its commands from `dependencies.md`. `dev`: the Step 3 table (~:168-171), `grill-me` (~:199), `step: plan` (~:225), `step: execute` (~:248). `project`: the Step 3 table including `kickoff-doc` (~:135-138), `grill-me` (~:168, ~:213). `project`'s `plan` and `execute` invoke nothing: no check there.
- Drop the dependency wording from any other place only if it now contradicts the section. Nothing else changes.

**Verify:** read-through: the two `## Dependencies` sections word-identical; `rg -n 'dependencies.md' skills/dev skills/project . </dev/null` shows the link in both; Gate's old-name grep unchanged.
**Done:** committed ("Check dependencies at start and at the phase that needs them").

### Task 3: `install.sh` as a dependency checker

Depends on: T1. **Files:** `install.sh`.

Rewrite: no symlinks, no installs, no prompts. Reads the skill names and install lines from `dependencies.md` (one parser, `awk` on the table); checks each skill: its plugin (the "Install as" id) among the `"id"` lines with `"enabled": true` of `claude plugin list --json` (grep/awk, no `jq`), if `claude` is present; else `~/.claude/skills/<name>` or `./.claude/skills/<name>`; prints `ok` / `missing` per skill with the user-scope command, exit 1 if a required one is missing. Keeps `--help`. If the start check makes it redundant (a reliable parser takes more than ~60 lines for what the session already reports), remove `install.sh` instead and record the deviation in `slices.md` in those terms.

**Verify:** `bash -n install.sh`; `shellcheck` if installed; run it on the owner's machine → all `ok`, exit 0; with `HOME` pointed at an empty scratch dir and `PATH` without `claude` → required ones `missing`, exit 1. No old names in it.
**Done:** committed ("Turn install.sh into a dependency checker").

### Task 4: Demonstrate V3's Done

Depends on: T1–T3. Verification only. Scratch `S=/private/tmp/claude-501/-Users-spleenteo-Sites-me-devflow/6710ec3a-a9a2-4f23-8f29-504e326894bb/scratchpad/v3`, repo `$S/repo` (`git init`), runs with `--plugin-dir /Users/spleenteo/Sites/me/devflow-flow`, prompt "Open the work dep-test in this repo. Stop right after the dependency check, before writing any file."

1. Owner's setup (old conductors hidden by `skillOverrides`): no dependency reported missing.
2. Dependencies off: `.claude/settings.local.json` keeps step 1's overrides for the old conductors and adds `enabledPlugins` `"superpowers@claude-plugins-official": false` and `skillOverrides` `"off"` for the bare personal `brainstorming`, `writing-plans`, `subagent-driven-development` and `grill-me`; confirm in the `init` event that none of them is listed. Expected: one message naming superpowers (required) and `grill-me` (optional), each with both install commands; shaping skills not reported.
3. `${CLAUDE_PLUGIN_ROOT}` arrives expanded in the Skill tool result (stream-json or session transcript, read-only) and the path exists; `find $S/repo -path '*/.git' -prune -o -newer $S/repo/.claude/settings.local.json -print` lists nothing (an empty `docs/work/` would not show in `git status`).
4. Unless T1 linked the docs page: in a scratch repo, `claude plugin marketplace add` and `install` with `--scope project` under `CLAUDE_CONFIG_DIR=$S/cfg` write `.claude/settings.json`.
5. Gate with V3's narrowing (README excluded; `install.sh` included again).

**Done:** outputs in the task report, then into the close narrative.
