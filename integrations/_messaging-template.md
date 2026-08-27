# [Provider Name] (Messaging)

[One sentence: what this channel is and which department it feeds.]

- **Kind:** API (read-only, polled by an adapter -- never an MCP server;
  see `../_company/messaging.md` on why the agent never touches this
  directly)
- **Can Read:** [Messages the bot account's granted scope can see -- name
  the specific label/folder/channel, not "everything"]
- **Can Write:** Nothing. Reading is unattended; every reply is a draft a
  human sends themselves. See the Approval Gate below.
- **Credential Required:** [Env var name the adapter reads, e.g.
  `SLACK_BOT_TOKEN`. Never the value.]
- **Where The Value Lives:** A GitHub Actions repository secret. Not a
  password manager entry, not `.env.local`: the only consumer is CI
  running `scripts/fetch-messages.sh`.

## Setup

1. **Bot account:** [name of the dedicated bot/service account -- never a
   person's own account, per `CREDENTIALS.md`'s least-privilege rule]
2. **Read scope:** [the narrowest scope the provider allows -- one label,
   one folder, one channel]
3. **Adapter:** `scripts/channels/[provider].sh`, following
   `scripts/channels/_template.sh`'s contract
4. **Watermark file:** `.messages/[channel].watermark`, gitignored,
   advances only on a successful fetch
5. Add the matching row to `../_company/messaging.md`'s Channel Roster

## Approval Gate

**Reading requires no approval.** The bot account's own scope, set at the
provider in Setup step 2, is the only limit on what it sees.

**Sending is not implemented, and adding it is a separate decision, not a
configuration change on this card.** Every message this channel produces
is a draft in a department's `output/`, reviewed and sent by a human
outside this repo. See `../_company/messaging.md`'s "Draft Only, Always"
section for the reasoning this rests on.
