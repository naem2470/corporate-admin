#!/usr/bin/env bash
# Shared helpers sourced by every script in scripts/. Not meant to be run
# directly.

# Resolve the workspace root regardless of the caller's cwd.
repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

# Color output only when stdout is a TTY and NO_COLOR is unset, so CI logs
# and piped output stay plain.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  _c_red=$'\033[31m'
  _c_yellow=$'\033[33m'
  _c_green=$'\033[32m'
  _c_reset=$'\033[0m'
else
  _c_red=""
  _c_yellow=""
  _c_green=""
  _c_reset=""
fi

say()  { printf '%s\n' "$*"; }
ok()   { printf '%s[ok]%s   %s\n' "$_c_green" "$_c_reset" "$*"; }
warn() { printf '%s[warn]%s %s\n' "$_c_yellow" "$_c_reset" "$*" >&2; }
fail() { printf '%s[fail]%s %s\n' "$_c_red" "$_c_reset" "$*" >&2; }

# List department folders, excluding _template. Same exclusion rule as
# CLAUDE.md's `status`, `skills`, and `integrations` triggers -- kept in one
# place so it can't drift between scripts. Assumes the caller has already
# cd'd to the repo root (every script that sources this file does), so
# results are relative paths like `departments/finance`.
departments() {
  find departments -mindepth 1 -maxdepth 1 -type d ! -name '_template' 2>/dev/null | sort
}

# True when running under a CI runner (GitHub Actions sets CI=true), so
# interactive scripts can skip prompts automatically instead of hanging.
is_ci() {
  [ -n "${CI:-}" ]
}

# Shared secret-smell pattern. Used by both scripts/validate.sh (check 11,
# scanned over every committable file) and .githooks/pre-commit (scanned
# over the staged diff only). One pattern, defined once, so the local
# backstop and the hook can never disagree about what looks like a secret.
# Not a substitute for the full-history gitleaks scan in CI -- see
# integrations/CREDENTIALS.md.
#
# Covers, in order: Anthropic keys, AWS access key IDs, PEM private key
# headers, Slack tokens (bot/user/app/refresh -- xoxb-/xoxp-/xoxa-/xoxr-),
# GitHub tokens (classic and fine-grained), and Google OAuth refresh
# tokens. The last two were added for scripts/channels/ adapters, which
# read exactly this shape of credential; extend this pattern before adding
# a new provider whose token has a different recognizable prefix.
SECRET_PATTERN='sk-ant-[A-Za-z0-9_-]{10,}|AKIA[0-9A-Z]{16}|-----BEGIN[A-Z ]*PRIVATE KEY-----|xox[bapr]-[A-Za-z0-9-]{10,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|1//[A-Za-z0-9_-]{20,}'
