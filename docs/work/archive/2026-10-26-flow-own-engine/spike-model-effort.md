---
work: flow-own-engine
tags: [spike, flow-own-engine]
description: Spike on how a skill can choose the model and reasoning effort of the subagents it dispatches, and how a user can override that choice.
---

# Spike — Model and effort from a skill

## Context

The conductor skills of the `flow` plugin dispatch subagents for planning, plan review, impact analysis, task execution and task review. Today the only lever used for deeper reasoning is the word "ultrathink" written into subagent prompts. Sources: the official Claude Code docs (code.claude.com) and the local CLI (`claude --version` = 2.1.310, so every version threshold cited below is met).

## Goal

Choose the model per role (most capable tier for planning and review, mid tier for executing a clear plan) and the reasoning effort (high for planning and reviews) through supported mechanisms. The user must be able to override ("run everything on the most capable model").

## Questions

| # | Question |
|---|----------|
| S2-Q1 | Which parameters does the Agent (subagent) tool accept for model and effort, with which values, and under which documented conditions should Claude set them? |
| S2-Q2 | Does "ultrathink" (or "think hard") inside a prompt that Claude writes for a subagent have a documented effect? Only in user prompts? |
| S2-Q3 | Can SKILL.md frontmatter set `model` or `effort`? Can a plugin subagent definition (`agents/*.md`) set them? |
| S2-Q4 | Which settings or environment variables fix the subagent model globally, and how do they interact with a per-call model choice? |
| S2-Q5 | What is the recommended way to say "most capable for X, mid tier for Y" without hard-coding model IDs that age? |

## Findings

### S2-Q1 — Agent tool parameters

