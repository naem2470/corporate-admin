#!/usr/bin/env bash
# Runs one department headless, through the Anthropic API, gated behind
# _company/autonomy.md. See that file for the full contract; this script
# only enforces it.
#
# Usage:
#   scripts/run-department.sh <department>              run for real
#   scripts/run-department.sh <department> --dry-run     print the command, spend nothing
#
# Exit 0: correctly did nothing (autonomy off, or this department not armed
#         while the global keys are also off -- the normal, shipped state).
# Exit 1: a gate that should have blocked a real run did not resolve
#         cleanly (armed but misconfigured, over budget, or the run itself
#         or its self-check failed).

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

AUTONOMY_FILE="_company/autonomy.md"
BUDGET_FILE="_company/budget.md"

DRY_RUN=0
DEPARTMENT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      say "Usage: $(basename "$0") <department> [--dry-run]"
      exit 0
      ;;
    -*)
      fail "unknown argument: $1 (try --help)"
      exit 2
      ;;
    *)
      DEPARTMENT="$1"
      ;;
  esac
  shift
done

if [ -z "$DEPARTMENT" ]; then
  fail "usage: $(basename "$0") <department> [--dry-run]"
  exit 2
fi

if [ ! -d "departments/$DEPARTMENT" ]; then
  fail "departments/$DEPARTMENT does not exist"
  exit 1
fi

