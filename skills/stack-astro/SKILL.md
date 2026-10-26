---
name: stack-astro
description: Flow stack preset, invoked only by Flow's conductors by its qualified name; never for general questions.
user-invocable: false
---

# Flow: stack preset, Astro

Opinions for a site built with Astro, read by Flow's conductors. A project that disagrees replaces this preset (`presets:` in its configuration file); nothing here is a command to the user.

## Rules

1. Pages are static by default; opt a route out with `export const prerender = false` only when its data is per request (session, query string, preview), because static output is the cheapest and most cacheable.
2. Set `output` once in `astro.config.*` and keep it; do not mix per-route overrides in both directions, because two defaults make the rendering mode of a route impossible to read.
3. Components are `.astro` unless they need client state or events; a framework component gets a `client:*` directive only for that interactivity, because every island ships JavaScript.
4. Prefer `client:idle` over `client:load`, and `client:visible` for below-the-fold parts only, and never `client:only` without a reason written in a comment, because eager hydration costs the first paint.
5. Content comes through typed queries (content collections with a schema, or generated types for a CMS), never untyped `fetch` in a page, because a renamed field must fail the build, not the page.
6. Declare environment variables with `astro:env` (`envField`, context `server`, access `secret`) in Astro 5; `import.meta.env` is replaced at build, so it cannot supply runtime secrets on SSR routes. Only public client variables (`PUBLIC_`) may reach client code, because anything else leaks into the bundle.
7. Local images go through `astro:assets` (`<Image />`, `<Picture />`) with explicit `alt` and dimensions; CMS assets go through the CMS preset's component; remote images through `astro:assets` need `image.domains` or `remotePatterns`; fonts are self-hosted, because remote assets add requests and layout shift.
8. Set `lang` and `dir` on the root element from the route's locale, and use logical CSS properties (`margin-inline-start`) over physical ones, because right-to-left locales break otherwise.
9. Client scripts that must survive navigation re-attach on `astro:page-load` when the site uses `<ClientRouter />`, because the router replaces the DOM and loses listeners.
10. Generate the sitemap and `robots.txt` from the config (`@astrojs/sitemap`, an endpoint), with `site` set, because hand-kept lists drift from the routes.
11. Keep dynamic routes explicit: `getStaticPaths` returns every locale and slug, and unknown paths hit a real 404 page, because a silent empty page returns 200.
12. Take adapters and hosting limits (bundle size, build time, route count) into account before adding a route-generating feature, because the host fails the deploy, not the build.

## Lenses

| Lens | Looks for |
|---|---|
| **Prerender and runtime** | Which routes are static and which SSR; what changes if data read at build time must be read per request; environment variables available only at build |
| **Content sources** | Queries to a CMS or content layer: nullable fields crossed on untranslated or empty records (a query that throws can return 200 with an empty body and nothing in the logs); environments and draft mode; cache and revalidation |
| **Islands and navigation** | Components with `client:*` and what survives a view transition: state attached to an element Astro replaces on navigation is lost; inline scripts that do or don't re-attach |
| **Languages and direction** | Per-locale routes and 404s; `lang` and `dir` on the root; physical vs logical CSS properties; fonts covering the served alphabets; `hreflang` and sitemap |
| **Weight and platform** | Hosting limits (bundle size, build time, route count); self-hosted fonts and images; `robots.txt` and crawler output |

## Tests

Level: essential
Sensitive areas: `src/pages/api/`, middleware and auth, data import and content-transform code, redirect and locale-routing logic

Essential when a test runner is configured (`vitest`, `@playwright/test`, a `scripts.test`), else none, with empty areas.

## Gate

- `npx astro check` (types and diagnostics), only when `@astrojs/check` is a dependency, else it prompts to install and hangs
- `npm run build` (the build catches broken routes and content schemas)
- `npm test` when `scripts.test` exists

## References

No external skill or guide is referenced: the Astro docs (docs.astro.build) are the source for the directives and APIs named above.
