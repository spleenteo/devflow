---
work: flow-plugin
status: active
superseded_by: null
tags: [decision, distribution, dependencies]
description: "The flow plugin declares no plugin dependencies: a list and a start check invite the user to install what's missing; rules out the plugin.json dependencies field."
---

# The plugin checks its dependencies at start instead of declaring them

**Date**: 2026-10-25 · **Work**: `flow-plugin` · **Status**: active

## Context

The flow conducts skills it doesn't own: superpowers (`brainstorming`, `writing-plans`, `subagent-driven-development`), rjs/shaping-skills (`shaping`, `breadboarding`, `framing-doc`, `kickoff-doc`), `grill-me`. Claude Code lets a plugin declare them in `plugin.json` `dependencies`. The spike tried it.

## Decision

`plugin.json` has no `dependencies`. A `dependencies.md` at the plugin root lists each dependency with the skills it provides, whether it's required, and the install commands at user and project scope. `/flow:dev` and `/flow:project` compare it with the skills the session lists at start, report what's missing in one message, and never install anything. rjs/shaping-skills is an entry of our own marketplace (`shaping-skills@flow`), pinned to a commit, installed when the user accepts the invitation.

## Alternatives discarded

- **Hard dependencies in `plugin.json`**: a dependency from another marketplace installs only if that marketplace is already added; otherwise the plugin itself fails to load (spike, outcome 4b). They also pull in marketplaces the user didn't choose.
- **Copying the shaping skills into the plugin**: the repository has no license.

## Consequences

The plugin always loads. A teammate who opens a project for the first time gets the flow from trust alone and an install invitation, not a working setup. Personal copies of the dependency skills count as present. The list must be kept in step with what the skills invoke.

## References

- [`spike-plugin-loading.md`](../work/archive/2026-10-25-flow-plugin/spike-plugin-loading.md#dependencies)
- https://code.claude.com/docs/en/plugins/dependencies
