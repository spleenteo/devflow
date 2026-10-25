# Dependencies

`flow` does not bundle the skills it hands work to, and it never installs anything: it reads this file, tells you what is missing and prints the commands. You run them.

A dependency counts as present when a skill listed in the session has its name, or its segment after `:` equals it. `superpowers:writing-plans` and a personal `writing-plans` both count.

| Source | Install as | Skills | Need | Used by |
|---|---|---|---|---|
| superpowers | `superpowers@claude-plugins-official` | `brainstorming` | required | frame, both flows |
| superpowers | `superpowers@claude-plugins-official` | `writing-plans`, `subagent-driven-development` | required | `/flow:dev` slice loop |
| shaping-skills | `shaping-skills@flow` | `shaping`, `breadboarding`, `framing-doc` | required for the definition phases | both flows |
| shaping-skills | `shaping-skills@flow` | `kickoff-doc` | required for its phase | `/flow:project` only |

Project scope is shared with the team through the project's settings: it writes the plugin's entry to `.claude/settings.json`, which you commit. Committing it enables the plugin for collaborators but does not download it, so each one runs the project-scope command once. See [Choose an install scope](https://code.claude.com/docs/en/discover-plugins#choose-an-install-scope). Flags: `claude plugin install <plugin> --scope user|project|local` and `claude plugin marketplace add <source> --scope user|project|local`.

### superpowers

Provides `brainstorming`, `writing-plans` and `subagent-driven-development`. Its marketplace, `claude-plugins-official`, is known by default: no marketplace line.

```bash
# user scope
claude plugin install superpowers@claude-plugins-official --scope user
# project scope
claude plugin install superpowers@claude-plugins-official --scope project
```

### shaping-skills

Provides `shaping`, `breadboarding`, `framing-doc` and `kickoff-doc`. It is served by the `flow` marketplace, from the repository `spleenteo/flow`, so the marketplace is added first.

```bash
# user scope
claude plugin marketplace add spleenteo/flow --scope user
claude plugin install shaping-skills@flow --scope user
# project scope
claude plugin marketplace add spleenteo/flow --scope project
claude plugin install shaping-skills@flow --scope project
```

The upstream ripple-check hook is not wired. It is opt-in upstream, needs `jq`, and interrupts every edit of a file with `shaping: true` in its frontmatter. To use it anyway, follow the upstream setup: <https://github.com/rjs/shaping-skills>.

## How the conductors use this file

`/flow:dev` and `/flow:project` read it at the start, before writing anything, and report what is missing in one message. They check again at the phase that invokes a dependency and stop that phase with these commands if it is absent. They never install.
