# Impact lenses

Each lens is one subagent, launched in parallel with the others, with `ultrathink` in the prompt. Each subagent reads `slices.md` in full, `shaping.md` and `breadboard.md` if present, and the code the slices touch. It reports one entry per problem, by severity: what · where (`file:line`) · why · proposed fix. If it finds nothing, it says so.

The three common lenses always run. Stack lenses are added from what was detected; on a small work pick one or two, saying which are skipped and why.

## Common, every stack

| Lens | Looks for |
|---|---|
| **Existence** | Do the files, models, functions, routes and tables the slices name still exist, with that name and signature? This is the check that costs most when missing. Before declaring something unused or dead: grep the whole source tree, value and setter, and say in the report where you looked |
| **Core flow and neighbours** | Which main user path is crossed or altered? Who else reads or writes the same data? Which settings or flags change the behaviour of what is about to be built? Which permissions or roles are affected? |
| **Memory and debt** | Is there a decision in `docs/decisions-log/`, `CLAUDE.md` or `docs/` that this work contradicts or makes obsolete? Which documents become false once the work ships? Are data migrations needed on existing content? |

## `rails`

| Lens | Looks for |
|---|---|
| **Transactions, callbacks and jobs** | Side effects in `after_save` that belong in `after_commit`; jobs enqueued before commit; scheduled jobs (`sidekiq-cron`, `whenever`) reading the touched tables; writes to schemas or databases other than the main one |
| **Time and locale** | `Time.now` or `Date.today` instead of `Time.zone`; date formats in views and exports; time zones in nightly jobs |
| **Migrations and data** | Reversibility; migrations that must run per tenant or schema; backfills on existing records; missing indexes on columns the new queries filter; N+1 in the views the slices touch |
| **Authorization** | `ability.rb`, Pundit policies or equivalents: who can do the new thing, and who must not; separate application areas (admin, portal, API) sharing the touched models |
| **Attachments and external services** | ActiveStorage and image CDNs; mailers and mail providers; PDFs; inbound and outbound webhooks |

## `astro`

| Lens | Looks for |
|---|---|
| **Prerender and runtime** | Which routes are static and which SSR; what changes if data read at build time must be read per request; environment variables available only at build |
| **Content sources** | CMS queries: nullable fields crossed on untranslated records (a query that throws returns 200 with an empty body and nothing in the logs); environments and draft mode; cache and revalidation |
| **Islands and navigation** | Components with `client:*` and what survives a view transition: state attached to an element Astro replaces on navigation is lost; inline scripts that do or don't re-attach |
| **Languages and direction** | Per-locale routes and 404s; `lang` and `dir` on the root; physical vs logical CSS properties; fonts covering the served alphabets; `hreflang` and sitemap |
| **Weight and platform** | Hosting limits (bundle size, build time, route count); self-hosted fonts and images; `robots.txt` and crawler output |

## `react`

| Lens | Looks for |
|---|---|
| **Context and consumers** | For every key that moves, is renamed, or changes meaning while keeping its name: the full caller list written before touching code, value and setter; the compiler doesn't protect an identical signature with different behaviour |
| **State and re-renders** | Who subscribes to what; providers split by change frequency; unmemoized components re-rendering on every change of a context they don't use |
| **Test coverage** | What existing tests really cover (often only `utils/` and `lib/`); where a manual regression checklist is needed because no test sees components, hooks and contexts; ambiguous labels in fixtures |
| **Data and backend** | Queries, mutations and access policies (RLS, security rules) on the touched tables; optimistic updates and cache invalidation; offline behaviour |
| **Types** | Exhaustive `switch` statements the compiler can check; discriminated unions instead of boolean flags; `tsc --noEmit` as part of the gate |

## `node`

| Lens | Looks for |
|---|---|
| **Entry points** | `package.json` scripts, CLIs, handlers and crons that invoke the touched code; who imports the modules whose signature changes |
| **Environment and secrets** | Environment variables read at runtime, defaults, differences between local and production |
| **Data** | Migrations, file formats written and read, compatibility with existing data |

## `generic`

The three common lenses suffice. If the repo has a recognisable stack this table doesn't cover, say so and write two or three ad-hoc lenses in the prompt, same format.
