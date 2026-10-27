<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="site/assets/brand/flow-logo-on-dark.svg">
    <img src="site/assets/brand/flow-logo-on-light.svg" alt="flow" height="48">
  </picture>
</h1>

A Claude Code plugin that runs a piece of work from idea to done, one slice at a time, and keeps its state on disk so a work resumes days later in a new session. `/flow:dev` takes software work in a repository to a branch merged after your ok; `/flow:project` runs a project that people carry out over weeks or months, in a folder outside any repo.

Flow brings its own dialogue for an idea that isn't clear (`/flow:brainstorm`, `/flow:grill`), its own agents for planning, review, impact and execution, and its own memory keeper for the changelog and the decisions. Shaping, breadboarding and framing come from the `shaping-skills` plugin. The detailed plan of each slice is written right before it starts, so it carries what the previous slices taught. Plans are reviewed by a fresh agent, and the flow returns to you at two points per slice. `/flow:dev` works with any stack and adds nothing to your project's `CLAUDE.md`.

How it fits together: [`docs/architecture.md`](docs/architecture.md). The website: [spleenteo.github.io/flow](https://spleenteo.github.io/flow/), built from [`site/`](site/).

## Install

Once per machine, at user scope, so the plugin is available in every project ([install scopes](https://code.claude.com/docs/en/plugins/install#choose-an-install-scope)):

```bash
claude plugin marketplace add spleenteo/flow --scope user
claude plugin install flow@flow --scope user
```

Recent versions also accept one step that adds the marketplace and installs the plugin. The session form below needs Claude Code 2.1.275 or later; the shell form, `claude plugin install flow --marketplace spleenteo/flow`, needs 2.1.292 or later ([add a marketplace and install in one command](https://code.claude.com/docs/en/plugins/install#add-a-marketplace-and-install-in-one-command)).

```text
/plugin install flow --marketplace spleenteo/flow
```

**Dependencies.** Flow plans, reviews and executes with its own agents. It hands shaping, breadboarding and framing to the `shaping-skills` plugin, and a stack's opinions to optional skills from other plugins. It checks for them but never installs them. Run `/flow:dev` in the project you'll work in: before anything else, the start check lists what's missing, with the commands to run. To check without opening a project, `install.sh` from a clone does the same from the shell, writing and installing nothing:

```bash
git clone https://github.com/spleenteo/flow.git flow
flow/install.sh
```

The list, with the commands at user and project scope: [`dependencies.md`](dependencies.md).

## Use in a project

To give a team the flow, commit this `.claude/settings.json` in the project. It declares the marketplace, with no `ref`, and enables the plugin:

```json
{
  "extraKnownMarketplaces": {
    "flow": { "source": { "source": "github", "repo": "spleenteo/flow" } }
  },
  "enabledPlugins": { "flow@flow": true }
}
```

What a teammate gets, from the docs:

- The marketplace is registered only after they accept the workspace trust dialog for the folder ([`extraKnownMarketplaces`](https://code.claude.com/docs/en/settings-reference#extraknownmarketplaces)).
- A plugin enabled only in project settings is not fetched onto a machine where it isn't installed, unless its marketplace entry has a relative-path source, as `flow` does ([enabled in project settings but not installed](https://code.claude.com/docs/en/plugins/loading#enabled-in-project-settings-but-not-installed)). So trust alone brings `flow`.
- The dependencies are not enabled by the file. The first `/flow:dev` tells the teammate what to install.

Leave out `ref`: whatever is on `main` of this repository is a release. A project that must stay behind can set `"ref": "v0.4.0"` (a branch or tag) in its `source`. The entry from the highest-precedence settings file is used whole, and project settings sit above user settings ([`extraKnownMarketplaces`](https://code.claude.com/docs/en/settings-reference#extraknownmarketplaces), [precedence](https://code.claude.com/docs/en/settings#settings-precedence)), so that project's `ref` wins; the cost is that switching between projects on different tags re-fetches the single copy each time. This is documented behaviour, not yet tried on a real project. Why no `ref` by default: [projects declare the marketplace without a ref](docs/decisions-log/2026-10-25-projects-declare-marketplace-without-ref.md).

## Usage

Plugin skills are invoked as `/plugin-name:skill-name` ([skills](https://code.claude.com/docs/en/skills)).

| Skill | What it does |
|---|---|
| [`/flow:dev`](skills/dev/SKILL.md) | Software work in a repo: profile, opening, definition phases (brainstorm, grill, frame, shaping, breadboard, slicing, impact), then a plan, review, execute and close loop per slice, then the closing sequence |
| [`/flow:project`](skills/project/SKILL.md) | A project that people carry out: appetite, a reality check in place of impact, plans of actions, a report at the end |
| [`/flow:brainstorm`](skills/brainstorm/SKILL.md) | A dialogue that finds out what you want and why, then writes a description a builder could plan from. Run by `/flow:dev` and `/flow:project` for an idea that isn't clear; also by hand |
| [`/flow:grill`](skills/grill/SKILL.md) | Rounds of numbered questions, each with a recommended answer, on a plan, a draft or one doubt. Settled answers land in a file you name. Run by the conductors, also by hand |
| [`/flow:changelog`](skills/changelog/SKILL.md) | The changelog entry and the `.version` bump for a finished work, on its branch |
| [`/flow:archive`](skills/archive/SKILL.md) | Moves a finished work or project home out of the way and repairs the links |

Open Claude Code inside the project and type `/flow:dev`, or say "resume mobile-menu". A bugfix is a one-slice work: straight to slicing, impact if it touches more than one file, the loop once.

**From `/flow:project` to `/flow:dev`.** When an action of a project is software, its plan row reads "flow:dev work `<slug>` in `<repo>` merged". You open that work with `/flow:dev` in its repo, in its own session, and the row closes when it is merged.

Running `/flow:dev`, `/flow:project`, `/flow:brainstorm` or `/flow:grill` is your choice of process: inside it, the process skills of other plugins (brainstorming, planning, plan execution, test-driven development, worktrees) don't apply.

## How a work runs

- **Profile.** On every run `/flow:dev` reads the profile of the repo: the stacks, the `merge` style and the test level. It asks only for what is missing, in one message, and writes the answers on the work's branch.
- **Opening.** One message with five questions and the answers it proposes: what to build, a code name, source material, whether the outcome is already clear in one sentence (technical work skips to slicing; product work starts from the frame), whether the problem is clear. It searches the project's memory first and says what already touches the same area. The work gets its own branch, `work/<slug>`, in the current checkout, and a dated folder in `docs/work/`.
- **Definition.** A product work whose problem isn't clear goes brainstorm → grill → frame: `/flow:brainstorm` writes `brainstorm.md`, `/flow:grill` settles what is open in it, then the frame is written with a short criterion on top that every later document is measured against. Then, as needed: shaping, breadboard, slicing (always), impact. Each phase writes one document, commits and stops. Impact has two agents read the slices against the real code and report in one ranked message.
- **Slice loop.** Per slice: Flow's planner writes the plan, a plan reviewer checks it, **first stop**; executors carry out the tasks, a task reviewer checks each one, then the close: the Done and the gate verified, lessons written, **second stop**: "V3 closed. Plan V4, or stop here?"
- **Tiers.** Planner, plan reviewer and impact run on the top tier; executors and task reviews on the mid tier. A `critical` task's review, the final review and a third fix round go to the top tier. Plans mark which tasks depend on which and which are `critical`; independent tasks run in parallel.
- **The ledger.** During execution `docs/work/<dir>/V<n>-ledger.md` records every dispatch (task, agent, model, outcome, commits) and which tasks are complete. A resumed work doesn't dispatch a complete task again.
- **Resume.** It reloads the standing documents (`STATUS.md`, the frame's criterion, the guidelines that apply, `lessons.md`, the matching decisions, the current plan and its ledger), says what it reloaded, and continues.
- **Close and merge.** After the last slice it asks before each step: close the work, the changelog and version (`/flow:changelog`), `/flow:archive`, then the merge. With `merge: local`, the default, it proposes the local merge into the target branch and runs it after your ok; with `merge: pr` it proposes a pull request and merges nothing. Push and tag each wait for their own ok. Code, changelog, version and archived work land together.

The decisions are the memory of why: when a choice discards a real alternative, `/flow:dev` proposes recording it and writes it only after your yes.

## Profile and stack presets

A stack can have a preset: a skill with opinionated rules, impact lenses, a test level, gate commands and references. Shipped: `astro`, `datocms` and `rails`, as `flow:stack-astro`, `flow:stack-datocms` and `flow:stack-rails`. A project with several stacks (`[astro, datocms]`) gets the presets of each. Some presets reference skills from other plugins, which are optional ([`dependencies.md`](dependencies.md)).

A preset never merges with your own. To use another skill for a stack, map it, in order of precedence:

1. `presets:` in `.flow.yml`, as `stack=skill` pairs;
2. the plugin option `stack_presets`, comma-separated pairs;
3. otherwise the shipped preset, when the stack has one.

The mapped skill replaces the shipped one entirely. If it isn't available in the session, Flow says so and does not fall back to the shipped preset. Why: [stack presets are replaceable skills](docs/decisions-log/2026-10-26-stack-presets-are-replaceable-skills.md).

## What lands in a project

Markdown only, versioned with the code, under `docs/` by default:

```
.flow.yml                 only when you set a key
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
      brainstorm.md
      frame.md
      slices.md
      lessons.md
      V1-plan.md
      V1-ledger.md
    archive/
```

`docs/` is the project's memory: what shipped, why, and how code is written here. `/flow:dev` searches it at the opening of every work, through `flow:docs`. The plugin's own files (skills, agents, templates, lenses, `dependencies.md`) stay in the plugin copy; a template reaches the project only when you accept it. Who writes and reads each path: [What a project holds](docs/architecture.md#what-a-project-holds).

## Project lenses

`docs/impact-lenses.md` holds the project's own lenses: what a change here can break that the code alone doesn't show, such as public URLs that need redirects or an export other teams import. `/flow:dev` applies them at impact and in every plan review, on top of the common lenses ([`skills/dev/common-lenses.md`](skills/dev/common-lenses.md)) and the lenses of the stack presets. Coding rules go in the guidelines, not here.

At the first run in a repo, `/flow:dev` offers to create the file from its template, [`skills/dev/impact-lenses.template.md`](skills/dev/impact-lenses.template.md). In a repo that is already past that first run, ask `/flow:dev` to create `docs/impact-lenses.md` from its template, then fill it in.

## Plan review lenses

Every slice plan is checked by a fresh agent, `flow:plan-reviewer`, with five lenses:

1. **Mandate fidelity**: the plan does only what the slice calls for and covers its Done.
2. **Ignored lessons**: a rule in `lessons.md` the plan doesn't follow.
3. **Existence**: the files and symbols the plan names exist and do what it assumes.
4. **Guideline compliance**: tests, naming and placement follow `docs/development-guidelines.md`.
5. **Project lenses**: the lenses in `docs/impact-lenses.md`; "project lenses: none" when the file is absent.

The guidelines template is [`skills/dev/development-guidelines.template.md`](skills/dev/development-guidelines.template.md); the decisions format is [`skills/docs/decisions.md`](skills/docs/decisions.md).

## Configuration

None required. Defaults: `docs/` as the root, `.version` at the repo root, `merge: local`, the stacks detected from `Gemfile`, `astro.config.*` or `package.json`.

Optional `.flow.yml` at the project root:

```yaml
root: docs                  # where work/, decisions-log/ and development-guidelines.md live
stacks: [astro, datocms]    # rails | astro | datocms | react | node | generic
merge: local                # local | pr
changelog: docs/CHANGELOG.md
version_file: .version
areas: [engine, ui]         # the area words a decision may carry
presets: [astro=my-stacks:astro]   # stack=skill pairs, replacing the shipped preset
```

`/flow:dev` writes `.flow.yml` only to record what you answered in the profile, on the work's branch, and in the upgrade (below).

**Plugin options.** Three options of the plugin, set from its configuration or in `pluginConfigs` of your user settings ([`pluginConfigs`](https://code.claude.com/docs/en/settings-reference#pluginconfigs), [user configuration](https://code.claude.com/docs/en/plugins/manifest-reference#user-configuration)):

| Option | What it does |
|---|---|
| `model_top` | Model for the top tier: an alias such as `opus` or a model ID. Empty: Flow's default |
| `model_mid` | Model for the mid tier. Empty: Flow's default |
| `stack_presets` | Skill per stack, as `stack=skill` pairs, comma-separated: `astro=my-stacks:astro, rails=my-stacks:rails` |

**Environment variables beat both.** `CLAUDE_CODE_SUBAGENT_MODEL_FORCE`, with `CLAUDE_CODE_SUBAGENT_MODEL`, forces the model of every subagent ([run every subagent on one model](https://code.claude.com/docs/en/sub-agents#run-every-subagent-on-one-model)), and `CLAUDE_CODE_EFFORT_LEVEL` overrides the effort of every agent ([effort level](https://code.claude.com/docs/en/model-config#set-the-effort-level)). The first pair overrides the models of Flow's agents and the options above; `CLAUDE_CODE_EFFORT_LEVEL` overrides their effort. The ledger records the value of the first two.

**Dependencies.** `install.sh` checks the dependencies for the current repo: it reads [`dependencies.md`](dependencies.md), shows the optional rows only for the stacks the checkout has, and installs nothing.

## Upgrading from an older Flow

Older versions were installed as skills named `devflow`, `devflow-docs`, `devflow-archive` and `projectflow`, configured by `.devflow.yml`. If you have them:

1. **Install the plugin first** (see [Install](#install)). Until the old skills are removed, both load: `/devflow` and `/flow:dev` are two copies of the conductor.
2. **Remove the old skills.** Symlinks: `rm ~/.claude/skills/{devflow,devflow-docs,devflow-archive,projectflow}` (`rm -r` if they are copied folders). For `npx` installs: `npx skills remove -g devflow devflow-docs devflow-archive projectflow`.
3. **New names:** `/devflow` is `/flow:dev`, `/projectflow` is `/flow:project`, `/devflow-docs` is `/flow:changelog`, `/devflow-archive` is `/flow:archive`.
4. **Run `/flow:dev`** in the project. It finds the old traces on the default branch and offers the upgrade step: `.devflow.yml` renamed to `.flow.yml`, `stack:` turned into `stacks:`, the old names in `docs/work/archived.md` and in the guidelines rewritten, all in one commit on a `flow-upgrade` branch that it proposes to merge. It also lists, without editing them, the lines of your `CLAUDE.md` files, `Skill(...)` entries in `.claude/settings.json` and project-scope skill copies that still carry the old names. The upgrade is a run of its own: nothing else happens until the next run. Open `work/*` branches that still hold an old file are pointed at, with the merge command to run after the upgrade (`git switch work/<slug> && git merge <default>`); the merge into the default branch waits for its own ok; declining stops the run, and the upgrade is offered again next time. Resuming a work whose branch still holds an old file stops until the branch is refreshed.

Until the upgrade runs, the old configuration file is not read.

**Superpowers may stay installed.** Inside `/flow:dev`, `/flow:project`, `/flow:brainstorm` and `/flow:grill`, its process skills don't apply; outside them they behave as before. Personal copies of `shaping`, `breadboarding` or `framing-doc` still count as present, but each shows twice in the listing (`shaping` and `shaping-skills:shaping`); remove a personal copy from `~/.claude/skills/` to drop it.

Existing projects keep their `docs/` as it is.

## Develop the plugin

```bash
git clone https://github.com/spleenteo/flow.git flow
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

## Credits

Flow's agents and skills took rules and adapted text from superpowers, thoughtbot's atomic-commits and Matt Pocock's grilling skill, all MIT-licensed: [CREDITS.md](CREDITS.md).

## License

[MIT](LICENSE)
