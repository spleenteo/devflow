---
work: lean-conductor
slice: V2
tests: none
updated: 2026-10-29
---

# V2 plan — Screenshots checked out of the main session

**Mandate**: [slices.md § V2](slices.md) · decisions: [design is agnostic](../../../decisions-log/2026-10-27-design-is-agnostic-skill-plus-tool-adapter.md), [design runs as a dev phase](../../../decisions-log/2026-10-27-design-runs-as-a-dev-phase.md), [slice runner](../../../decisions-log/2026-10-29-slice-execution-runs-in-a-runner-subagent.md) · **Guidelines**: [Tests, Naming, Language, Commits, Gate](../../../development-guidelines.md) · **Lessons**: [lessons.md](lessons.md) · **Execution rules**: [executor.md](../../../../agents/executor.md)

**Summary**
1. New agent `agents/screen-checker.md`: mid tier, low effort, `tools: Read`, returns a verdict per screen in a few lines.
2. `skills/design/SKILL.md`: a § Check (export as PNG to a `mktemp -d` folder, one checker dispatch per round of edits, no image ever in session), Compose calls it, the contract's Export and Safety's "Exports only on request" gain the check export, a § Models paragraph.
3. `skills/design-pen/SKILL.md`: Export allows the check export; Session's scratch rule cites it; Cautions name `TakeScreenshot`.
4. `shared/work.md` § Agents and `docs/architecture.md` list the new agent. The Done runs at the close, by the conductor with the user.

**Files**: agents/screen-checker.md, skills/design/SKILL.md, skills/design-pen/SKILL.md, shared/work.md, docs/architecture.md

## The slice, decided here

- The check export extends the contract's `### Export` instead of adding a ninth operation: same tool call, another folder; a project's own adapter keeps the eight sections it already fills.
- Pen's tools that return images into the session, from this machine's transcripts: `execute` with `TakeScreenshot([...])` (339 results, 18 of them `edits` retries of a snippet holding it) and `browser` with `action: "return-screenshot"` (38) or `"cdp"` (11). `Export` returned none.
- The folder: `mktemp -d`, made once per run of `/flow:design` at the first check and reused; never inside the base, never deleted by the skill, never committed.
- One dispatch per round of edits, all screens of the round in it, before step 6 asks for approval: the Gotcha's cost rule. Artifacts (HTML) are not checked: they aren't drawn through the adapter.
- When the dispatch runs in the background, the skill says one line, ends the turn and touches neither the design file nor the folder until the notification arrives. No `Agent` tool: skip the check and say so; never read the image in session instead.
- `/flow:project` and `/flow:dev`'s design phase reach the rule through the skill; neither file changes.

## Tasks

