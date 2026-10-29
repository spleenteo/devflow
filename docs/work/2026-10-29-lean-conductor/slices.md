---
shaping: true
---

# Lean conductor — Slices

Technical work: no frame, no shaping. The mandate is [STATUS.md](STATUS.md) and the numbers are in [baseline.md](baseline.md): the main session averaged 167k of context over 270 calls, and grew across the slices until auto-compact fired at 296k.

Expected weight, from the baseline: V1 is the largest lever (the context stops carrying closed slices), V2 removes about 120k of images that stayed in context for hours, V3 removes about a third of the bookkeeping calls.

Not in this work: the 48k at the first call (the user's installed plugins; Flow's share is covered by the decision of 2026-10-26 on stack presets); the conductor's reads of `shared/work.md` and `SKILL.md`, which are already targeted `grep` and `sed -n` ranges, the cheapest form a read can take.

## V1 — A clean restart at each slice close

**In.**
- At the second stop of a slice (`step: close`) and at the stop of a definition phase (Step 5, move 5), the conductor's message ends with the restart offer: the state is on disk, `/clear` then `/flow:dev` resumes at the next step. Said in one line, never pressed.
- The resume path (`## On start: open or resume`) is checked against what the next step really needs once the conversation is gone: the next slice's plan step reads its section of `slices.md`, `lessons.md`, the decisions and the previous plan; the next definition phase reads the document the last one produced. Whatever is missing from the reload table is added there, and nothing else.
- What `/clear` and `/compact` do, and that only the user can run them, stated once in `shared/work.md` with a link to the official docs page, or verified in this slice.

**Out.**
- Running `/clear` or `/compact` for the user: the conductor can't.
- A restart offer at the first stop (after the reviewed plan): execution follows at once and needs the plan, which is the bulk of what the session holds by then.
- Changing what the standing documents are.

**Done.** In a throwaway repo, a small work runs to the close of V1; `/clear`; `/flow:dev` resumes at V2 `step: plan` with the five-line summary right, and the planner gets a full packet. `measure/context.py` on that session shows the context of the first call after the resume within about 15k of the session's first call.

**Gotchas.**
- The `SKILL.md` of `/flow:dev` reloads in full on every invocation (46k chars, about 11k tokens): that is the floor of a resume, and it is still far below 150k.
- A resume at `phase: design` already reloads `shaping.md` and `docs/design/README.md`; check it doesn't need more.

## V2 — Screenshots checked out of the main session

**In.**
- In `/flow:design` (and its adapter's cautions when the adapter is the one exporting), a rule for checking a drawn screen: export the image to a scratch folder, then dispatch a subagent with the image path and what to check (layout, overlaps, text that doesn't fit, the screen against the requirement it draws); it returns a verdict in a few lines. The main session never reads the image.
- The subagent's role: an existing agent if one fits by its tools and stance (`flow:task-reviewer` reads files and reports), else a new definition. Decided in the plan.
- The user still gets to see the screens in the design tool; the rule is only about the conductor's own check.

**Out.**
- Images the user pastes or asks Claude to look at: those are the user's call.
- Downscaling images before reading them: a smaller image still stays in context for the rest of the session.
- Moving the whole drawing work into a subagent: the design phase is a dialogue with the user.

**Done.** In a throwaway repo with the design adapter, drawing one screen and checking it leaves no image block in the main session's transcript (`measure/big_results.py` lists none), and the verdict names a real defect planted on purpose.

**Gotchas.**
- In the baseline, the check ran after each edit of a screen (nine reads for four screens). The rule has to make one dispatch per round of edits cheap, or the conductor will skip the check.

## V3 — Bookkeeping in fewer writes

**In.**
- The ledger: one write per task when its review passes (dispatch, review and `complete` lines together), instead of one write per dispatch and one per review. On resume, a task with no lines is re-dispatched, which is what happens today to a task interrupted mid-flight.
- The close of a slice and of a phase: `STATUS.md`, `slices.md`, `lessons.md` and the commit in one call, as the baseline already did in its better moments ("Write V1 narrative, lessons, STATUS and commit").
- Applying review fixes to a plan: in one write, never one `sed` per finding.

**Out.**
- Dropping the ledger or its per-dispatch report: it is the memory a resume at `step: execute` needs.
- A helper script for the bookkeeping: the rule is enough.

**Done.** In a throwaway repo, a slice with three tasks runs through execute and close; `measure/bash_kinds.py` counts at most one bookkeeping call per task plus one per stop. The baseline averaged about 6.

**Gotchas.**
- `shared/work.md` § Agents says ledger lines are "written once, when the agent returns": that sentence changes, and the resume rule must still hold with it.
