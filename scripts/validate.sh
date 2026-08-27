#!/usr/bin/env bash
# The keystone script. Same checks, same rules, whether run locally by a
# person, by .githooks/pre-commit before a commit, or by
# .github/workflows/validate.yml on every PR. See scripts/README.md.
#
# Usage:
#   scripts/validate.sh              run every check
#   scripts/validate.sh --quiet      findings only, no "[ok]" lines
#   scripts/validate.sh --only NAME  run a single check (see --help for names)
#
# Exit 0 if every check passes, 1 if any check fails.

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

QUIET=0
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --quiet) QUIET=1 ;;
    --only)
      ONLY="${2:-}"
      shift
      ;;
    -h|--help)
      say "Usage: $(basename "$0") [--quiet] [--only <check>]"
      say ""
      say "Checks:"
      say "  structure        every departments/*/ has the required shape"
      say "  placeholders     no unresolved {{PLACEHOLDER}} outside templates"
      say "  cross_refs       Inputs/Integrations table paths resolve"
      say "  context_length   CONTEXT.md files are 80 lines or fewer"
      say "  file_length      no markdown file exceeds 200 lines"
      say "  em_dash          no em dashes anywhere"
      say "  gitkeep          every output/ has .gitkeep or real content"
      say "  role_trigger     department CONTEXT.md has Role and Trigger sections"
      say "  org_chart_paths  org-chart.md Department Folder paths resolve"
      say "  naming           file/folder names are lowercase-with-hyphens"
      say "  secrets          no secret-shaped strings in committable files"
      say "  autonomy         _company/autonomy.md is well-formed and armed rows are safe"
      exit 0
      ;;
    *)
      fail "unknown argument: $1 (try --help)"
      exit 2
      ;;
  esac
  shift
done

FAILURES=0

run_check() {
  local name="$1" desc="$2"
  if [ -n "$ONLY" ] && [ "$ONLY" != "$name" ]; then
    return
  fi
  if "check_$name"; then
    [ "$QUIET" = 0 ] && ok "$desc"
  else
    FAILURES=$((FAILURES + 1))
  fi
}

# --- 1: department structure ------------------------------------------------
check_structure() {
  local status=0 d f sub
  for d in $(departments); do
    for f in CONTEXT.md learnings.md; do
      [ -f "$d/$f" ] || { fail "$d: missing $f"; status=1; }
    done
    for sub in output skills integrations; do
      [ -d "$d/$sub" ] || { fail "$d: missing $sub/ directory"; status=1; }
    done
  done
  return $status
}

