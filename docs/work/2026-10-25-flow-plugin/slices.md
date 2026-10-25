---
shaping: true
---

# Flow plugin — Slices

The mandate is [`brief.md`](brief.md), as amended by the decisions in [`spike-plugin-loading.md`](spike-plugin-loading.md): soft dependencies (no `dependencies` field), and projects that declare the marketplace without a `ref`, with `main` holding released states only. No frame (technical work), no shaping or breadboard (the shape is the brief; the work changes existing Markdown skills and adds no places). Impact corrections of 2026-10-25 applied.

**How slices are demonstrated.**

- Skill behaviour: `claude -p --plugin-dir /Users/spleenteo/Sites/me/devflow-flow` from a scratch repo, in the owner's logged-in configuration (nothing gets registered). The scratch repo's `.claude/settings.local.json` sets `skillOverrides` to `"off"` for the personal `devflow`, `devflow-docs`, `devflow-archive`, `projectflow`, so the old conductors can't answer instead of the new ones. Where a demo is about dependencies, it also turns off the personal `brainstorming`, `writing-plans`, `subagent-driven-development`, `grill-me`, `shaping`, `breadboarding`, `framing-doc`, `kickoff-doc` and sets `enabledPlugins` `superpowers@claude-plugins-official: false`. Check in the run that turning off a bare name doesn't hide `superpowers:<name>`.
- What a subagent received: `--output-format stream-json --verbose`, then grep the Agent `tool_use` input.
- Installation: `claude plugin` commands in an isolated `CLAUDE_CONFIG_DIR` (no login needed). A marketplace added from a local path loads in place, skipping the clone and the cache; the path real users take is exercised with the worktree served as a git URL, as in the spike.
- The branch's README is wrong from V1 to V6: don't hand the branch to anyone before V6.

**The Gate during the work.** The guidelines' Gate covers the whole repo; until V6 closes, its old-name grep and link check also exclude `README.md` and `install.sh` (V6 removes the exclusion; `install.sh` is rewritten in V3 and rejoins then). Allowed matches, written down: the `.devflow.yml` fallback sentence in `dev`, `changelog`, `archive`; `spleenteo/devflow` (repository URL); after V6, the README migration note and the sentence on repo `devflow` vs plugin `flow`.

**Old names today** (`rg -c -i '\bdevflow\b|devflow-(docs|archive)|projectflow|\.devflow\.yml'` outside `docs/`): `devflow/SKILL.md` 24, `projectflow/SKILL.md` 13, `devflow-docs/SKILL.md` 10, `devflow-archive/SKILL.md` 6, `devflow/decisions-log.md` 3, `devflow/development-guidelines.template.md` 1, `projectflow/decisions.md` 1, `install.sh` 5, `README.md` 40.

## V1 — The plugin skeleton

**In**
- `.claude-plugin/plugin.json`: `name: flow`, `description`, `author`, `license: MIT`, `homepage`, `repository`. No `version`, no `dependencies`, no `skills` key (the default `skills/` scan suffices).
- `.claude-plugin/marketplace.json`: `name: flow`, `owner`, `description`; entry `flow` with `source: "./"`; entry `shaping-skills` with a `github` source on `rjs/shaping-skills` pinned by the full `sha` from the remote (`23e32c1ee2293595906d0d55f44424427afa7bac`, which contains `kickoff-doc`), listing `./shaping`, `./breadboarding`, `./framing-doc`, `./kickoff-doc`. Its ripple-check hook (`hooks/shaping-ripple.sh`): wire it in the entry, or leave it out and say why in `dependencies.md` (V3).
- `git mv` the four folders to `skills/dev`, `skills/project`, `skills/changelog`, `skills/archive`; set `name:` in each frontmatter to the folder name. Supporting files move with their skill.
- Repoint the three README links to the moved files (`README.md:167,171,175`).

**Out**: the skills' text beyond `name:` (V2); `install.sh` (V3); the rest of the README (V6).

**Done**
- `claude plugin validate .` passes; the only warnings are the missing `version`.
- Isolated configuration: `claude plugin marketplace add <worktree>`; `claude plugin details flow@flow` lists `archive, changelog, dev, project`; `claude plugin install shaping-skills@flow`, then `claude plugin details shaping-skills@flow` lists `breadboarding, framing-doc, kickoff-doc, shaping`.
- `claude -p --plugin-dir` (demo setup above) names `flow:dev`, `flow:project`, `flow:changelog`, `flow:archive`.
- Gate green (with the exclusions above).

