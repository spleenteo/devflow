# Changelog

What shipped, by version, newest first. Each entry names the work it came from; the version lives in `.version`.

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
