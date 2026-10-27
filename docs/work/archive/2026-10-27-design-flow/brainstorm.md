---
tags: [work, design-flow, brainstorm]
description: "What the user wants from a design capability in Flow: a design loop that lives in files, keeps a design system aligned with code, and is reachable from /flow:dev, /flow:project and on its own."
---

# Brainstorm — Design flow

## Intent

The user already designs with Pen (pen.dev) inside Flow works, by hand. This morning, on a product feature in another project, the loop went like this: shaping described a search interface, Claude drew it in Pen, the user looked at it and improved the requirements, the plan was executed, and once the feature was done the Pen file was updated and became the source for screenshots in the docs and on the site. The same day, Flow's own landing page was designed in Pen, approved by eye and published.

It works, but Flow doesn't know the step exists. The user has to slip it in without knowing when or how, Flow doesn't know about `docs/design/`, and the user is left with open questions about how to organise the files.

What the user wants is **the loop, not the tool**: design as a step Flow knows how to offer, producing artifacts the user can see and touch before code exists, and kept alive afterwards.

## Why files

Claude artifacts are interactive and are the right medium in some cases, but they stay closed inside Claude: reusing one means exporting it. A design file in the repo (or in a project's home) travels with the work, is versioned, and anyone can open it. Flow may ask which medium fits a given case: a Claude artifact or a design file.

Pen is today's tool, chosen for three reasons the user gave: a generous free tier (for now), good integration with Claude Code and its CLI, and it lives in a repo. Tomorrow another tool (Paper was named) may fit better.

## Where it is used

Three entry points, all wanted:

1. **Inside `/flow:dev`**: during the definition of a feature, the shaped interface becomes something to look at before the plan.
2. **Inside `/flow:project`**: artifacts for non-software work — slides, diagrams, landing pages.
3. **On its own**: design work with no code to follow (a brand, a deck).

## What success looks like

The user discusses a new feature, and Flow already knows it can go through the design capability. That capability knows where the project's design system is, opens it, and draws the feature's UI from the existing components, proposing new ones where needed. **If a design system exists, nothing starts from scratch.**

## Goals

- **Discovery.** Flow knows the project's design files exist, where they are and which one fits the task (design system, brand, site, product).
- **Reuse.** A feature's UI is composed from the design system's components and tokens.
- **Promotion.** A new component, once the user approves it, is promoted into the design system, so the next feature finds it.
- **Bootstrap.** When a project has no design system, it is extracted from the existing code: tokens and components.
- **Alignment, both ways.** The design system is kept aligned with the code. Sometimes code moves first (a visual bootstrap in Pen, then tweaks in the browser) and the design file must be realigned after the fact; sometimes the design file moves first and the change must be carried to code. This two-way nature is the point.
- **Timing of alignment.** Certainly at the close of a work. At every slice close it may cost more than it gives (see "Left to the builder").
- **Exports, optional.** The design file *can* be the source of screenshots for docs and the site, but often it won't be: an export happens only when the user wants one, never as a mandatory step. When it happens, it is checked by the file's existence, since a failed export can exit 0 (*builder's call*).

## First release

The user wants **a simplified first taste**. Builder's proposal, accepted: the hook into `/flow:dev` and `/flow:project`, **discovery, reuse and promotion**, and the guideline on how design files are set up and kept. Bootstrap and alignment come later, in their own works.

## Alignment: whose job

The user is unsure, and says so: design and code can drift through changes that never pass through Flow (a developer working on their own). The user's current leaning is that **keeping design and code aligned stays the responsibility of developers and designers, by hand**, possibly stated in the project's `CLAUDE.md`. So in the first release Flow does not detect drift. What "aligned" means (tokens only, tokens and component list, each component's look and props) and who detects drift stay open for the later work. Note: Flow never writes a project's `CLAUDE.md` on its own; at most it can propose a line.

## Test bed

Flow's own repo has only a landing page, too little to exercise a design system. A small project of the user's, where anything can be tried, is the first test bed; a richer product of theirs may come later. Flow's `docs/design/flow_home-page.pen` is not restructured by this work.

## Calls made by the builder

- **Claude artifacts**: Flow offers one as an alternative medium; when chosen, it produces it, without design-system reuse or promotion, which apply to design files only.
- **Bootstrap trigger** (later release): offered as its own step when no design system exists, never inline blocking a feature. With no code to extract from (a project, a standalone work), it starts an empty library from the brand's inputs.

## Non-goals and anti-goals

- **Never delete or destroy artifacts** (files, components, frames) unless the user explicitly asks. A component that looks unused may serve a later iteration.
- **Consent, not prohibition.** The capability runs in the same session that writes code, so "it never touches code" would be a fake rule. What matters is that every change of direction (design → code, code → design) is proposed and approved by the user.
- **Not tied to Pen in its concept.** The loop must survive a change of tool.
- **Not a replacement for Claude artifacts.** They remain an option when interactivity matters.

## What we know about Pen (recon, 2026-10-27)

From pen.dev's docs and the Pencil MCP tools available in session:

- **Libraries.** A file can be turned into a design library (`.lib.pen` suffix; irreversible). Other files import it (`imports: { alias: "./x.lib.pen" }` in the schema). Library components placed in a file keep a link; library changes load when the importing file is reopened, not live. Between two plain `.pen` files there are no references: components must be copied.
- **No pages or folders** inside a file: one infinite canvas of top-level frames, plus groups. `note` and `context` nodes hold text on the canvas, so guidance can live in the file too.
- **Themes and variables** (design tokens) are document-level, with theme axes (e.g. light/dark).
- **CLI.** `pen --out x.pen --prompt …` creates a file; `pen interactive -o x.pen` runs headless with `save()`; `pen interactive -a desktop -i x.pen` opens it in the app; `--export` writes PNG/JPEG/WebP/PDF. An export failure can exit 0, so the file's existence must be checked.
- **Git.** The docs call `.pen` version-control friendly, but files are encrypted: diffs are unreadable, conflicts are resolved by keeping both versions and reapplying in Pen, and a file should be saved and closed before switching branches or pulling. Relevant because Flow always works on branches.
- **This repo.** `docs/design/flow_home-page.pen` holds three top-level frames (Home Page, Avatar dark, Avatar light) and no reusable components. Pen currently has a copy open at an older path (`~/Sites/me/devflow/docs/design/`).

So the user's imagined layout holds, with one distinction: shared sources (design system, brand) as libraries, and per-area files (site, product) that import them.

## The user's open doubts, and where they stand

| Doubt | Status |
|---|---|
| Can several files talk to each other, or one file with folders? | Answered by recon: libraries + importing files; no folders |
| Can Flow ship a guideline on how to set up and manage the files? | Open; the form is the builder's (below) |
| Can a project read several guidelines at once (astro + datocms + design)? | Yes for stacks: the decision of 2026-10-26 resolves each stack's preset independently. Whether design is a stack is open |
| `flow:pen` or a tool-agnostic name? | The user cares about the loop, not Pen: lean agnostic. Final naming open |

## Left to the builder

The user handed these over; they are to be proposed and settled in the grill:

- **The form inside Flow**: a user-invocable skill (`/flow:design`) also called by `/flow:dev` and `/flow:project`; a preset like the stack ones; a guideline; or a mix.
- **Name**, within "tool-agnostic".
- **Where tool-specific knowledge lives** (Pen today), so it can be swapped.
- **Folder conventions** under `docs/design/` (repo) and in a project's home.
- **The exact hook points** in `/flow:dev` and `/flow:project`, and the per-slice check. The builder's guess: a light check at slice close ("did this slice touch the UI?") that proposes realignment only when it did, and a full alignment step at the work's close.

## Settled

- Form inside Flow — a tool-agnostic `/flow:design` skill owns the loop (discovery, reuse, promotion, choice of medium, consent), plus a replaceable tool adapter (Pen today) resolved like stack presets; the file guideline is a document in the project, not a skill.
- Hook in `/flow:dev` — an optional `design` phase after shaping (or breadboard) and before slicing, offered only when the work touches a UI; corrected requirements flow back into `shaping.md`.
- Hook in `/flow:project` — no fixed rule: the conductor reads the slice's context and proposes `/flow:design` only when an artifact fits that case; files go to `<home>/design/` when used.
- First-release cut — no per-slice check and no work-close alignment step; promotion on approval is the only design-system write.
- Choice of medium — Flow reads the context and proposes one, with the reason: a Claude artifact for interactive or exploratory work, a design file for static artifacts (landing pages, UI, web); the user confirms or changes it.
- Names — skill `/flow:design`; shipped adapter `flow:design-pen`; a project switching tools maps its own `<plugin>:design-<tool>`.
- Tool configuration — `design: <tool>` in `.flow.yml` (absent means no tool, artifacts only); the adapter resolves through the presets chain with `design` as its key.
- Design folder — always `docs/design/`, never split across paths; when setup or an update finds design files elsewhere (a `design/` folder, stray `.pen` files), it proposes moving them into `docs/design/`.
- Design folder in a project — `docs/design/` relative to the root in both layouts: the repo root, or the project's home (`<home>/docs/design/`).
- File index — two places, kept current by `/flow:design` and read first: `docs/design/README.md` with a table (file, role, contents, imported libraries), tool-agnostic and the primary index; plus a note inside each design file describing it (Pen: a `note`/`context` node), written through the adapter.
- Promotion — on approval, the component moves into the design-system library; the feature file keeps a linked instance, not a copy; the index is updated; nothing is deleted unasked; the tool mechanics live in the adapter.
- Moving stray files — on its first run in a repo or project, `/flow:design` looks for design files outside `docs/design/` and proposes moving them, in one message with the list, only on an ok, warning to close files open in the app first; not part of Flow's upgrade.
