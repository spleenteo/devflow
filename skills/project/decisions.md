# Decisions

`decisions/` inside the project's home is the memory of *why*. It outlives the slices and the plans. One file per decision, dated, never rewritten into something else.

## When to write one

- a **real alternative was discarded**: in six months someone will propose it again;
- a **known problem was deferred on purpose**: whoever finds it must know it was known, and why;
- the choice **will surprise** whoever reads the plan later: a more expensive supplier, an order that looks wrong, a step skipped;
- an **outside constraint** shaped the choice: a permit, a person's availability, a rule.

Not for choices without alternatives, preferences (they belong in `constraints.md`), or what the plan already says by itself.

**Propose, never write unasked**: *"This choice discarded X. Record it?"* Projectflow asks at the close of every step and during execution when it sees one. Decisions are written when taken, never in bulk at the end.

## File

`decisions/YYYY-MM-DD-<slug>.md`

```markdown
---
project: <name>
slice: <S<n> or null>
status: active
superseded_by: null
tags: [decision, <topic>]
description: "<one line: what was decided and what it rules out>"
---

# <Title: the decision as a statement>

**Date**: YYYY-MM-DD · **Slice**: S<n> · **Status**: active

## Context

What was on the table, and what forced a choice.

## Decision

What was decided, concretely: names, numbers, dates.

## Alternatives discarded

- **<Alternative>**: why it lost. Keep the reasons that turned out wrong too, marked as such.

## Consequences

What it costs, what to watch, what becomes possible or impossible.

## References

The slice's section, spikes, quotes, messages, documents.
```

## Superseding

Never edit a decision into its opposite. Write a new file, set `status: superseded` and `superseded_by` in the old one, and add one line under its title saying so.

## Who reads it

| Reader | When |
|---|---|
| Reality check | Before the first plan |
| Plan review | Every plan |
| `report.md` | At exit, linked |
| Neighbouring projects | Through the project memory search |
