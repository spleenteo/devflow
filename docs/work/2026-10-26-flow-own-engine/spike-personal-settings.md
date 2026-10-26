---
work: flow-own-engine
tags: [spike, flow-own-engine]
description: Where personal (never committed) plugin settings and user-level stack files can live, and how a small team can share them, per the official Claude Code docs.
---

# Spike — Where personal settings live

## Context

The `flow` plugin keeps project settings in the repo (`.flow.yml`, `docs/development-guidelines.md`). It also needs personal settings that are never committed: model preferences and user-level "stack files" (one Markdown file per framework, adding to or replacing the ones the plugin ships). A small team (two people) should be able to share personal stack files without forking the plugin.

Method: official docs on code.claude.com only, plus the local CLI (`claude` 2.1.310). Where the docs are silent the answer is "not documented".

## Goal

Pick a layout for personal settings and shared stack files that uses only documented mechanisms.

## Questions

| # | Question |
| :- | :- |
| S3-Q1 | Does the plugin manifest support a user configuration prompted at install/enable time? Where are values stored, how do skills read them, can they hold file paths or lists? |
| S3-Q2 | Is there a documented per-plugin data directory that survives plugin updates? Where is it on disk? |
| S3-Q3 | What conventions do user / project / local settings follow, and may a plugin read its own keys from those files? |
| S3-Q4 | Can a plugin skill reliably read a file in the user's home (e.g. `~/.claude/flow/`) — permission prompts, sandbox? |
| S3-Q5 | Is a second, personal plugin (own marketplace) shipping Markdown files for another plugin to read a workable pattern? How does plugin A locate plugin B's files? |

## Findings

### S3-Q1 — `userConfig`

Yes. Source: https://code.claude.com/docs/en/plugins/manifest-reference.md#user-configuration and https://code.claude.com/docs/en/plugins/components.md (section "Ask the user for configuration values").

- **Declaration.** `userConfig` in `plugin.json`: keys are identifiers (letters, digits, underscores). Each option takes `type` (`string`, `number`, `boolean`, `directory`, `file`), `title`, `description` (all required), plus optional `required`, `default`, `options`, `multiple`, `sensitive`, `min`/`max`. Unknown keys inside an option make the plugin fail to load.
- **When prompted.** The dialog opens for unset options on install in `/plugin`, `/plugin install <plugin>@<marketplace>` in a session, or enabling from the Installed tab. `/plugin configure <plugin>@<marketplace>` reopens it. `claude plugin install` (shell) never prompts; use `--config KEY=VALUE` or `claude plugin configure --values-stdin` (confirmed in the local `--help`, which says values are "single-line strings").
- **Storage.** Non-sensitive values go under `pluginConfigs["<plugin>@<marketplace>"].options` in the user's `settings.json`. Sensitive values go to the macOS Keychain, falling back to `~/.claude/.credentials.json` (https://code.claude.com/docs/en/settings-reference.md#pluginconfigs).
- **Reading in skills.** `${user_config.KEY}` is substituted in skill and agent content, MCP/LSP config and exec-form hook `args`. In skill and agent content only non-sensitive values are substituted. Hooks also get `CLAUDE_PLUGIN_OPTION_<KEY>` as an environment variable. Shell-form hooks and monitors reject `${user_config.*}`. Bash commands that Claude runs do not get the plugin variables in their environment.
- **Paths and lists.** `type: "directory"` and `type: "file"` exist, so a path is supported. `default` may be "a string, number, boolean, or array of strings", and `multiple` "allows an array of strings" for `string` options. Options with `multiple` and `sensitive` ones get no row in `/config`. Not documented: whether `~` is expanded in a path value, whether `directory`/`file` can be combined with `multiple`, and how an array renders when substituted into skill content.

### S3-Q2 — Persistent data directory

Yes. `${CLAUDE_PLUGIN_DATA}` resolves to `~/.claude/plugins/data/<id>/`, "created on first reference and kept across plugin updates". `<id>` is the plugin id with every character other than letters, digits, `_`, `-` replaced by `-` (`my-plugin@my-marketplace` becomes `my-plugin-my-marketplace`). Claude Code deletes it when the plugin is uninstalled from its last scope unless `--keep-data` is used. The root can move via `CLAUDE_CODE_PLUGIN_CACHE_DIR`. It is substituted in skill content ("only in plugin skills") and exported to hook, MCP and LSP processes, not to Bash tool commands. By contrast `${CLAUDE_PLUGIN_ROOT}` changes with every version, so no state belongs there.
Sources: https://code.claude.com/docs/en/plugins/manifest-reference.md#environment-variables, https://code.claude.com/docs/en/plugins/loading.md#find-plugins-on-disk, https://code.claude.com/docs/en/skills.md (string substitutions).
Caveat: docs describe it as a place for dependencies, generated code and caches. Nothing in the docs presents it as a place for hand-edited user files.

### S3-Q3 — User / project / local settings

Source: https://code.claude.com/docs/en/settings.md and https://code.claude.com/docs/en/settings-reference.md.

