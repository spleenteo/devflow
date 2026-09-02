#!/usr/bin/env bash
# devflow installer.
#
# Links the three skills into the Claude Code skills directory, checks every
# dependency, and asks before installing a missing one or updating an existing one.
set -euo pipefail

SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
LOCK="$HOME/.agents/.skill-lock.json"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK=0
YES=0
PROBLEMS=0

usage() {
  cat <<USAGE
Usage: install.sh [--check] [--yes]

  --check   report only, change nothing
  --yes     answer yes to every prompt
  --help    this text

Environment:
  CLAUDE_SKILLS_DIR   skills directory (default: ~/.claude/skills)
USAGE
}

for arg in "$@"; do
  case "$arg" in
    -c|--check) CHECK=1 ;;
    -y|--yes) YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

ask() {
  [ "$CHECK" = 1 ] && return 1
  [ "$YES" = 1 ] && return 0
  { : </dev/tty; } 2>/dev/null || return 1   # no controlling terminal: answer no
  local reply
  read -r -p "  $1 [y/N] " reply </dev/tty || return 1
  [[ "$reply" =~ ^[Yy]$ ]]
}

have() { command -v "$1" >/dev/null 2>&1; }

run() {
  echo "  \$ $*"
  "$@"
}

# ---------------------------------------------------------------- devflow skills

echo "devflow skills -> $SKILLS_DIR"
[ "$CHECK" = 1 ] || mkdir -p "$SKILLS_DIR"
for s in devflow devflow-docs devflow-archive projectflow; do
  t="$SKILLS_DIR/$s"
  if [ -L "$t" ] && [ "$(readlink "$t")" = "$HERE/$s" ]; then
    echo "  ok       $s"
  elif [ -e "$t" ] || [ -L "$t" ]; then
    echo "  skip     $s ($t exists, not linked to this clone)"
  elif [ "$CHECK" = 1 ]; then
    echo "  missing  $s"
    PROBLEMS=1
  else
    ln -s "$HERE/$s" "$t"
    echo "  linked   $s"
  fi
done

# ---------------------------------------------------------------- dependencies

echo
echo "dependencies"

# How a present skill is managed: skills-cli | git <repo root> | manual
managed_by() {
  local name="$1" real repo
  if [ -f "$LOCK" ] && grep -q "\"$name\": {" "$LOCK"; then
    echo "skills-cli"; return
  fi
  real="$(cd "$SKILLS_DIR/$name" 2>/dev/null && pwd -P || true)"
  repo="$(git -C "${real:-/nonexistent}" rev-parse --show-toplevel 2>/dev/null || true)"
  if [ -n "$repo" ]; then echo "git $repo"; else echo "manual"; fi
}

CLI_UPDATE=()
GIT_SEEN=()

check_git_repo() {
  local repo="$1" name="$2" behind
  for seen in "${GIT_SEEN[@]:-}"; do [ "$seen" = "$repo" ] && return; done
  GIT_SEEN+=("$repo")
  git -C "$repo" fetch -q 2>/dev/null || true
  behind="$(git -C "$repo" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)"
  if [ "$behind" -gt 0 ]; then
    echo "  update   $name: clone at $repo is $behind commit(s) behind"
    if ask "Update it now? (git -C $repo pull)"; then run git -C "$repo" pull --ff-only; fi
  fi
}

# group: "<github repo>|<skill> <skill> ..."
for group in "rjs/shaping-skills|shaping breadboarding framing-doc" "mattpocock/skills|grill-me"; do
  repo="${group%%|*}"
  skills="${group#*|}"
  missing=()
  for name in $skills; do
    if [ -e "$SKILLS_DIR/$name" ]; then
      how="$(managed_by "$name")"
      echo "  ok       $name (${how%% *})"
      case "$how" in
        skills-cli) CLI_UPDATE+=("$name") ;;
        git\ *) check_git_repo "${how#git }" "$name" ;;
      esac
    else
      echo "  missing  $name ($repo)"
      missing+=("$name")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    PROBLEMS=1
    flags=()
    for m in "${missing[@]}"; do flags+=(-s "$m"); done
    if ! have npx; then
      echo "           npx not found: install Node.js, or clone $repo and symlink each skill into $SKILLS_DIR"
    elif ask "Install ${missing[*]} from $repo? (npx skills add $repo -g ${flags[*]})"; then
      run npx skills add "$repo" -g -y "${flags[@]}"
      PROBLEMS=0
    fi
  fi
done

if [ "${#CLI_UPDATE[@]}" -gt 0 ] && have npx; then
  if ask "Check ${CLI_UPDATE[*]} for updates? (npx skills update ${CLI_UPDATE[*]} -g)"; then
    run npx skills update "${CLI_UPDATE[@]}" -g -y
  fi
fi

# superpowers: a Claude Code plugin
PLUGIN="superpowers@claude-plugins-official"
if ! have claude; then
  echo "  ?        superpowers: claude CLI not found. Inside Claude Code run: /plugin install $PLUGIN"
elif claude plugin list 2>/dev/null | grep -q "superpowers@"; then
  echo "  ok       superpowers (plugin)"
  if ask "Update the superpowers plugin? (claude plugin update $PLUGIN)"; then
    run claude plugin update "$PLUGIN" -s user
  fi
else
  echo "  missing  superpowers (plugin)"
  PROBLEMS=1
  if ask "Install it? (claude plugin install $PLUGIN)"; then
    run claude plugin install "$PLUGIN" -s user
    PROBLEMS=0
  fi
fi

echo
if [ "$PROBLEMS" = 1 ]; then
  echo "something is missing; see above"
  exit 1
fi
echo "all set: open Claude Code in any project and type /devflow"
