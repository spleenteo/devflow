# Work 1 — Turn devflow into the `flow` plugin, with project impact lenses

Open a work in this repo: turn the skill set into a Claude Code plugin named **`flow`**,
installable from GitHub, and add support for project-level impact lenses.
Everything the work produces (skills, docs, README, commit messages, work documents) is in English.
Nothing in the repo names or assumes a specific user project or personal tool: the plugin is for anyone.

## Why

The skills are used across several projects and keep improving here. With a plugin:

- a teammate who clones a project that uses the flow gets it after trusting the folder, without
  installing it by hand (the project's `.claude/settings.json` declares the marketplace and enables
  the plugin);
- each machine runs one tagged version, pinned once at user scope; upgrading is one edit, visible
  and reversible;
- the plugin is developed in this repo, and users receive tagged versions only.

Each project's specifics (lenses, guidelines) stay in the project's repo. The plugin brings the method.

The plugin is the first of a family: `flow` is the namespace, and today it ships two conductors,
`/flow:dev` (software, today's `devflow`) and `/flow:project` (non-software, today's `projectflow`).
Future extensions (for example documentation or design) join the same namespace as new skills.

## What must come out

1. **Plugin and marketplace in the same repo**: `.claude-plugin/plugin.json` (name `flow`, with
   `description` and `author`, **no `version`**) and `.claude-plugin/marketplace.json`, with the
   plugin sourced from the repo root (`./`). Marketplace name: `flow` unless the spike finds a reason
   against it (plugin id `flow@flow`).
2. **Layout and rename.** The skills move to `skills/<name>/SKILL.md` with `name:` equal to the folder,
   so no `skills` key is needed:

   | Today | Folder | Command |
   |---|---|---|
   | `devflow/` | `skills/dev/` | `/flow:dev` |
   | `projectflow/` | `skills/project/` | `/flow:project` |
   | `devflow-docs/` | `skills/changelog/` | `/flow:changelog` (`flow:docs` stays reserved for the future documentation extension) |
   | `devflow-archive/` | `skills/archive/` | `/flow:archive` |

   Applied everywhere: frontmatter, triggers, cross-references between skills, README, docs.
   `/flow:<skill>` is the canonical form everywhere it's written (the bare name also works when no
   other command claims it; the docs don't rely on that).
   The config file becomes `.flow.yml`; the skills read `.devflow.yml` when `.flow.yml` is absent and
   say so in one line. The non-default root offered at first run becomes `flow/` instead of `devflow/`.
   Paths written into projects (`docs/work/`, `docs/decisions-log/`, `docs/development-guidelines.md`,
   `docs/CHANGELOG.md`, `.version`) don't change.
   References to personal tools and projects are removed: `projectflow` names Maestro and
   `<documents_path>` (`projectflow/SKILL.md:33`, `:80`, `README.md:98`) and a real project in an
   example (`projectflow/SKILL.md:62`). The home becomes "the folder the user names at opening";
   examples use invented names.
3. **The plugin is the only install path.** The symlink install goes, and so does `npx skills add`
   (a personal install would register bare `/dev`, `/project`, `/archive`). `install.sh` stays only as
   a dependency checker. Outside a repo (always the case for `/flow:project`) the plugin is installed
   at user scope: `claude plugin marketplace add spleenteo/devflow` and
   `claude plugin install flow@flow --scope user`.
