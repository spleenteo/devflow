---
work: flow-own-engine
tags: [spike, flow-own-engine]
description: Which Claude Code mechanism lets a conductor skill delegate a memory operation to a `flow:docs` skill running in its own context and get back a short result.
---

# Spike — A skill in its own context

## Context

The `flow` plugin will have a skill `flow:docs` that owns permanent project memory (decisions, changelog, version). The conductor skills (`flow:dev`, `flow:project`) must ask it to act ("record this decision", "search memory for X") and receive a short result, without loading its instructions and formats into their own context. Checked against Claude Code 2.1.310 (`claude --version`) and the official docs at code.claude.com. Where the docs are silent, the text says "not documented".

## Goal

Pick the documented mechanism that gives a delegated, isolated memory operation with a short returned result, and know its limits (permissions, visibility, file access).

## Questions

| # | Question |
|---|----------|
| S1-Q1 | Can a plugin skill run in its own (forked) context via SKILL.md frontmatter? Which keys exist and what do they do? |
| S1-Q2 | Can a plugin ship a subagent (agents/ folder)? How is it named, and how does a skill make Claude dispatch it via the Agent tool? |
| S1-Q3 | How does one skill invoke another skill of the same plugin (`plugin:skill`)? What does the caller receive when the invoked skill is forked? |
| S1-Q4 | Can a forked skill or plugin subagent read plugin files (`${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_SKILL_DIR}`) and write project files? |
| S1-Q5 | Which option is recommended for "a conductor delegates a memory operation and gets a short result"? Trade-offs? |

## Findings

### S1-Q1 — Forked skill via frontmatter: yes

Source: https://code.claude.com/docs/en/skills.md

- `context: fork` — "Set to `fork` to run in a forked subagent context." Despite the name it is not a fork of the conversation: Claude Code "starts a new subagent of the type set in the `agent` field and gives it the skill content as its prompt. The subagent doesn't see your conversation history, so the skill's instructions have to stand on their own."
- `agent` — which subagent type runs the fork: built-ins (`Explore`, `Plan`, `general-purpose`) or a custom agent; default `general-purpose`.
- `background` — only with `context: fork`. Default `true`: the fork runs in the background and its result arrives later. `background: false` waits for the result in the invoking turn. Requires v2.1.218+. Claude Code waits anyway in `-p` / Agent SDK mode and when `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`. A backgrounded fork gets the narrower background tool set.
- `model` — with `context: fork` "the value sets the forked subagent's model instead". Also `effort`.
- `allowed-tools` — tools usable without asking during the turn that invokes the skill; the grant clears at the next user message. It does not restrict tools ("every tool remains callable"). `disallowed-tools` removes tools from the pool while the skill is active.
- `disable-model-invocation: true` — Claude cannot invoke the skill on its own (description not in context); the user can. Also blocks preloading into subagents.
- `user-invocable: false` — hidden from the `/` menu; only Claude can invoke it. Description stays in context.
- Warning in the docs: `context: fork` only makes sense for skills with explicit task instructions; pure guidelines return "no meaningful output".
- Whether a forked skill's `allowed-tools` grant reaches the subagent's own tool calls: not documented.

### S1-Q2 — Plugin subagents: yes

Sources: https://code.claude.com/docs/en/plugins/components.md , https://code.claude.com/docs/en/sub-agents.md , https://code.claude.com/docs/en/plugins/manifest-reference.md

