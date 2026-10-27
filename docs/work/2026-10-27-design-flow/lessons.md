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

