# Dependencies

`flow` does not bundle the skills it hands work to, and it never installs anything: it reads this file, tells you what is missing and prints the commands. You run them.

A dependency counts as present when a skill listed in the session has its name, or its segment after `:` equals it. `shaping-skills:shaping` and a personal `shaping` both count.

| Source | Install as | Skills | Need | Used by |
|---|---|---|---|---|
| shaping-skills | `shaping-skills@flow` | `shaping`, `breadboarding`, `framing-doc` | required for the definition phases | both flows |
| shaping-skills | `shaping-skills@flow` | `kickoff-doc` | required for its phase | `/flow:project` only |
| datocms | `datocms@datocms-skills` | `datocms-cda`, `datocms-frontend-integrations`, `datocms-structured-text`, `datocms-cli`, `datocms-content-modeling` | optional (datocms) | `flow:stack-datocms` preset |
| rails-development | `rails-development@skills` | `rails-patterns`, `testing-patterns` | optional (rails) | `flow:stack-rails` preset |

Per-stack rows (Need `optional (<stack>)`) are reported only in a project of that stack.

The design tool (the Pencil app or its `pen` CLI for `design: pen`) is not a skill and is not listed here: `/flow:design` checks it through its adapter's `## Requires`, and `install.sh` does not.

Project scope is shared with the team through the project's settings: it writes the plugin's entry to `.claude/settings.json`, which you commit. Committing it enables the plugin for collaborators but does not download it, so each one runs the project-scope command once. See [Choose an install scope](https://code.claude.com/docs/en/plugins/install#choose-an-install-scope). Flags: `claude plugin install <plugin> --scope user|project|local` and `claude plugin marketplace add <source> --scope user|project|local`.

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

### datocms

Provides `datocms-cda`, `datocms-frontend-integrations`, `datocms-structured-text`, `datocms-cli` and `datocms-content-modeling`, referenced by the `flow:stack-datocms` preset. It is served by the `datocms-skills` marketplace, from the GitHub repository `datocms/agent-skills`, so the marketplace is added first.

```bash
# user scope
claude plugin marketplace add datocms/agent-skills --scope user
claude plugin install datocms@datocms-skills --scope user
# project scope
claude plugin marketplace add datocms/agent-skills --scope project
claude plugin install datocms@datocms-skills --scope project
```

### rails-development

Provides `rails-patterns` and `testing-patterns`, referenced by the `flow:stack-rails` preset. It is served by thoughtbot's marketplace, named `skills`, from the GitHub repository `thoughtbot/skills`, so the marketplace is added first.

```bash
# user scope
claude plugin marketplace add thoughtbot/skills --scope user
claude plugin install rails-development@skills --scope user
# project scope
claude plugin marketplace add thoughtbot/skills --scope project
claude plugin install rails-development@skills --scope project
```

## How the conductors use this file

`/flow:dev` and `/flow:project` read it at the start, before writing anything, and report what is missing in one message. They check again at the phase that invokes a dependency and stop that phase with these commands if it is absent. They never install.