# --- 2: no unresolved {{PLACEHOLDER}} outside template files ---------------
check_placeholders() {
  local status=0 line file
  while IFS= read -r line; do
    file="${line%%:*}"
    case "$file" in
      ./setup/questionnaire.md) continue ;;
      ./departments/_template/*) continue ;;
      ./integrations/_template.md) continue ;;
      ./_company/company-info.md) continue ;;
    esac
    fail "$line -- run 'setup' (see setup/questionnaire.md) to fill this in"
    status=1
  done < <(grep -rn '{{' --include='*.md' . 2>/dev/null | grep -v '^\./\.git/')
  return $status
}

# --- 3: Inputs/Integrations table paths resolve -----------------------------
# Scoped to table rows under a "## Inputs" or "## Integrations" heading, and
# skips any candidate containing '[' (template placeholders like
# `[skills/[name]/SKILL.md or ...]`). A naive whole-file backtick scan
# produces ~20 false positives on this repo (globs, ~/ paths, illustrative
# examples in INSTALLING.md prose) -- this scoping was tested and resolves
# cleanly against every real Inputs/Integrations table in the repo.
check_cross_refs() {
  local status=0 f dir paths p
  while IFS= read -r f; do
    dir="$(dirname "$f")"
    paths="$(awk '/^## (Inputs|Integrations)/{t=1;next} /^## /{t=0} t && /^\|/' "$f" \
      | grep -o '`[^`]*`' | tr -d '`')"
    [ -z "$paths" ] && continue
    while IFS= read -r p; do
      [ -z "$p" ] && continue
      case "$p" in
        *'['*) continue ;;
      esac
      if [ ! -e "$dir/$p" ] && [ ! -e "$p" ]; then
        fail "$f: broken reference '$p' in an Inputs/Integrations table"
        status=1
      fi
    done <<< "$paths"
  done < <(find . -name 'CONTEXT.md' -not -path './.git/*')
  return $status
}

# --- 4: CONTEXT.md line limit -----------------------------------------------
check_context_length() {
  local status=0 f n
  while IFS= read -r f; do
    n=$(wc -l < "$f" | tr -d ' ')
    if [ "$n" -gt 80 ]; then
      fail "$f: $n lines, exceeds the 80-line CONTEXT.md limit"
      status=1
    fi
  done < <(find . -name 'CONTEXT.md' -not -path './.git/*')
  return $status
}

# --- 5: no markdown file over 200 lines -------------------------------------
check_file_length() {
  local status=0 f n
  while IFS= read -r f; do
    n=$(wc -l < "$f" | tr -d ' ')
    if [ "$n" -gt 200 ]; then
      fail "$f: $n lines, exceeds the 200-line reference-file limit"
      status=1
    fi
  done < <(find . -name '*.md' -not -path './.git/*')
  return $status
}

# --- 6: no em dashes ---------------------------------------------------------
check_em_dash() {
  local status=0
  while IFS= read -r line; do
    fail "$line: em dash found (use ' -- ' or a comma instead)"
    status=1
  done < <(grep -rn $'—' --include='*.md' . 2>/dev/null | grep -v '^\./\.git/')
  return $status
}

# --- 7: every output/ has .gitkeep or real content --------------------------
check_gitkeep() {
  local status=0 d n
  while IFS= read -r d; do
    n=$(find "$d" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')
    if [ "$n" -eq 0 ]; then
      fail "$d: empty, needs a .gitkeep so the folder persists in git"
      status=1
    fi
  done < <(find . -type d -name output -not -path './.git/*')
  return $status
}

# --- 8: department CONTEXT.md has Role and Trigger sections -----------------
check_role_trigger() {
  local status=0 d
  for d in $(departments); do
    grep -q '^## Role' "$d/CONTEXT.md" 2>/dev/null || {
      fail "$d/CONTEXT.md: missing '## Role' section"
      status=1
    }
    grep -q '^## Trigger' "$d/CONTEXT.md" 2>/dev/null || {
      fail "$d/CONTEXT.md: missing '## Trigger' section"
      status=1
    }
  done
  return $status
}

# --- 9: org-chart.md Department Folder paths resolve ------------------------
check_org_chart_paths() {
  local status=0 chart dir paths p
  chart="_company/org-chart.md"
  [ -f "$chart" ] || return 0
  dir="$(dirname "$chart")"
  # Only the roster table, before "## Adding a Role" -- the Role Skill &
  # Integration Assignments table further down has no Department Folder
  # column and shouldn't be scanned.
  paths="$(awk '/^## Adding a Role/{exit} /^\|/' "$chart" | grep -o '`[^`]*`' | tr -d '`')"
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    case "$p" in
      *'['*) continue ;;
    esac
    if [ ! -e "$dir/$p" ] && [ ! -e "$p" ]; then
      fail "$chart: broken Department Folder reference '$p'"
      status=1
    fi
  done <<< "$paths"
  return $status
}

# --- 10: lowercase-with-hyphens naming ---------------------------------------
# Exceptions, both deliberate and pre-existing in this repo (not something
# this check invented): an exact-match list of routing/reference files that
# are uppercase by convention throughout this workspace (CLAUDE.md,
# CONTEXT.md, etc.), and underscore-prefixed folders/files (_company,
# _template, _template.md), where only the part after the underscore must
# be lowercase-with-hyphens.
check_naming() {
  local status=0 p base rest allowed a is_allowed
  allowed="CLAUDE.md CONTEXT.md README.md INSTALLING.md CREDENTIALS.md EXTENSIONS.md LICENSE MEMORY.md"
  while IFS= read -r -d '' p; do
    base="$(basename "$p")"
    case "$base" in
      .*) continue ;;
    esac
    is_allowed=0
    for a in $allowed; do
      [ "$base" = "$a" ] && is_allowed=1 && break
    done
    [ "$is_allowed" = 1 ] && continue
    case "$base" in
      _*)
        rest="${base#_}"
        case "$rest" in
          *[A-Z]*|*' '*)
            fail "$p: underscore-prefixed name must be lowercase-with-hyphens after the underscore"
            status=1
            ;;
        esac
        continue
        ;;
    esac
    case "$base" in
      *[A-Z]*|*' '*)
        fail "$p: name must be lowercase-with-hyphens, no spaces"
        status=1
        ;;
    esac
  done < <(find . -mindepth 1 -not -path './.git*' -print0)
  return $status
}

# --- 11: secret-smell test on committable files ------------------------------
# Local backstop, not the real scan -- CI runs gitleaks over full history.
# Uses `git ls-files --cached --others --exclude-standard` (tracked +
# untracked-but-not-ignored) rather than `git ls-files` alone, since this
# repo currently has zero commits and nothing tracked yet; that file list is
# what `git add -A` would pick up, which is what actually matters here.
check_secrets() {
  local status=0 f
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    if grep -InE "$SECRET_PATTERN" -- "$f" >/dev/null 2>&1; then
      fail "$f: matches a secret-shaped pattern -- check before committing (see integrations/CREDENTIALS.md)"
      status=1
    fi
  done < <(git ls-files --cached --others --exclude-standard)
  return $status
}

# --- 12: _company/autonomy.md is well-formed and armed rows are safe -------
# Does not care whether autonomy is MANUAL or AUTONOMOUS -- only that
# whatever state it is in is internally consistent, so a Department
# Autonomy row that claims "autonomous" can never ship with no cap, no
# tool allowlist, or Bash in that allowlist. See _company/autonomy.md for
# why the allowlist, not the permission mode, is the real containment.
check_autonomy() {
  local status=0 f="_company/autonomy.md" dir line st cells dept mode cap tools
  [ -f "$f" ] || return 0
  dir="$(dirname "$f")"

  st="$(grep -m1 '^\*\*Status:' "$f" | sed -E 's/^\*\*Status: *([A-Za-z]*)\*\*.*/\1/')"
  case "$st" in
    MANUAL|AUTONOMOUS) : ;;
    *)
      fail "$f: Status must be MANUAL or AUTONOMOUS, found '${st:-<none found>}'"
      status=1
      ;;
  esac

  while IFS= read -r line; do
    case "$line" in
      '|'*'`../departments/'*) : ;;
      *) continue ;;
    esac
    IFS='|' read -r -a cells <<< "$line"
    dept="$(printf '%s' "${cells[1]:-}" | tr -d ' `')"
    mode="$(printf '%s' "${cells[2]:-}" | tr -d '[:space:]')"
    cap="$(printf '%s' "${cells[3]:-}" | tr -d '[:space:]')"
    tools="$(printf '%s' "${cells[6]:-}" | tr -d '[:space:]')"

    if [ ! -e "$dir/$dept" ] && [ ! -e "$dept" ]; then
      fail "$f: Department Autonomy row references '$dept', which does not resolve"
      status=1
    fi

    if [ "$mode" = "autonomous" ]; then
      if [ -z "$cap" ]; then
        fail "$f: $dept is autonomous with no Per-Run Cap"
        status=1
      fi
      if [ -z "$tools" ]; then
        fail "$f: $dept is autonomous with no Allowed Tools"
        status=1
      fi
      case "$tools" in
        *Bash*)
          fail "$f: $dept's Allowed Tools includes Bash -- containment for an unattended run relies on no shell access"
          status=1
          ;;
      esac
    fi
  done < "$f"
  return $status
}

run_check structure       "department folders have the required shape"
run_check placeholders    "no unresolved {{PLACEHOLDER}} values outside templates"
run_check cross_refs      "Inputs/Integrations table paths resolve"
run_check context_length  "CONTEXT.md files are 80 lines or fewer"
run_check file_length     "no markdown file exceeds 200 lines"
run_check em_dash         "no em dashes"
run_check gitkeep         "every output/ has .gitkeep or real content"
run_check role_trigger    "department CONTEXT.md files have Role and Trigger sections"
run_check org_chart_paths "org-chart.md Department Folder paths resolve"
run_check naming          "file and folder names are lowercase-with-hyphens"
run_check secrets         "no secret-shaped strings in committable files"
run_check autonomy        "_company/autonomy.md is well-formed and armed rows are safe"

if [ "$FAILURES" -gt 0 ]; then
  fail "$FAILURES check(s) failed"
  exit 1
fi
[ "$QUIET" = 0 ] && ok "all checks passed"
exit 0
