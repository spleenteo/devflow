---
shaping: true
---

# Flow plugin — Slices

The mandate is [`brief.md`](brief.md), as amended by the decisions in [`spike-plugin-loading.md`](spike-plugin-loading.md): soft dependencies (no `dependencies` field), and projects that declare the marketplace without a `ref`, with `main` holding released states only. No frame (technical work), no shaping or breadboard (the shape is the brief; the work changes existing Markdown skills and adds no places).

**How slices are demonstrated.** No session can start in an isolated configuration (not logged in), but `claude -p --plugin-dir <worktree>` runs in the owner's logged-in configuration without registering anything: that's how a slice shows a skill's behaviour. Installation paths are shown with `claude plugin` commands in an isolated `CLAUDE_CONFIG_DIR`, which need no login.

**Old names.** References to `devflow`, `devflow-docs`, `devflow-archive`, `projectflow`, `.devflow.yml` appear today in `devflow/SKILL.md` (21), `projectflow/SKILL.md` (9), `devflow-docs/SKILL.md` (9), `devflow-archive/SKILL.md` (5), `devflow/decisions-log.md` (2), `install.sh` (5), `README.md` (36).

## V1 — The plugin skeleton

**In**
- `.claude-plugin/plugin.json`: `name: flow`, `description`, `author`, `license: MIT`, `homepage`, `repository`. No `version`, no `dependencies`.
- `.claude-plugin/marketplace.json`: `name: flow`, `owner`, `description`; entry `flow` with `source: "./"`; entry `shaping-skills` with a `github` source on `rjs/shaping-skills` pinned by `sha`, listing `./shaping`, `./breadboarding`, `./framing-doc`, `./kickoff-doc` (`project` uses `kickoff-doc`).
- `git mv` the four folders to `skills/dev`, `skills/project`, `skills/changelog`, `skills/archive`; set `name:` in each frontmatter to the folder name. Supporting files (`lenses.md`, `decisions-log.md`, templates) move with their skill.

**Out**: any change to the skills' text beyond `name:` (V2); `install.sh` and README (V6).

**Done**
- `claude plugin validate .` passes; the only warnings are the missing `version`.
- In an isolated configuration: `claude plugin marketplace add <worktree>` then `claude plugin details flow@flow` lists `archive, changelog, dev, project`; `claude plugin install shaping-skills@flow` lists `breadboarding, framing-doc, kickoff-doc, shaping`.
- `claude -p --plugin-dir <worktree> "list the skills of the flow plugin"` names `flow:dev`, `flow:project`, `flow:changelog`, `flow:archive`.

**Gotchas**
- The plugin root is the repo root: `README.md`, `install.sh`, `docs/` are copied into the plugin cache. Harmless; the architecture doc says so (V5).
- The main checkout keeps the old folders on `main`, so the symlinks keep working until the migration.
- Check that `flow` isn't rejected or warned on as a marketplace or plugin name.

## V2 — The rename inside the skills

**In**
- Frontmatter descriptions and triggers (`/flow:dev`, "open the work X", …) in all four skills.
- Cross-references: `dev` invokes `/flow:changelog` and `/flow:archive`; `project` hands off to `/flow:dev`; the lifecycle table and "Relation to" sections.
- Config: `.flow.yml`, read first; `.devflow.yml` read when `.flow.yml` is absent, with a one-line notice. Same keys. The non-default root offered at Step 0 becomes `flow/`.
- References to dependency skills: written so they resolve whether the skill comes from a plugin (`superpowers:writing-plans`) or a personal install (`writing-plans`). Verify how the session lists them before choosing the wording (spike, "Not run", item 3).
- Agnostic: remove Maestro and `<documents_path>` from `project` (home = the folder the user names; inside a documents vault, propose `<vault>/<Name>/`); replace `Cerbaia` with an invented name.

**Out**: README and `install.sh` (V6); new behaviour (V3, V4).

**Done**
- The Gate grep returns nothing outside `docs/work/`, `docs/briefs/`, and the `.devflow.yml` fallback line.
- `claude -p --plugin-dir <worktree>` in a scratch repo: asked to "open a work", the session invokes `flow:dev` and its first message refers to `/flow:changelog` and `/flow:archive` by those names.

**Gotchas**
- `dev` and `project` are kept in sync by hand: every edit to one is checked against the other.
- Examples inside the skills (`/devflow`, `devflow work <slug> merged`) are part of the rename.

## V3 — Soft dependencies