4. **Dependencies**, as far as the platform allows (verified facts below).
   > **Superseded on 2026-10-25** by soft dependencies: no `dependencies` field; a list next to the
   > skills and a check at start that invites the user to install what's missing, at user or project
   > scope. See [`spike-plugin-loading.md`](spike-plugin-loading.md#dependencies). The text below is
   > the original mandate.
   - superpowers (`brainstorming`, `writing-plans`, `subagent-driven-development`): a `dependencies`
     entry on `claude-plugins-official`, plus `allowCrossMarketplaceDependenciesOn` in `marketplace.json`;
   - `grill-me`: it ships in the `mattpocock-skills` plugin (marketplace `mattpocock`, MIT): same
     mechanism, accepting that the dependency brings its other skills along;
   - `shaping`, `breadboarding`, `framing-doc` (rjs/shaping-skills): not a plugin, and the repo has no
     license, so they are **not** copied in. Option to test: an entry in our `marketplace.json` with a
     `github` source pinned to a commit and the skill folders listed (with no `plugin.json` there, the
     entry is the manifest), declared as a same-marketplace dependency. If it doesn't work, the README
     says how to install them by hand.
   The skills cite their dependencies by bare name today (`writing-plans`); as plugins they are
   `superpowers:writing-plans`, `mattpocock-skills:grill-me`. The references must resolve.
5. **Project lenses by convention**: if the project has `<root>/impact-lenses.md` (`<root>` is the
   configured root, `docs/` by default, next to `development-guidelines.md`):
   - format: the same `| Lens | Looks for |` table as `lenses.md`, optionally grouped under `##` headings;
   - impact: the file goes into the packet of the stack-lens subagent (or the single subagent on a
     one-slice work);
   - plan review: a fifth row, **Project lenses**, checks the plan against them;
   - Step 0 mentions the file and offers a template (`impact-lenses.template.md` next to
     `lenses.md`), never creates it unasked; no config key.
   Without the file, everything works as today. Out of scope for `/flow:project`.
6. **Architecture documentation** in `docs/architecture.md`, with Mermaid diagrams GitHub renders,
   written from the spike's verified facts. At least:
   - marketplace → plugin → skills → dependencies, and how a machine pins a tag and a project enables
     the plugin;
   - the `/flow:dev` lifecycle (opening, definition phases, slice loop with its two stops, closing
     sequence) and which skill hands off to which;
   - what is read and written on disk in the project (`docs/` as memory, project lenses, guidelines);
   - where the plugin ends and the external dependencies begin; what lands in the plugin cache.
7. **README**: Install (plugin at user scope with the tag; the project `settings.json` snippet;
   what a teammate gets from trust alone and what they still install); project lenses; developing
   the plugin locally (`claude --plugin-dir .`, which replaces the installed `flow` for that session);
   a link to the architecture doc; one sentence on why the repo is `devflow` and the plugin `flow`;
   a migration note for current users (`/devflow` → `/flow:dev`, `.devflow.yml` → `.flow.yml`,
   removing the old symlinks and duplicate personal copies of the dependency skills).
8. **Versioning**: this repo adopts its own conventions. `.version` and `docs/CHANGELOG.md` are
   written by `/flow:changelog` in the closing sequence (current version: none; first release `0.1.0`).
   The git tag is `v<.version>`. `plugin.json` carries no `version`, so a tag can never disagree with
   the manifest.
9. **First tag `v0.1.0`**, published only on approval, after the merge.

## Facts from the official Claude Code documentation (checked on 2026-10-25)

- `plugin.json` requires only `name`; `marketplace.json` requires `name`, `owner.name` and
  `plugins[]`, with `name` and `source` per entry. `"./"` as source means the marketplace root.
- Skills: in a plugin, `name:` in the frontmatter sets the last segment (`/flow:dev`); the bare
  `/dev` also works unless another command uses it, and collisions are silent.
- A project with `extraKnownMarketplaces` (github source) and `enabledPlugins` in its
  `.claude/settings.json`: after the folder is trusted, Claude Code registers the marketplace. A
  relative-source plugin loads without `claude plugin install`; an external-source one doesn't.
- Marketplaces are registered per user, one per name: a marketplace added in one project is
  available in every project.
- `ref` (branch or tag) pins a `github` marketplace source. `version` in `plugin.json`, if present,
  keeps users on that string however many commits follow; without it, a relative-path plugin is
  versioned by commit SHA. Third-party marketplaces don't update by themselves without `autoUpdate: true`.
- `dependencies` in `plugin.json`: `"name"`, `"name@marketplace"` or `{name, marketplace, version}`
  (semver range resolved on `<plugin>--v<version>` tags). Missing dependencies install on
  `claude plugin install`, `/reload-plugins`, marketplace auto-update and `marketplace add`; trusting
  a repo is not in the list. A dependency from another marketplace installs only if that marketplace
  is in `allowCrossMarketplaceDependenciesOn` of the root `marketplace.json`.
- `${CLAUDE_SKILL_DIR}` resolves to the skill's folder at every install level; `${CLAUDE_PLUGIN_ROOT}`
  points at the versioned cache and changes on every update.
- `claude plugin validate` warns on a missing `version`, and on a `CLAUDE.md` at the plugin root.

## Spike, before slicing

`spike-plugin-loading.md` in the work's folder, with a throwaway test repo:

1. The relative-source plugin loads with trust only, no install, from a repo pointing at this branch.
2. **Pinning**: the marketplace declared at user scope with `ref: <tag A>` and in a project with
   `ref: <tag B>` (or with no `ref`): which version loads in that project, and what changes on switching.
   The design is user-scope pinning; the spike says what the project's declaration should contain so a
   teammate without the user-scope pin still gets a tagged version.
3. `skills/dev/SKILL.md` with `name: dev` → `/flow:dev`; bare-name collisions.
4. Dependencies: does superpowers install when `flow` is first loaded from a trusted repo, or only after
   `/reload-plugins`? Does the `github`-source entry for rjs/shaping-skills work as a same-marketplace
   dependency, pinned to a commit?
5. Bare-name references to dependency skills (`writing-plans`) resolve to the plugin ones.
6. `claude plugin validate .` (and with `--strict`: which warnings fail it).
7. A machine with the old symlinks and the plugin both active: what shows up, and the clean-up steps.

The outcomes settle the open points above; slicing starts after.

## How to run this work

- **The conductor must not edit itself.** `~/.claude/skills/devflow` is a symlink into this clone.
  Run the work from a worktree (`git worktree add ../devflow-flow chore/convert-to-plugin`); the main
  checkout stays on `main`, so the symlinks keep serving the current conductor. Nothing in
  `~/.claude/skills` changes until the migration, after the merge.
- **Opening**: technical work; the spike runs before slicing, a stated deviation from the usual
  spike-inside-the-loop.
- **Step 0**: accept the guidelines template and write a `## Gate`:
  `claude plugin validate .`; a grep for the old names
  (`rg -n '/devflow|devflow-docs|devflow-archive|/projectflow|\.devflow\.yml|Maestro' --glob '!docs/work/**' --glob '!docs/CHANGELOG.md'`)
  that returns only the migration note and the fallback read; a Markdown link check. No `CLAUDE.md`
  at the repo root.
- **Impact**: the stack is `generic`. Ad-hoc lenses: names and namespace (every old name, trigger,
  frontmatter); paths that change by install mode (`${CLAUDE_SKILL_DIR}`, plugin cache); references
  between skills and to dependencies; README and docs drift.
- `dev` and `project` share their skeleton and are kept in sync by hand: every change to one is a
  question for the other.

## Out of scope

- The lenses of any specific project (each project writes its own).
- Changes to the flow's phases, stops or documents. The rename changes names; project lenses add one input.
- Renaming the GitHub repository.
- The decisions-log format (Work 2).

## Constraints

Dedicated branch; no merge into `main` and no published tag without explicit approval.

Entry: technical work (for whoever uses the flow the outcome is clear: they install the plugin,
call `/flow:dev` and `/flow:project`, and project lenses are read), so the spike, then straight to slicing.
