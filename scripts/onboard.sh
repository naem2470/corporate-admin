#!/usr/bin/env bash
# The one command a new person runs after cloning this repo. Idempotent --
# safe to run again on an already-configured machine. See scripts/README.md.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
if [ -z "$ROOT" ]; then
  fail "not inside a git repository -- clone the repo first"
  exit 1
fi
cd "$ROOT" || exit 1

say "corporate-admin onboarding"
say "=========================="
say ""

# --- 1. Prerequisites --------------------------------------------------------
say "1. Checking prerequisites"
if ! command -v git >/dev/null 2>&1; then
  fail "git is required and was not found"
  exit 1
fi
ok "git found"

if [ -z "${BASH_VERSION:-}" ]; then
  warn "not running under bash -- some checks may not work as expected"
else
  bash_major="${BASH_VERSINFO[0]:-0}"
  if [ "$bash_major" -lt 4 ]; then
    warn "bash $BASH_VERSION found; 4.0+ recommended"
  else
    ok "bash $BASH_VERSION found"
  fi
fi

if command -v claude >/dev/null 2>&1; then
  ok "claude CLI found"
else
  warn "claude CLI not found -- fine if you're only reviewing PRs, but you'll need it to run departments"
fi
say ""

# --- 2. Credentials -----------------------------------------------------------
say "2. Credentials"
if [ -f ".env.local" ]; then
  ok ".env.local already exists, leaving it alone"
elif [ -f ".env.example" ]; then
  cp ".env.example" ".env.local"
  ok "created .env.local from .env.example"
else
  warn ".env.example not found, skipping"
fi

if [ -f ".env.example" ]; then
  vars="$(grep -vE '^\s*#|^\s*$' ".env.example" | cut -d= -f1)"
  if [ -z "$vars" ]; then
    say "  No integration in this workspace has a credential wired up yet"
    say "  (see .env.example for why). Nothing to set here for now."
  else
    say "  Credential names this workspace expects (never put real values in git):"
    while IFS= read -r var; do
      [ -n "$var" ] && say "    - $var"
    done <<< "$vars"
    say "  Set real values as environment variables on your machine, or in"
    say "  .env.local (already gitignored). See integrations/CREDENTIALS.md."
  fi
fi
say ""

# --- 3. Git hooks ---------------------------------------------------------
say "3. Git hooks"
bash "$SCRIPT_DIR/install-hooks.sh"
say ""

# --- 4. Validate ------------------------------------------------------------
say "4. Validating workspace"
if bash "$SCRIPT_DIR/validate.sh"; then
  ok "workspace is healthy"
else
  warn "validate.sh found issues (see above). This is expected before 'setup' has run."
fi
say ""

# --- 5. Your seat -----------------------------------------------------------
say "5. Your seat"
if [ -f "_company/org-chart.md" ]; then
  say "  Current roster (_company/org-chart.md):"
  awk '/^\|/{print "    " $0}' "_company/org-chart.md" | head -10
  say ""
  say "  Not on the roster yet? See setup/employee-onboarding.md."
fi
say ""

# --- 6. Next steps ------------------------------------------------------------
say "6. Next steps"
say "  - Read CONTEXT.md at the repo root -- it routes any task to where it belongs."
say "  - If placeholders were flagged above, type 'setup' in Claude Code to fill them in."
say "  - To run a department, open its CONTEXT.md and follow the Process section."
say "  - New department? scripts/new-department.sh <name>"
say ""
ok "onboarding complete"
