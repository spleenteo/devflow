# Ledger — V3
printenv CLAUDE_CODE_SUBAGENT_MODEL_FORCE CLAUDE_CODE_SUBAGENT_MODEL: rc=1 (both unset)
Ruling: User at first stop said "ok" — the eleven review fixes are already in the plan (ab43d02); the Done items needing a fresh interactive session with the user go in as pending, the ones runnable here (bash_kinds.py fixture, rg checks) are run by the runner — user instruction — none
Ruling: this ledger is written one line per dispatch, by the rules in shared/work.md as they stood at the start of V3 (T1 changes them) — conductor instruction — none

- T1 · flow:executor · definition: sonnet · DONE · 2cbeee0
  Report: DONE; commit 2cbeee0; tests none; validate passed with warnings (unread); Verified greps match (first set checked mid-edit); Servers: none; Concerns: the close sentence placed after "…and `step:` to `plan`, add the Log line." (packet quoted it shorter); model sentence ends the two-writes bullet; file-changed notice, not re-read.
- T3 · flow:executor · definition: sonnet · DONE · 1ff6ab2
  Report: DONE; commit 1ff6ab2; tests none; grep 3 matches; validate passed with warnings (unread); Servers: none; Concerns: none.
- T2 · flow:executor · definition: sonnet · DONE · 3b0563d
  Report: DONE; commit 3b0563d; tests none; Verified greps match (lines 299, 320, 324, 326, 327; no-match set empty; Update before Commit; one-call phrase once); validate passed with warnings (unread); Servers: none; Concerns: plan-fix sentence was at 299 not 300; Step 5 move 1 "before the commit" left as is.
- T4 · flow:executor · definition: sonnet · DONE · eeb188c
  Report: DONE; commit eeb188c; tests none; `one call` 2 matches (255 close, 270 Step 5); validate passed with warnings (unread); Servers: none; Concerns: close sentence appended to the end of move 3.
- T5 · flow:executor · definition: sonnet · DONE · b5d6d7b 21d010e
  Report: DONE; commits b5d6d7b (README only, though its subject names architecture too), 21d010e (architecture); tests none; greps match; link check on the two files empty; Servers: none; Concerns: its edit script failed midway (architecture text ends "writes." not "writes,"), so two commits instead of one.
- T6 · flow:executor · definition: sonnet · DONE · ee10b23
  Report: DONE; commit ee10b23; tests none; fixture run: bookkeeping 2, git 2, work reads 2, edits elsewhere 1, `bookkeeping calls: 2`; Servers: none; Concerns: kind `work state (STATUS/plan)` renamed `work reads`.
