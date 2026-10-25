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
- Skills are cited as `/flow:<skill>` in every document. Dependency skills by bare name with the plugin form in brackets: `writing-plans` (`superpowers:writing-plans`), so the reference holds for plugin and personal installs alike. The brackets go only at a dependency's first mention in each skill, bare afterwards; `grill-me` stays bare because the presence rule (a listed name, or its segment after `:`) covers both the plugin and the personal install. Checked: with only the plugin copy visible, a session resolves the bare name to the plugin skill.
- No names of specific user projects or personal tools anywhere. Examples use invented names.

## Language

English in every file, commit message and work document.

## Commits

Imperative mood, English, one concern per commit. Explicit `git add <paths>`, never `-A` or `.`. No `CLAUDE.md` at the repo root (`claude plugin validate` warns on it).

## Gate

Green before a slice closes, in order, from the repo root. The link check skips links inside fenced code blocks, where templates hold placeholder links. Both `rg` calls name the path (`.`): without one, `rg` reads stdin when it isn't a terminal and hangs.

```bash
claude plugin validate .        # passes; the only warnings are the missing version
# old names: only the allowed matches remain (the .devflow.yml fallback sentence and
# dev's notice, Step 0's condition and ls, the "devflow work ... merged" notes,
# the repository URL, the README migration note and the repo-vs-plugin sentence)
rg -n -i '\bdevflow\b|devflow-(docs|archive)|projectflow|\.devflow\.yml' \
  --glob '!docs/work/**' --glob '!docs/briefs/**' --glob '!docs/CHANGELOG.md' \
  --glob '!docs/development-guidelines.md' . | rg -v 'spleenteo/devflow'
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