**Gotchas**
- The plugin root is the repo root: `README.md`, `install.sh`, `docs/` land in the plugin cache. Harmless; V5 says so.
- The main checkout keeps the old folders on `main`, so the symlinks keep working until the merge.

**Deviations found while planning V1**
- V1's Done says "Gate green", but the old-name grep can't be clean until V2 rewrites the skills' text. At V1 the grep's count is recorded, not required to be zero; validate and the link check must be green.
- The link check had no command; V1 writes it into the Gate (it's the first slice that runs it).
- `shaping-skills` hook: not wired (opt-in upstream, needs `jq`, interrupts every edit of a `shaping: true` file); the reason goes to V3's `dependencies.md`.

**V1 — done on 2026-10-25** (commits `c820af7`, `f6d5c8b`, `d62b317`, plus the close)
- Isolated install: `flow@flow` lists `archive, changelog, dev, project`; `shaping-skills@flow` lists `breadboarding, framing-doc, kickoff-doc, shaping`. Validate passes; its own warnings are only the missing `version` (the plugin-directory section adds icon and README-install advice).
- Session demo, read from the `init` event of `claude -p --output-format stream-json --verbose`: with `skillOverrides: "off"` in the scratch repo's `.claude/settings.local.json`, the four old skills are gone even in `-p` (266 skills); with `--plugin-dir`, `flow:archive`, `flow:changelog`, `flow:dev`, `flow:project` appear (270).
- Gate with V1's narrowing: old-name grep 51 lines across 7 skill files (V2 clears them); link check green on 19 files.
- Found during execution: `rg` without a path reads stdin when the shell isn't a terminal and hangs; the Gate now passes `.` to both calls.
- Rulings: STATUS.md travelled in T1's commit (bookkeeping); T4 ran as a subagent so its outputs live in its report. Deferred minors: link check ignores angle-bracket link targets, `~~~` fences, indented code and reference links (none in the repo); `install.sh` still loops over the old folders (V3); skills' text still cites the old names (V2).

## V2 — The rename inside the skills

**In**
- Frontmatter descriptions and triggers in all four skills. Drop "update docs" from `changelog`'s triggers (it would collide with the future `flow:docs`).
- Prose and headings: a skill refers to itself as "this skill" or `/flow:<name>`, to the family as "the flow"; `# Devflow` becomes `# Flow: dev`, and so on. Includes `development-guidelines.template.md:3`, `decisions-log.md`, `project`'s `decisions.md:14`, "Relation to devflow".
- Cross-references: `dev` invokes `/flow:changelog` and `/flow:archive`; `project` hands off to `/flow:dev` and still accepts the old phrase "devflow work `<slug>` merged" in existing plans. The lifecycle table's Owner column says "the `flow` plugin", not "this repo".
- Supporting files cited as `${CLAUDE_SKILL_DIR}/lenses.md`, `…/decisions-log.md`, `…/development-guidelines.template.md` (`project`: `…/constraints.template.md`, `…/decisions.md`). Packets hand subagents the expanded absolute path.
- Config: `.flow.yml`, read first; `.devflow.yml` read when `.flow.yml` is absent. The same fallback sentence, worded identically, in `dev`, `changelog`, `archive`; the one-line notice is printed once, by `dev`. Step 0's condition and its `ls` check both files. The non-default root offered at Step 0 becomes `flow/`.
- Dependency skills cited by bare name with the plugin form in brackets: `writing-plans` (`superpowers:writing-plans`), `shaping` (`shaping-skills:shaping`). Verify in the demo how the session lists them (spike, "Not run", item 3) before settling the wording, and align the Naming rule in the guidelines.
- Agnostic: in `project`, the home becomes the folder the user names (inside a documents vault, propose `<vault>/<Name>/`), with no personal tool or path variable; the resume example uses an invented project name.

**Out**: README (V6); `install.sh` (V3); new behaviour (V3, V4).

**Done**
- Gate green: the old-name grep over the repo (exclusions above) returns only the allowed matches.
- The personal tool, path variable and project name that `projectflow/SKILL.md:33,62,80` and `README.md:98` cite today appear nowhere in `skills/` (README in V6).
- Demo: asked to "open a work", the session invokes `flow:dev`, and the skill text it loaded refers to `/flow:changelog` and `/flow:archive`; `${CLAUDE_SKILL_DIR}/lenses.md` resolves to an existing file.

**Gotchas**
- `dev` and `project` are kept in sync by hand: every edit to one is checked against the other.

**Deviations found while planning V2**
- Dependency skills get the plugin form in brackets only at their first mention in each skill, not every time: the text would double in length for no reader.
- The plan-row phrase for a software action becomes *"flow:dev work `<slug>` merged"*; the old *"devflow work … merged"* is read the same.
- Allowed old-name matches extended: besides the fallback sentence and `spleenteo/devflow`, `dev`'s one-time notice, Step 0's condition and `ls` (they must name `.devflow.yml`), and the old-phrase notes in `dev` and `project`.
- The dependency-name check (spike "Not run", item 3) runs first, as T0, so it settles the wording before the text is written.

**V2 — done on 2026-10-25**
- T0 settled the wording: with only the plugin copy visible, a bare `writing-plans` resolves to `superpowers:writing-plans`; the Naming rule says so.
- Demo with `--plugin-dir`: the `init` event lists the four `flow:*` skills and no old name; asked to open a work, the session calls `flow:dev`; the loaded text cites `/flow:changelog`, `/flow:archive` and an absolute `.../skills/dev/lenses.md` that exists; nothing written in the scratch repo.
- Gate with V2's narrowing: validate passes (warnings: missing version, README install line, the latter V6's); old-name grep shows only the allowed matches (`dev` :43, :72, :75, :304; `project` :216; `changelog` :37; `archive` :8); link check green after rewording V1's narrative, which quoted link syntax in prose.
- Rulings: T0, T2's fix and T3 reviewed by the controller on their small diffs instead of a reviewer subagent. Fixes: T1 one round (an instruction at :207, an ambiguous "it", the skill-dir paths); T2 one round (`breadboarding` unbracketed at its first mention). Deferred minor: nested parentheses in `dev`'s Why paragraph.

