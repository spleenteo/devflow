# Lessons — flow-plugin

- Pass a path to every `rg` in a script or gate (`rg ... .`): with no path and no terminal on stdin, `rg` reads stdin and hangs.
- Prefix every `claude plugin` command in a test with `CLAUDE_CONFIG_DIR=<scratch>/cfg` on the same line: the shell drops exports between calls, and the install would land in the real `~/.claude`.
- What a session sees is the `skills` / `slash_commands` arrays of the `init` event (`claude -p --output-format stream-json --verbose`), never the model's prose.
- `skillOverrides: "off"` in a scratch repo's `.claude/settings.local.json` hides personal skills in `-p` runs: use it to take the old conductors out of every demo.
- A subagent reports its commit with `git rev-parse --short HEAD` output, not a shell variable it never printed.
- Prose in any Markdown file outside fences must not quote the bracket-parenthesis link syntax: the Gate's link check reads it as a link. Describe it in words.
- `skillOverrides` match exact names: hiding `subagent-driven-development` leaves `superpowers:subagent-driven-development` visible. List the plugin form too when a demo must hide it.
- Before naming a skill as a dependency the flow invokes, read its frontmatter: `disable-model-invocation: true` makes it user-only, absent from the model's listing and impossible to invoke.
- `enabledPlugins: {"<id>": false}` in a scratch repo's `settings.local.json` disables a user-scope plugin for `-p` demos.
- A demo trap must be one the code alone can't reveal, and the demo compares runs with and without the feature: otherwise a common lens finds it and the demo proves nothing.
- Don't edit files a running demo reads: hold the fix round until it ends.
- Check rendered diagrams by eye against the skill text, not only for render errors: missing edges (a skippable phase, a loop back) render without complaint.
- A document that summarises a skill is reviewed against the skill's own lines, quoted side by side: attribution slips (which plugin provides a skill) survive a read-through.
