# Impact lenses

Two subagents in parallel: one runs the common lenses, the other the stack lenses. On a one-slice work, one subagent runs all of them. Each gets the same packet (`slices.md` in full, the matching decisions' descriptions, the guidelines, the project lenses when present, the resolved presets' `## Rules`) and reads the code the slices touch on its own. Each reports one entry per problem, by severity: what · where (`file:line`) · why · recommended fix, and names the lenses that found nothing.

The common lenses always run. The stack lenses are each resolved preset's `## Lenses` text, carried verbatim in the packet, or the tables below for a stack without a preset. On a small work, pick one or two stack lenses, saying which are skipped and why.

## Common, every stack

| Lens | Looks for |
|---|---|
| **Existence** | Do the files, models, functions, routes and tables the slices name still exist, with that name and signature? This is the check that costs most when missing. Before declaring something unused or dead: grep the whole source tree, value and setter, and say in the report where you looked |
| **Core flow and neighbours** | Which main user path is crossed or altered? Who else reads or writes the same data? Which settings or flags change the behaviour of what is about to be built? Which permissions or roles are affected? |
| **Memory and debt** | Is there a decision in `docs/decisions-log/` (matched by key words and by `touches:` against the files the slices name), `CLAUDE.md` or `docs/` that this work contradicts or makes obsolete? Which documents become false once the work ships? Are data migrations needed on existing content? |

## Stacks without a preset

The stacks Flow ships a preset for (`astro`, `datocms`, `rails`) keep their lenses in the preset, not here. These stacks have none. A shipped stack whose mapped preset isn't in the session has no table here either: the `generic` rule applies (ad-hoc lenses), and it contributes no Rules, Tests or Gate.

### `react`

| Lens | Looks for |
|---|---|
| **Context and consumers** | For every key that moves, is renamed, or changes meaning while keeping its name: the full caller list written before touching code, value and setter; the compiler doesn't protect an identical signature with different behaviour |
| **State and re-renders** | Who subscribes to what; providers split by change frequency; unmemoized components re-rendering on every change of a context they don't use |
| **Test coverage** | What existing tests really cover (often only `utils/` and `lib/`); where a manual regression checklist is needed because no test sees components, hooks and contexts; ambiguous labels in fixtures |
| **Data and backend** | Queries, mutations and access policies (RLS, security rules) on the touched tables; optimistic updates and cache invalidation; offline behaviour |
| **Types** | Exhaustive `switch` statements the compiler can check; discriminated unions instead of boolean flags; `tsc --noEmit` as part of the gate |

### `node`

| Lens | Looks for |
|---|---|
| **Entry points** | `package.json` scripts, CLIs, handlers and crons that invoke the touched code; who imports the modules whose signature changes |
| **Environment and secrets** | Environment variables read at runtime, defaults, differences between local and production |
| **Data** | Migrations, file formats written and read, compatibility with existing data |

### `generic`

The three common lenses suffice. If the repo has a recognisable stack this table doesn't cover, say so and write two or three ad-hoc lenses in the prompt, same format.

## Project lenses

A project adds its own lenses in `docs/impact-lenses.md` (under the root `.flow.yml` sets, if any). Template: `impact-lenses.template.md`, next to this file. Same format as the tables above: `| Lens | Looks for |`, lens names in bold, optionally split under `##` headings.

They add to the stack lenses, never replace them. Who reads them:

| When | Who | How |
|---|---|---|
| Impact | The stack-lens subagent, or the single one on a one-slice work | The file's contents travel verbatim in the packet: both impact subagents receive them, only this one runs them; each project lens is run like a stack lens and named in the report when it found nothing |
| Every plan review | The review subagent | Fifth row, **Project lenses**, applied to the plan |

When the file is absent, the report says "project lenses: none" in one line: not a finding.
