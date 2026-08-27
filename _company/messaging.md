# Inbound Messaging

**Status: INACTIVE**

While this says INACTIVE, nothing here runs. No inbox is polled, no channel
is read, no credential is used. An agent that opens this file while Status
says INACTIVE should stop reading here and go back to whatever it was
doing.

`INACTIVE` and `ACTIVE` are the only two valid values. Anything else is a
validation failure, not a third mode.

## Why This Exists

Departments run on a clock and on files. Nothing in this repo can see a
message that arrives from outside it: a bill lands in an inbox, a question
lands in a channel, and the department only finds out when a human relays
it by hand.

This file adds the missing half, and only that half. A department can
learn what arrived. It cannot answer.

## Draft Only, Always

**No adapter may send.** Reading is unattended; every reply is a draft a
human reviews and sends themselves, outside this repo.

This is the reason `autonomy.md`'s prohibition on autonomous runs using
"an integration whose card has a write-capable Approval Gate" needs no
exception carved into it. A read-and-draft channel never triggers that
gate, because nothing it does reaches a counterparty.

Adding a send capability later is a separate decision with its own
approval, not a configuration change here. Treat any adapter that grows a
send call as a review failure, not a feature.

## The Agent Never Touches The Network

`autonomy.md` names the tool allowlist as the real containment: an
autonomous run gets `Read,Write,Edit,Glob,Grep`, so no shell and no
network. Handing that agent a mail tool would destroy the property.

So the fetch happens outside the agent, before it starts:

| Step | Who | What it touches |
|------|-----|-----------------|
| 1. Fetch | `../scripts/channels/[provider].sh` | The network. No agent involved. |
| 2. Read | The department's autonomous run | `.messages/[channel].jsonl` on local disk, with plain `Read`. |
| 3. Send | A human | Their own mail client, outside this repo entirely. |

The allowlist never widens. That is what makes this safe to ship.

## Channel Roster

Per-channel opt-in. A channel set to `active` still does nothing unless
this file says ACTIVE and `autonomy.md` says AUTONOMOUS.

| Channel | Provider | Adapter | Bot Identity | Read Scope | Routes To | Mode |
|---------|----------|---------|--------------|------------|-----------|------|

No channels configured. Add a row per the checklist below.

`Routes To` names a department folder. That is how a message reaches a
department without editing any department's `CONTEXT.md`.

## Adding a Channel

Ordered. Step 1 is the only limit that survives a mistake in this repo's
own scripts, so it comes first.

1. Create a **dedicated bot account** at the provider. Never wire a
   person's own account: see `../integrations/CREDENTIALS.md` on
   per-seat, least-privilege credentials.
2. Scope its access **read-only, and as narrow as the provider allows**: one
   label, one folder, or one channel. This repo cannot enforce scope.
3. Add the credential as a GitHub Actions repository secret. Record its
   name, never its value.
4. Copy `../scripts/channels/_template.sh` to `[provider].sh` and fill in
   the fetch. Read `../scripts/channels/README.md` first.
5. Write an integration card from `../integrations/_messaging-template.md`.
6. Add a row above naming the adapter, the bot, the scope, and the
   department it routes to.
7. Run `bash scripts/fetch-messages.sh --dry-run` and read what it prints.
8. Only then flip `Status:` to `ACTIVE`.

## Kill Switch

Fastest first:

1. **Delete the provider secret** in repository settings. Instant, no
   commit. The adapter fails its credential check and the fetch skips.
2. **Set `Status: INACTIVE`** here. Needs a commit and a merge, so it is
   the record of the decision rather than the emergency stop.
3. **Revoke the bot account** at the provider. Slowest, but the only one
   that also invalidates a leaked copy of the credential.

## The Honest Limits

- **The watermark goes stale like the spend ledger.** If a run's pull
  request sits unmerged, the next run re-reads the same messages and
  drafts duplicates. Same failure mode `autonomy.md` already documents for
  the ledger, for the same reason.
- **Poll latency is the cron interval**, currently daily. This is not a
  live inbox.
- **A read-only credential still reads everything it can see.** Step 2
  above is the only thing narrowing it, and it happens at the provider.
- **Fetched message bodies are third-party content.** They land in
  `.messages/`, which `.gitignore` covers, and must never be committed.
