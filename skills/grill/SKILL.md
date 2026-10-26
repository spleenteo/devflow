---
name: grill
description: Stress-tests a plan, a draft or one doubt in rounds of numbered questions, each with a recommended answer. Run by Flow's conductors, or by hand with /flow:grill.
---

# Flow: grill

Running a `/flow:` skill is the user's explicit choice of process. Inside it, no other process skill applies: not brainstorming, grilling, planning, plan execution, test-driven development or worktree skills, from any plugin or personal. Name `flow:brainstorm` and `flow:grill` by their qualified names.

Interview the user until you reach a shared understanding of the plan, draft or doubt in front of you. Map it as a **design tree**: every decision branches into the decisions that hang off it.

## Rounds

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you haven't heard. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the answers.

```
❓ **Q1** - **<question title>**: <question body, may run several paragraphs, including choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body>

➡️ <your recommended answer>
```

Word each question so that "yes" accepts your recommendation. Each answered round reshapes the tree: recompute the frontier and ask the next round. A question that depends on another still open in this round belongs to a later round.

**Facts are never asked.** What the repo, the files or the tools can tell you, you look up: dispatch the built-in `Explore` subagent ([sub-agents docs](https://code.claude.com/docs/en/sub-agents.md)), read-only. A running lookup is an unsettled prerequisite: only the questions downstream of it wait; ask the rest of the round now. The decisions are the user's.

The session is done when the frontier is empty and the user confirms the shared understanding. Don't act on it before.

## Added by Flow

**Criterion anchor.** When a `## The criterion` block is in reach (the work's `frame.md`), each question names the line of the criterion it serves. A question that serves none is not asked: it is parked. Before a criterion exists (the definition path, ahead of the frame) there is no anchor: don't ask for one.

**Target.** The caller passes the file the answers land in (`brainstorm.md`, `slices.md`, a plan). By hand, it is the file the user names, else ask. Settled answers are written there as the rounds close. Called: the caller commits on the work branch. By hand: write, don't commit, and say so.

**Parked questions.** A question that serves no criterion line, or that the user defers, goes to the target under `## Parked questions`, one line each, `- YYYY-MM-DD — <question>`. Create the section when it is missing.

**Decision candidates.** A settled answer that discards a real alternative is proposed as a decision, in one question with its gist; never written unasked. On a yes, invoke the Skill tool with skill `flow:docs` and a `decision-write` request, built per the work reference § Decisions (`${CLAUDE_PLUGIN_ROOT}/shared/work.md`), self-contained: header line plus one note line per item. The caller passes `layout`, `dir`, `work` (or `project` and `slice`) and `area`. By hand: `work: null`, and `area` from `areas:` in `.flow.yml`, else ask.

## What it returns to a caller

When the session is done, answer the caller with three short lists: the **settled answers** (one line each, also written in the target), the **parked questions** (as written), and the **decision candidates** (accepted and recorded, or declined).

By hand, say where the answers were written and that nothing was committed.

---

Grilling by Matt Pocock, MIT: see CREDITS.md.