- **Files.** User `~/.claude/settings.json` (all your projects). Shared project `.claude/settings.json` (commit it). Project local `.claude/settings.local.json` (you, this project; Claude Code adds it to the global git excludes when it writes the file, otherwise gitignore it yourself). Precedence, highest first: managed, command line (`--settings`), local, shared project, user. Lists such as `permissions.allow` merge across files.
- **Plugin-owned keys in those files.** The only documented plugin keys are `enabledPlugins` (any file) and `pluginConfigs` (user or managed only). The docs say Claude Code ignores `pluginConfigs` entries in project and local files "because it substitutes these values into plugin hook, MCP, and LSP configurations, and a cloned repository must not be able to supply them". Plugins may ship a `settings.json`, but only `agent` and `subagentStatusLine` take effect (https://code.claude.com/docs/en/plugins/components.md, "Default settings").
- **Arbitrary custom keys.** Not documented. The docs describe rejection of invalid values and per-key handling, but no general rule for unknown keys, and no mechanism for a plugin to read its own free-form keys from these files. A skill can read the JSON with the Read tool like any file, but that is a convention, not a documented plugin API.

### S3-Q4 — Reading `~/.claude/flow/` from a skill

Sources: https://code.claude.com/docs/en/permissions.md, https://code.claude.com/docs/en/permission-modes.md, https://code.claude.com/docs/en/sandboxing.md.

- **Permissions.** The permission table says read-only tools need no approval "within the working directory and additional directories". It does not say outright what the Read tool does for a path outside them in default mode. In auto mode, reads outside run without a prompt except that the first one asks once (never in `-p` or background sessions). `permissions.blockReadsOutsideWorkingDirectories` makes the file tools refuse such reads in every mode. So: not documented as prompt-free in default mode, and blockable by the user.
- **Making it reliable.** A user-settings allow rule with a home-relative path (`~/` is documented in the Read/Edit rule syntax) or `permissions.additionalDirectories` grants access without prompts. The docs give rule syntax, not a plugin-shipped grant. A plugin cannot add permission rules (only `agent` and `subagentStatusLine` apply from plugin settings).
- **Sandbox.** It covers Bash, PowerShell and Monitor processes only. "Tools such as Read, Edit, Write ... follow permission rules instead." Sandboxed Bash can read most of the machine by default, writes limited to the working directory.
- **Writes.** `.claude` is a protected path for writes (prompted in default mode, denied in `dontAsk`), so a skill that writes into `~/.claude/flow/` will prompt. `~/.claude/plugins/data/` is not listed in the documented exceptions.
- **Dynamic injection.** The `` !`cmd` `` form in a skill runs through permission rules and aborts on anything but allow (outside auto mode), so `cat ~/.claude/flow/x` there needs an `allowed-tools` entry or an allow rule (https://code.claude.com/docs/en/skills.md, "Inject dynamic context").

### S3-Q5 — Personal plugin (own marketplace) as a shared stack-file source

Sources: https://code.claude.com/docs/en/plugins/loading.md, https://code.claude.com/docs/en/plugins/dependencies.md, https://code.claude.com/docs/en/plugins/host-marketplace.md.

- **Distribution works.** A two-person marketplace can be a private git repo or a shared directory (`/plugin marketplace add`); both are documented. A plugin made only of skills and Markdown is valid, and `dependencies` lets `flow` declare it (`name`, `name@marketplace`, or object with semver `version`). Cross-marketplace dependencies need `allowCrossMarketplaceDependenciesOn` in the root marketplace's `marketplace.json`, unless the dependency is already installed and enabled at the same scope.
- **Locating plugin B's files from plugin A: not documented.** The only documented path variables are `${CLAUDE_PLUGIN_ROOT}` (the plugin's own version directory), `${CLAUDE_PLUGIN_DATA}` (its own data directory) and `${CLAUDE_PROJECT_DIR}`. There is no variable for another plugin's root or data. Plugin B's files sit at `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` and `installed_plugins.json` records each `installPath`, but the docs present those as internal records, not an API. The version segment changes on every update.
- **Reaching files across plugins.** Components cannot be declared outside the plugin root (`path escapes plugin directory`). The only documented sharing mechanism is symlinks to targets inside the same marketplace, which are dereferenced (copied) into the cache. It does not span two marketplaces. Files outside the plugin are not copied, so a script reading `../shared` fails.
- **Alternative that stays inside one plugin.** Skills of plugin B are discoverable by name like any plugin skill (`/<plugin>:<skill>`), so B could expose each stack as a skill and A invokes it. Whether a skill can load another plugin's skill programmatically is not documented in the pages read.

## Outcome

- Personal model preferences: declare `userConfig` in `flow` (`model` as `string` with `options`, optional `stack_dir` as `directory`). Values land in user `settings.json` under `pluginConfigs`, never in the repo. Read them with `${user_config.KEY}` in skill content.
- User stack files: keep them in a user-chosen directory (the `stack_dir` option, default under `~/.claude/flow/`). Document that the user adds an allow rule or `additionalDirectories` for it, since default-mode reads outside the project are not documented as prompt-free.
- Team sharing: use a plain git repo of Markdown cloned to that directory, not a second plugin. Cross-plugin file lookup is not documented. If a plugin is preferred, ship the stacks as skills of that plugin and declare it in `dependencies`.
- Do not rely on `${CLAUDE_PLUGIN_DATA}` for hand-edited files, and do not invent free-form keys in `settings.json`: neither is documented for that use.
- Open: `~` expansion and array handling in `userConfig` paths. Verify with a throwaway plugin before building on it.
