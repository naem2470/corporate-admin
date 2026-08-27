#!/usr/bin/env bash
# Fetches inbound messages for every active channel in
# _company/messaging.md's Channel Roster, gated behind that file's Status
# AND _company/autonomy.md's two keys. See messaging.md for the full
# contract; this script only enforces it.
#
# Usage:
#   scripts/fetch-messages.sh              fetch for real
#   scripts/fetch-messages.sh --dry-run    print what would run, fetch nothing
#
# Exit 0: correctly did nothing (messaging or autonomy off -- the normal,
#         shipped state), or fetched cleanly.
# Exit 1: a gate that should have blocked a real fetch did not resolve
#         cleanly (a channel armed but misconfigured, or an adapter failed).

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

MESSAGING_FILE="_company/messaging.md"
AUTONOMY_FILE="_company/autonomy.md"

DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      say "Usage: $(basename "$0") [--dry-run]"
      exit 0
      ;;
    *)
      fail "unknown argument: $1 (try --help)"
      exit 2
      ;;
  esac
  shift
done

trim() {
  local v="$1"
  v="${v#"${v%%[![:space:]]*}"}"
  v="${v%"${v##*[![:space:]]}"}"
  printf '%s' "$v"
}

# --- Gate 1: _company/messaging.md Status -----------------------------------
status_line="$(grep -m1 '^\*\*Status:' "$MESSAGING_FILE" 2>/dev/null || true)"
messaging_status="$(printf '%s' "$status_line" | sed -E 's/^\*\*Status: *([A-Za-z]+)\*\*.*/\1/')"

if [ "$messaging_status" != "ACTIVE" ]; then
  say "$MESSAGING_FILE says Status: ${messaging_status:-unknown} -- nothing to do."
  exit 0
fi

# --- Gate 2: _company/autonomy.md Status ------------------------------------
# Messaging never runs ahead of autonomy: it is strictly narrower, not an
# independent capability.
autonomy_status_line="$(grep -m1 '^\*\*Status:' "$AUTONOMY_FILE" 2>/dev/null || true)"
autonomy_status="$(printf '%s' "$autonomy_status_line" | sed -E 's/^\*\*Status: *([A-Za-z]+)\*\*.*/\1/')"

if [ "$autonomy_status" != "AUTONOMOUS" ]; then
  say "$AUTONOMY_FILE says Status: ${autonomy_status:-unknown} -- nothing to do."
  exit 0
fi

# --- Find active channel rows -------------------------------------------------
# Roster columns: Channel | Provider | Adapter | Bot Identity | Read Scope |
# Routes To | Mode. Scoped to table rows under "## Channel Roster" only --
# messaging.md has an earlier table too ("The Agent Never Touches The
# Network"'s Step/Who/What table), so an unscoped whole-file grep for
# lines starting with "| " would mix the two together. Same scoping idiom
# as validate.sh's check_cross_refs.
mapfile -t roster_lines < <(awk '/^## Channel Roster/{t=1;next} /^## /{t=0} t && /^\|/' "$MESSAGING_FILE" 2>/dev/null | grep -v -- '---' | tail -n +2)

if [ "${#roster_lines[@]}" -eq 0 ]; then
  say "no channels in $MESSAGING_FILE's Channel Roster -- nothing to do."
  exit 0
fi

status_overall=0
fetched_any=0

for line in "${roster_lines[@]}"; do
  IFS='|' read -r -a cells <<< "$line"
  # cells[0] empty; [1]=Channel [2]=Provider [3]=Adapter [4]=Bot Identity
  # [5]=Read Scope [6]=Routes To [7]=Mode
  channel="$(trim "${cells[1]:-}")"
  adapter_name="$(trim "${cells[3]:-}")"
  # Routes To is written backtick-wrapped, same convention as autonomy.md's
  # Department column -- strip the backticks along with whitespace, or a
  # literal `../departments/x/` cell never resolves as a real path.
  routes_to="$(trim "${cells[6]:-}" | tr -d '`')"
  mode="$(trim "${cells[7]:-}")"

  [ -z "$channel" ] && continue
  if [ "$mode" != "active" ]; then
    say "$channel: mode is '$mode', not active -- skipping."
    continue
  fi

  adapter_path="scripts/channels/${adapter_name}"
  if [ ! -f "$adapter_path" ]; then
    fail "$channel: adapter '$adapter_path' does not exist"
    status_overall=1
    continue
  fi

  if [ ! -d "departments/$routes_to" ]; then
    fail "$channel: Routes To '$routes_to' does not resolve to a department"
    status_overall=1
    continue
  fi

  watermark_file=".messages/${channel}.watermark"
  out_file=".messages/${channel}.jsonl"
  mkdir -p .messages

  if [ "$DRY_RUN" = 1 ]; then
    say "[dry-run] would run: bash $adapter_path '$channel' '$watermark_file' '$out_file'"
    say "[dry-run] no adapter invoked, nothing fetched."
    continue
  fi

  fetched_any=1
  if ! bash "$adapter_path" "$channel" "$watermark_file" "$out_file"; then
    fail "$channel: adapter exited non-zero"
    status_overall=1
    continue
  fi
  ok "$channel: fetched into $out_file (routes to $routes_to)"
done

if [ "$DRY_RUN" = 1 ]; then
  exit 0
fi

if [ "$fetched_any" = 0 ] && [ "$status_overall" = 0 ]; then
  say "no active channels -- nothing fetched."
fi

exit $status_overall
