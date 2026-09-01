#!/usr/bin/env bash
# Collega le skill di devflow in ~/.claude/skills/ e controlla le dipendenze.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mkdir -p "$dest"

echo "Skill:"
for s in devflow devflow-docs devflow-archive; do
  target="$dest/$s"
  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$here/$s" ]; then
      echo "  ok     $s (già collegata)"
    else
      echo "  SKIP   $s: $target punta altrove ($(readlink "$target"))"
    fi
  elif [ -e "$target" ]; then
    echo "  SKIP   $s: $target esiste e non è un symlink"
  else
    ln -s "$here/$s" "$target"
    echo "  link   $s -> $target"
  fi
done

echo
echo "Dipendenze:"
for d in shaping breadboarding framing-doc grill-me; do
  if [ -e "$dest/$d" ]; then
    echo "  ok     $d"
  else
    echo "  MANCA  $d  (shaping-skills: https://github.com/rjs/shaping-skills · grill-me: ~/.agents/skills)"
  fi
done

plugins="$HOME/.claude/plugins/installed_plugins.json"
if [ -f "$plugins" ] && grep -q '"superpowers@' "$plugins"; then
  echo "  ok     superpowers (plugin)"
else
  echo "  MANCA  superpowers  (claude plugin install superpowers@claude-plugins-official)"
fi
