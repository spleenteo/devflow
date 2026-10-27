---
name: stack-datocms
description: Flow stack preset, invoked only by Flow's conductors by its qualified name; never for general questions.
user-invocable: false
---

# Flow: stack preset, DatoCMS

Opinions for a project that reads content from DatoCMS, read by Flow's conductors. It adds to the framework's preset (`[astro, datocms]`), never replaces it. A project that disagrees replaces this preset (`presets:` in its configuration file).

## Rules

**CLI**

1. Work on the project through the DatoCMS CLI (`datocms`), linked once per repo (`datocms link`, which writes `datocms.config.json`), because schema, environments and migrations then run the same way for everyone and in CI.
2. Before planning a schema change, read the live schema with `datocms schema:inspect` instead of guessing it from the code, because the code shows only the fields it queries.
3. For API details and examples, use the DatoCMS skills when the session has them (References), else `datocms cma:docs` and the docs at datocms.com, never memory, because the API changes and remembered option names drift.

**Environments**

4. Change the schema in a sandbox, never by hand on the primary environment: `datocms migrations:run` forks the primary into a sandbox (`--destination`) and runs the pending migrations there; `datocms environments:promote` makes it primary once reviewed, because the primary serves production.
5. Run migrations in place on the primary (`--in-place --allow-primary`) only for strictly additive changes, because a run that fails halfway has no rollback.
6. Pass the environment to every client explicitly, from a variable the app reads, and keep production reads on the primary, because a sandbox returns different content without any error.
7. Keep the CMA token and the draft read token server-side and out of git, because one writes and the other reads unpublished content.

**Schema**

8. Every schema change is a migration script (`datocms migrations:new <name>`, or `--autogenerate=<sandbox>` to diff a sandbox built in the dashboard) committed with the code that uses it, because a migration is reviewable and replayable.
9. Query types come from the schema (`datocms schema:generate`, `gql.tada` or GraphQL Code Generator) and are checked in CI, because a field renamed in the CMS must fail the build, not the page.
10. Treat optional and localized fields as nullable in the code, because an untranslated or half-filled record returns `null`, not a fallback.

**Naming**

11. Name models for what they hold, not for how a page shows them, because the same content is reused by other pages and other apps.
12. Pages are regular models named `… Page` (`Home Page`, `Product Page`); reusable blocks are named `… Block` (`Text Block`, `Newsletter Signup Block`); the API key is the snake_case of the name (`newsletter_signup_block`) and matches the component's name in the code, because one name then finds the model, the block and its renderer.
13. Name fields by data type first (`slug`, `image`, `color`), then by function (`title`, `autoplay`), and by appearance only through `layout` and `style`, because names tied to a design break when the design changes.
14. Use the standard field names: `title` (not `heading`), `subtitle`, `slug` (built from `title`), `text` for structured text (not `body` or `content`), `blocks` for a modular content field, `items` for a list of the same block, `image` / `images`, `video`, `page` / `pages` for links to page models. A second field of the same type is named by its function (`background_image`). A boolean is named by its function (`autoplay`, `loop`), never by its look (`is_gray`), because a boolean means nothing without context.
15. Control appearance with two fields: `layout` (position, size, direction: `full-width`, `image-text`, `text-image`) and `style` (visual variant: `default`, `highlighted`), each a string with only allowed values, or `style` a link to a Style model when variants are shared across models, because a new variant is then a new value, not a new field or block.

## Lenses

| Lens | Looks for |
|---|---|
| **Environments and migrations** | The environment each read, build and migration targets; schema changes not shipped as a migration; anything run in place on the primary that isn't additive |
| **Schema and types** | Generated types out of date with the schema; models or fields renamed or removed that queries or content still use; optional and localized fields read as if always present |
| **Naming** | New models, blocks and fields against the naming rules: `Page` and `Block` suffixes, standard field names, appearance through `layout` and `style` only |
| **Tokens** | CMA or draft tokens reachable from client code or committed |

## Tests

Level: essential
Sensitive areas: query and fragment modules, `migrations/`, webhook and revalidation endpoints, draft-mode routes, content import scripts

Essential when a test runner is configured, else none, with empty areas.

## Gate

This preset adds no gate of its own beyond the framework's. When generated query types are committed, add the project's generation command (for example `npm run generate-types`) followed by `git diff --exit-code` on the generated file, so stale types fail; only commands whose script exists are proposed.

## References

All optional, never invoked by this preset; a conductor or agent that has them in the session uses them for API details and examples (Rule 3):

- `datocms-cli` (`datocms:datocms-cli`): CLI, migrations, environments, schema inspection and codegen.
- `datocms-content-modeling` (`datocms:datocms-content-modeling`): schema decisions.
- `datocms-cda` (`datocms:datocms-cda`): queries, localization, cache tags, type generation.
- `datocms-frontend-integrations` (`datocms:datocms-frontend-integrations`): draft mode, Content Link, official components.
- `datocms-structured-text` (`datocms:datocms-structured-text`): Structured Text rendering.