- A plugin ships agents as Markdown files under `agents/` (default location). Frontmatter `name` and `description`, body is the system prompt.
- Name: `<plugin>:<name>`, where `<name>` is the frontmatter `name` or the file name. Example: `flow:docs-keeper`. Subfolders become segments (`agents/review/security.md` → `my-plugin:review:security`). `:` is not allowed in the `name` itself.
- Supported frontmatter in plugin agents: `name`, `description`, `model`, `effort`, `maxTurns`, `autoCompactWindow`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `omitClaudeMd`, `isolation`, `color`. Ignored: `permissionMode`, `hooks`, `mcpServers`, `initialPrompt`.
- The `skills` field preloads the full skill content into the subagent at startup (up to 32 names); skills with `disable-model-invocation: true` cannot be preloaded. This lets an agent carry the `flow:docs` instructions in its own context.
- Dispatch: Claude delegates by matching the agent `description`; you can also write "Use the `flow:docs-keeper` subagent to ..." in a skill; users can @-mention `@agent-flow:docs-keeper`. The Agent tool's `subagent_type` parameter exists, but the docs do not describe its schema or give a documented way to force a specific `subagent_type` from skill text. Exact dispatch syntax from a skill body: not documented beyond natural-language instruction.
- Result: "The parent doesn't see the subagent's intermediate tool calls or outputs, only that final result" (https://code.claude.com/docs/en/tools-reference.md).

### S1-Q3 — Skill calling a skill; what the caller receives

Sources: https://code.claude.com/docs/en/skills.md , https://code.claude.com/docs/en/tools-reference.md

- The `Skill` tool "executes a skill within the main conversation". Plugin skills are namespaced `/plugin-name:skill-name`. Permission rules such as `Skill(anthropic-skills:pdf)` show Claude invokes skills by namespaced name.
- The docs do not state explicitly that a skill can instruct Claude to call another skill by `plugin:skill`, nor describe skill-to-skill chaining: not documented.
- Without `context: fork`: the invoked skill's rendered content enters the conversation as one message and stays there, so the caller's context pays for the full instructions (https://code.claude.com/docs/en/skills.md, "Skill content lifecycle").
- With `context: fork`: "The subagent summarizes its results and returns them to your main conversation when it finishes." By default it is backgrounded and the result arrives later; `background: false` makes the invoking turn wait. A synchronous guarantee for a skill-to-skill call: not documented beyond `background: false`.
- A fork starts with no conversation history, so the caller must pass everything needed in the request (arguments / text).

### S1-Q4 — File access of forks and plugin subagents

Sources: https://code.claude.com/docs/en/plugins/manifest-reference.md , https://code.claude.com/docs/en/sub-agents.md , https://code.claude.com/docs/en/skills.md

- `${CLAUDE_SKILL_DIR}` (the skill's own subdirectory, not the plugin root), `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_PLUGIN_DATA}` are substituted inline in skill, command and agent Markdown content. They are NOT in the environment of commands run through the Bash tool, in the main session or in a subagent. So a forked skill or agent must receive the absolute path through the substituted text, not read it from env.
- `${CLAUDE_PLUGIN_ROOT}` changes on every plugin update; do not write state there. Persistent plugin state goes in `${CLAUDE_PLUGIN_DATA}`.
- Reading and writing: a subagent "inherits the built-in tools and MCP tools available in the main conversation" unless `tools` / `disallowedTools` narrow it. So Read/Write/Edit on plugin files and project files are available by default. There is no doc sentence that says this specifically for forked skills or plugin agents: the access follows tool inheritance (inference, flagged as not documented explicitly).
- Permissions: the subagent inherits the main conversation's permission mode; `permissionMode` in a plugin agent is ignored. Foreground subagents pass permission prompts to the user; background subagents surface them in the main session, and a lasting grant applies to the whole session. Permission rules in settings apply to the whole session, not only to the plugin subagent.
- Background subagents get a smaller built-in tool set that still includes Read, Grep, Glob, Bash, Edit, Write, WebFetch.

### S1-Q5 — Recommendation and trade-offs

Derived from the pages cited above; the recommendation is our reading of them, not a documented best practice for this exact case.

| Option | Token cost for the conductor | User visibility | Permissions | Notes |
|---|---|---|---|---|
| A. `flow:docs` skill with `context: fork`, `background: false` | Only the short returned summary enters the conductor context; instructions stay in the fork. The `flow:docs` description is in the listing. | Delegation row plus subagent panel; transcript via `/tasks`. | Inherits session mode; prompts shown to the user. | Skill text is the fork prompt, so requests must be self-contained. Skill-to-skill call by `plugin:skill` is not documented explicitly. |
| B. Plugin subagent in `agents/` (with `skills: [docs]` or its own prompt) | Same: only the final result returns. | Same as A. | Same; `permissionMode`/`hooks` ignored. | Dispatch relies on description matching or natural-language naming; forcing the exact `subagent_type` is not documented. `skills` preload cannot use a `disable-model-invocation: true` skill. |
| C. Plain `Skill` call without fork | Full `flow:docs` instructions enter the conductor context and persist (re-attached after compaction, 5,000 tokens each). | Inline. | Normal. | Fails the "do not load instructions into my context" requirement. |

Each subagent spends its own tokens and counts toward the same usage limits; many subagents returning detailed results also consume context (https://code.claude.com/docs/en/sub-agents.md). Keep the returned summary short by saying so in the fork prompt.

Best fit for the requirement: option A (forked skill, `background: false`), with option B as the fallback if skill-to-skill invocation proves unreliable. Both need a runtime test, because the docs do not confirm the end-to-end conductor flow.

## Outcome

- `flow:docs` can be a forked skill (`context: fork`, `agent: general-purpose`, `background: false`): its instructions and formats stay out of the conductor context; only its summary returns.
- A plugin subagent (`flow:<name>`, optionally preloading skills) is the documented alternative with the same isolation.
- Fork and subagent inherit Read/Write/Edit and the session permission mode; plugin paths must come from `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PLUGIN_ROOT}` substituted in the Markdown, not from env.
- Requests must be self-contained (no conversation history); ask for a short result explicitly.
- To verify in a runtime test: skill-to-skill call by `plugin:skill`, synchronous return, permission prompts during writes.

## Runtime test (2026-10-26)

A throwaway plugin with two skills, run headless with `claude -p "/<plugin>:caller" --plugin-dir <dir>` on CLI 2.1.310. `caller` (no fork) asked for `<plugin>:worker` through the Skill tool; `worker` had `context: fork` and `background: false`, a marker string in its body, wrote a file and returned one line.

- The worker ran as a `general-purpose` subagent with its body plus `ARGUMENTS: <request>` as the prompt.
- It wrote its file in the project directory.
- The caller received only the returned line and wrote it to its own file: `WORKER OK: record decision: use tabs`.
- The marker appeared only in the subagent's messages (`parent_tool_use_id` set), never in the caller's context.

Confirmed end to end: a conductor can delegate to a forked skill of the same plugin and get back a short result without loading that skill's instructions.
