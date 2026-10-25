# Project impact lenses

This project's own lenses: what a change here can break that the code alone doesn't show. `/flow:dev` reads this file at impact and in every plan review, and applies each lens on top of the built-in checks `/flow:dev` runs for the project's stack (Rails, Astro, …). Write a lens as a question about what this project breaks, not as a coding rule: coding rules go in `development-guidelines.md`. Delete the examples and keep only lenses that are true here.

| Lens | Looks for |
|---|---|
| **Public URLs** | A route or slug that changes: does the old one keep a redirect? Links from outside, saved bookmarks and search results still point at it |
| **Shared export** | A field renamed or removed in the model: does it also change the nightly CSV other teams read? Their import breaks without warning |

<!-- Optional: with many lenses, group them under `##` headings (for example `## Data`, `## Public surface`), each with its own `| Lens | Looks for |` table. -->
