# Ledger — V3
CLAUDE_CODE_SUBAGENT_MODEL_FORCE, CLAUDE_CODE_SUBAGENT_MODEL: unset
- T1 · flow:executor · definition: sonnet · DONE · def597d
  - Checks: all Verified passed (Files touched/Requirement corrections needed a cross-reference to reach 2). Servers: none. Concerns: none.
- T3 · flow:executor · definition: sonnet · DONE · 0a7d5fd
  - Checks: all Verified passed; reminder at 4 places; "On the ok:" became "On the ok." in § Upgrade, Writing. Servers: none. Concerns: none.
- T1 review · flow:task-reviewer · definition: sonnet · pass/pass · low: no rule for a call without `Screens:` (left as is)
- T1: complete
- T2 · flow:executor · definition: sonnet · DONE · 03bd50d
  - Checks: all Verified passed (`/flow:design` ×7). Servers: none. Concerns: demos left to the conductor.
- T2 review · flow:task-reviewer · opus/high (critical) · pass/pass · mediums: close needs move 3 before move 2 with updated: and Log line; the criterion paragraph implied a path instruction for /flow:design; lows: double colon, "said so", dropped adapter note, reminder reason at a non-switch
- T2 fix · conductor · ec2d5dc + label fix · both mediums and three lows fixed; the last low left (one wording everywhere)
- T2: complete
- Beds: v3-pen's library copied from the V2 bed (Button and Price Row), not rebuilt; README row says so
- T3 review · flow:task-reviewer · opus/high (critical) · pass/pass · two lows: lead-ins around the reminder ("On the ok." fragment; lost colon before the merge block)
- T3 fix · conductor · 7ae7fef · both lows fixed; count still 4
- T3: complete
- Close fix · conductor · 4ba9c1a · the Pen adapter's override path inside a library instance needs the alias (`<inst>/<alias>:<childId>`); found in the v3-pen demo's tool errors
- Demos (conductor), beds v3-pen, v3-pen-resume, v3-cli, v3-art: v3-cli skipped design with the reason (a terminal command), no Open commit; v3-art offered a Claude artifact because no `design:`; v3-pen offered a design file (static screen, `design: pen`) with the save-and-close reminder, committed `Open the design phase` alone with a Log line, called `flow:design` with the criterion, `Shaping:` and `Screens:`; the new requirement (discount code) went into shaping.md in English, in both tables, fidelity check by flow:plan-reviewer, then one `Close the design phase` commit with shaping.md, STATUS.md (`phase: slicing` at HEAD) and docs/design files; stop before slicing. v3-pen-resume: opening named phase design, reloaded shaping.md and docs/design/README.md, asked resume-or-new; on "riprendi" called flow:design with `Shaping:`. Noise: denials for plugin-file reads (fixed with --add-dir) and for `$(mktemp)` commands (retried)
- Gate: green