- Model: when Claude invokes a subagent it "can also pass a `model` parameter for that specific invocation". It takes precedence over the definition's `model`. It also applies when the subagent is resumed or sent a follow-up. Source: https://code.claude.com/docs/en/sub-agents.md#choose-a-model
- Accepted model values are documented for the frontmatter `model` field: aliases `sonnet`, `opus`, `haiku`, `fable`; a full model ID such as `claude-opus-5-5` ("accepts the same values as the `--model` flag"); `inherit`. Other aliases exist in https://code.claude.com/docs/en/model-config.md#model-aliases (`best` = Fable where available, else Opus; `default`; `opusplan`; `[1m]` suffixes). Whether the Agent tool's `model` parameter accepts exactly the same set (for example `best`): not documented. The tool schema is not published on the docs pages read (https://code.claude.com/docs/en/tools-reference.md#agent-tool-behavior lists no parameters).
- Effort: "When you ask Claude to run a non-fork subagent at a specific effort level, it can also pass an `effort` parameter for that invocation." It overrides the definition's `effort` and persists on resume. Requires v2.1.292 or later. It is not available for forks. Source: https://code.claude.com/docs/en/sub-agents.md#choose-an-effort-level
- Effort values are documented for the frontmatter field: `low`, `medium`, `high`, `xhigh`, `max`; "available levels depend on the model" (https://code.claude.com/docs/en/sub-agents.md#supported-frontmatter-fields). The exact value set of the Agent tool `effort` parameter: not documented.
- Conditions on when Claude should set them: the only documented trigger is "when you ask Claude" for a specific effort level. No rule is documented about setting `model` on its own initiative or only when a skill asks. Not documented.
- Resolution order for the model: per-invocation `model` > definition `model` frontmatter > `CLAUDE_CODE_SUBAGENT_MODEL` > main conversation's model. A mod's `agent.spawn` hook model replaces the per-invocation value. Source: https://code.claude.com/docs/en/sub-agents.md#choose-a-model
- Related caveat: a family alias (for example `opus`) resolves to the main conversation's exact model when the main model is in that family, or when the family cannot be identified on some providers. Same source.
- Subagents inherit the session's extended-thinking setting (v2.1.198+); there is no per-subagent thinking setting. Same source.

### S2-Q2 — "ultrathink" and "think hard"

- "Include `ultrathink` anywhere in your prompt to request deeper reasoning on that turn without changing your session effort setting. Claude Code recognizes the keyword and adds an in-context instruction. The effort level sent to the API is unchanged." Phrases such as "think", "think hard", "think more" are passed through as ordinary text and are not recognized. Source: https://code.claude.com/docs/en/model-config.md#use-ultrathink-for-one-off-deep-reasoning
- "think hard" therefore has no documented keyword effect.
- Skill content: "include `ultrathink` anywhere in the skill content" (https://code.claude.com/docs/en/skills.md, tip in the string-substitution area).
- Whether the keyword is recognized inside a prompt that Claude itself writes for a subagent: not documented. The docs speak of "your prompt" (user prompt) and skill content only. Even where it works, it is an in-context instruction and does not change the API effort level, so it is not equivalent to the `effort` parameter or frontmatter field.

### S2-Q3 — Frontmatter in skills and plugin subagents

- Skill `model`: "Model to use when this skill is active. The override applies for the rest of the current turn and isn't saved to settings. The session model resumes when you send your next prompt." Accepts the same values as `/model`, or `inherit`. With `context: fork` it sets the forked subagent's model instead. Source: https://code.claude.com/docs/en/skills.md (frontmatter reference)
- Skill `effort`: "Effort level when this skill is active. Overrides the session effort level." Options `low`, `medium`, `high`, `xhigh`, `max`. Same source. `context: fork` and `agent:` select a subagent type to run the skill in (https://code.claude.com/docs/en/skills.md#run-skills-in-a-subagent).
- Subagent definition: `model` (aliases, full ID, `inherit`) and `effort` (`low`..`max`) are supported fields. Source: https://code.claude.com/docs/en/sub-agents.md#supported-frontmatter-fields
- Plugin subagents: only `hooks`, `mcpServers` and `permissionMode` are ignored ("for security reasons"). `model` and `effort` are not listed as ignored, so they apply. Source: https://code.claude.com/docs/en/sub-agents.md#choose-the-subagent-scope (note under "Plugin subagents"). An explicit statement that `model`/`effort` work for plugin agents: not documented beyond this absence.
- Frontmatter effort overrides the session level but not `CLAUDE_CODE_EFFORT_LEVEL`; `maxEffortLevel` and organization caps still limit it. Source: https://code.claude.com/docs/en/model-config.md#set-the-effort-level

### S2-Q4 — Global settings and environment variables

- `CLAUDE_CODE_SUBAGENT_MODEL`: only a default for subagents, teammates and workflow agents "that aren't assigned a model another way". A per-invocation model or a definition's `model` (including `inherit`) wins. Since v2.1.251; before that it overrode both. `inherit` equals unset. By itself it does not change the built-in Explore and Plan subagents. Sources: https://code.claude.com/docs/en/env-vars.md and https://code.claude.com/docs/en/sub-agents.md#choose-a-model
- `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (v2.1.257+): forces one model onto every subagent. With both variables set, the model is the one in `CLAUDE_CODE_SUBAGENT_MODEL`; with only FORCE set, subagents run on the main conversation's model (Explore keeps its built-in model). While FORCE is on, definition `model` fields are ignored and Claude cannot pass a model when starting a subagent. Forks and `model: inherit` skills in a subagent still use the main model. Source: https://code.claude.com/docs/en/sub-agents.md#run-every-subagent-on-one-model
- Effort: `CLAUDE_CODE_EFFORT_LEVEL` (`low|medium|high|xhigh|max|auto`) takes precedence over `--effort`, `/effort`, settings, skill/subagent frontmatter and the per-invocation `effort`. Source: https://code.claude.com/docs/en/env-vars.md and https://code.claude.com/docs/en/sub-agents.md#choose-an-effort-level
- Main-session model: `--model`, `/model`, the `model` setting and `ANTHROPIC_MODEL` set the main conversation's model, which is the fallback for subagents (https://code.claude.com/docs/en/model-config.md). Subagent whole-model override list: https://code.claude.com/docs/en/model-config.md (line on "Subagent and teammate models").
- `availableModels` (organization allowlist) can substitute a blocked model. Source: https://code.claude.com/docs/en/sub-agents.md#choose-a-model
- Implication for overrides: the user who wants "everything on the most capable model" has two documented routes. (1) Start the session on that model and set `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (subagents then follow the main model) or set both variables to force a named model. (2) Without env vars, ask in the prompt; Claude passes the `model` parameter per call (no documented guarantee that Claude honors a skill's tier mapping over a user request, but a per-invocation value is the top of the order). A skill cannot override the FORCE variable.

### S2-Q5 — Expressing tiers without hard-coded IDs

- The docs recommend aliases for staying current: "Aliases point to the recommended version for your provider and update over time. To pin to a specific version, use the full model name." `opus`, `sonnet`, `haiku` resolve to the newest version on the Anthropic API and to older versions on some providers; `fable`/`best` exist for the top tier. Source: https://code.claude.com/docs/en/model-config.md#model-aliases
- Provider pins: `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL` (and the Fable equivalent) redefine what an alias means (https://code.claude.com/docs/en/model-config.md).
- A documented pattern for per-role models: subagent definitions with `model:` and `effort:` in frontmatter (https://code.claude.com/docs/en/sub-agents.md#supported-frontmatter-fields). A skill can name the agent type per role, or the plugin can ship one agent per role.
- A documented tier-by-role construct also exists: `opusplan` (opus in plan mode, sonnet for execution), main session only (https://code.claude.com/docs/en/model-config.md#model-aliases).
- A documented recommendation on how a skill should word "most capable for X, mid tier for Y": not documented. Note that "most capable" maps to `opus` or `fable`/`best`, and "mid tier" to `sonnet`, only by alias semantics; the docs do not define tiers abstractly.

## Outcome

1. Per call, Claude can pass `model` (aliases, full ID, `inherit` documented for frontmatter) and `effort` (v2.1.292+, non-fork); the Agent tool schema itself is not published.
2. Most robust design: ship plugin agents (`agents/*.md`) per role with `model: opus|sonnet` and `effort: high` in frontmatter; use aliases, not IDs. Skill frontmatter `model`/`effort` only affects the skill's own turn.
3. Drop "ultrathink" for subagents: it is documented for user prompts and skill content only, and "think hard" is not a keyword.
4. User override: `CLAUDE_CODE_SUBAGENT_MODEL` alone loses to definitions and per-call values; use it with `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` (v2.1.257+), and `CLAUDE_CODE_EFFORT_LEVEL` for effort.
5. Not documented: exact Agent-tool value sets, rules for when Claude sets model/effort, and unprompted `ultrathink` handling in Claude-written subagent prompts.
