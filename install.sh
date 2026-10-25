#!/usr/bin/env bash
# flow dependency checker.
#
# Reads dependencies.md, reports which skills the plugin hands work to are
# present, and prints the commands for the missing ones. Installs nothing,
# links nothing, asks nothing. Exit 1 if a required skill is missing.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS="$HERE/dependencies.md"

usage() {
  cat <<USAGE
Usage: install.sh [--help]

Checks the skills listed in dependencies.md (next to this script). For each one
prints ok or missing; for a missing one prints the user-scope install command.
Exit 1 if a required skill is missing, 0 otherwise. Installs nothing.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

[ -f "$DEPS" ] || { echo "dependencies.md not found next to install.sh" >&2; exit 2; }

# Ids of the enabled plugins, one per line (empty without the claude CLI).
enabled_plugins() {
  command -v claude >/dev/null 2>&1 || return 0
  claude plugin list --json 2>/dev/null | awk '
    /"id":/      { s = $0; sub(/.*"id": *"/, "", s); sub(/".*/, "", s); id = s }
    /"enabled":/ { if ($0 ~ /true/ && id != "") print id; id = "" }'
}

# Table rows as: plugin-id <TAB> skill <TAB> need (required|optional)
rows() {
  awk -F'|' '
    /^\| *Source/ || /^\|---/ { next }
    /^\|/ && NF >= 6 {
      id = $3; gsub(/[ `]/, "", id)
      need = ($5 ~ /^ *required/) ? "required" : "optional"
      s = $4
      while (match(s, /`[^`]+`/)) {
        print id "\t" substr(s, RSTART + 1, RLENGTH - 2) "\t" need
        s = substr(s, RSTART + RLENGTH)
      }
    }' "$DEPS"
}

PLUGINS="$(enabled_plugins)"
HAVE_CLAUDE=0; command -v claude >/dev/null 2>&1 && HAVE_CLAUDE=1

present() {   # present <plugin-id> <skill>: its plugin is enabled, or it is a personal/project skill
  if [ "$HAVE_CLAUDE" = 1 ] && printf '%s\n' "$PLUGINS" | grep -qxF "$1"; then return 0; fi
  [ -e "$HOME/.claude/skills/$2" ] || [ -e "./.claude/skills/$2" ]
}

REQ_MISSING=0; OPT_MISSING=0; SEEN=" "
echo "flow dependencies (from dependencies.md)"
while IFS=$'\t' read -r id skill need; do
  if present "$id" "$skill"; then
    echo "  ok       $skill"
    continue
  fi
  echo "  missing  $skill ($need)"
  if [ "$need" = required ]; then REQ_MISSING=1; else OPT_MISSING=1; fi
  case "$SEEN" in *" $id "*) continue ;; esac
  SEEN="$SEEN$id "
  [ "${id#*@}" = claude-plugins-official ] || echo "           marketplace first: see dependencies.md"
  echo "           claude plugin install $id --scope user"
done < <(rows)

echo
if [ "$REQ_MISSING" = 1 ]; then
  echo "a required skill is missing; run the commands above (project scope: see dependencies.md)"
  exit 1
fi
[ "$OPT_MISSING" = 1 ] && echo "all required skills present; an optional one is missing" || echo "all dependencies present"
exit 0
