---
work: flow-plugin
status: active
superseded_by: null
tags: [decision, distribution, versioning]
description: "Projects declare the flow marketplace without a ref and main holds released states only; rules out per-project tag pins and release channels as the default."
---

# Projects declare the marketplace without a ref; main is the release line

**Date**: 2026-10-25 · **Work**: `flow-plugin` · **Status**: active

## Context

The first brief wanted each project pinned to a tag in its `.claude/settings.json`, then the owner chose to pin once at user scope. The docs say a marketplace is registered once per name per user, the entry from the highest-precedence settings file wins whole (project above user), and a changed source is re-fetched. So a project `ref` overrides the user pin, and projects on different tags re-fetch the single copy at every switch.

## Decision

A project's `.claude/settings.json` declares the `flow` marketplace without `ref` and enables `flow@flow`. Work happens on branches; a merge into `main` is a release, tagged `v<.version>` on the merge commit. A user-scope pin is optional. A project-level `ref` stays documented as an escape hatch for a project that must stay behind.

## Alternatives discarded

- **Per-project `ref` as the default**: works by precedence, but every switch between projects on different tags re-fetches the marketplace and asks for `/reload-plugins`.
- **Release channels as separate marketplace names** (`flow`, `flow-edge`): more moving parts than one developer's release cadence needs.

## Consequences

`main` must never hold unreleased work: the guidelines' `## Releases` rule carries this. Decided from the docs without an authenticated session; the first project that adopts the plugin is the real test. If the documented precedence turns out wrong, this decision is superseded.

## References

- [`spike-plugin-loading.md`](../work/archive/2026-10-25-flow-plugin/spike-plugin-loading.md#pinning)
- https://code.claude.com/docs/en/settings-reference (`extraKnownMarketplaces`)
- https://code.claude.com/docs/en/plugins/marketplace-reference
