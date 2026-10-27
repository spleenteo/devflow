---
kind: decision
status: active
superseded_by: null
work: design-flow
area: workflow
touches: [skills/design]
description: "Design is a tool-agnostic /flow:design skill plus a replaceable tool adapter chosen via the presets chain; rules out one skill fused with Pen."
---

# Design is a tool-agnostic skill plus a replaceable tool adapter

**Date**: 2026-10-27

## The decision

Design in Flow is a tool-agnostic `/flow:design` skill that owns the loop (discovery, reuse, promotion, choice of medium, consent), plus a replaceable tool adapter (`flow:design-pen` shipped) resolved through the presets chain with `design` as its key; the project picks the tool with `design: <tool>` in `.flow.yml`.

## Context

The user designs with Pen today but cares about the loop, not the tool; another tool (e.g. Paper) may fit better later. The design capability had to be reachable from /flow:dev, /flow:project and on its own.

## Alternatives discarded

- **One skill holding the loop and Pen knowledge together**: switching tools would mean rewriting the loop.
- **A pure preset, like the stack presets**: presets carry rules and lenses, not a user-invocable loop with its own steps and consent.

## Consequences

Two pieces to keep in step: the skill must never name tool-specific mechanics, and every adapter must expose the same operations (open, read index note, promote, export). A project mapping its own adapter replaces the shipped one entirely.

## Reopen when

A second adapter is written and the skill/adapter boundary turns out to be in the wrong place.

## References

- [brainstorm](../work/2026-10-27-design-flow/brainstorm.md)

## Status log

- 2026-10-27 — recorded
