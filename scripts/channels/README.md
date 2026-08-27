# Channel Adapters

One script per messaging provider, each fetching into the same shape so
the agent that reads the result never needs to know which provider it
came from.

## Writing One

1. Copy `_template.sh` to `[provider].sh` (lowercase-hyphen name, e.g.
   `slack.sh`, `gmail.sh`).
2. Fill in the fetch. Read the template's own comments first: the
   contract (three positional args), the output shape (six fixed JSON
   fields), and the rules (never write, never hardcode a credential).
3. Add a row to `../../_company/messaging.md`'s Channel Roster naming this
   adapter, the credential env var it reads, and which department it
   routes to.
4. Write an integration card from
   `../../integrations/_messaging-template.md`.

## The Output Shape

Every adapter writes newline-delimited JSON, one message per line:

```
{"id":"...", "from":"...", "timestamp":"2026-08-27T09:00:00Z", "subject":"...", "body":"...", "permalink":"..."}
```

Exactly these six fields. Drop anything provider-specific before writing
the line. This is what keeps a department's read step identical
regardless of which channels feed it.

## Draft Only, Always

**No adapter may send, post, reply, or change anything at the provider
beyond reading.** `scripts/validate.sh`'s messaging check greps every file
here for send-shaped calls and fails the build if it finds one. This is
not a style preference: it is the reason an unattended run reading a
channel never needs the write-capable-integration approval gate
`_company/autonomy.md` already requires elsewhere. See
`_company/messaging.md`'s "Draft Only, Always" section for the full
reasoning.

## Testing Without Credentials

`_template.sh` makes no network call and always exits 0 having fetched
nothing. Run it directly to confirm the contract:

```
bash scripts/channels/_template.sh test-channel /tmp/watermark /tmp/out.jsonl
echo $?      # 0
cat /tmp/out.jsonl   # empty
```

A real adapter should behave the same way when its credential is unset or
rejected: fail loudly (exit 1) rather than silently fetching nothing, so
a broken credential does not look identical to a quiet channel.

## Bash Only

No provider SDK gets added here. `curl` plus the provider's plain HTTP
API only, same constraint the rest of `scripts/` follows: see
`../README.md` and `../../integrations/INSTALLING.md` on why this
workspace stays dependency-free.