- T3 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass, no findings · cannot verify: validate warnings (runner: expected kind)
- T3: complete
- T1 review · flow:task-reviewer · opus (top tier, critical; effort high from plan-reviewer.md) · Spec pass, Quality pass · low: work.md:207 model sentence sits after the STOP sentence, far from the `<model>` field; low: work.md:119 the recovery steps use git, a plain-folder project home can't (plan's wording); low: DONE with concerns should be DONE_WITH_CONCERNS · reviewer re-ran the four Verified greps on the committed file: all match
- T1: complete
- T4 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · low: project SKILL ~277 "Commit at each of these points…" now overlaps move 2 (pointer, no conflict); low: sentence appended to move 3 is the right reading · cannot verify: validate warnings
- T4: complete
- T2 review · flow:task-reviewer · opus (top tier, critical; effort high from plan-reviewer.md) · Spec pass, Quality pass, no findings · checked against T1's wording, the fallback line (315), the design-phase paragraph (245) and slice-runner's "close moves 1–2" · cannot verify: validate warnings, the pathspec commit form
- T2: complete
- T5 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · medium (process): b5d6d7b touches README only but its subject names architecture, and the task split into two commits of one kind; low: the two subjects read as two tasks · cannot verify: link check output
Ruling: T5's process medium is accepted with no fix round — the content is right and complete, and the only fix is rewriting history, which the commit rules forbid; the ledger lists both shas under T5 — cost if wrong: one commit subject on the branch over-claims (README and architecture) for a README-only change
- T5: complete
- T6 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · low: bash_kinds.py:9 a quoted `->`/`=>` before a docs/work path counts as a write (lookbehind `[0-9&>=-]`)
Ruling: T6 gets a runner-found medium, round 1 to the same executor — the runner re-ran the fixture (matches) plus edge cases: `cd <work dir> && cat >> V3-ledger.md <<'EOF'` counts as `work reads`, not bookkeeping, and that is how the runner writes this ledger, so the Done count on a runner transcript would undercount; `sed -i ''`, relative `> docs/work/…` and `&>` behave right — cost if wrong: the Done's "at most 8" passes on an undercount
- T6 fix 1 (SendMessage, same executor) · flow:executor · definition: sonnet · DONE · c0cbfd6
  Report: DONE; commit c0cbfd6; tests none; fixture a1–a7 unchanged (2/2/2/1, `bookkeeping calls: 2`); e1 cd+`cat >>` → bookkeeping, e2 cd+`sed -n … 2>/dev/null` → work reads, e3 `&>` → not bookkeeping; Servers: none; Concerns: none. Runner re-ran: cd+`cat >>` counts, cd+`2>&1` doesn't.
- T6 fix 1 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · low: after a cd into the work folder, `>/dev/null` or a quoted `->`/`=>` counts as a write; low: `cd docs/work` without a trailing slash is missed
- T6: complete
- Final review · flow:task-reviewer · opus (top tier; effort high) · Spec pass, Quality fail · medium: dev SKILL:211 "invoke the tool telling it where to save, commit, update `phase:`, stop" keeps the old order; medium: work.md:211 + dev SKILL:328 a runner dying after a final-review fix commit and before the tail write leaves it in no ledger line, and the resume rule only looks at tasks without `complete`; low: work.md:211 tail omits the gate's fix round; low: dev SKILL:334 pending/Final review/Gate read as separate writes; low: Step 5 one-call close (dev:356, project:270) has no recovery line; low: work.md:121 "`STATUS.md` updated first" reads as before the other documents · all quotes checked against the files by the runner: present
Ruling: Final-review fixes: both mediums and the four lows (each one phrase on the same lines) go to one fresh mid-tier executor, one commit per file under the owning task's subject (T1 work.md, T2 dev SKILL, T4 project SKILL); medium 2 takes the resume-bullet option (every task complete and no tail → the final review takes the ledger's shas plus `git log <first ledger sha>..HEAD`), which keeps the Done count unchanged — cost if wrong: a final review on resume also re-reads the task commits already reviewed
- Final-review fixes · flow:executor · definition: sonnet · DONE · 6bb3ac2 a880138 c795d5f
  Report: DONE; commits 6bb3ac2 (work.md), a880138 (dev SKILL), c795d5f (project SKILL); tests none; phrase greps show each fix, old wording gone; staged stat checked against each subject; validate passed with warnings; Servers: none; Concerns: none.
- Final-review fix review · flow:task-reviewer · opus (top tier; effort high) · Spec pass, Quality pass · low: dev SKILL:211 the parenthetical names only Step 5's moves 2–3; low: dev SKILL:334 "all" after two items reads oddly (means the pending lines too) · cannot verify: validate warnings unnamed (runner's gate: expected kind)
Gate (runner, after the fix round): validate passed with warnings (marketplace manifest, system files); old names only in README § Upgrading and shared/work.md § Upgrade; link check empty
Ruling: T6 reopened for a runner-found medium, round 2 to the same executor — bash_kinds.py on this runner's own transcript gives `bookkeeping calls: 5`, but 3 of its cd+`cat >> V3-ledger.md` heredocs are counted as git because the heredoc body holds the word git (ledger lines quote `git log`, `git cat-file`); the git test must ignore heredoc bodies — cost if wrong: the Done's bound passes on an undercount
- T6 fix 2 (SendMessage, same executor) · flow:executor · definition: sonnet · DONE · 16013c2
  Report: DONE; commit 16013c2; tests none; fixture a1–a7 unchanged; g1/g2 heredoc bodies with git or docs/work → bookkeeping, g3 `cat <<'EOF' | git commit -F -` → git, g4 python heredoc → other; Servers: none; Concerns: none. Runner re-ran on its own transcript: `bookkeeping calls: 8` (was 5).