## V3 — Soft dependencies

**In**
- `dependencies.md` at the plugin root, one row per dependency (source, skills it provides, required or optional, which flow and phase needs it, install commands at user and at project scope):
  - superpowers: `brainstorming` (frame, both flows), `writing-plans` and `subagent-driven-development` (`dev` slice loop): required;
  - `shaping-skills@flow`: `shaping`, `breadboarding`, `framing-doc` (both flows), `kickoff-doc` (`project` only): required for the definition phases; the hook decision from V1;
  - `grill-me` (both flows): optional.
- A start check in `dev` and `project`: compare the list with the skills listed in the session; a dependency is present when a listed name, or its segment after `:`, equals it. Report what's missing in one message with the commands; never install; don't block a start whose first phases don't need it; check again at the phase that needs it. Cited as `${CLAUDE_PLUGIN_ROOT}/dependencies.md`.
- `install.sh`: owned here. Rewritten as a terminal dependency checker reading `dependencies.md`, or removed if the start check makes it redundant; removal is a deviation from the brief, recorded with the reason.

**Out**: any `dependencies` field in `plugin.json`; the README (V6).

**Done**
- Demo, owner's setup: no missing dependency reported.
- Demo, dependencies turned off (setup above): one message reporting superpowers (required) and `grill-me` (optional), each with both install commands.
- `dependencies.md` linked from both skills.

**Deviations found while planning V3**
- `grill-me` now ships in a plugin too (`mattpocock-skills@mattpocock`, 27 skills); `dependencies.md` offers both that and the single-skill `npx skills add` route. The presence rule (name or segment after `:`) covers both, so the Naming rule keeps it bare.
- The Done's demo also checks shaping skills are not reported (present as personal skills in the owner's setup), and that `${CLAUDE_PLUGIN_ROOT}` expands in skill text.
- `install.sh` leaves the Gate's narrowing at V3, its owner; README stays excluded until V6.
- Both conductors gain a row in `## What it does NOT do`: they don't install dependencies, they print the commands.
- `install.sh` counts a skill present when its plugin is enabled or a folder of that name is in the personal or project skills, whether or not `claude` is on the path: the presence rule is by name.

