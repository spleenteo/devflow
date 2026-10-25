# V6 — README and migration: Implementation Plan

> **For agentic workers:** run with `subagent-driven-development`, task by task. Absolute paths always (the shell resets its cwd and drops variables). Worktree: `/Users/spleenteo/Sites/me/devflow-flow`. Never touch `/Users/spleenteo/Sites/me/devflow` or `~/.claude/` (reading is fine). Read `docs/work/2026-10-25-flow-plugin/lessons.md` first.

**Goal:** the README tells a new user how to install and use the `flow` plugin and an existing user how to migrate; the Gate runs over the whole repo with no exclusions.

**Spec:** `slices.md` § V6; `docs/architecture.md`; `dependencies.md`; `docs/development-guidelines.md` (Releases, Gate); the decisions in `docs/decisions-log/`.

## Global Constraints

- The README is the entry point, not a second copy of the skills or of `architecture.md`: install, use, configure, migrate, develop; for the rest it links (`docs/architecture.md`, `dependencies.md`, the skills, the guidelines). Target under ~200 lines.
- Install path: plugin only. Remove the `npx skills add` path, the symlink install, `install.sh` as an installer (it is a dependency checker now: say so in one line) and `grill-me` (decision `2026-10-25-no-grill-me-dependency.md`).
- Every Claude Code behaviour stated links to a `code.claude.com` page, reusing `architecture.md`'s links where they fit.
- Agnostic: invented examples (`acme-app`); no personal projects or tools. Old names appear only in the migration note and the repo-vs-plugin sentence.
- English; explicit `git add`; trailer `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`; hashes with `git rev-parse --short HEAD`.

## Review Focus

1. The two-command install comes first; the one-step form (`/plugin install flow --marketplace spleenteo/devflow`) is offered as "recent versions also accept", with no version number unless a `code.claude.com` page states one.
2. The project snippet: `extraKnownMarketplaces` without `ref` plus `enabledPlugins`; what a teammate gets on trust alone and what the start check will then ask them to install. Stated as documented behaviour with its links, not demonstrated (the first project that adopts it is the test, as the pinning decision says). Must agree with `architecture.md` and the decision.
3. Migration on a machine with both the symlinks and the plugin: the old `/devflow` and the new `/flow:dev` both load until the symlinks go; say to install first, then remove.
4. Personal copies of dependency skills alongside the plugin copies: harmless (presence rule), but duplicates in the listing; say how to drop them.

---

### Task 1: Rewrite the README (critical)

**Files:** `README.md`.

Sections, in order: what it is (three sentences; repo `devflow` vs plugin `flow` in one); Install (user scope, two commands; one-step alternative; dependencies: run `/flow:dev` and the start check lists what's missing, or `./install.sh` from a clone; link `dependencies.md`); Use in a project (the `.claude/settings.json` snippet, trust, `ref` as escape hatch stated as documented behaviour with its link); Usage (the four skills, one line each, `/flow:project` → `/flow:dev` hand-off; links to the SKILL files); What lands in a project (short, links `architecture.md#what-a-project-holds` or the actual anchor); Project lenses (what, where, template, how a repo past Step 0 adds the file: ask `/flow:dev` to create `docs/impact-lenses.md` from its template); Plan review lenses, now five, named (mandate fidelity, ignored lessons, existence, guideline compliance, project lenses); Configuration (`.flow.yml` keys, `.devflow.yml` fallback); Migrating from the symlink skills, every point: `/devflow` → `/flow:dev`, `/projectflow` → `/flow:project`, `/devflow-docs` → `/flow:changelog`, `/devflow-archive` → `/flow:archive`; `.devflow.yml` → `.flow.yml` (still read); install the plugin first, then remove the symlinks (`~/.claude/skills/{devflow,devflow-docs,devflow-archive,projectflow}`) or, for `npx` installs, `npx skills remove devflow devflow-docs devflow-archive projectflow`; duplicate personal copies of the dependency skills (harmless, how to drop them); existing `docs/work/archived.md` headers citing `/devflow-archive` can stay or be edited by hand; Develop the plugin (`claude --plugin-dir .`, the `## Releases` warning, link guidelines); Update / Uninstall (`claude plugin marketplace update flow`, `claude plugin update flow@flow`, `claude plugin uninstall flow@flow`, each checked against `--help`); License.

No clone line that names the old folder (`cd devflow`): use `git clone <url> flow` or `git -C`.

Keep what's still true in the current README (usage examples, the lifecycle wording) when it matches the skills; rewrite the rest.

**Verify:** old-name grep on `README.md` (`rg ... README.md`, path always given) prints only the migration note, the repo-vs-plugin sentence and the Configuration fallback sentence; each migration point above present; link check (no exclusions) empty; `claude plugin validate .` no longer advises a README install line; every command checked against `--help`; names check empty.
**Done:** committed ("Rewrite the README for the flow plugin").

### Task 2: Drop the Gate's exclusions

Depends on: T1. **Files:** `docs/work/2026-10-25-flow-plugin/slices.md` (top: "The Gate during the work" says the narrowing ended with V6), `docs/development-guidelines.md` Gate comment: allowed matches list matches reality (adds `architecture.md`'s two and the README's migration note, repo-vs-plugin sentence and Configuration fallback sentence); expected validate warnings drop the README install line once T1's README carries the one-step form.

**Verify:** the Gate exactly as written in the guidelines, no extra globs: validate passes; grep only allowed matches; link check empty.
**Done:** committed ("End the Gate's narrowing").

### Task 3: Demonstrate V6's Done

Depends on: T1, T2. Verification only. Scratch `/private/tmp/claude-501/-Users-spleenteo-Sites-me-devflow/6710ec3a-a9a2-4f23-8f29-504e326894bb/scratchpad/v6/`. Serve the branch: `git clone --bare --branch chore/convert-to-plugin /Users/spleenteo/Sites/me/devflow-flow <scratch>/srv/flow.git`, then `git -C <scratch>/srv/flow.git symbolic-ref HEAD refs/heads/chore/convert-to-plugin` so the default branch is the work. Try in order, recording which worked: (a) `git daemon --export-all --base-path=<scratch>/srv --port=9418 --reuseaddr` in the background, URL `git://127.0.0.1:9418/flow.git`; (b) smart HTTP: `git http-backend` as CGI with `GIT_PROJECT_ROOT=<scratch>/srv` and `GIT_HTTP_EXPORT_ALL=1` behind a small Python `http.server` CGI handler, URL `http://127.0.0.1:<port>/flow.git`. Follow the README's install commands with that URL in place of `spleenteo/devflow`, every `claude plugin` command prefixed with `CLAUDE_CONFIG_DIR=<scratch>/cfg` on the same line. Pass: `claude plugin details flow@flow` lists `archive, changelog, dev, project`. Stop the server afterwards. The project snippet is not run (Review Focus 2).

**Done:** outputs in the task report, then into the close narrative.
