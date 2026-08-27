#!/usr/bin/env bash
# Copies departments/_template/ into a new department. Removes the
# copy-paste step CLAUDE.md's "Add a new department" row already documents.
#
# Usage: scripts/new-department.sh <name>
#   <name> must be lowercase-with-hyphens (e.g. "sales", "customer-support").

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
if [ -z "$ROOT" ]; then
  fail "not inside a git repository"
  exit 1
fi
cd "$ROOT" || exit 1

NAME="${1:-}"
if [ -z "$NAME" ]; then
  fail "usage: scripts/new-department.sh <name>"
  exit 1
fi

case "$NAME" in
  *[A-Z]*|*' '*)
    fail "department name must be lowercase-with-hyphens, no spaces: '$NAME'"
    exit 1
    ;;
esac

DEST="departments/$NAME"
if [ -e "$DEST" ]; then
  fail "$DEST already exists -- refusing to overwrite"
  exit 1
fi

if [ ! -d "departments/_template" ]; then
  fail "departments/_template not found -- can't scaffold from a missing template"
  exit 1
fi

cp -r "departments/_template" "$DEST"
ok "created $DEST from departments/_template"
say ""
say "Three things the template can't do for you:"
say ""
say "  1. Fill in $DEST/CONTEXT.md -- at minimum the Role and Trigger sections,"
say "     and the [Department Name] title at the top."
say "  2. Add a row to _company/org-chart.md's roster table naming this department."
say "  3. Add a routing row to the root CONTEXT.md's Task Routing table so"
say "     agents know when to come here."
say ""
say "Then run: scripts/validate.sh"
