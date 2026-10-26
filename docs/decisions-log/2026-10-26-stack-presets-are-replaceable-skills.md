---
kind: decision
status: active
superseded_by: null
work: flow-own-engine
area: presets
touches: [skills/stack-astro, dependencies.md, docs/development-guidelines.md]
description: "Stack knowledge ships as opinionated flow:stack-<name> skills; a project or user maps a stack to a custom skill that replaces the shipped one entirely."
---

# Stack presets are opinionated skills that a project can replace, never merge

**Date**: 2026-10-26

## The decision

One skill per stack the owner uses, `flow:stack-<name>`, holds patterns, impact lenses, pointers to external skills and gate commands. `.flow.yml`, then `userConfig`, may map a stack to another skill; then the shipped one is never invoked. Several stacks per project resolve independently.

## Context

Flow had one generic lens file and an empty guidelines template. Stack knowledge had to live somewhere a team can share and a user can change, without a preset editing Flow's own files. Shaping compared two homes (A2.2-A and A2.2-B).

## Alternatives discarded

- **Markdown files in a user folder (A2.2-A)**: reading a folder outside the working directory can prompt for permission on every start, which fails the ask-once requirement.
- **Merging a custom preset over the shipped one**: two sources of truth per stack; replacement is predictable.
- **Forking the plugin to change an opinion**: the replacement mapping exists to avoid it.

## Consequences

Each shipped stack adds one line to the skill listing. Preset descriptions carry no bare stack keywords, so they don't fire on their own. A preset influences gate and test level only until the guidelines are drafted.

## Reopen when

Skill listing cost of the shipped presets becomes a problem, or a stack needs partial overrides often enough that full replacement is the burden.

## References

- [shaping](../work/archive/2026-10-26-flow-own-engine/shaping.md) (R4, A2, A2.2 comparison)
- [spike on personal settings](../work/archive/2026-10-26-flow-own-engine/spike-personal-settings.md)
- [slices](../work/archive/2026-10-26-flow-own-engine/slices.md) (V5)

## Status log

- 2026-10-26 — recorded
