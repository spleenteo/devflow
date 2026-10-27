---
tags: [work, design-flow, lessons]
description: "Rules learned while running the design-flow slices, read by every later subagent."
---

# Lessons

- A fix round sent to an executor dictates the subject `Fix review findings on T<n>: <what>`, never a free subject.
- Ask the executor to re-run every Verified check after a fix, `claude plugin validate .` included, and to list any it skipped under Concerns.
- A skill's behaviour is demonstrated with `claude -p --plugin-dir <repo>` in a scratchpad repo, `--continue` for a second turn, `--output-format stream-json --verbose` to see which skills were invoked.
- Anything a skill writes for people (index rows, notes) follows the language of the folder's documents, not the conversation's.
- Probe every tool behaviour a plan relies on before the task that writes it into a skill; the reviewer can't run tools.
- Run a skill's Done demos in real sessions before closing: reviews read the text, demos found the defects (a non-existent API call, a temp file left in the repo, a path base).
- A tool's generated identifiers (library aliases) are read back, never assumed in a skill or a test bed.

- Demo sessions of a conductor need `--add-dir <plugin repo>` as well as `--plugin-dir`: without it the conductor can't read the plugin's own references (`shared/work.md`, `dependencies.md`) and silently runs on less.
- `--allowedTools` prefix rules don't match commands holding `$(...)`: in headless demos such calls are denied and retried; widen the list or accept the noise, and note it.
- A demo of a later slice exercises the earlier slices' skills on new ground: read its tool errors, not only its final message (V3 found the adapter's override path for imported instances wrong).
- Claude Code's shell check stops a command holding a brace next to a quote (`{ … '…' … }`), and a headless session can't approve it: Pen command strings go in backticks (now in the adapter). Other headless checks (`$(...)`, variables in loops) are retried by the sessions and are noise, not defects.