- T6 fix 2 review · flow:task-reviewer · definition: sonnet · Spec pass, Quality pass · low: a non-heredoc `<<` (a shift inside quotes, `$((1<<n))`) in a multi-line command drops the lines after it; low: a script heredoc writing under docs/work via `.write_text(` is no longer seen as bookkeeping (worth a comment)
- T6: complete (reopened, fixed in round 2)
Done checks run by the runner: every task's Verified greps match on the final tree; the T6 fixture a1–a7 gives bookkeeping 2, git 2, work reads 2, edits elsewhere 1, `bookkeeping calls: 2`; `git cat-file -t` on every ledger sha returns commit; bash_kinds.py on this runner's own transcript (old one-line-per-dispatch ledger, so not the Done's bound) gives `bookkeeping calls: 8`
pending: In a throwaway repo, a slice with three tasks runs through execute and close via /flow:dev in a fresh interactive session (`--permission-mode default`); bash_kinds.py on the runner's transcript R gives `bookkeeping calls:` at most 8 plus the allowances (1 per `Ruling:`, 1 per reopened task, 2 per STOP); the ledger ends in `## Close draft`; record where nested transcripts land
pending: Plan fixes: between the user's yes and the runner dispatch, T holds exactly one Bash call writing V1-plan.md and no Edit on it
pending: Conductor's close: T holds one Bash call writing slices.md, lessons.md and STATUS.md chained with && up to git commit; record which construct raised an approval prompt, if any, and choose the split from it
pending: Old ledger, two fixtures (old format and new format, sha2 = `Fix review findings on T1: x` unlisted in the new one): after the resume, a flow:task-reviewer dispatch names T1 with both shas and no flow:executor dispatch names T1
Final review: done
Gate: green — `claude plugin validate .` passed with the expected warnings (marketplace manifest, system files); old names only in README § Upgrading and shared/work.md § Upgrade; link check empty

## Close draft

Narrative: Six tasks, all in parallel; T1–T5 passed their first review, and the ledger of this slice was written one line per dispatch, by the rules as they stood at its start. T5's edit script failed midway, so README and architecture landed in two commits, the first with a subject that over-claims; accepted without a rewrite. The runner's own checks on bash_kinds.py found two undercounts the reviews missed: a ledger write after `cd` into the work folder counted as a read (round 1, c0cbfd6), and a heredoc body quoting `git log` made a ledger write count as git (T6 reopened, round 2, 16013c2); on this runner's transcript the count went from 5 to 8. The final review found two mediums: dev SKILL:211 still said commit then STATUS.md for the shaping-skills phases, and the one-write tail could lose a final-review fix commit on a resume (every task complete, no tail, and the subject rule only looks at incomplete tasks); fixed in one round (6bb3ac2, a880138, c795d5f) with four one-phrase lows, the resume now takes `git log <first ledger sha>..HEAD` when there is no tail. The four Done items need a fresh interactive session with the user and are pending.
Lessons:
- Test a transcript-measuring script on a real transcript, not only on the plan's fixture: the fixture had no `cd` and no heredoc body quoting git, and both undercounted. (V3)
- When a write is deferred to a later batch, check every commit that can land before the batch: the final review's fix round needed its own resume rule. (V3)
- An executor's edit script that asserts its matches should run them all before writing any file, or one bad match splits the task across commits. (V3)
Decision candidate: none