**In**
- `dependencies.md` at the plugin root: one row per dependency (plugin or source, skills it provides, required or optional, which flow and which phase needs it, install commands at user scope and at project scope). superpowers: required for `dev` (`brainstorming`, `writing-plans`, `subagent-driven-development`); `shaping-skills@flow` (`shaping`, `breadboarding`, `framing-doc`, `kickoff-doc`): required for the definition phases of `dev` and `project`; `grill-me`: optional.
- A start check in `dev` and `project`: compare the list with the skills available in the session; report what's missing in one message with the commands; never install; don't block a start whose first phases don't need the missing piece; check again at the phase that needs it.
- `install.sh` reduced to a dependency checker for the terminal, reading the same list, or removed if the start check makes it redundant (decide in the plan, say why).

**Out**: any `dependencies` field in `plugin.json`.

**Done**
- In a scratch repo, `claude -p --plugin-dir <worktree>` with the owner's setup reports no missing dependency.
- The missing case: with the superpowers plugin disabled for that run (`.claude/settings.local.json` in the scratch repo, `false` for it) and a skill list that then lacks it, the start check shows the one-message report with both install commands. If the personal copies still satisfy the check, say so and show the report for `grill-me` instead.
- `dependencies.md` is linked from both skills and from the README (V6).

**Gotchas**
- The owner's machine has personal copies of `brainstorming`, `writing-plans`, `subagent-driven-development` beside the superpowers plugin: the check must count either as present.
- `${CLAUDE_PLUGIN_ROOT}` resolves in plugin skill content; since the plugin is the only install path, the skills can cite `${CLAUDE_PLUGIN_ROOT}/dependencies.md`.

## V4 — Project impact lenses

**In**
- `skills/dev/impact-lenses.template.md`: the `| Lens | Looks for |` table, optional `##` groups, two invented examples.
- `lenses.md`: a "Project lenses" section saying where the file lives (`<root>/impact-lenses.md`), its format, and who reads it.
- `dev/SKILL.md`: Conventions table row; impact packet of the stack-lens subagent (or the single subagent) includes the file; plan review gets a fifth row, **Project lenses**; Step 0 mentions the file and offers the template, never creates it unasked; the slice packet includes it.
- No config key. `project` untouched.

**Out**: the lenses of any real project.

**Done**
- A fixture repo with `docs/impact-lenses.md` holding one lens with a deliberate trap: a `claude -p --plugin-dir <worktree>` run that asks for the impact packet of a one-slice work shows the lens in the subagent prompt and a finding on the trap.
- Without the file, the same run shows no mention of project lenses.

## V5 — Architecture documentation

**In**
- `docs/architecture.md`, Mermaid diagrams GitHub renders, built from the spike's verified facts and the decisions:
  - distribution: repo → marketplace `flow` → plugin `flow` (skills) and `shaping-skills`; user scope install; a project's `.claude/settings.json` declaring the marketplace without `ref` and enabling the plugin; tags on `main`;
  - the `flow:dev` lifecycle: opening, definition phases, slice loop with its two stops, closing sequence, and the hand-offs to `flow:changelog`, `flow:archive` and the dependency skills; `flow:project` hand-off to `flow:dev`;
  - what is read and written in a project (`docs/` as memory, guidelines, project lenses, `.flow.yml`);
  - where the plugin ends: dependencies and the start check; what lands in the plugin cache.
- Linked from the README (V6).

**Done**
- Every diagram renders: `npx -y @mermaid-js/mermaid-cli` turns each block into an SVG without errors, and the rendered SVGs are checked by eye.
- Every behaviour of Claude Code the document states links to the docs page or the spike.

## V6 — README, migration, release discipline

**In**
- Install: `claude plugin marketplace add spleenteo/devflow` + `claude plugin install flow@flow --scope user`; the project snippet (`extraKnownMarketplaces` without `ref`, `enabledPlugins`); what a teammate gets from trust alone and what the start check will ask them to install; the project-level `ref` as an escape hatch, documented as behaviour read from the docs.
- Dependencies (link to `dependencies.md`), project lenses, local development (`claude --plugin-dir .`), the architecture doc link, one sentence on repo `devflow` vs plugin `flow`.
- Migration note: `/devflow` → `/flow:dev` and the other three; `.devflow.yml` → `.flow.yml` (still read); remove `~/.claude/skills/{devflow,devflow-docs,devflow-archive,projectflow}` and duplicate personal copies of the dependency skills.
- Remove the `npx skills add` path and the symlink install.
- `docs/development-guidelines.md`: a `## Releases` section: work on branches; a merge into `main` is a release; tag `v<.version>` on the merge commit.

**Done**
- In a fresh isolated configuration, following the README's commands literally (with the local worktree path in place of `spleenteo/devflow`) ends with `claude plugin details flow@flow` listing the four skills.
- The Gate is green, links included.

## After V6: closing sequence

`devflow-docs` from the main checkout (the frozen conductor) creates `docs/CHANGELOG.md` and `.version` (`0.1.0`); `devflow-archive` archives the work. Merge and tag `v0.1.0` only on approval. Then the owner's machine migrates per the README.
