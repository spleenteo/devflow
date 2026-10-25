# V4 — Project impact lenses: Implementation Plan

> **For agentic workers:** run with `subagent-driven-development`, task by task. Absolute paths always (the shell resets its cwd). Worktree: `/Users/spleenteo/Sites/me/devflow-flow`. Never touch `/Users/spleenteo/Sites/me/devflow` or `~/.claude/` (reading is fine). Read `docs/work/2026-10-25-flow-plugin/lessons.md` first.

**Goal:** a project can add its own impact lenses in `<root>/impact-lenses.md`; `/flow:dev` hands them to impact and to every plan review, and offers a template, never creating the file unasked.

**Spec:** `slices.md` § V4; `docs/development-guidelines.md`; `lessons.md`.

## Global Constraints

- File: `<root>/impact-lenses.md` (default `docs/impact-lenses.md`; with `root` in `.flow.yml`, under that root). No config key. `project` untouched.
- Format: the same `| Lens | Looks for |` table as `lenses.md`, optionally split under `##` headings. Lens names bold, as in `lenses.md`.
- Supporting files cited as `${CLAUDE_SKILL_DIR}/<file>`; packets carry the expanded absolute path of skill files. The project lenses travel as text: the contents of `docs/impact-lenses.md`, verbatim, in the impact packet and in the slice packet (one verbatim packet, Cost discipline rule 2).
- Examples invented, generic, no real project or tool names.
- No new behaviour beyond the slice: the project lenses add to the stack lenses, never replace them.
- English; explicit `git add`; trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`; hashes with `git rev-parse --short HEAD`.

## Review Focus

1. A repo where `docs/impact-lenses.md` is absent: impact and review run as before and say "project lenses: none" once, not a finding.
2. A repo that ran Step 0 long ago: the file is still discoverable (impact and the Conventions row name it), not only offered at Step 0.
3. Project lenses reach the subagent as text it must apply, with the same report format; silence on a project lens reads as "didn't run", as for the others.
4. The fifth review row must not duplicate "Guideline compliance": project lenses are about what the change breaks in this project, guidelines about how code is written.

---

### Task 1: Template and `lenses.md` section

**Files:** create `skills/dev/impact-lenses.template.md`; modify `skills/dev/lenses.md` (a `## Project lenses` section at the end).

- Template: one-paragraph header (what the file is for, that `/flow:dev` reads it at impact and in every plan review, how to write a lens: a question about what this project breaks, not a coding rule), the table with two invented examples (e.g. **Public URLs**: a route or slug that changes must keep a redirect; **Shared export**: a field renamed in the model also changes the nightly CSV other teams read), and a commented hint on optional `##` groups.
- `lenses.md` section: where the file lives, format, who reads it (the stack-lens subagent at impact, or the single one; every plan review as the fifth row), that it adds to the stack lenses.

Also `lenses.md:3`: the packet list gains the project lenses when present.

**Verify:** link check green; the template renders as a valid table; no real names (`rg -n -i` on the personal project and tool names the controller passes in the dispatch, never written in the repo, returns nothing).
**Done:** committed ("Add the project impact lenses template"). The plan and `STATUS.md` go in their own commit first ("Plan V4"), by the controller.

### Task 2: `dev` reads the project lenses (critical)

Depends on: T1. **Files:** `skills/dev/SKILL.md`.

- Conventions table: a row **Project lenses** · `docs/impact-lenses.md` · read if present by impact and plan review; template at `${CLAUDE_SKILL_DIR}/impact-lenses.template.md`.
- Step 0: `impact-lenses.md` joins the list of what the skill adds inside `docs/` (as optional) and the `ls`; after the guidelines offer, offer the lenses template the same way, under the chosen root (the user fills it in; declined → not created).
- Cost discipline rule 1 and the `phase: impact` packet sentence name the project lenses. `phase: impact`: the stack-lens subagent's packet (or the single subagent's) includes the contents of `docs/impact-lenses.md` when present; the report names project lenses that found nothing; absent file → one line "project lenses: none".
- Slice packet: includes the contents of `docs/impact-lenses.md` when present.
- `step: review`: fifth row **Project lenses** — the project's own lenses from `docs/impact-lenses.md`, applied to the plan; when the file is absent, the review says so in one line instead of skipping the row silently.
- Nothing else changes.

**Verify:** read-through against Review Focus 1–4; old-name grep unchanged (7 allowed lines); `claude plugin validate .` as before; link check green.
**Done:** committed ("Read project impact lenses at impact and in plan review").

### Task 3: Demonstrate V4's Done

Depends on: T1, T2. Verification only. Scratch `S=/private/tmp/claude-501/-Users-spleenteo-Sites-me-devflow/6710ec3a-a9a2-4f23-8f29-504e326894bb/scratchpad/v4`; settings as V3's demo step 1 (old conductors off).

1. Fixture repo `$S/fixture` (`git init`, committed): a tiny generic app (a model, a script that exports CSV with column names built dynamically from the model's field names), `docs/work/2026-10-25-trap/STATUS.md` at `phase: impact` and `slices.md` with one slice that renames a model field. `docs/impact-lenses.md` with one lens, **Partner CSV contract**: the exported CSV's column names are a contract with another team; a change needs their sign-off and a transition period. The trap: nothing in the code says the CSV is consumed outside, so only the lens reveals that the rename breaks a contract.
2. Run: `claude -p "Resume the work trap. Run its impact phase now without asking; apply nothing; stop after the report." --output-format stream-json --verbose --plugin-dir /Users/spleenteo/Sites/me/devflow-flow`. A Skill `tool_use` names `flow:dev`. If the run ends at the resume question with no Agent call, continue with `claude -p --resume <session_id> "Resume; run impact; apply nothing; stop after the report."` (same flags), and record which path was taken. Pass: an Agent `tool_use` input contains the lens text; the final report has a finding about the CSV contract / the other team.
3. Same run on a copy without `docs/impact-lenses.md`: no project lens in any Agent input; the report says project lenses: none; compare findings with run 2 — the contract finding appears only with the file.
4. Gate (README excluded).

**Done:** outputs in the task report, then into the close narrative.
