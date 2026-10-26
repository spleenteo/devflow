---
work: flow-own-engine
slice: V6
tags: [plan, flow-own-engine]
description: "Plan for V6: five plugin agents with model and effort, Flow's own plan, execution and review prompts, test policy, commit and server rules, model precedence; no ultrathink, no writing-plans or subagent-driven-development."
---

# V6 — Engine · plan

**Mandate**: [`slices.md` § V6](slices.md#v6--engine). **Spike**: [`spike-model-effort.md`](spike-model-effort.md), plus the runtime check below. **Guidelines**: [`docs/development-guidelines.md`](../../development-guidelines.md). **Lessons**: [`lessons.md`](lessons.md). **Decisions**: `2026-10-26-flow-writes-and-runs-its-own-plans`, `2026-10-26-atomic-commit-criteria-absorbed-not-a-dependency`.

**Execution rules**: executors on `sonnet`; reviewers on `opus` for `critical` tasks, `sonnet` otherwise; current checkout on `work/flow-own-engine`; parallel executors commit with the pathspec form; check the tree before re-dispatching; demos headless on throwaway repos, flags as an array, pre-answered prompts saying where to stop.

**Runtime check, done at this plan** (scratch plugin with one agent `model: haiku` and a skill reading `${user_config.model_mid}`): the agent is dispatched as `<plugin>:<name>`; with nothing set it ran on its definition's model; with `model_mid` set through `--settings` the skill passed it and the agent ran on it; with "run it on opus" in the prompt as well, `opus` won. The Agent input in the stream JSON carries `subagent_type` and `model`. A second run: an agent with `disallowedTools: Agent, Skill` loads, and its Bash calls appear in the stream with `parent_tool_use_id` set.

**The engine, decided here:**
- **Agents** in `agents/`, dispatched as `flow:<name>`: `planner` (`opus`, `high`), `plan-reviewer` (`opus`, `high`), `impact` (`opus`, `high`), `executor` (`sonnet`, `medium`), `task-reviewer` (`sonnet`, `medium`). Description: "Flow agent, dispatched only by Flow's conductors with a context packet; never for general requests." Reviewers, impact and planner get `Read, Grep, Glob, Bash` (planner also `Write`, for its plan file only); executor has `disallowedTools: Agent, Skill` (no other skill's TDD or execution process can take over; the presets' Rules arrive in the packet). Bodies hold the role's discipline and output contract; lenses and the object under review always come in the packet, so `impact` and `plan-reviewer` serve both conductors.
- **Tiers**: the conductors speak of "top tier" (planner, plan-reviewer, impact, the fidelity check, a `critical` task's review, the final review, a third fix round) and "mid tier" (executor, other task reviews); only the agent definitions name aliases. Model per dispatch, first hit: the user's explicit request in this session (for a role or for everything); the preference for the tier; else no `model`, so the definition holds. A role whose definition is mid, dispatched on the top tier with no request or preference, takes `model` and `effort` from the frontmatter of `plan-reviewer.md`; with a preference it takes that model and the same `effort`. `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` and `CLAUDE_CODE_EFFORT_LEVEL` beat all this; one sentence names them for the user, with the doc links from the spike.
- **One place, and the variables**: tiers, precedence, the ledger and the dispatch contract go in a new `shared/work.md` § Agents, which names no variable (it is read with Read, so nothing in it is substituted). Each conductor's SKILL.md carries a short **Models** paragraph with the substituted values: `${user_config.model_top}`, `${user_config.model_mid}` (empty, or beginning with `${`, = unset) and the expanded path `${CLAUDE_PLUGIN_ROOT}/agents/`, then points to § Agents.
- **Ledger**: `<work dir>/V<n>-ledger.md`, first line `# Ledger — V<n>`. At the start of execute the conductor runs `printenv CLAUDE_CODE_SUBAGENT_MODEL_FORCE CLAUDE_CODE_SUBAGENT_MODEL` once and writes the result on the second line. Then one line per dispatch, `- <task> · <agent> · <model: passed value, or "definition: <alias>", plus "forced" when the variable is set> · <outcome> · <commits>`; `- T<n>: complete` when a task's review passes; `Ruling: <what> — <why> — <cost if wrong>` lines. Each agent's report is appended under its line, trimmed to status, commits, tests run, concerns. On resume at `step: execute` the ledger is reloaded and tasks marked complete are never dispatched again. Written by the conductor, committed with the close.
- **Test policy** (written once, in `executor.md`; the task-reviewer receives that file's expanded path in its packet and checks against it): level from the packet (`tests:`, else the project's `Level:`). `none`: no test file written, no test command run. `essential`: tests for code in the sensitive areas only. `full`: test first on new code. Runs are focused on the files the task touched; the full suite runs only at the gate, at close, by the conductor. The task-reviewer runs no tests and no build: it reads the executor's evidence and the diff.
- **Commit rules** (executor only, credited to thoughtbot's atomic-commits, MIT): one commit per task; build and the level's tests green, app working, no dead code; one kind of work per commit (refactor, feature, cleanup), a task holding two kinds splits them, refactor first, and says so; a review fix is its own commit, `Fix review findings on T<n>: <what>`; `git add <paths>` then `git commit -m … -- <paths>`, retried once after a second when `index.lock` is busy; never `-A`, `.`, `--amend`, rebase, push.
- **Server rule** (executor): start no dev server, watcher or long-running process; when a check needs one, report folder, command, port and URL and leave it to the conductor; anything started for a check is stopped before returning. The conductor follows the same rule at close.
- **Execution loop** (dev, replacing `subagent-driven-development`): check the tree first (a dead run may have left files). Per task, dispatch `flow:executor` with the packet, the task text and the Interfaces of the tasks it depends on. Tasks with no pending dependency and disjoint files run in parallel; tasks sharing a file or a build step that would see the other's half-written files run one after another. Statuses: `DONE` → review; `DONE_WITH_CONCERNS` → read the concerns, then review; `NEEDS_CONTEXT` → answer from the repo and the packet, continue the same executor; `BLOCKED` → more context, then the top tier, then split the task, else a ruling, or stop for one of the four reasons. Review: `flow:task-reviewer` on the task's own commits (`git show <shas>`, from the executor's report), never a BASE..HEAD range that parallel tasks share. Findings: rounds 1–2 go back to the same executor (SendMessage; a fresh executor with the findings and the commits when it's unavailable), each followed by a review of the fix commits; round 3 is a fresh executor on the top tier; after it, a ruling and on. Stops only for an irreversible step, a security matter, a side effect outside the checkout, a plan broken beyond guessing. Final review (`task-reviewer`, top tier, the slice's commits) when the plan has more than four tasks or touches files shared with other slices; its findings get one fix dispatch and one review, residuals are ruled.
- **Planner output**: each task also states **Interfaces** (what it consumes from earlier tasks, what it produces for later ones) when another task depends on it; deviations from the mandate are returned as lines, and the conductor records them in `slices.md` (§ Deviations found while planning) as today.
- **Credits**: `CREDITS.md` at the root with superpowers' and atomic-commits' MIT notices and what was taken; one credit line in each agent body that took a rule.

## Tasks

### T1 — Five agents and credits · `critical`
- **What**: the five definitions per "Agents", bodies per "Test policy", "Commit rules", "Server rule". `planner`: Flow's plan format (this work's V-plans: header with Mandate, Guidelines, Lessons, Execution rules; the decisions taken; Tasks with What / Files / Verified / Done, `depends on`, `critical`; Order; Deviations from the mandate), TDD only where the level asks, under 100 lines, saves only to the path given, returns the path and the deviation lines. `plan-reviewer` and `impact`: apply the packet's lenses, read the code or files to check existence, report ranked findings as what · where · why · fix with lenses that found nothing named, edit nothing. `executor`: one task, scope discipline, the status contract and a short report. `task-reviewer`: spec compliance and quality on the commits given, checks against the test policy and commit rules of the `executor.md` path in its packet (never a copy), runs no tests or build, verdict lines, edits nothing. `CREDITS.md`.
- **Files**: `agents/{planner,plan-reviewer,impact,executor,task-reviewer}.md`, `CREDITS.md` (new).
- **Verified**: `claude plugin validate .`; a headless run in a throwaway repo lists the five as `flow:*` in the `init` event's `agents`.
- **Done**: five agents, credits on file.

### T2 — § Agents and the plan, review and impact steps · `critical` · depends on: T1
- **What**: `shared/work.md` § Agents per "Tiers", "One place, and the variables", "Ledger". `skills/dev/SKILL.md`: the **Models** paragraph; Why paragraph without `writing-plans` and `subagent-driven-development`; Cost discipline rule 5 → tiers by role, pointing to § Agents; impact dispatches `flow:impact` (two, or one on a one-slice work); `step: plan` dispatches `flow:planner` with the packet and the path, and records the returned deviations in `slices.md`; `step: review` dispatches `flow:plan-reviewer` with the lens table; Step 5's fidelity-check subagent is `flow:plan-reviewer`; every `ultrathink` and the dependency checks for the two superpowers skills removed; lifecycle table rows → the agents.
- **Files**: `shared/work.md`, `skills/dev/SKILL.md`.
- **Verified**: `rg -n -i 'ultrathink|writing-plans|subagent-driven' skills shared </dev/null` finds nothing in `dev`; `claude plugin validate .`.
- **Done**: plan, review and impact run on Flow's agents with the model precedence.

### T3 — The execution loop · `critical` · depends on: T2
- **What**: `skills/dev/SKILL.md` `step: execute` per "Execution loop" and "Ledger"; the resume table reloads the ledger at `step: execute`; `step: close` reads the ledger's rulings, runs the full suite only through the gate, follows the server rule, commits the ledger with the close; the worktree line removed.
- **Files**: `skills/dev/SKILL.md`.
- **Verified**: read-through against "Execution loop"; `claude plugin validate .`.
- **Done**: a slice executes with no external skill.

### T4 — `/flow:project` and dependencies · depends on: T2
- **What**: `skills/project/SKILL.md`: the **Models** paragraph; the reality check dispatches `flow:impact` (Resources, Sequence; one on a one-slice project), the plan review and the fidelity check `flow:plan-reviewer`, all pointing to § Agents; `ultrathink` removed; Cost discipline names the tiers. `dependencies.md`: the `writing-plans`, `subagent-driven-development` row removed, the line-5 example and the superpowers section's "Provides" line rewritten to `brainstorming` only (it leaves in V7).
- **Files**: `skills/project/SKILL.md`, `dependencies.md`.
- **Verified**: `rg -n -i ultrathink skills agents </dev/null` prints nothing; `bash -n install.sh` and `./install.sh` here still parse the table.
- **Done**: as verified.

### T5 — Demonstrate and gate · depends on: T3, T4
- **What**: headless, `--max-budget-usd 15` per run, `lsof -nP -iTCP -sTCP:LISTEN` before and after each run. **Fixture** (scratchpad, built at this plan): a Node repo on `work/greet` cut from `main`; `.flow.yml` `stacks: [node]`, `merge: local`; `docs/development-guidelines.md` with `## Tests` (`Level:`, `Sensitive areas:`) and `## Gate`; `src/auth/token.js` (`makeToken`), `src/ui/banner.js` (`banner`), `src/index.js`; `docs/work/2026-10-26-greet/STATUS.md` at `phase: slice`, `slice: V1`, `step: plan`, impact skipped in the Log; `slices.md` with one slice V1: a refactor (move name normalization into `src/auth/name.js`), a feature (the banner greets the normalized name), and a tiny HTTP server `src/server.js` on port 4321 whose Done is "`curl localhost:4321/` shows the greeting" (tempts a server). Prompt: "/flow:dev resume greet; the owner approves the plan and all review fixes, execute, close the slice, record no decision; stop after the close, no exit sequence." Settings for a preference: `--settings '{"pluginConfigs":{"flow@inline":{"options":{"model_mid":"haiku"}}}}'`.
  1. `Level: none`, the preference set: plan → review → execute → close; no test file in `git log -p main..`, no test command in any Bash call (main or subagent); planner and plan-reviewer dispatches carry no `model`, executor and task-reviewer carry `haiku`; the ledger names each agent and model.
  2. `Level: essential`, `Sensitive areas: src/auth/`, `vitest` installed with `scripts.test`, the preference set, prompt adding "run the executors on sonnet": tests only under `src/auth/`; executor dispatches carry `sonnet`, task-reviewers `haiku`.
  3. `Level: full`, no settings: every test command in a subagent's Bash names files of its own task; `npm test` runs once, in the main session at the gate; executor dispatches carry no `model`, ledger "definition: sonnet".
  4. In 1–3: each commit holds a single kind (task commits, plus `Fix review findings on T<n>` commits); listening ports unchanged after the run; no subagent `Skill` call.
  5. A folder of projects with a home at `phase: reality`, prompt "run the reality check and stop after the report": the run dispatches `flow:impact`, no `effort` in the input.
  Then `rg -i ultrathink skills agents` and the Gate with the narrowing.
- **Files**: none in the repo.
- **Verified**: `git`, `jq` over the stream JSON (Agent inputs, Bash calls by `parent_tool_use_id`), the ledger.
- **Done**: outcomes as stated, Gate green.

## Order

T1 → T2 → T3 and T4 (separate files) → T5. One commit per task, pathspec form.

## Deviations from the mandate

- **Reports live in the ledger**, under each dispatch line, not as separate files.
- **`impact` and `plan-reviewer` serve `/flow:project` too**: the reality check and the action-plan review reuse them, their lenses in the packet.
- **A top-tier task review reads its alias from `plan-reviewer.md`**, so aliases stay in the definitions only.
- **The `writing-plans`, `subagent-driven-development` row leaves `dependencies.md` now**; superpowers stays for `brainstorming` until V7.
- **`effort` is not observable in the stream JSON**: Done 8 is shown by the dispatch carrying no `effort`, so the definition's holds.
- **"One commit per task" counts the task's work**: a task holding two kinds makes one commit per kind, and each review fix is its own named commit (no `--amend`, no rebase while executors share the checkout).
- **The executor can't invoke skills** (`disallowedTools: Agent, Skill`): while superpowers stays installed for `brainstorming`, its TDD and execution skills can't take over a task.
- **The fidelity checks of Step 5** (both conductors) run on `flow:plan-reviewer`.
- **Stale prose left for V8**: `README.md` and `docs/architecture.md` on superpowers and the execution.