## V4 — Project impact lenses

**In**
- `skills/dev/impact-lenses.template.md`: the `| Lens | Looks for |` table, optional `##` groups, two invented examples.
- `lenses.md`: a "Project lenses" section: where the file lives (`<root>/impact-lenses.md`), its format, who reads it.
- `dev/SKILL.md`: Conventions row; the impact packet of the stack-lens subagent (or the single subagent) includes the file; plan review gets a fifth row, **Project lenses**; the slice packet includes it; Step 0 mentions the file and offers the template (`${CLAUDE_SKILL_DIR}/impact-lenses.template.md`), never creates it unasked.
- No config key. `project` untouched.

**Out**: the lenses of any real project; the README section (V6).

**Done**
- A fixture repo holding a one-slice work at `phase: impact` (`STATUS.md`, `slices.md`) and `docs/impact-lenses.md` with one lens and a deliberate trap: a stream-json run of the impact phase shows the lens in the subagent's input and a finding on the trap.
- Without the file, the same run shows no project lenses.

## V5 — Architecture documentation

**In**
- `docs/architecture.md`, Mermaid diagrams GitHub renders:
  - distribution: repo → marketplace `flow` → plugins `flow` and `shaping-skills`; user-scope install; a project's `.claude/settings.json` declaring the marketplace without `ref` and enabling the plugin; releases as merges to `main` with tags;
  - the `flow:dev` lifecycle: opening, definition phases, slice loop with its two stops, closing sequence, hand-offs to `flow:changelog`, `flow:archive` and the dependency skills; `flow:project` handing off to `flow:dev`;
  - what is read and written in a project (`docs/` as memory, guidelines, project lenses, `.flow.yml`);
  - where the plugin ends: the dependency list and the start check; what lands in the plugin cache.
- `docs/development-guidelines.md`: a `## Releases` section: work on branches; a merge into `main` is a release; tag `v<.version>` on the merge commit; develop with `--plugin-dir`, never by adding the marketplace from the clone being edited (it would load in place and the conductor would edit itself).
- Claude Code behaviour is linked to the official docs pages, not to the spike (the spike gets archived and walled).

**Done**
- Every diagram renders with `npx -y @mermaid-js/mermaid-cli` (`mmdc`; first run downloads Chromium) and is checked by eye.
- Every statement about Claude Code links to a docs page.

## V6 — README and migration

**In**
- Install: `claude plugin marketplace add spleenteo/devflow` + `claude plugin install flow@flow --scope user`; the project snippet (`extraKnownMarketplaces` without `ref`, `enabledPlugins`); what a teammate gets from trust alone and what the start check will ask them to install; a project-level `ref` as an escape hatch, stated as documented behaviour.
- Links to `dependencies.md` and `docs/architecture.md`; project lenses (including how a repo already past Step 0 adds the file); local development (`claude --plugin-dir .`, and the warning from `## Releases`); the review lenses now five; one sentence on repo `devflow` vs plugin `flow`.
- Migration note: `/devflow` → `/flow:dev` and the other three; `.devflow.yml` → `.flow.yml` (still read); remove the symlinks (`~/.claude/skills/{devflow,devflow-docs,devflow-archive,projectflow}`) or, for `npx` installs, `npx skills remove devflow devflow-docs devflow-archive projectflow`; duplicate personal copies of the dependency skills; existing `docs/work/archived.md` headers that cite `/devflow-archive` can stay or be edited by hand.
- Remove the `npx skills add` path and the symlink install. The Gate exclusions for `README.md` and `install.sh` go.

**Done**
- A fresh isolated configuration follows the README's commands, with the worktree served as a git URL in place of `spleenteo/devflow`, and ends with `claude plugin details flow@flow` listing the four skills.
- The Gate is green over the whole repo, links included.

## After V6: closing sequence

1. From the worktree session, with the frozen skills of the main checkout: `devflow-docs` (answer the current version as `0.0.0`, so the minor bump gives `0.1.0`), then `devflow-archive`.
2. On approval only: merge into `main`, push, tag `v0.1.0`, push the tag.
3. The owner migrates right after the merge, which removes the old folders under the symlinks: install from GitHub first, then remove the symlinks.
