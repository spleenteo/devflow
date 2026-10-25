# V1 — The plugin skeleton: Implementation Plan

> **For agentic workers:** run with `subagent-driven-development`, task by task. Absolute paths always: the shell resets its cwd to the main checkout. Worktree: `/Users/spleenteo/Sites/me/devflow-flow` (branch `chore/convert-to-plugin`). Never touch `/Users/spleenteo/Sites/me/devflow` (main checkout) or `~/.claude/`.

**Goal:** the repo becomes a marketplace `flow` holding the plugin `flow` (four skills under `skills/`) and a pinned `shaping-skills` entry.

**Architecture:** manifests in `.claude-plugin/`; the plugin's source is the repo root; skills found by the default `skills/` scan. Skills' text unchanged except `name:`.

**Spec:** `slices.md` § V1; `docs/development-guidelines.md`.

## Global Constraints

- No `version` and no `dependencies` in `plugin.json`; no `skills` key.
- `shaping-skills` pinned by `sha` `23e32c1ee2293595906d0d55f44424427afa7bac`.
- English; explicit `git add <paths>`; commit message trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Test configurations and repos live in `/private/tmp/claude-501/-Users-spleenteo-Sites-me-devflow/6710ec3a-a9a2-4f23-8f29-504e326894bb/scratchpad/v1/`, never in the repo.

## Review Focus

1. A `-p` run in an untrusted scratch repo may ignore its `.claude/settings.local.json` (`skillOverrides`): T4 checks that the old skills are really hidden before trusting the demo.
2. `git mv` of a folder that ~/.claude/skills symlinks into: the symlinks point at the main checkout, not the worktree; T2 confirms they still resolve.
3. `shaping-skills` hook: not wired (see T1); the reason must be written where V3 will find it.

---

### Task 1: Manifests

**Files:** create `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`.

- `plugin.json`: `name: "flow"`, `description` (one sentence: conductors for software work and for non-software projects, one slice at a time), `author: {name: "Matteo Papadopoulos"}`, `license: "MIT"`, `homepage` and `repository`: `https://github.com/spleenteo/devflow`.
- `marketplace.json`: `name: "flow"`, `owner: {name: "Matteo Papadopoulos"}`, `description`; plugins:
  - `{name: "flow", source: "./", description}`;
  - `{name: "shaping-skills", description, source: {source: "github", repo: "rjs/shaping-skills", sha: <above>}, skills: ["./shaping", "./breadboarding", "./framing-doc", "./kickoff-doc"]}`. No `hooks`: upstream makes its ripple-check hook opt-in, it needs `jq`, and it interrupts every edit of a `shaping: true` file. The reason is in `## V1 notes for V3` at the end of this plan.

**Verify:** `claude plugin validate /Users/spleenteo/Sites/me/devflow-flow` → "Validation passed with warnings", and the only warnings are the missing `version`.
**Done:** both files, plus this plan file (`V1-plan.md`, with the hook note) and `slices.md` (V1 deviations), committed ("Add the flow plugin and marketplace manifests").

### Task 2: Move the skills (critical)

**Files:** `mkdir skills` first (`git mv` fails into a missing directory), then `git mv` `devflow` → `skills/dev`, `projectflow` → `skills/project`, `devflow-docs` → `skills/changelog`, `devflow-archive` → `skills/archive`; in each `SKILL.md`, `name:` becomes `dev`, `project`, `changelog`, `archive`. Modify `README.md:167,171,175`: the three links point to `skills/dev/lenses.md`, `skills/dev/development-guidelines.template.md`, `skills/dev/decisions-log.md` (link text too).

No other text changes (V2). `install.sh` untouched (V3).

**Verify:** `git status` shows renames (R), not delete+add; `ls -l ~/.claude/skills/devflow` still resolves (main checkout unchanged); `rg -n '^name:' skills/*/SKILL.md` shows the four new names.
**Done:** committed ("Move the skills under skills/ with their plugin names").

### Task 3: Link check in the Gate

**Files:** modify `docs/development-guidelines.md` § Gate: replace the comment line on links with a command that prints every relative Markdown link whose target doesn't exist (outside `docs/work/archive/`; skips `http`, `mailto` and pure `#anchor` links; resolves paths against the linking file's directory; strips `#anchor` from the target). Empty output = green. Portable on macOS: `rg`, `awk`, `dirname`, `test -e` only (no `grep -P`, `realpath -m`, `sed -r`). Links inside fenced code blocks (```) are skipped (templates hold placeholder links, e.g. `skills/changelog/SKILL.md`); the guideline says so in one line. Accepts extra `--glob` exclusions, for the narrowing a work's `slices.md` sets.

**Verify:** run it on the worktree → no output; temporarily break one link in a scratch copy → the command prints it.
**Done:** committed ("Add a link check to the Gate"). Depends on: T2 (it must run on the final layout).

### Task 4: Demonstrate V1's Done

Depends on: T1, T2, T3. Nothing to commit unless a check fails and needs a fix (then the fix goes in the task it belongs to).

1. Isolated install. Every `claude plugin` command carries the full prefix `CLAUDE_CONFIG_DIR=/private/tmp/claude-501/-Users-spleenteo-Sites-me-devflow/6710ec3a-a9a2-4f23-8f29-504e326894bb/scratchpad/v1/cfg` (the shell drops exports between calls; without it the install lands in the real `~/.claude`): `claude plugin marketplace add /Users/spleenteo/Sites/me/devflow-flow`; `claude plugin install flow@flow`; `claude plugin details flow@flow` → Skills (4) `archive, changelog, dev, project`. `claude plugin install shaping-skills@flow`; `claude plugin details shaping-skills@flow` → `breadboarding, framing-doc, kickoff-doc, shaping`.
2. Session demo: scratch repo `<scratch>/v1/repo` (`git init`), `.claude/settings.local.json` with `skillOverrides` `"off"` for `devflow`, `devflow-docs`, `devflow-archive`, `projectflow`. Both passes run `claude -p "ok" --output-format stream-json --verbose` and read the `skills` and `slash_commands` arrays of the `system`/`init` event (not the model's prose). Without the plugin: none of the four old names (if they appear, the override isn't applied in `-p`: report it, don't work around it). With `--plugin-dir /Users/spleenteo/Sites/me/devflow-flow`: `flow:dev`, `flow:project`, `flow:changelog`, `flow:archive` present.
3. Gate, with V1's narrowing (`--glob '!README.md' --glob '!install.sh'` on both the grep and the link check): validate (as T1); old-name grep (the skills' text still matches at V1: record the count); link check green.

**Done:** the outputs of 1–3 pasted into the close report.

## V1 notes for V3

- `shaping-skills` hook not wired: opt-in upstream, needs `jq`, interrupts every edit of a `shaping: true` file. `dependencies.md` says so and links the upstream setup.
