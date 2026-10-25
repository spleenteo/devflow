# flow

A Claude Code plugin that runs a piece of work from idea to done, one slice at a time, and keeps its state on disk so a work resumes days later in a new session. `/flow:dev` takes software work in a repository to a branch ready to merge; `/flow:project` runs a project that people carry out over weeks or months, in a folder outside any repo. The repository is named `devflow`; the plugin and its marketplace are both named `flow`.

Shaping produces the slices. The detailed plan of each slice is written right before it starts, so it carries what the previous slices taught. Plans are reviewed by a fresh head, and the flow returns to you at two points per slice. `/flow:dev` works with any stack and adds nothing to your project's `CLAUDE.md`.

How it fits together: [`docs/architecture.md`](docs/architecture.md).

## Install

Once per machine, at user scope, so the plugin is available in every project ([install scopes](https://code.claude.com/docs/en/plugins/install#choose-an-install-scope)):

```bash
claude plugin marketplace add spleenteo/devflow --scope user
claude plugin install flow@flow --scope user
```

Recent versions also accept one step that adds the marketplace and installs the plugin. The session form below needs Claude Code 2.1.275 or later; the shell form, `claude plugin install flow --marketplace spleenteo/devflow`, needs 2.1.292 or later ([add a marketplace and install in one command](https://code.claude.com/docs/en/plugins/install#add-a-marketplace-and-install-in-one-command)).

```text
/plugin install flow --marketplace spleenteo/devflow
```

**Dependencies.** The flow hands the thinking, planning and execution to skills from two other plugins, superpowers and shaping-skills. It checks for them but never installs them. Run `/flow:dev` in any directory: the start check lists what's missing, with the commands to run. From a clone, `./install.sh` does the same check from the shell and installs nothing:

```bash
git clone https://github.com/spleenteo/devflow.git flow
flow/install.sh
```

The list, with the commands at user and project scope: [`dependencies.md`](dependencies.md).

## Use in a project

To give a team the flow, commit this `.claude/settings.json` in the project. It declares the marketplace, with no `ref`, and enables the plugin:

```json
{
  "extraKnownMarketplaces": {
    "flow": { "source": { "source": "github", "repo": "spleenteo/devflow" } }
  },
  "enabledPlugins": { "flow@flow": true }
}
```

What a teammate gets, from the docs:

- The marketplace is registered only after they accept the workspace trust dialog for the folder ([`extraKnownMarketplaces`](https://code.claude.com/docs/en/settings-reference#extraknownmarketplaces)).
- A plugin enabled only in project settings is not fetched onto a machine where it isn't installed, unless its marketplace entry has a relative-path source, as `flow` does ([enabled in project settings but not installed](https://code.claude.com/docs/en/plugins/loading#enabled-in-project-settings-but-not-installed)). So trust alone brings `flow`.
- The dependencies are not enabled by the file. The first `/flow:dev` tells the teammate what to install.

Leave out `ref`: whatever is on `main` of this repository is a release. A project that must stay behind can set `"ref": "v0.4.0"` (a branch or tag) in its `source`. The entry from the highest-precedence settings file is used whole, and project settings sit above user settings ([`extraKnownMarketplaces`](https://code.claude.com/docs/en/settings-reference#extraknownmarketplaces), [precedence](https://code.claude.com/docs/en/settings#settings-precedence)), so that project's `ref` wins. This is documented behaviour, not yet tried on a real project. Why no `ref` by default: [projects declare the marketplace without a ref](docs/decisions-log/2026-10-25-projects-declare-marketplace-without-ref.md).

## Usage

Plugin skills are invoked as `/plugin-name:skill-name` ([skills](https://code.claude.com/docs/en/skills)).

| Skill | What it does |
|---|---|
| [`/flow:dev`](skills/dev/SKILL.md) | Software work in a repo: opening, definition phases (frame, shaping, breadboard, slicing, impact), then a plan, review, execute and close loop per slice |
| [`/flow:project`](skills/project/SKILL.md) | A project that people carry out: appetite, a reality check in place of impact, plans of actions, a report at the end |
| [`/flow:changelog`](skills/changelog/SKILL.md) | The changelog entry and the `.version` bump for a finished work, on its branch |
| [`/flow:archive`](skills/archive/SKILL.md) | Moves a finished work to `docs/work/archive/` and repairs the links |

Open Claude Code inside the project and type `/flow:dev`, or say "resume mobile-menu". A work goes like this:

- **Opening.** One message with five questions and the answers it proposes: what to build, a code name, source material, whether the outcome is already clear in one sentence (technical work skips to slicing; product work starts from the frame), whether the problem is clear.
- **Definition.** Each phase writes one document in `docs/work/<date>-<slug>/`, commits, and stops. Impact has two subagents read the slices against the real code and report in one ranked message.
- **Slice loop.** Plan, review by a fresh subagent, **first stop**; execute, close with the Done and the gate verified, lessons written, **second stop**: "V3 closed. Plan V4, or stop here?"
- **Resume.** It reloads the standing documents (`STATUS.md`, the frame's criterion, the guidelines that apply, `lessons.md`, the matching decisions, the current plan), says what it reloaded, and continues.
- **Close.** It asks before each step: close the work, `/flow:changelog`, `/flow:archive`, then reports that the branch is ready to merge. It doesn't merge, push or tag.

A bugfix is a one-slice work: straight to slicing, impact if it touches more than one file, the loop once.

**From `/flow:project` to `/flow:dev`.** When an action of a project is software, its plan row reads "flow:dev work `<slug>` in `<repo>` merged". You open that work with `/flow:dev` in its repo, in its own session, and the row closes when it is merged.

## What lands in a project

Markdown only, versioned with the code, under `docs/` by default:

```
.version
docs/
  CHANGELOG.md
  development-guidelines.md
  impact-lenses.md
  decisions-log/
    2026-09-03-server-side-locale-detection.md
  work/
    archived.md
    2026-09-02-mobile-menu/
      STATUS.md
      slices.md
      lessons.md
      V1-plan.md
    archive/
```

`docs/` is the project's memory: what shipped, why, and how code is written here. `/flow:dev` searches it at the opening of every work. The plugin's own files (skills, templates, lenses, `dependencies.md`) stay in the plugin copy; a template reaches the project only when you accept it. Who writes and reads each path: [What a project holds](docs/architecture.md#what-a-project-holds).

## Project lenses

`docs/impact-lenses.md` holds the project's own lenses: what a change here can break that the code alone doesn't show, such as public URLs that need redirects or an export other teams import. `/flow:dev` applies them at impact and in every plan review, on top of the lenses for the stack ([`skills/dev/lenses.md`](skills/dev/lenses.md)). Coding rules go in the guidelines, not here.

At the first run in a repo, `/flow:dev` offers to create the file from its template, [`skills/dev/impact-lenses.template.md`](skills/dev/impact-lenses.template.md). In a repo that is already past that first run, ask `/flow:dev` to create `docs/impact-lenses.md` from its template, then fill it in.

## Plan review lenses

Every slice plan is checked by a fresh subagent with five lenses:

1. **Mandate fidelity**: the plan does only what the slice calls for and covers its Done.
2. **Ignored lessons**: a rule in `lessons.md` the plan doesn't follow.
3. **Existence**: the files and symbols the plan names exist and do what it assumes.
4. **Guideline compliance**: tests, naming and placement follow `docs/development-guidelines.md`.
5. **Project lenses**: the lenses in `docs/impact-lenses.md`; "project lenses: none" when the file is absent.

The guidelines template is [`skills/dev/development-guidelines.template.md`](skills/dev/development-guidelines.template.md); the decisions format is [`skills/dev/decisions-log.md`](skills/dev/decisions-log.md).

## Configuration

None required. Defaults: `docs/` as the root, `.version` at the repo root, the stack detected from `Gemfile`, `astro.config.*` or `package.json`.

Optional `.flow.yml` at the project root:

```yaml
root: docs              # where work/, decisions-log/ and development-guidelines.md live
stack: astro            # rails | astro | react | node | generic
changelog: docs/CHANGELOG.md
version_file: .version
```

`/flow:dev` writes it in one case only: when you choose a non-default root at the first run. When `.flow.yml` is absent and a `.devflow.yml` exists, the skills read that instead, with the same keys, and `/flow:dev` suggests renaming it.

## Migrating from the symlink skills

If you used the four skills installed as symlinks or with `npx skills`:

1. **Install the plugin first** (see [Install](#install)). Until the old skills are removed, both load: `/devflow` and `/flow:dev` are two copies of the conductor.
2. **Then remove the old skills.** Symlinks: `rm ~/.claude/skills/{devflow,devflow-docs,devflow-archive,projectflow}`. For `npx` installs: `npx skills remove -g devflow devflow-docs devflow-archive projectflow`.
3. **New names:** `/devflow` → `/flow:dev`, `/projectflow` → `/flow:project`, `/devflow-docs` → `/flow:changelog`, `/devflow-archive` → `/flow:archive`.
4. **Configuration:** rename `.devflow.yml` to `.flow.yml` when convenient. The old name is still read.
5. **Personal copies of the dependencies.** If you installed `shaping`, `breadboarding`, `framing-doc` or the superpowers skills as personal skills, they still count as present and do no harm, but each skill shows twice in the listing (`shaping` and `shaping-skills:shaping`). To drop a personal copy, remove its folder or symlink under `~/.claude/skills/`, or for `npx` installs `npx skills remove -g shaping breadboarding framing-doc`.
6. **Existing projects.** Their `docs/` is unchanged. A `docs/work/archived.md` header that cites `/devflow-archive` can stay as it is or be edited by hand.

## Develop the plugin

```bash
git clone https://github.com/spleenteo/devflow.git flow
claude --plugin-dir ./flow
```

`--plugin-dir` loads the clone for one session in place of the installed `flow` ([flags that load a plugin for one session](https://code.claude.com/docs/en/plugins/cli-reference#flags-that-load-a-plugin-for-one-session)).

Read the [Releases](docs/development-guidelines.md#releases) rules before changing anything. A merge into `main` is a release, because projects declare the marketplace without a `ref`. Never add the marketplace from the clone you are editing: a local marketplace loads in place, so every session would run the conductor from the files you are editing. The guidelines, the Gate and the commit rules: [`docs/development-guidelines.md`](docs/development-guidelines.md).

## Update

Third-party marketplaces don't auto-update by default ([keep plugins updated](https://code.claude.com/docs/en/plugins/install#keep-plugins-updated)). To pick up a release:

```bash
claude plugin marketplace update flow
claude plugin update flow@flow
```

## Uninstall

```bash
claude plugin uninstall flow@flow
```

Projects are untouched: `docs/` is plain Markdown.

## License

[MIT](LICENSE)
