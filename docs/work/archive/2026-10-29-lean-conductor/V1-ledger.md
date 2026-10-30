# Ledger — V1
printenv CLAUDE_CODE_SUBAGENT_MODEL_FORCE CLAUDE_CODE_SUBAGENT_MODEL: rc=1

- T2 · flow:executor · definition: sonnet · DONE · ae8c0bf
  Report: DONE; commit ae8c0bf; tests none (level none), Verified greps match; Servers: none; Concerns: none.
- T1 · flow:executor · definition: sonnet · DONE · dec3b45
  Report: DONE; claude plugin validate passed; concerns: points at `#### The loop` (created by T5); "Commit" under never-do; two doc links added.
- T3 · flow:executor · definition: sonnet · DONE · 4780c1c
  Report: DONE; rg checks pass; concerns: Nesting paragraph also names NO_NESTING (from T1); placed between Tiers and Model per dispatch.
- T4a · flow:executor · definition: sonnet · DONE · c8d07f9
  Report: DONE; Verified rg pass; Always row trimmed, new By phase and step table, explanation extended.
- T6 · flow:executor · definition: sonnet · DONE · 4f4caf5
  Report: DONE; Verified rg 1 match line 94.
- T2 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass, no findings
- T2: complete
- T4b · flow:executor · definition: sonnet · DONE · 5cea238
  Report: DONE; plan/review use Summary and Files; rule 5 and lifecycle row name the runner; T4a untouched.
- T6 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass, no findings
- T6: complete
- T3 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · low: work.md:189 "nested" prompts not stated by the docs (say "background subagents, nested ones included"); low, cannot verify: anchor #turn-fork-mode-on-or-off
- T3: complete
- T4a review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · low: SKILL.md:180 the plan row doesn't name the slice's section of slices.md (the packet rule builds it; not a regression)
- T4a: complete
- T1 review · flow:task-reviewer · opus (top tier, critical) · Spec pass, Quality pass · medium: slice-runner.md:27 "NO_NESTING with nothing written" contradicts the ledger opened before the first dispatch → fix round 1 to the same executor · low: Agents:/User at first stop: fields without stated use; report should have been DONE_WITH_CONCERNS; link form .md vs none
- T4b review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · low: report misstated an rg result (file correct)
- T4b: complete
- T1 fix round 1 · flow:executor (same, SendMessage) · definition: sonnet · DONE · ed28c69
  Report: DONE; concern: T5 (and T3) must say the fallback keeps the ledger's first lines.
- T1 fix round 1 review · flow:task-reviewer · opus · Spec pass, Quality pass · medium: NO_NESTING told to "say" something the return format has no field for → fix round 2 · low: "first lines" understates after a STOP resume; link form; DONE vs DONE_WITH_CONCERNS
- T1 fix round 2 · flow:executor (same, SendMessage) · definition: sonnet · DONE · 21b44c1
- T1 fix round 2 review · flow:task-reviewer · opus · Spec pass, Quality pass, no findings
- T1: complete
- T5 · flow:executor · definition: sonnet · DONE_WITH_CONCERNS · 4c1b5ac, e117aa3
  Report: Verified rg pass; concerns: printenv fixed in a second commit; "there" read as the runner (fallback: the conductor asks directly); final-review bullet now follows the `Final review: run | skip` field; fallback keeps the ledger head.
- T5 review · flow:task-reviewer · opus · Spec pass, Quality fail · medium: pending:/Gate:/Final review: lost on a close resumed in a new session → fix round 1 (with three lows in the same file: NO_NESTING head wording, Files on resume, BLOCKED owner)
Ruling: T5 landed in two commits (4c1b5ac, e117aa3), against one commit per task — history isn't rewritten on a work branch — cost if wrong: one extra commit in the log, folded by a squash at merge if wanted
- T5 fix round 1 · flow:executor (same, SendMessage) · definition: sonnet · DONE · 307dec5
- T5 fix round 1 review · flow:task-reviewer · opus · Spec pass, Quality pass · low: work.md:210 tail omits `pending:` lines; close row has no start point without pending lines; Verified not re-run
- T5: complete
Ruling: the two format lows (work.md:210 `pending:` in the ledger tail; SKILL.md:181 start the close reload from `Final review:` with the `pending:` lines just before it) go to T7's executor, which runs after T5 alone — they make the format reference match the rule just written — cost if wrong: two lines outside T7's named files
- T7 · flow:executor · definition: sonnet · DONE · 1d81732, 6e40c73
  Report: Verified rg checks and Gate link check pass; "phase and step" pattern worded differently (README:89, architecture:131 match the intent).
- T7 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · low: report lacked `Servers:`
- T7: complete
- Final review · flow:task-reviewer · opus · Spec fail, Quality fail · medium: second runner in the same session; resume at execute redoes moves 1-3; red gate not handled; Done check A counts the close commit; README/architecture say the conductor checks Done and gate · low: plan reload wording in docs; step: close listed but never written; packet-on-top rule vs runner; overlapping failure cases; fallback Stops; move 5 line; nested-prompt claim unverified · cannot verify: fork-mode anchor (the page's own links use it)
- Final review fixes · flow:executor (fresh) · definition: sonnet · DONE · fd9e15d, 6907416, 143e735
  Report: link check clean; old-names check clean; slice-runner.md unchanged (reads close moves from the skill).
- Final review fixes review · flow:task-reviewer · opus · Spec pass, Quality fail · medium: red-gate STOP is a fifth stop kind not named in the Stops list nor slice-runner.md:31, no retry limit; "/tasks" is a user command the conductor can't read · low: check A prose vs command window, `rg ` substring; resume rule written twice; README:86 repetition
Ruling: the two remaining mediums and three lows go to one more fresh executor, checked by the conductor with grep instead of another review — the fixes are wording on lines already reviewed twice — cost if wrong: a wording slip found at the Done runs or the next work
