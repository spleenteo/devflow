---
work: flow-own-engine
slice: V7
tags: [plan, flow-own-engine]
description: "Plan for V7: flow:brainstorm and flow:grill, ported and credited; the definition path brainstorm → grill → frame in both conductors; grill on a doubt inside a slice; superpowers leaves."
---

# V7 — Widen and narrow · plan

**Mandate**: [`slices.md` § V7](slices.md#v7--widen-and-narrow). **Guidelines**: [`docs/development-guidelines.md`](../../../development-guidelines.md). **Lessons**: [`lessons.md`](lessons.md). **Decisions**: `2026-10-25-no-grill-me-dependency`, `2026-10-26-flow-writes-and-runs-its-own-plans`. **Sources**: superpowers 7.0.0 `skills/brainstorming/` (`SKILL.md`, `builder-check-prompt.md`; MIT, Jesse Vincent), in the local plugin cache; `mattpocock/skills` `skills/productivity/grilling/SKILL.md` and `LICENSE` (MIT, Matt Pocock), fetched to the session scratchpad at this plan.

**Execution rules**: executors on `sonnet`; reviewers on `opus` for `critical` tasks, `sonnet` otherwise; current checkout on `work/flow-own-engine`; parallel executors commit with the pathspec form; demos headless on throwaway repos, flags as an array, a `--resume` loop where questions come first, every turn's answer written out.

**The two skills, decided here:**
- **Process ownership** (top of both conductors and both new skills): running a `/flow:` skill is the user's explicit choice of process; inside it no other process skill applies (brainstorming, grilling, planning, plan execution, test-driven development or worktree skills, from any plugin or personal). `flow:brainstorm` and `flow:grill` are always named by qualified name. No sentence names superpowers.
- **`flow:brainstorm`** (`skills/brainstorm/SKILL.md`, user-invocable, not forked: a dialogue). Description: Flow's dialogue for an idea that isn't defined yet; run by Flow's conductors before the frame, or by hand with `/flow:brainstorm`; no product categories, so it doesn't trigger on any creative request. Kept from `brainstorming`: what do you know first; one open question per message; play back in chunks with guesses marked; size the work; the written description; the builder check. Changed:
  - **Exits instead of executing**: no hand-off to a plan or build skill. Taking the skip offer ends it at once, as the source does: called, it returns to its caller; by hand, it names `/flow:dev` or `/flow:project` as the next step. A clear request ends it the same way.
  - **Writes where the caller says**: the caller passes the path (the conductors pass `<work dir>/brainstorm.md` or `<home>/brainstorm.md`); by hand with no path it asks, never `docs/superpowers/`. Called, the caller commits on the work branch; by hand it writes, doesn't commit, and says so.
  - **Visuals as local artifacts**: offered just in time, in a message of their own; on a yes, an HTML or SVG file written next to the target. Never a server, never a published page.
  - **No spike**: a throwaway build is proposed to the caller, never built here.
  - **Builder check** on `flow:plan-reviewer`, top tier: packet = the document's path, the domain, "the document is its own mandate", one lens **Builder questions** (the adapted text of `builder-check-prompt.md`: the questions a builder would still need answered, each with why it changes the plan); the reviewer's ranked findings are read as ranked questions. The skill carries a Models line (`${user_config.model_top}`, unset rule, `${CLAUDE_PLUGIN_ROOT}/agents/`), pointing to § Agents. § Agents' "Used for" and the five agents' descriptions say "Flow's skills" instead of "Flow's conductors".
- **`flow:grill`** (`skills/grill/SKILL.md`, user-invocable, not forked). Description: stress-tests a plan, a draft or one doubt in rounds; run by Flow's conductors, or by hand with `/flow:grill`. From `grilling`: the design tree, rounds over the **frontier**, numbered questions in its format, each with a recommended answer worded so "yes" accepts it, facts looked up by a read-only subagent (the built-in `Explore`, [sub-agents docs](https://code.claude.com/docs/en/sub-agents.md)) never asked, done when the frontier is empty and the user confirms. Added:
  - **Criterion anchor**: when a `## The criterion` block is in reach, each question names the line it serves, and a question serving none is parked. Before a criterion exists (the definition path), no anchor.
  - **Caller's target**: the file answers land in (`brainstorm.md`, `slices.md`, a plan); by hand, the file the user names, else asked. Writes and commits as `flow:brainstorm` does.
  - **Parked questions**: written to the target under `## Parked questions`, one line each, `- YYYY-MM-DD — <question>`, the section created when missing.
  - **Decision candidates**: a settled answer that discards a real alternative is proposed as a decision; on a yes, `decision-write` to `flow:docs` per the work reference § Decisions. Called, the caller passes `layout`, `dir`, `work` (or `project`, `slice`) and `area`; by hand, `work: null`, `area` from `areas:` in `.flow.yml`, else asked.
- **Definition path** (both conductors): a product work whose problem isn't clear runs `flow:brainstorm` (writes `brainstorm.md`) → `flow:grill` (target `brainstorm.md`) → the frame: `framing-doc` when there is source material, else the conductor writes `frame.md` with the criterion block on top, built from both, and carries the parked questions into its body. `brainstorm.md` joins the "never reloaded" column of the resume table (dev) and the file list (project). Inside a slice or a definition phase, a vague point goes to `flow:grill` with the point and the document it belongs to as target; this replaces "one question at a time".
- **superpowers leaves**: its rows and section in `dependencies.md`, and every mention in skills and agents except credit lines. The decision `2026-10-25-no-grill-me-dependency.md` (legacy) gets `## Status log` with one line, `- 2026-10-26 — partly superseded by flow:grill: grill rounds replace the one-question rule; grilling is ported with credit, still not a dependency`; frontmatter unchanged, no `kind:`.

## Tasks

### T1 — `flow:brainstorm` · `critical`
- **What**: the skill per "Process ownership" and "flow:brainstorm"; a credit line at its end. `agents/*.md` descriptions and `shared/work.md` § Agents "Used for" per the builder-check bullet.
- **Files**: `skills/brainstorm/SKILL.md` (new), `agents/*.md` (descriptions only), `shared/work.md`.
- **Verified**: `claude plugin validate .`; `rg -n -i 'superpowers|writing-plans|server' skills/brainstorm </dev/null` shows only the credit line and the "never a server" rule.
- **Done**: as decided.

### T2 — `flow:grill` · `critical`
- **What**: the skill per "Process ownership" and "flow:grill"; a credit line at its end.
- **Files**: `skills/grill/SKILL.md` (new).
- **Verified**: `claude plugin validate .`; the round format and the four additions present.
- **Done**: as decided.

### T3 — Conductors, dependencies, credits, decision · `critical` · depends on: T1, T2
- **What**: `skills/dev/SKILL.md`: the process-ownership line; Why; Step 1 question 5; the `frame` row of the phase table; the "never swap in another tool" sentence; "If a point stays vague"; the resume table (`brainstorm.md`); the lifecycle note naming the thinking tools. `skills/project/SKILL.md`: the same, with Step 1 question 7, the file list, and the plan template's "To settle before starting" line. `dependencies.md`: superpowers rows and section removed, the opening sentence still true. `CREDITS.md`: the opening sentence rewritten (skills and agents, three projects), superpowers' `brainstorming` added, Matt Pocock's `grilling` with its MIT notice. The decision's status-log line.
- **Files**: `skills/dev/SKILL.md`, `skills/project/SKILL.md`, `dependencies.md`, `CREDITS.md`, `docs/decisions-log/2026-10-25-no-grill-me-dependency.md`.
- **Verified**: `rg -n -i superpowers skills agents dependencies.md </dev/null` → credit lines only; `` rg -n '`brainstorming`|grill-me|one question at a time' skills </dev/null `` → nothing outside the process-ownership sentence and `skills/brainstorm`, `skills/grill` credits; `./install.sh` here exits 0 with no `brainstorming` row and no superpowers command; `bash skills/docs/scripts/decisions-check --areas engine,workflow,presets,release docs/decisions-log` → `checked 5, legacy 3, errors 0`; `claude plugin validate .`.
- **Done**: as verified.

### T4 — Demonstrate and gate · depends on: T3
- **What**: headless, superpowers installed and enabled (user scope), `--max-budget-usd 10` per run, listening ports before and after. In each run, first check that superpowers' SessionStart hook ran (its event or injected context in the stream); if it isn't observable headless, say so in the close. No Skill call precedes the conductor's first step.
  1. `/flow:brainstorm make the README title bold` in a throwaway repo → it says the request is clear and exits; no file written; no other brainstorming skill invoked.
  2. `/flow:brainstorm`, path given, on "a one-page site for my bakery; I want to compare two layouts", context pre-answered. Turn 1 → the visual offer on its own, no server. Turn 2 (`--resume`) "yes" → an HTML or SVG file next to the path; no server process; ports unchanged.
  3. `/flow:grill` on a throwaway `plan.md` (five lines, two open choices), target that file. Turn 1 → a numbered round, each question with a recommendation. Turn 2 "yes to Q1, park Q2" → `plan.md` has `## Parked questions` with Q2's line.
  4. `/flow:dev` in a throwaway repo, a product request with the problem unclear: a `--resume` loop of at most six turns up to the frame commit, answers written out (turn 1 profile and opening, "the problem isn't clear"; then "skip the questions" to the brainstorm; "yes to every recommendation" and "we're done" to the grill; "write the frame and commit it, then stop") → Skill calls in order `flow:brainstorm`, `flow:grill`; `brainstorm.md` and `frame.md` (criterion on top) committed on `work/<slug>`; no Skill call outside `flow:*` and the presets.
  5. `/flow:project` in a folder of projects, the same shape → the same order, both files in the home.
  Then the Gate with the narrowing.
- **Files**: none in the repo.
- **Verified**: `git`, `jq` over the stream JSON (Skill calls by name and order, Bash calls, hook events), the files.
- **Done**: outcomes as stated, Gate green.

## Order

T1 and T2 in parallel (separate files) → T3 → T4. One commit per task, pathspec form.

## Deviations from the mandate

- **The builder check runs on `flow:plan-reviewer`** with one lens, its findings read as questions: no sixth agent, the tier from § Agents. The agents' descriptions widen from "Flow's conductors" to "Flow's skills".
- **The brainstorm writes `brainstorm.md`** and the grill targets it; the conductor writes `frame.md` from both when there is no source material; `framing-doc` stays for source material.
- **Process ownership is stated in every Flow entry skill**, naming process kinds, not plugins, so another plugin's brainstorming, planning or TDD skill can't take over inside a Flow run.
- **The brainstorm's spike becomes a proposal**; visuals are local files only.
- **Facts in `flow:grill` are looked up by the built-in `Explore`**, not by a Flow agent.
- **The decision on grill-me keeps `status: active`**: partly superseded, said in its status log; legacy, so no `kind:`.
- **Stale prose left for V8**: `README.md` and `docs/architecture.md` on superpowers, brainstorming and grill-me.
