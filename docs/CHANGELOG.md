# Changelog

What shipped, by version, newest first. Each entry names the work it came from; the version lives in `.version`.

## v0.4.1 — 2026-10-30 — Flow tells you when a newer release is out

Flow now checks, at the start of a session, whether a newer release exists, so an installed copy no longer falls silently behind.

- **Update notice**: `/flow:dev` and `/flow:project` compare the highest `v*` tag of Flow's repository with the installed version, after the dependency check, and add one line with the update commands to the first message when a newer release exists.
- **Quiet when it cannot know**: offline, or on a development copy, nothing is shown.
- **Docs**: the README's Update section mentions the notice.
- **Work**: `update-check`

---

## v0.4.0 — 2026-10-30 — Lighter work sessions, and screens checked without filling the session

A slice's execution no longer piles up in the main session, so long works stay well under the point where the context is compacted. Design screens can now be checked by a separate agent that returns only a verdict.

- **Slice runner**: in `/flow:dev`, executing a slice (executors, reviewers, fix rounds, the ledger, the final review and the gate) runs in one background subagent that returns a short summary; the main session keeps the stops, `STATUS.md` and the commits. With nested subagents turned off, the loop runs in the main session as before.
- **Leaner hand-offs**: the slice packet is written to a file and passed by path, the planner returns a ten-line summary and the plan's files, and the ledger and the slice close are written in fewer calls.
- **Screen check**: a new screen-checker agent looks at an exported screen and reports a verdict, and `/flow:design` and the Pen adapter use it so screenshots stay out of the main session.
- **Projects**: the project close chains its bookkeeping in one call.
- **Docs**: the README and the architecture describe the runner, the ledger writes and the screen checker.
- **Work**: `lean-conductor`
- **Decision**: [A slice's execution runs in a runner subagent, not in the main session](decisions-log/2026-10-29-slice-execution-runs-in-a-runner-subagent.md)
- **Decision**: [The main session grows less instead of being cleared at every slice](decisions-log/2026-10-29-main-session-grows-less-not-cleared.md)

---

## v0.3.0 — 2026-10-27 — A design phase for Flow, with /flow:design

Flow can now carry design work alongside the code: design files live in the repo, and a new `/flow:design` skill composes screens from a shared library and promotes new components back to it. Pen is the first supported tool.

- **/flow:design**: a skill that works by hand or when called by a work; it sets up the place and index for design files, composes screens from the library, and promotes reusable components.
- **Tool adapter**: the skill is agnostic of the design tool; `flow:design-pen` is the adapter for Pen, and `stack_presets` can map another adapter in its place.
- **Dev phase**: `/flow:dev` gains a design phase inside a work, with a reminder to close design files before a branch switch.
- **Projects**: `/flow:project` can propose design actions in its plans and works in a project home; the project `STATUS.md` template records design and presets.
- **Brainstorm**: real artifacts produced in a brainstorm can be handed on to `/flow:design`.
- **Docs and site**: the README, the architecture, the guidelines and the site's phase overview describe the design phase and its adapters.
- **Work**: `design-flow`
- **Decision**: [Design is an agnostic skill plus a tool adapter](decisions-log/2026-10-27-design-is-agnostic-skill-plus-tool-adapter.md)
- **Decision**: [Design runs as a dev phase](decisions-log/2026-10-27-design-runs-as-a-dev-phase.md)

---

## v0.2.1 — 2026-10-27 — A simpler DatoCMS preset

The DatoCMS preset now holds only the essentials, grouped by theme, and adds naming conventions for models and fields.

- **CLI**: work goes through the `datocms` CLI linked to the repo; the live schema is read with `schema:inspect` before planning; API details come from the DatoCMS skills or `cma:docs`, never memory.
- **Environments**: schema changes run in a sandbox fork and are promoted after review; in place on the primary only for additive changes; tokens stay server-side.
- **Schema**: every change is a committed migration; query types are generated and checked in CI; optional and localized fields are nullable.
- **Naming**: `… Page` models and `… Block` blocks with snake_case API keys matching the components; standard field names; appearance only through `layout` and `style`.
- **Lenses**: four, one per theme plus tokens; the rendering, image, SEO and cache rules are left to the DatoCMS skills.

---

## v0.2.0 — 2026-10-26 — Flow runs on its own engine

Flow no longer borrows its planning, review and dialogue steps from other plugins: it writes, reviews and runs its own work, keeps its own memory, and knows each project's profile. Existing projects move over with a guided upgrade.

- **Work layer**: the rules for opening, running, closing and resuming a work live once, in a shared reference that `/flow:dev`, `/flow:project` and `/flow:archive` all follow. A work runs on its own branch in the current checkout and closes with a local merge after an ok.
- **Changelog and memory**: `flow:docs` records changelog entries and versions, and searches past decisions; `/flow:changelog` is now only an entry point to it.
- **Decisions**: decisions have one format (kind, area, files touched, status log) with a check script, and `flow:docs` writes, updates and checks them.
- **Project profile**: the first time, `/flow:dev` asks which stacks, tests and merge rules the project uses, and writes them on the work branch; the guidelines template is shorter.
- **Stack presets**: Astro, DatoCMS and Rails knowledge ships as `flow:stack-<name>` skills; a project or a user can map a stack to a skill of their own, which replaces the shipped one entirely.
- **Own agents**: planner, plan reviewer, impact, executor and task reviewer run slice plans and reviews, with a ledger of each dispatch and one commit per task. The plan and review skills of other plugins leave the dependencies, with credit given in `CREDITS.md`.
- **Brainstorm and grill**: `/flow:brainstorm` and `/flow:grill` replace the borrowed dialogues, before the frame and when stress-testing a plan; both also work by hand.
- **Upgrade**: projects on the old layout are upgraded as a run of their own, on a branch, merged after an ok; the old-name fallbacks are removed. README and architecture are rewritten for the new shape.
- **Work**: `flow-own-engine`
- **Decision**: [Flow writes and runs its own plans](decisions-log/2026-10-26-flow-writes-and-runs-its-own-plans.md)
- **Decision**: [stack presets are replaceable skills](decisions-log/2026-10-26-stack-presets-are-replaceable-skills.md)
- **Decision**: [a work runs on a branch in the current checkout](decisions-log/2026-10-26-work-runs-on-a-branch-in-the-current-checkout.md)
- **Decision**: [atomic commit criteria absorbed, not a dependency](decisions-log/2026-10-26-atomic-commit-criteria-absorbed-not-a-dependency.md)
- **Decision**: [flow-own-engine ships as one release](decisions-log/2026-10-26-flow-own-engine-ships-as-one-release.md)

---

## v0.1.0 — 2026-10-25 — The conductors become the `flow` plugin

The four personal skills are now one Claude Code plugin, installed from GitHub instead of symlinked from a clone, so every project can use the same released version and a teammate gets it from the project's settings.

- **Plugin and marketplace**: the repository `spleenteo/flow` (formerly `spleenteo/devflow`) is a marketplace named `flow` that serves the plugin `flow` and a pinned `shaping-skills` entry. Install with `claude plugin marketplace add spleenteo/flow` and `claude plugin install flow@flow`.
- **New names**: `/devflow` is `/flow:dev`, `/projectflow` is `/flow:project`, `/devflow-docs` is `/flow:changelog`, `/devflow-archive` is `/flow:archive`. Configuration moves to `.flow.yml`; an existing `.devflow.yml` is still read.
- **Soft dependencies**: `dependencies.md` lists the skills the flow hands work to (superpowers, shaping-skills). `/flow:dev` and `/flow:project` check them at start and at the phase that needs one, print the install commands, and never install. `install.sh` is now a report-only checker. `grill-me` is no longer a dependency: a vague point is settled in dialogue.
- **Project impact lenses**: a project can write its own lenses in `docs/impact-lenses.md`; `/flow:dev` applies them at impact and as a fifth row of every plan review, and offers a template.
- **Documentation**: `docs/architecture.md` explains distribution, the `/flow:dev` lifecycle, what a project holds and where the plugin ends, with diagrams; the README covers install, project setup and migration from the symlinked skills; the guidelines gain release rules (a merge into `main` is a release, tagged).
- **Work**: `flow-plugin`
- **Decision**: [soft dependencies](decisions-log/2026-10-25-soft-dependencies.md)
- **Decision**: [projects declare the marketplace without a ref](decisions-log/2026-10-25-projects-declare-marketplace-without-ref.md)
- **Decision**: [grill-me is not a dependency](decisions-log/2026-10-25-no-grill-me-dependency.md)

---
