#!/usr/bin/env bash
# Adapter contract for one messaging provider. Copy this file to
# scripts/channels/[provider].sh and fill in the fetch. Read
# scripts/channels/README.md first.
#
# This template makes no network call and is runnable as-is: it always
# exits 0 having fetched nothing, which is the same outcome a real adapter
# reports on a quiet channel.
#
# Contract:
#   $1  channel name, as it appears in _company/messaging.md's roster
#   $2  path to this channel's watermark file (read the last-seen marker
#       here, write the new one here on success)
#   $3  path to write output to
#
# Output ($3): newline-delimited JSON, one message per line, exactly these
# fields and no others -- the agent-facing shape must not vary by
# provider:
#   id         provider's own message id, stable across fetches
#   from       sender address or display name
#   timestamp  ISO 8601 UTC
#   subject    empty string if the provider has no concept of one
#   body       plain text, provider formatting stripped
#   permalink  a URL a human can click to see the original, or ""
#
# Rules:
#   - Exit 0 having written nothing is normal, not an error: it means no
#     new messages since the watermark.
#   - Exit 1 only on a real failure (auth rejected, provider unreachable,
#     malformed response). Do not exit 1 for "nothing new."
#   - MUST NEVER WRITE. No send, no post, no reply, no mark-as-read, no
#     state change at the provider beyond reading. scripts/validate.sh's
#     messaging check greps every file here for send-shaped calls; a
#     provider SDK function named anything like send/post/reply/write is a
#     review failure, not a feature to wire up.
#   - Read the credential from the environment variable named in this
#     channel's roster row. Never hardcode a value here, never fall back
#     to a default. See ../../integrations/CREDENTIALS.md.

set -uo pipefail

CHANNEL="${1:?channel name required}"
WATERMARK_FILE="${2:?watermark file path required}"
OUT_FILE="${3:?output file path required}"

# --- Replace everything below with the real fetch --------------------------
#
# Shape to follow:
#
#   last_seen="$(cat "$WATERMARK_FILE" 2>/dev/null || echo "")"
#
#   # Call the provider's API here, using a credential read from an env
#   # var (never hardcoded), filtered to messages newer than $last_seen.
#   # curl is available; no SDK may be added without a dependency
#   # manifest, which this repo deliberately does not have.
#
#   # For each message, append one JSON line to "$OUT_FILE" in the shape
#   # documented above.
#
#   # On success, write the new watermark:
#   #   printf '%s' "$new_last_seen" > "$WATERMARK_FILE"

: > "$OUT_FILE" # template fetches nothing; a real adapter overwrites this

exit 0
