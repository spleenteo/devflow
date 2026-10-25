# Changelog

What shipped, by version, newest first. Each entry names the work it came from; the version lives in `.version`.

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
