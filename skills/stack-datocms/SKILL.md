---
name: stack-datocms
description: Flow stack preset, invoked only by Flow's conductors by its qualified name; never for general questions.
user-invocable: false
---

# Flow: stack preset, DatoCMS

Opinions for a project that reads content from DatoCMS, read by Flow's conductors. It adds to the framework's preset (`[astro, datocms]`), never replaces it. A project that disagrees replaces this preset (`presets:` in its configuration file).

## Rules

1. Read through `@datocms/cda-client` (`executeQuery`), not hand-rolled `fetch`, because it carries the token, environment and draft headers in one place.
2. Queries are typed from the schema (`gql.tada` or GraphQL Code Generator) and checked in CI, because a field renamed in the CMS must fail the build.
3. Treat every field of a localized or optional model as nullable and handle it in the component, because an untranslated record returns `null`, not a fallback.
4. Set `fallbackLocales` in the query when a locale may be incomplete, and decide per page whether a missing translation is a 404 or a fallback, because the default is silence.
5. Draft content is read only through a server-side route with the draft token (`excludeInvalid`, `includeDrafts` on), never from the browser, because the draft token can read unpublished records.
6. Pass the environment explicitly (`environment` option or `DATOCMS_ENVIRONMENT`) and keep production reads on the primary environment, because a forked sandbox returns different content silently.
7. Request cache tags (`returnCacheTags`) and revalidate by tag from the webhook, not by time, because time-based revalidation either serves stale content or wastes builds.
8. Render Structured Text with the framework's official component (`StructuredText`) and pass block and inline-record renderers for every block type queried, because an unhandled block drops content without an error.
9. Images use the responsive image fragment (`responsiveImage`) with the official `Image` component, and always select `alt`, because it provides `srcset`, blur-up and the CDN transforms.
10. SEO comes from `_seoMetaTags` and the site favicon fragment, rendered by the official helper, because hand-copied tags go stale when editors change them.
11. Change the schema through CLI migrations (`datocms migrations:new`, `migrations:run`) committed with the code, never by hand in the dashboard of a shared environment, because a migration is reviewable and replayable.
12. Keep the CMA token and the full-access CDA token out of client bundles and out of git, because both write or read drafts.
13. Query only the fields a page renders and paginate with `first`/`skip` (max 100 per page), because oversized queries hit rate and size limits.

## Lenses

| Lens | Looks for |
|---|---|
| **Nullable fields and locales** | Fields crossed on untranslated or half-filled records (a query that throws can return 200 with an empty body and nothing in the logs); `fallbackLocales`; blocks or records missing a renderer |
| **Environments and draft mode** | The environment each read, build and migration targets; draft token reachable only server-side; preview and visual-editing routes |
| **Cache and revalidation** | Cache tags requested and purged; webhook to revalidation path; pages that stay stale or rebuild on every publish |
| **Schema and types** | Schema changes shipped as migrations; generated query types up to date; models renamed or removed that queries or content still use |
| **Rate limits and weight** | Query size and page size; number of requests per build; image and video transforms requested |

## Tests

Level `essential` when a test runner is configured, else `none`. Sensitive areas: query and fragment modules, webhook and revalidation endpoints, draft-mode routes, migrations (`migrations/`), content import scripts.

## Gate

This preset adds no gate of its own beyond the framework's. When generated query types are committed, add the project's generation command (for example `npm run generate-types`) followed by `git diff --exit-code` on the generated file, so stale types fail; only commands whose script exists are proposed.

## References

All optional, never invoked by this preset:

- `datocms-cda` (`datocms:datocms-cda`): queries, localization, cache tags, type generation.
- `datocms-frontend-integrations` (`datocms:datocms-frontend-integrations`): draft mode, Content Link, official components.
- `datocms-structured-text` (`datocms:datocms-structured-text`): Structured Text rendering.
- `datocms-cli` (`datocms:datocms-cli`): migrations and schema codegen.
- `datocms-content-modeling` (`datocms:datocms-content-modeling`): schema decisions.