# Trim leading/trailing whitespace from a value.
trim() {
  local v="$1"
  v="${v#"${v%%[![:space:]]*}"}"
  v="${v%"${v##*[![:space:]]}"}"
  printf '%s' "$v"
}

# --- Key 1: _company/autonomy.md Status -------------------------------------
status_line="$(grep -m1 '^\*\*Status:' "$AUTONOMY_FILE" 2>/dev/null || true)"
autonomy_status="$(printf '%s' "$status_line" | sed -E 's/^\*\*Status: *([A-Z]+)\*\*.*/\1/')"

if [ "$autonomy_status" != "AUTONOMOUS" ]; then
  say "$AUTONOMY_FILE says Status: ${autonomy_status:-unknown} -- nothing to do."
  exit 0
fi

# --- Key 2: repo variable, passed in as an env var by the workflow ----------
if [ "${AUTONOMY_MODE:-}" != "autonomous" ]; then
  say "AUTONOMY_MODE is not 'autonomous' (repo variable unset or off) -- nothing to do."
  exit 0
fi

# --- Key 3: this department's row in the Department Autonomy table ---------
dept_line="$(grep -F "\`../departments/$DEPARTMENT/\`" "$AUTONOMY_FILE" 2>/dev/null || true)"
if [ -z "$dept_line" ]; then
  fail "no Department Autonomy row for '$DEPARTMENT' in $AUTONOMY_FILE"
  exit 1
fi

IFS='|' read -r -a cells <<< "$dept_line"
# cells[0] is empty (text before the leading |); cells[1]=Department,
# [2]=Mode, [3]=Per-Run Cap, [4]=Period Budget, [5]=Cadence, [6]=Allowed Tools.
dept_mode="$(trim "${cells[2]:-}")"
per_run_cap="$(trim "${cells[3]:-}")"
period_budget="$(trim "${cells[4]:-}")"
cadence="$(trim "${cells[5]:-}")"
allowed_tools="$(trim "${cells[6]:-}")"

if [ "$dept_mode" != "autonomous" ] || [ -z "$per_run_cap" ] || [ -z "$allowed_tools" ]; then
  fail "$DEPARTMENT is not cleanly armed (mode='$dept_mode' cap='$per_run_cap' tools='$allowed_tools')"
  fail "an armed department with no cap or no tool allowlist is the dangerous state -- fix the row in $AUTONOMY_FILE, do not just retry"
  exit 1
fi

# The table cell may be written as "$2.00" for a human reading the file;
# --max-budget-usd wants a bare number. cap_num is what actually gets
# passed to the CLI, per_run_cap stays around only for log messages.
cap_num="$(printf '%s' "$per_run_cap" | tr -dc '0-9.')"
if [ -z "$cap_num" ]; then
  fail "$DEPARTMENT: Per-Run Cap '$per_run_cap' has no number in it"
  exit 1
fi

# --- Current period, from the department's Cadence cell. Computed
# unconditionally: it labels the ledger row below even when there is no
# Period Budget to check against.
case "$cadence" in
  *[Mm]onthly*)   period="$(date -u +%Y-%m)" ;;
  *[Ww]eekly*)    period="$(date -u +%G-W%V)" ;;
  *[Dd]aily*)     period="$(date -u +%Y-%m-%d)" ;;
  *[Qq]uarterly*) q=$(( ($(date -u +%-m) - 1) / 3 + 1 )); period="$(date -u +%Y)-Q${q}" ;;
  *)              period="$(date -u +%Y-%m-%d)" ;;
esac

# --- Layer 2: period budget, a soft guard against the ledger being stale ---
if [ -n "$period_budget" ] && [ -n "$cadence" ]; then
  if [ -f "$BUDGET_FILE" ]; then
    spent="$(awk -F'|' -v dept="$DEPARTMENT" -v per="$period" '
      $0 ~ /^\|/ {
        p=$2; sc=$3; cost=$5
        gsub(/^[ \t]+|[ \t]+$/, "", p)
        gsub(/^[ \t]+|[ \t]+$/, "", sc)
        gsub(/^[ \t]+|[ \t]+$/, "", cost)
        gsub(/[^0-9.]/, "", cost)
        if (p == per && tolower(sc) ~ tolower(dept) && cost != "") sum += cost
      }
      END { printf "%.4f", sum+0 }
    ' "$BUDGET_FILE")"
    budget_num="$(printf '%s' "$period_budget" | tr -dc '0-9.')"
    if [ -n "$budget_num" ]; then
      projected="$(awk -v s="$spent" -v c="$cap_num" 'BEGIN { printf "%.4f", s + c }')"
      over="$(awk -v p="$projected" -v b="$budget_num" 'BEGIN { print (p > b) ? 1 : 0 }')"
      if [ "$over" = "1" ]; then
        fail "$DEPARTMENT: \$$spent already spent this period ($period), plus this run's \$$per_run_cap cap would exceed the \$$period_budget period budget"
        fail "(ledger figure is only as fresh as the last merged PR -- see the honest limits in $AUTONOMY_FILE)"
        exit 1
      fi
    fi
  fi
fi

# --- Build and, unless --dry-run, execute the invocation --------------------
prompt="Run the department at departments/$DEPARTMENT/CONTEXT.md end to end, following its Process section, and write the resulting artifact to departments/$DEPARTMENT/output/."

cmd=(claude --print
  --max-budget-usd "$cap_num"
  --output-format json
  --allowed-tools "$allowed_tools"
  --permission-mode acceptEdits
  --model sonnet
  "$prompt")

if [ "$DRY_RUN" = 1 ]; then
  say "[dry-run] would run:"
  printf '  %q' "${cmd[@]}"
  printf '\n'
  say "[dry-run] no API call made, nothing spent."
  exit 0
fi

if ! command -v claude >/dev/null 2>&1; then
  fail "claude CLI not found on PATH -- cannot run for real (use --dry-run to check the command without it)"
  exit 1
fi

result_json="$("${cmd[@]}")"
run_status=$?
if [ $run_status -ne 0 ]; then
  fail "$DEPARTMENT: claude exited $run_status"
  exit 1
fi

# --- Record actual spend, jq when available, grep/sed fallback otherwise ---
if command -v jq >/dev/null 2>&1; then
  total_cost="$(printf '%s' "$result_json" | jq -r '.total_cost_usd // empty')"
else
  total_cost="$(printf '%s' "$result_json" | grep -o '"total_cost_usd"[[:space:]]*:[[:space:]]*[0-9.]*' | grep -o '[0-9.]*$')"
fi
total_cost="${total_cost:-unknown}"

ledger_row="| $period | $DEPARTMENT | -- | \$${total_cost} | Autonomous run, $(date -u +%Y-%m-%dT%H:%MZ) |"
placeholder='| _(none recorded yet)_ | | | | |'
if grep -qF "$placeholder" "$BUDGET_FILE"; then
  # First real entry: replace the placeholder row rather than leaving it
  # alongside real data.
  sed -i "s|$placeholder|$ledger_row|" "$BUDGET_FILE"
else
  printf '%s\n' "$ledger_row" >> "$BUDGET_FILE"
fi
say "recorded \$${total_cost} to $BUDGET_FILE's Spend Ledger"

# --- Self-check before the workflow opens a PR on this ----------------------
if ! bash scripts/validate.sh --quiet; then
  fail "$DEPARTMENT: the run's own output fails scripts/validate.sh -- not opening a PR on this"
  exit 1
fi

ok "$DEPARTMENT: run complete, output written, ledger updated, validate.sh clean"
