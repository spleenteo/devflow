# Ledger — V2
CLAUDE_CODE_SUBAGENT_MODEL_FORCE, CLAUDE_CODE_SUBAGENT_MODEL: unset
- T1 · flow:executor · definition: sonnet · DONE · 5f971c9
  - Checks: validate passes; headings in order; no stub text; import_library ×2; heredoc form; no `ds:`. Servers: none. Concerns: bed demo left to the close.
- T2 · flow:executor · definition: sonnet · dispatched with T1's review running in parallel (T2 cites only T1's section names)
- T1 review · flow:task-reviewer · opus (critical) · pass/pass · medium: no precondition on nested refs from another library; lows: call 2 drops the instance's own properties, `<child>` vs `<childId>`, alias rule said three times; cannot verify: the `edits`/`editId` retry rule's source (the Pencil MCP execute instructions)
- T1 fix round 1 · same executor · e7a5abe · medium + two lows fixed; all Verified checks re-run
- T1: complete
- T2 · flow:executor · definition: sonnet · DONE · 0292ddd
  - Checks: all Verified passed. Servers: none. Concerns: none.
- T2 review · flow:task-reviewer · opus (critical) · pass/pass · medium: List before Import; no operation creates a new area file; lows: Pen words in the skill, zero-library case, "replaced" missing from the safety rule
- Demo F1 turn 2 found a bug: the adapter's Compose names `U(...)`, which the execute API lacks (the run recovered with `Update`)
- T2 fix round 1 · same executor · both mediums, the bug, three lows
- T2 fix round 1 · same executor · ff5df90 · fixes landed (also touched T1's file, as the conductor sent both)
- T2 fix review · flow:task-reviewer · opus · pass/pass · lows: which library to import in Compose, run-on at :91, the Safety exemption names removal but not the instances' replacement; process: subject hides the T1 change, Tests line lists no commands. Cannot-verify settled by the conductor: `pen interactive -o <new>` with no `-i` creates the file (the V2 bed's files were made that way); validate passes (conductor ran it)
- T2: complete
- Close fix · flow:executor · definition: sonnet · DONE · 2951014 · scratch copies via mktemp + heredoc only; export folder absolute (relative resolves from the .pen file)
- Close fix review · flow:task-reviewer · definition: sonnet · pass/pass · lows: line 46 run-on, "relative to the working directory" reads against the Export caveat
- Demos (conductor): F1 drew Payment from the library's Button (alias generated: B), built Price Row locally on an ok, promoted it on approval in two calls (library holds it, area uses B:eHULq, local copy gone, notes and index in English); both directions answered with a proposal and no write; export on request, file checked; F2 in a new session used B:eHULq six times and created no component. Defects found and fixed: `U(...)` (ff5df90), temp file in the repo and export path (2951014)
