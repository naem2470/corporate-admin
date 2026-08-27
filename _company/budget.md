# Budget and Cost Control

**Status: INACTIVE**

While inactive, this file imposes nothing. No department reads it, no run
is slower or different because it exists. An agent that opens this file
while Status says INACTIVE should stop reading here and go back to
whatever it was doing.

## Why This Exists

Budget and cost tracking was skipped when this workspace was first
built: real overhead, no clear payoff at solo-founder stage. This file
is that feature built anyway, on the explicit understanding it might
not be needed yet. Turning it on later should be an edit, not a
redesign.

## Activation Checklist

1. Change the Status line above to `ACTIVE`.
2. Fill in at least one row of the Budget Policy table below.
3. Add this row to the `## Checkpoints` table of every department that
   should honor a limit, adjusting the step number:
   `| [step #] | Spend so far this period vs. the budget.md limit | Continue, adjust limit, or stop |`

Nothing else changes. Departments not listed in step 3 stay unmetered even
after activation.

## Scope

Tracks AI/agent spend only: tokens and model cost from running
departments. Company operating spend (subscriptions, vendor bills, bank
transactions) belongs to the Finance department, which already owns money
in and out. Tracking the same dollars in two places invites drift.

## Budget Policy

| Scope | Limit | Period | Response at Limit |
|-------|-------|--------|---------------------|
| _Example: Company_ | _$50_ | _Monthly_ | _Pause and ask (interactive) or hard-stop (scheduled)_ |
| _Example: Finance department_ | _$10_ | _Monthly_ | _Pause and ask_ |

Rows above are examples, not real limits. Delete or replace them at
activation. Scope can be company-wide, a single department, or a single
role, matching the tiers already used for skills and integrations.

## Where The Numbers Come From

Two paths, because interactive and scheduled runs are measured differently
and enforced differently.

### Interactive sessions (how departments are run today)

If a token-counting hook is installed (optional, plugin-dependent), it
typically works like this:

```
node ~/.claude/hooks/caveman-stats.js
```

Reads the current session's JSONL transcript
(`~/.claude/projects/[project]/[session-id].jsonl`) and reports real,
per-session token counts: output tokens, cache-read tokens, turn count. No
dollar figure: this workspace's models (`claude-opus-5`,
`claude-sonnet-5`) are not in the script's pricing table, so it reports
tokens only. Treat any dollar figure that script ever prints as an
unrelated savings estimate, not spend, and re-check its pricing table
before trusting a dollar number from it again.

**No technical enforcement exists for interactive sessions.** At a limit,
the agent pauses and presents the overage to the founder, who decides to
continue, adjust the limit, or stop. This is a checkpoint, not a cap.

### Scheduled / headless runs

Any department whose Trigger is recurring and wired to `/schedule` runs
headless, and headless runs support a real, CLI-enforced cap:

```
claude --print --max-budget-usd <amount> ...
```

This is an actual hard stop, confirmed present in the installed Claude
Code CLI. **Use it for every scheduled department run once this feature is
active.** A scheduled run is exactly the case where nobody is watching, so
it is the one place a checkpoint is not enough.

Headless runs with `--output-format json` also return authoritative,
Anthropic-computed `total_cost_usd` and a per-model `modelUsage` breakdown.
This is real spend, not an estimate, and needs no rate card maintained
here.

### The honest limit

The interactive session log is per-session and per-project, not
per-department: a session that runs Finance and then edits a skill
produces one blended number. Subagent work (any `Task`/`Explore`/`Agent`
delegation) is logged in a separate file tree
(`[session-id]/subagents/*.jsonl`) and is easy to undercount if only the
main session file is read. True per-department attribution needs either
running each department in its own session, or accepting the numbers
below as approximate.

## Autonomous Runs

`autonomy.md` is what actually lets a department run unattended; ships
`Status: MANUAL`, same dormancy contract as this file. When active, an
autonomous run is capped three ways, not one: `--max-budget-usd` per run
(a real CLI hard stop), a period-budget check against the ledger below
before a run even starts (`scripts/run-department.sh`), and an account
spend limit set at Anthropic, outside this repo entirely. That third one
is the only cap that survives a bug in this repo's own scripts, so
`autonomy.md`'s Activation Checklist sets it first, before an API key
exists.

## Spend Ledger

Append-only. A row per period this is actually checked, once active.

| Period | Scope | Tokens | Est. Cost | Notes |
|--------|-------|--------|-----------|-------|
| _(none recorded yet)_ | | | | |
