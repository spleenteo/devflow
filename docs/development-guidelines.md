# Development guidelines

Rules the plans and the changes in this repo must follow. The repo is a Claude Code plugin made of Markdown skills: there is no build and no test framework.

## Tests

No test framework. A slice is verified by running what it changed:

- `claude plugin validate .` for anything under `.claude-plugin/` or `skills/`;
- a throwaway test repo, created outside this repo (in the session scratchpad or `/tmp`), for loading, naming and settings behaviour. Never committed;
- for a change to a skill's instructions, a read-through against the brief and the skills that cite it.

Every behaviour of Claude Code a document states is either verified in a spike or a slice, or linked to the official docs page that says it.

## Naming

- A skill's folder is its `name:`, kebab-case: `skills/dev/SKILL.md` has `name: dev`.
- User-invocable skills are cited as `/flow:<skill>` in every document. Skills that aren't user-invocable (`flow:docs`, `flow:stack-<name>`) and agents (`flow:planner`, …) are cited as `flow:<name>`, with no slash. Dependency skills are cited by bare name, with the plugin form in brackets at the first mention: `shaping` (`shaping-skills:shaping`). The brackets go only at a dependency's first mention in each skill, bare afterwards.
- No names of specific user projects or personal tools anywhere. Examples use invented names.

## Language

English in every file, commit message and work document.

## Commits

Imperative mood, English, one concern per commit. Explicit `git add <paths>`, never `-A` or `.`. No `CLAUDE.md` at the repo root (`claude plugin validate` warns on it).

## Gate

Green before a slice closes, in order, from the repo root. The link check skips links inside fenced code blocks, where templates hold placeholder links. Both `rg` calls name the path (`.`): without one, `rg` reads stdin when it isn't a terminal and hangs.

```bash
claude plugin validate .        # passes; expected warnings: missing version and icon, the folder also holding a marketplace manifest
# old names: the only allowed matches are in shared/work.md § Upgrade and in the README's
# § Upgrading from an older Flow; nothing else.
# --hidden so .claude-plugin/ is searched too
rg -n -i --hidden '\bdevflow\b|devflow-(docs|archive)|projectflow|\.devflow\.yml' \
  --glob '!.git' --glob '!.git/**' \
  --glob '!docs/work/**' --glob '!docs/briefs/**' --glob '!docs/CHANGELOG.md' \
  --glob '!docs/development-guidelines.md' .
# every relative Markdown link resolves: prints "file -> target" per broken link, nothing when green.
# Add --glob '!path' to the rg --files call for the narrowing a work's slices.md sets.
rg --files --glob '*.md' --glob '!docs/work/archive/**' . | while read -r f; do
  awk '/^ *```/{x=!x; next} !x{s=$0; while(match(s,/\]\([^) ]+/)){print substr(s,RSTART+2,RLENGTH-2); s=substr(s,RSTART+RLENGTH)}}' "$f" |
    while read -r t; do
      case "$t" in http*|mailto:*|\#*) continue;; esac
      test -e "$(dirname "$f")/${t%%#*}" || echo "$f -> $t"
    done
done
```

While a work is in progress, its `slices.md` may narrow the Gate (for example, files a later slice rewrites); the narrowing ends with that work.

## Releases

How a change in this repo reaches the projects that use the plugin: see [Distribution](architecture.md#distribution).

- **Work on branches.** Every change, a work's documents included, is made on a branch.
- **A merge into `main` is a release.** Projects declare the `flow` marketplace without a `ref`, so whatever is on `main` is what they get. `main` never holds unreleased work: nothing is committed to it directly. Why: [projects declare the marketplace without a ref](decisions-log/2026-10-25-projects-declare-marketplace-without-ref.md).
- **Version and tag.** `/flow:changelog` bumps `.version` and writes the changelog entry on the branch, before the merge. After the merge, tag the merge commit `v` followed by the content of `.version` (`v0.4.0`) and push the tag.
- **Develop with `--plugin-dir`.** Run `claude --plugin-dir /path/to/clone` to load the clone you are editing for one session; it takes the place of an installed `flow` for that session ([flags that load a plugin for one session](https://code.claude.com/docs/en/plugins/cli-reference#flags-that-load-a-plugin-for-one-session)).
- **Never add the marketplace from the clone you are editing.** A marketplace added from a local path loads its relative-path plugins in place, from that folder, not from a copy in the cache ([in-place and copied plugins](https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins)). `flow` has the source `./`, so every session would run the conductor from the files it is editing: the conductor would edit itself. A user also has one marketplace per name ([marketplace reference](https://code.claude.com/docs/en/plugins/marketplace-reference)), so the local one would replace the released `flow`.
