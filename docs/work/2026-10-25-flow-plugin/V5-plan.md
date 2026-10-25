# V5 — Architecture documentation: Implementation Plan

> **For agentic workers:** run with `subagent-driven-development`, task by task. Absolute paths always (the shell resets its cwd). Worktree: `/Users/spleenteo/Sites/me/devflow-flow`. Never touch `/Users/spleenteo/Sites/me/devflow` or `~/.claude/` (reading is fine). Read `docs/work/2026-10-25-flow-plugin/lessons.md` first.

**Goal:** a reader who never saw the repo understands, from one document with diagrams, how the plugin is distributed, how its conductors run a work, what they read and write in a project, and where the plugin ends; contributors know how a change becomes a release.

**Spec:** `slices.md` § V5; `docs/development-guidelines.md`; `lessons.md`; decisions in `docs/decisions-log/` (soft dependencies, marketplace without `ref`, no grill-me dependency).

## Global Constraints

- The source of truth is the shipped text: `skills/*/SKILL.md`, `dependencies.md`, `.claude-plugin/*.json`, the decisions. The document describes them; it adds no behaviour and contradicts none. Where it summarises a skill, it links to the file.
- Every statement about Claude Code's own behaviour (marketplaces, scopes, settings precedence, plugin cache, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_SKILL_DIR}`, `--plugin-dir`, skill naming `plugin:skill`) links to an official page under `https://code.claude.com/docs/en/`, checked to exist and to say it (WebFetch), before drafting the section that needs it. Never to `spike-*.md` or anything under `docs/work/`. A claim no page supports is either stated as this repo's rule (no Claude Code claim in it) or dropped.
- Mermaid only (GitHub renders it): `flowchart` or `sequenceDiagram`; no HTML and no angle brackets in labels (write `vVERSION`, `DATE-SLUG`), labels with punctuation in quotes, no styling directives, ≤ ~20 nodes per diagram. One diagram per section; prose around it explains what the diagram can't.
- Agnostic: invented names in examples (`acme-app`), no personal projects or tools.
- English; explicit `git add`; trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`; hashes with `git rev-parse --short HEAD`.

## Review Focus

1. A diagram that shows a step the skill doesn't do (merge, push and tag are the user's, outside `/flow:dev`), or omits a stop: after each definition phase (Step 5), two per slice.
2. A Claude Code claim that's true per the spike but stated nowhere in the docs: drop it or find the page.
3. Stale names: `grill-me` as a dependency, `devflow` as a skill, `.devflow.yml` except as the fallback.
4. The `## Releases` rule must agree with the decision "projects declare the marketplace without `ref`": `main` holds released states only.

---

### Task 1: `docs/architecture.md` (critical)

**Files:** create `docs/architecture.md`.

Sections, each with its diagram:

1. **Distribution** — repo → marketplace `flow` (`.claude-plugin/marketplace.json`) → plugins `flow` (source `./`) and `shaping-skills` (pinned GitHub commit); user-scope install; a project's `.claude/settings.json` declaring the marketplace without `ref` and enabling `flow@flow`; a merge to `main` is a release, tagged `v<.version>`. Links: the decision files, the docs pages on marketplaces, install scopes, settings.
2. **The `/flow:dev` lifecycle** — dependency check → Step 0 (first run) → open or resume → definition phases (frame, shaping, breadboard, slicing, impact, each optional except slicing and impact; each ends with a **stop**, Step 5) → slice loop (plan → review → **stop** → execute → close → **stop**) → closing sequence (Step 6: close the work, `/flow:changelog`, `/flow:archive`, report; each step asks). Merge, push and tag are drawn outside the skill, as the user's action on approval; which dependency skill each phase hands off to; `/flow:project` handing a software action to `/flow:dev`. Taken from `skills/dev/SKILL.md` and `skills/project/SKILL.md` as they are now.
3. **What a project holds** — what the conductors read and write: `docs/work/<date>-<slug>/` (STATUS, slices, plans, lessons), `docs/decisions-log/`, `docs/development-guidelines.md`, `docs/impact-lenses.md`, `docs/CHANGELOG.md`, `docs/work/archived.md` and the walled `docs/work/archive/`, `.version`, `.flow.yml` (with the `.devflow.yml` fallback). Who writes each, who reads each.
4. **Where the plugin ends** — (no mention of `install.sh` or the README: V6 rewrites them) `dependencies.md` and the start/phase checks (never installs); what lands in the plugin cache vs the project; `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_SKILL_DIR}`.

Opening paragraph: what the plugin is in three sentences, and the repo-vs-plugin name (repo `devflow`, plugin `flow`) in one.

**Verify:** first a one-node smoke render (the first run downloads Chromium; if it fails, report BLOCKED, don't skip the check). Then each Mermaid block extracted to `/private/tmp/claude-501/-Users-spleenteo-Sites-me-devflow/6710ec3a-a9a2-4f23-8f29-504e326894bb/scratchpad/v5/` (`mkdir -p` first; absolute paths in every command, no shell variables across calls) and rendered with `npx -y @mermaid-js/mermaid-cli -i <n>.mmd -o <n>.png`, zero errors; the PNG paths listed in the report for the controller's by-eye check; every `code.claude.com` link fetched and the sentence it supports quoted in the report; link check green; old-name grep: `architecture.md` matches only the fallback mention and the repo-name sentence.
**Done:** committed ("Document the plugin's architecture").

### Task 2: `## Releases` in the guidelines

Depends on: T1 (links to it). **Files:** `docs/development-guidelines.md`.

A section after `## Gate`: work on branches; a merge into `main` is a release; `.version` bumped by `/flow:changelog`, tag `v<.version>` on the merge commit; `main` never holds unreleased work (link the decision); develop with `claude --plugin-dir <clone>`, never by adding the marketplace from the clone being edited (a local-path marketplace loads in place: the conductor would edit itself; link the docs page that says a local path isn't copied to the cache, or state it as this repo's rule without a Claude Code claim if no page says it). Link to `architecture.md#distribution`.

**Verify:** link check green; read-through against the decision.
**Done:** committed ("Add the release rules to the guidelines").

### Task 3: Demonstrate V5's Done

Depends on: T1, T2. Controller: open each PNG and check by eye that it reads, matches the section and shows no mangled label; Gate (README excluded); note in `slices.md` ("The Gate during the work") that `architecture.md` adds two allowed matches from V5: the `.devflow.yml` fallback mention and the repo-vs-plugin sentence. Findings go back to T1 as a fix round.
