---
work: flow-plugin
status: active
superseded_by: null
tags: [decision, dependencies]
description: "grill-me is not a dependency of the flow: upstream it is user-only, so a vague point is settled in dialogue; rules out depending on grill-me or on its target skill grilling."
---

# grill-me is not a dependency

**Date**: 2026-10-25 · **Work**: `flow-plugin` · **Status**: active

## Context

Both conductors told the model to invoke `grill-me` when a point stayed vague, and V3 listed it as an optional dependency. V3's demo found it reported missing in a setup where it was installed: upstream (`mattpocock/skills`) `grill-me` now carries `disable-model-invocation: true`, so it is absent from the model's skill listing and can't be invoked, and its body only forwards to another skill, `grilling`.

## Decision

The flow depends on no grilling skill. When a point stays vague, the conductor settles it in dialogue: one question at a time, each with the answer it would propose, until the point closes or the user parks it as an open question. A user who wants `grill-me` keeps it as their own shortcut.

## Alternatives discarded

- **Depend on `grilling`**, the skill `grill-me` forwards to: one more external dependency, from a 27-skill plugin, for a step the conductor does well in dialogue.
- **Keep `grill-me` and count hidden skills as present**: the check would pass, but the model still couldn't invoke it.

## Consequences

`dependencies.md` lists only superpowers and shaping-skills; its required/optional column stays for future entries. The README's mention goes in V6.

## References

- [`slices.md`](../work/archive/2026-10-25-flow-plugin/slices.md), V3 deviations and close
- https://github.com/mattpocock/skills
