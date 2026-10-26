---
work: flow-own-engine
slice: V5
tags: [plan, flow-own-engine]
description: "Plan for V5: three opinionated stack presets (astro, datocms, rails) as skills, resolved per stack through .flow.yml, userConfig or the shipped preset; common lenses on their own; a first guidelines draft from the presets; per-stack optional dependencies."
---

# V5 — Stack presets · plan

**Mandate**: [`slices.md` § V5](slices.md#v5--stack-presets). **Stacks shipped** (asked at this plan, 2026-10-26): `astro`, `datocms`, `rails`. **Guidelines**: [`docs/development-guidelines.md`](../../development-guidelines.md). **Lessons**: [`lessons.md`](lessons.md). **Builds on**: V4's Profile in `skills/dev/SKILL.md`, the `stack_presets` option in `plugin.json`.

**Execution rules**: executors on `sonnet`; reviewers on `opus` for `critical` tasks, `sonnet` otherwise; current checkout on `work/flow-own-engine`; check the tree before re-dispatching a failed executor; demos headless on throwaway repos, flags as an array, two turns where a question comes first; a skill's work checked where it ran.

**Presets, decided here:**
- **Shape**: `skills/stack-<name>/SKILL.md`, `name: stack-<name>`, `user-invocable: false`, not forked (the conductor needs the text). Description: "Flow stack preset, invoked only by Flow's conductors by its qualified name; never for general questions." No bare stack name in the description. Body sections, fixed: `## Rules` (opinionated patterns and peculiarities, each with a one-clause reason), `## Lenses` (`| Lens | Looks for |`), `## Tests` (proposed level and sensitive areas), `## Gate` (proposed commands), `## References` (external skills and guides: bare name with the plugin form in brackets at first mention, each marked optional; never invoked by the preset).
- **Content**: `astro` takes today's astro lenses, keeping a generic **Content sources** lens for any CMS, and adds rules (static by default, SSR per route only when data is per request; islands only for interactivity; typed content queries; self-hosted images and fonts). `datocms` takes the DatoCMS specifics (nullable fields on untranslated records, environments and draft mode, cache tags) and adds rules (reads through `@datocms/cda-client` with typed queries; draft mode and cache tags; structured text and responsive images through the official components; schema changes as CLI migrations); references the `datocms` plugin's skills. `rails` takes today's rails lenses and adds rules from thoughtbot's practice; references `rails-patterns` and `testing-patterns`. A project that disagrees replaces the preset.
- **Shipped list**: `astro`, `datocms`, `rails`, fixed in the skill text; no lookup in the skill listing.
- **Detection**: `datocms` when `package.json` depends on `@datocms/cda-client`, `@datocms/astro`, `react-datocms`, `vue-datocms`, `@datocms/svelte`, `datocms-structured-text-utils` or `@datocms/cli` (a `datocms.config.json` alone doesn't count). It adds to the others (`[astro, datocms]`) and, like other JS stacks, suppresses `node`.
- **Resolution, per stack**: `presets:` in the configuration file (flow list of `stack=skill` pairs, `presets: [astro=my-stacks:astro]`), then `${user_config.stack_presets}` (same pairs, comma-separated; empty or literal = unset), then the shipped `flow:stack-<name>` when the stack is in the shipped list, else none. Only the resolved skill is invoked. A mapped skill not in the session: say so and use the fallback lenses, never the shipped preset. A stack with no preset (`react`, `node`, `generic`) uses the fallback lenses.
- **Where the presets reach the work**: their `## Rules` go into the slice packet (every plan, review and execution) and into the impact packet; their `## Lenses` go verbatim into the stack-lens impact subagent's packet; never a path into another plugin. Invoked at the profile's proposal (Tests, Gate, References), at impact, and once per slice when the packet is built.
- **Several presets**: level = the highest proposed; areas = the union; gate = the union of commands, duplicates removed, each attributed to its preset; commands whose script the repo lacks are dropped and named.
- **Lenses file**: `skills/dev/lenses.md` moves to `skills/dev/common-lenses.md` (`git mv`): intro, common lenses, a **Stacks without a preset** section (today's `react` and `node` tables and the `generic` rule) and the project lenses section.
- **First draft of the guidelines**: when `docs/development-guidelines.md` is missing, the profile's offer becomes a draft: `## References` from the presets, `## Tests` with the merged level and areas (the profile lines), `## Gate` merged, plus the code's observed conventions where the presets are silent; `## Deviations` only when there is content. When the file exists, its missing sections are proposed only when the profile is asking anyway or at Step 0, never a rewrite, never asked again once declined in that run. After the draft, gate and test level come only from the guidelines.
- **Dependencies**: per-stack optional rows in `dependencies.md`, Need cell `optional (<stack>)`: `datocms@datocms-skills` (for `datocms`), `rails-development@skills` (`rails-patterns`, `testing-patterns`, for `rails`). No `astro` row: no external Astro skill is referenced. The start check reports per-stack rows using the stacks the profile reads (else detection), so they appear only in a project of that stack. `install.sh` parses five columns as today, reads the stack from the Need cell, labels every per-stack row with it (`ok` and `missing` alike), and omits rows of stacks the current directory doesn't have (stacks from `.flow.yml` `stacks:`/`stack:` in the checkout, else the detection signals; `.devflow.yml` and unmerged branches are not read, a stated limit).

## Tasks

### T1 — The three presets · `critical`
- **What**: the three skills per "Shape" and "Content"; lenses moved from `skills/dev/lenses.md` (astro keeps a generic Content sources lens; datocms gets the DatoCMS specifics; rails all).
- **Files**: `skills/stack-astro/SKILL.md`, `skills/stack-datocms/SKILL.md`, `skills/stack-rails/SKILL.md` (new).
- **Verified**: `claude plugin validate .`; each body has the five sections; `rg -n -i '^description:.*(astro|datocms|rails)' skills/stack-*/SKILL.md </dev/null` prints nothing.
- **Done**: three presets; every lens of today's astro and rails tables has a home.

### T2 — Common lenses, resolution, packets, dependencies sentence · `critical` · depends on: T1
- **What**: `git mv skills/dev/lenses.md skills/dev/common-lenses.md`, then edit per "Lenses file". In `skills/dev/SKILL.md`: Conventions rows (Stacks detection gains `datocms` and suppression of `node`; Impact lenses → common lenses plus each resolved preset); a **Presets** paragraph in the Profile ("Shipped list", "Resolution", "Several presets"; the `presets` key in the configuration key list; `${user_config.stack_presets}` with the unset rule); the profile's level and gate proposals from the presets; impact: invoke each resolved preset, `## Rules` in both packets, `## Lenses` verbatim in the stack-lens packet, fallback lenses otherwise; the slice packet gains the resolved presets' `## Rules`; § Dependencies: per-stack rows only for the project's stacks, read through the profile (else detection).
- **Files**: `skills/dev/common-lenses.md` (moved), `skills/dev/SKILL.md`.
- **Verified**: `rg -n "lenses\.md" skills shared </dev/null` finds only `common-lenses.md` and `impact-lenses`; `claude plugin validate .`.
- **Done**: resolution, packets and dependency filtering as decided.

### T3 — Guidelines draft · depends on: T2
- **What**: in `skills/dev/SKILL.md` Profile and Step 0: the draft per "First draft of the guidelines".
- **Files**: `skills/dev/SKILL.md`.
- **Verified**: read-through against the bullet; `claude plugin validate .`.
- **Done**: as decided.

### T4 — `dependencies.md` and `install.sh` · depends on: T1
- **What**: `dependencies.md`: the two rows, their install sections, one sentence on per-stack rows. `install.sh` per "Dependencies".
- **Files**: `dependencies.md`, `install.sh`.
- **Verified**: `bash -n install.sh`; with `claude` hidden from `PATH` and `HOME` pointed at an empty scratch folder (so nothing reads as installed): in a throwaway Astro repo with `@datocms/cda-client` → datocms rows labelled, rails rows absent; in a throwaway Rails repo → the reverse; in this repo → no per-stack rows. Then with the real environment in the Astro repo → the datocms rows labelled `ok`.
- **Done**: as verified.

### T5 — Demonstrate and gate · depends on: T2, T3, T4
- **What**: headless. Before the demos, a quick check that `--settings '{"pluginConfigs":{"flow@inline":{"options":{"stack_presets":"astro=probe:astro"}}}}'` substitutes with two `--plugin-dir` flags (a scratch copy of the plugin with a probe skill).
  1. a throwaway Astro repo depending on `@datocms/cda-client`, no profile. Turn 1: proposes `stacks: [astro, datocms]`, offers the guidelines draft (presets may run here: checked in both turns). Turn 2 accepts and answers Step 1 → `flow:stack-astro` and `flow:stack-datocms` invoked across the two turns; `git show work/<slug>:docs/development-guidelines.md` has References, Tests, Gate.
  2. an impact run: the repo from 1 with a work at `phase: impact` and a one-slice `slices.md`, `.flow.yml` with `presets: [astro=probe:astro]`, a throwaway plugin `probe` (second `--plugin-dir`) whose `astro` skill carries a marker lens; prompt "run impact and stop after the report" → `probe:astro` invoked, `flow:stack-astro` never, `flow:stack-datocms` invoked; the Agent inputs hold the marker lens text and no `${CLAUDE_` or plugin cache path.
  3. as 2 with the mapping in `--settings` `pluginConfigs` instead of `.flow.yml`.
  4. a repo with its own guidelines holding `## Tests` (with the profile lines) and `## Gate` only, no configuration file: the profile proposes `## References` only; turn 2 → existing sections byte-identical.
  5. start check with `--settings '{"enabledPlugins":{"rails-development@skills":false,"datocms@datocms-skills":false}}'`: in a throwaway Rails repo it reports the `rails-development` row; in the Astro repo it doesn't, and reports the `datocms` row.
  6. `install.sh` as in T4.
  7. in the Astro repo, the `init` event lists `flow:stack-astro`; three prompts on Astro topics the preset covers (static vs SSR, islands, images) → no preset invoked.
  Then the Gate with the narrowing.
- **Files**: none in the repo.
- **Verified**: `git`, `cat`, `jq` over the stream JSON (Skill calls by name, Agent inputs).
- **Done**: seven outcomes as stated, Gate green.

## Order

T1 → T2 → T3 → T4 (T4 could run beside T2: separate files) → T5. One commit per task, explicit paths.

## Deviations from the mandate

- **Today's `react` and `node` lenses stay**, in `common-lenses.md` § Stacks without a preset.
- **`datocms` is a stack** detected from its packages, so an Astro project with DatoCMS resolves two presets.
- **The `presets` key** in the configuration file uses the `stack=skill` pairs of `userConfig`, as a flow list.
- **No `astro` dependency row**: no external Astro skill is referenced, so `install.sh` labels the datocms rows in an Astro + DatoCMS repo, not astro rows.
- **`flow:stack-<name>` is cited without a slash**, like `flow:docs`: not user-invocable. V8 updates the Naming rule.
- **`install.sh` reads only the checkout's `.flow.yml`**: no `.devflow.yml`, no unmerged branches.
- **The presets' opinions are a first draft** from public practice and today's lenses; the owner reviews them at this slice's close.
- **Stale prose left for V8**: `docs/architecture.md` mentions of `lenses.md`.
