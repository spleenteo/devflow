# Spike — plugin loading, names, pinning, dependencies

Questions from [`brief.md`](brief.md#spike-before-slicing), answered with a stub plugin (`flow`, skills `dev` and `project`, tags `v0.0.1`–`v0.0.3`) in a throwaway marketplace `flowstub`, served from a local bare repo over smart HTTP, with an isolated Claude Code configuration (`CLAUDE_CONFIG_DIR`). Claude Code 2.1.310. Docs pages cited are under `https://code.claude.com/docs/en/`.

**Limit of the setup**: the isolated configuration isn't logged in, so no interactive or `-p` session can start in it (onboarding, then login). Everything the `claude plugin` CLI does was tested; what happens at session start (registration from a project's settings, trust) wasn't, and is marked **open**.

## Outcomes

| # | Question | Outcome | How we know |
|---|---|---|---|
| 1 | A relative-source plugin loads from a trusted project's settings, no install | **Open** (docs say yes) | `plugins/org`: "A plugin that the marketplace lists by a relative path loads from the marketplace copy once the repository's `extraKnownMarketplaces` entries apply". The CLI (`plugin list`, `marketplace list`, `marketplace update`) ignores a project's `extraKnownMarketplaces`: registration happens only at session start |
| 2 | Pinning: user scope vs project scope, different refs | **Open**, and the docs point against the brief's design | See "Pinning" below |
| 3 | `skills/dev/SKILL.md` with `name: dev` → `/flow:dev` | **Yes** | `claude plugin details flow@flowstub`: "Skills (2) dev, project". Namespacing under the plugin name is documented (`plugins-reference`, `name`); the bare `/dev` also works unless another command uses it (`skills`) |
| 4a | A dependency in the same marketplace, `github` source pinned to a `sha` | **Works** | `shaping-skills` entry with `source: {github, repo: rjs/shaping-skills, sha}` and `skills: [./shaping, ./breadboarding, ./framing-doc]`: `claude plugin install flow@flowstub` installed it as "+ 1 dependency: shaping-skills"; `details` lists `breadboarding, framing-doc, shaping` |
| 4b | A dependency from another marketplace (superpowers, mattpocock-skills), with `allowCrossMarketplaceDependenciesOn` | **Installs only if that marketplace is already added.** Otherwise `flow` itself fails to load | Install output: `dependency "superpowers@claude-plugins-official" was not installed (no marketplace you have added lists it) ... "flow" will not load without them`; `plugin list`: `✘ failed to load`. After `claude plugin marketplace add anthropics/claude-plugins-official` and `mattpocock/skills`, each add installed the missing dependency ("+ 1 dependency: superpowers") and `flow` loaded |
| 4c | Dependencies install when a trusted repo is first opened | **Open** (docs say no) | `plugins/dependencies`: missing dependencies install on `plugin install`, `/reload-plugins`, auto-update, `marketplace add`; repo trust isn't in the list |
| 5 | Bare references to dependency skills (`writing-plans`) resolve to the plugin ones | **Open** | Needs a session |
| 6 | `claude plugin validate .` | **Passes with warnings**: no `version` (plugin and marketplace entry); no marketplace `description`. `--strict` fails on those warnings. Plugin-directory checks also report README and LICENSE missing in the stub (the real repo has both) | Run on the stub |
| 7 | Old symlinks and plugin active together | **No name clash, two conductors**: the personal skills are `devflow`, `devflow-docs`, …; the plugin's are `flow:dev`, … Both sets would be listed and both would trigger on "open the work X" | By naming; the migration note removes the symlinks |

## Pinning

What the docs say, read together:

- `settings-reference`, `extraKnownMarketplaces`: "When more than one settings file defines a marketplace entry under the same name, Claude Code uses the entry from the highest-precedence file whole". Project settings rank above user settings.
- Same section: "Claude Code registers each marketplace it doesn't already know."
- `plugins/loading`: "A declared marketplace whose source changed in settings: Claude Code re-fetches it from the new source and shows `Plugins changed. Run /reload-plugins to activate.`"
- `plugins/marketplace-reference`: "Each user registers one marketplace per `name`".

So a project that declares the marketplace with a `ref` **overrides** the user-scope pin while you're in that project, and switching between two projects pinned to different refs re-fetches the single marketplace copy each time. The brief's design ("pin once at user scope; projects only enable") holds only if projects declare the marketplace **without** a `ref` and the user-scope entry exists — and then a teammate without the user-scope entry gets the repository's default branch.

Consequence for the design, to settle before slicing:

- **A. Projects declare no `ref`; `main` only ever holds released states** (development on branches, merge = release, tag on the merge commit). The user-scope pin is optional, a teammate gets the latest release. Simple; needs the release discipline written into the guidelines.
- **B. Projects declare `ref: <tag>`** and that wins in the project (per-project pinning, as in the original brief). The cost is a re-fetch and a `/reload-plugins` notice when switching between projects on different tags.
- **C. Release channel by marketplace name** (`flow` = latest release on `main`, `flow-edge` = development), as `plugins/host-marketplace` suggests for channels.

Recommended: **A**, with B as the documented escape hatch for a project that must stay behind. Confirm with one authenticated session (below) before writing it down.

## Dependencies

- `shaping-skills` as an entry of our own marketplace, pinned to a commit `sha`, works and needs no allowlist. The repo has no license: the entry points at it, nothing is copied.
- A hard dependency on another marketplace makes `flow` fail to load for anyone who hasn't added that marketplace. `claude-plugins-official` is present for most users by default; `mattpocock` isn't.
- Options for `grill-me`: (a) keep the cross-marketplace dependency and say in the README to add `mattpocock/skills` first; (b) an entry in our marketplace for `mattpocock/skills` pinned to a `sha` (MIT), same mechanism as shaping-skills — but a user who already has `mattpocock-skills@mattpocock` gets a second copy; (c) drop `grill-me` from the hard dependencies, since devflow uses it only "if a point stays vague", and report it missing when needed, as today.
- Recommended: superpowers as a cross-marketplace dependency (official marketplace, present by default); shaping-skills as a pinned same-marketplace entry; `grill-me` per (c).

**Decided on 2026-10-25: soft dependencies.** Hard `dependencies` make `flow` fail to load whenever one is missing, and pull in marketplaces the user hasn't chosen. Instead:

- `plugin.json` declares no `dependencies`: `flow` always loads.
- A list next to the skills names each dependency: the skills it provides, where it comes from, whether it's required or optional, and the install commands at user scope and at project scope.
- At the start of `/flow:dev` and `/flow:project`, the skill compares the list with the skills available in the session (plugin or personal installs alike) and reports what's missing in one message, with the commands. It never installs anything. A missing dependency needed only later doesn't block the start; the check runs again at the phase that needs it.
- `shaping-skills` stays as an entry of our marketplace pinned to a commit: a separate plugin the user installs when invited (`shaping-skills@flow`), not a dependency.
- `grill-me` is optional.

This closes 4b and 4c.

## Still open: one authenticated session

Run once, in a logged-in configuration (yours, with throwaway names, or the isolated one after `/login`):

1. Open `repoA` (project pins `ref: v0.0.1`) with the user scope at `v0.0.3`: which marker does `/flow:dev` print, and does the "Plugins changed" notice appear? Then `repoB` (`v0.0.2`).
2. A fresh configuration opening `repoA`: does `flow` load with trust only, and do its dependencies install without `/reload-plugins`?
3. In a session with superpowers from the plugin only (no personal copies), does an instruction "invoke `writing-plans`" resolve to `superpowers:writing-plans`?
