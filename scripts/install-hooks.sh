#!/usr/bin/env bash
# Wires .githooks/ into git via core.hooksPath, so pre-commit is
# version-controlled instead of living in the untracked .git/hooks/. Called
# by scripts/onboard.sh; safe to run again on an already-configured machine.

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

if [ ! -f ".githooks/pre-commit" ]; then
  fail ".githooks/pre-commit not found -- nothing to install"
  exit 1
fi

chmod +x .githooks/pre-commit 2>/dev/null || true
git config core.hooksPath .githooks

ok "git hooks installed (core.hooksPath = .githooks)"
say "  pre-commit now runs a secret check and scripts/validate.sh on every commit."
say "  Bypass for a genuine emergency: git commit --no-verify"