### T1 — The screen-checker agent
- **What**: create `agents/screen-checker.md` in the shape of `agents/task-reviewer.md`. Front matter: `name: screen-checker`, the `description:` the other agents share, `tools: Read`, `model: sonnet`, `effort: low`. Opening line: you look at exported screens and say what is wrong; you change nothing. § What comes in the packet: the criterion block when there is one, then per screen its absolute PNG path and what it must show (the requirement lines, or the user's request by hand), and what to check. § What you do: `Read` each image; check layout and alignment, overlaps, text cut or overflowing its box, and the screen against what it must show; judge only what the image shows. § What you never do: read any file but the given images; write; run commands; dispatch agents or invoke skills; propose a redesign. § What you never do also says: never pass a screen you could not read. § What you return: one line per screen `<screen>: pass | fail`, or `<screen>: unreadable — <reason>`, then at most 3 defect lines per screen `<screen> — <defect> — <where in the image>` and `+N more` past them, or `No defects.`
- **Files**: `agents/screen-checker.md`
- **Verified**: `claude plugin validate .` passes with only the guideline's expected warnings; `rg -n '^tools: Read$|^effort: low$|^model: sonnet$' agents/screen-checker.md` → 3 matches; `rg -c '^## What (comes in the packet|you do|you never do|you return)$' agents/screen-checker.md` → 4; `rg -n 'pass \| fail|unreadable' agents/screen-checker.md` → the return lines.
- **Interfaces**: produces the agent `flow:screen-checker`, its packet and its return format, for T3.

### T2 — shared/work.md § Agents
- **What**: after the Executor row, `| Screen checker | \`flow:screen-checker\` | mid | A drawn screen's check, from exported images (/flow:design) |`. The Tiers paragraph's mid list becomes "(executor, other task reviews, the screen checker)".
- **Files**: `shared/work.md`
- **Verified**: `rg -n 'screen-checker|screen checker' shared/work.md` → the table row and the Tiers line.

### T3 — design SKILL: the check · critical · depends on: T1
- **What**: in `skills/design/SKILL.md`:
  1. New `## Models` after § Called: "Flow's agents are in `${CLAUDE_PLUGIN_ROOT}/agents/` (dispatched as `flow:<name>`). Preference for the mid tier: `${user_config.model_mid}`. A value that is empty, or begins with `${`, is unset. Which model each dispatch takes and the dispatch contract: the work reference, § Agents (`${CLAUDE_PLUGIN_ROOT}/shared/work.md`)."
  2. § Called (line 16): the list of sections gains Check. Contract, `## Cautions` bullet (line 64): "what can go wrong with the tool's files, and how to avoid it; and every tool or call that returns an image into the session". Contract, `### Export` bullet (line 63): "export nodes to a folder; also the check export of § Check (PNG, to a scratch folder outside the base)".
  3. § Compose: step 6 becomes "Run § Check on the screens changed in this round, then ask whether the screen is approved."
  4. New `## Check` after § Compose: the main session never receives an image, by `Read` or by any tool result: never read an exported image unless the user asks to look at it, and never call a tool the adapter's `## Cautions` name as returning one. Once per round of edits, for design files only: make the folder with `mktemp -d` at the first check of the run and reuse it; export the round's screens through the adapter's Export as PNG to it; check each path with `test -f`; dispatch `flow:screen-checker` (mid tier, see § Models) with T1's packet, paths absolute; when the dispatch runs in the background, say one line, end the turn and touch neither the design file nor the folder until the notification arrives. Fix the defects it names, or show the verdict to the user in step 6; an `unreadable` screen is reported to the user in one line at step 6, never counted as a pass. The folder is outside the base and never committed. No `Agent` tool: skip the check and say so in one line.
  5. § Safety, "Exports only on request" (line 117): "Exports only on request, except the check export of § Check." The rest of the bullet stays.
- **Files**: `skills/design/SKILL.md`
- **Verified**: `rg -n '^## Check$|^## Models$|screen-checker|except the check export' skills/design/SKILL.md` → both headings, the dispatch in § Check, the Safety line; `rg -n 'returns an image into the session' skills/design/SKILL.md` → the Cautions bullet; `rg -n 'TakeScreenshot|execute' skills/design/SKILL.md` → no match (the skill names no tool mechanics); `claude plugin validate .` passes.
- **Interfaces**: consumes T1's packet and return; produces the heading `## Check` that T4 cites as "`/flow:design` § Check".

### T4 — design-pen adapter: check export and Cautions
- **What**: in `skills/design-pen/SKILL.md`: § Session, the CLI bullet (line 46): after "Nothing temporary is ever written inside the base." add "The check export of `/flow:design` § Check goes to a `mktemp -d` folder too." § Export (line 92): "only on request, or for the check export of `/flow:design` § Check: format `png`, `{scale:1}`, the folder it passes, absolute and outside the base, used as is." The rest stays. § Cautions, new bullet: "`TakeScreenshot([...])` in `execute`, also inside an `edits` retry of a snippet holding it, and `browser` with `action: \"return-screenshot\"` or `\"cdp\"` attach images to the tool result, so they land in the session's context: never call them; the check goes through Export (`/flow:design` § Check)."
- **Files**: `skills/design-pen/SKILL.md`
- **Verified**: `rg -n 'check export' skills/design-pen/SKILL.md` → the Session and Export lines; `rg -n 'TakeScreenshot' skills/design-pen/SKILL.md` → 1 match, in § Cautions; `rg -n 'return-screenshot' skills/design-pen/SKILL.md` → 1 match; `claude plugin validate .` passes.

### T5 — architecture
- **What**: `docs/architecture.md` line 132, after "the corrections it returns are written into `shaping.md`.": "Each round of edits is checked by `flow:screen-checker` (mid tier) from PNG exports in a scratch folder, so no image enters the main session." Line 214, the agents node: add `screen-checker` after `task-reviewer`.
- **Files**: `docs/architecture.md`
- **Verified**: `rg -n 'screen-checker' docs/architecture.md` → lines 132 and 214; the Gate's link check prints nothing.

## Order

T1, T2, T4, T5 in parallel (disjoint files). T3 after T1.

## Done check at close (the conductor with the user)

Fixture in `$(mktemp -d)/demo`: `git init`, a README commit, `.flow.yml` with `design: pen`, committed. The Pen app is open with its MCP server. The user runs `claude --plugin-dir /Users/spleenteo/Sites/me/flow --permission-mode default`, then `/flow:design` "a sign-in screen: email, password, a Sign in button", accepts the index, creates `docs/design/auth.pen` in the app when asked, approves the first round, then asks for one more round: "set the button label to 'Sign in to your Acme workspace now' and keep the button 120 px wide" (the planted defect: text that doesn't fit). `T` is the newest `~/.claude/projects/<key>/*.jsonl`; `S` is the second `agent-*.jsonl` under `${T%.jsonl}/subagents/` whose `.meta.json` holds `"agentType":"flow:screen-checker"`, by its `toolUseId`'s order in `T`.

- No image in session: `python3 -I -c 'import json,sys;print(sum(1 for l in open(sys.argv[1]) for d in [json.loads(l)] if isinstance((d.get("message") or {}).get("content"),list) for c in d["message"]["content"] if c.get("type")=="tool_result" and isinstance(c.get("content"),list) for b in c["content"] if b.get("type")=="image"))' "$T"` → 0; unique `tool_use` ids with `name == "Agent"` and `input.subagent_type == "flow:screen-checker"` in `T` (a `python3 -I -c` one-liner, like the one above) → 2; `git -C <fixture> status --short --untracked-files=all | rg -c '\.png$'` → no match.
- The verdict: the second round's task notification in `$T` names the button label not fitting.
- No blocking prompt: the same one-liner on `S` → 1 or more; `grep -c '"is_error":true' "$S"` → 0; the user notes whether a prompt appeared in the main session (approved prompts don't fail the item). If the checker can't read the folder, the item fails and the narrative names it with a decision candidate (a folder the subagent can already read).
- One image's cost: in `S`, context per assistant message (input + cache read + cache creation, deduplicated by `message.id`, the V1 one-liner) of the message after the image's `tool_result` minus that of the message that issued the `Read`; image size from `sips -g pixelWidth -g pixelHeight <png>`. If it differs from 13k, the conductor corrects the Screenshots row and the closing note of `baseline.md`, committed with the close. Results go in the V2 narrative, with the export scale next to the `sips` size.

## Deviations from the mandate

- `skills/design-pen/SKILL.md:46` doesn't contradict the check (it forbids temporary files inside the base; the check folder is outside): it gains a cross-reference, not an exception.
- The baseline's "about 13k" appears only in `baseline.md`, not in `slices.md` above: only `baseline.md` is corrected.
- The Done runs `/flow:design` by hand in the fixture, not through `/flow:dev`'s design phase: the check sits in the skill both modes share.
