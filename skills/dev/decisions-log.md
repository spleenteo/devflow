# Decisions log

`docs/decisions-log/` is the memory of *why*. It outlives the works, which get archived, and the code, which changes. One file per decision, dated, never rewritten into something else.

## When to write one

Write a decision when:

- a **real alternative was discarded**: in six months someone will propose it again;
- a **known problem was deferred on purpose**: whoever finds it must know it was known, and why it's still there;
- the behaviour **will surprise** whoever reads the code: a guard that looks useless, a callback in an unexpected place, a limit chosen against the obvious default;
- an **outside constraint** shaped the code: a platform limit, a client requirement, a legal rule.

Don't write one for choices without alternatives, for style preferences (they belong in `development-guidelines.md`), or for what the code already says by itself.

**Propose, never write unasked**: *"This choice discarded X. Record it in `decisions-log/`?"* Devflow asks at the close of every step. Decisions are written when taken, never in bulk at the end: by then the reason has faded.

## File

`docs/decisions-log/YYYY-MM-DD-<slug>.md`. The date is when the decision was taken; the slug names the decision, not the work.

```markdown
---
work: <slug of the work, or null>
status: active
superseded_by: null
tags: [decision, <area>, <topic>]
description: "<one line: what was decided and what it rules out>"
---

# <Title: the decision as a statement>

**Date**: YYYY-MM-DD · **Work**: `<slug>` · **Status**: active

## Context

What was on the table, and what forced a choice. Two to five sentences.

## Decision

What was decided, in one paragraph. Concrete: names, numbers, paths.

## Alternatives discarded

- **<Alternative>**: why it lost. Keep the reasons that turned out wrong too, marked as such: they explain the history.

## Consequences

What it costs, what to watch, what becomes possible or impossible. Include the known problem deferred, if any, and where it will show up.

## References

Links to the work's `shaping.md` or `slices.md`, spikes, external docs, tickets.
```

## Superseding

A decision is never edited into its opposite. When it changes:

1. Write a new file with the new decision.
2. In the old one set `status: superseded` and `superseded_by: <new file>`, and add one line under the title saying so.

History stays readable. The question in six months is "why didn't we do X?", and the answer is often in a superseded file.

## Who reads it

| Reader | When |
|---|---|
| Impact lens "Memory and debt" | Before the first plan: does the work contradict or obsolete a decision? |
| Plan review | Every plan: does it repeat a choice differently from a recorded decision? |
| `devflow-docs` | Links the work's decisions from the changelog entry |
| `devflow-archive` | Leaves them in place: they outlive the work |
