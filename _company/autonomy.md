# Autonomous Operation

**Status: MANUAL**

While this says MANUAL, nothing here runs. No department executes on a
schedule, no API key is used, no money is spent. An agent that opens this
file while Status says MANUAL should stop reading here and go back to
whatever it was doing.

`MANUAL` and `AUTONOMOUS` are the only two valid values. Anything else is
a validation failure, not a third mode.

## Why This Exists

`../.github/workflows/daily-digest.yml` already detects which recurring
department is overdue. It never runs one. Closing that gap means an agent
runs unattended, and unattended means it spends money with nobody
watching. So this is a spend-control file first and a scheduler second.

Company operating spend (vendor bills, bank transactions) is not in scope
here and stays with Finance. This tracks only what the agents themselves
cost to run. See `budget.md`, which owns the limits and the ledger.

## The Two Keys

Two independent switches must both be open before anything runs. Either
one closed stops everything.

| Key | Where | What it is for |
|-----|-------|----------------|
| 1. `Status:` above | This file, in git | The auditable declaration of intent. Changing it moves through a reviewed pull request. |
| 2. `AUTONOMY_MODE` | A GitHub repository variable, **not** in git | The instant kill switch. Delete it in Settings and everything stops with no commit and no waiting for CI. |

The split is deliberate. A file alone cannot be turned off quickly in an
emergency. A repo variable alone leaves no record of why autonomy was
turned on or who agreed to it. Requiring both gives a reviewable history
and a fast stop.

## Department Autonomy

Per-department opt-in. A department set to `autonomous` still does nothing
unless both keys above are open.

| Department | Mode | Per-Run Cap | Period Budget | Cadence | Allowed Tools |
|------------|------|-------------|---------------|---------|---------------|
| `../departments/finance/` | manual | | | | |

This table lives here rather than in each department's `CONTEXT.md`
because it is an assignment, not storage, the same idiom
`../skills/INSTALLING.md` uses for the role tier. It also keeps
`CONTEXT.md` files clear of the 80-line limit.

**Allowed Tools is the real containment.** An unattended run cannot sit at
a permission prompt, so permission mode is not a boundary. The tool
allowlist is. `Read,Write,Edit,Glob,Grep` lets an agent read its context
and write a markdown artifact and nothing else: no `Bash`, so it cannot
shell out, and no `WebFetch`, so it cannot reach the network. Widening
this list is a deliberate, reviewed edit.

## What An Autonomous Run May Do

- Read its own department's `CONTEXT.md` and `learnings.md`, plus
  `company-info.md`, `founder-preferences.md`, and `budget.md`.
- Read `.messages/[channel].jsonl` if `messaging.md` routes a channel here.
  Fetching happens outside this run entirely; see that file.
- Write exactly one artifact into its own department's `output/`.
- Open a pull request with that artifact and its ledger row.

It may not merge that pull request, edit anything under `_company/` other
than appending a ledger row, run any department other than the one named,
or use an integration whose card has a write-capable Approval Gate. Those
are documented policy, not a technical wall, exactly as
`../integrations/INSTALLING.md`'s root-only caveat describes.

## Activation Checklist

Ordered. Step 1 is the only cap that survives a bug in this repo's own
scripts, so it comes first.

1. Set a spend limit in the Anthropic Console, before a key exists.
2. Create an API key. Add it as the GitHub Actions secret
   `ANTHROPIC_API_KEY`. See `../integrations/anthropic-api.md`.
3. Fill the department's row above: mode, per-run cap, period budget,
   cadence, allowed tools.
4. Set `budget.md` to `Status: ACTIVE` and fill one Budget Policy row.
5. Flip `Status:` above to `AUTONOMOUS` and merge that pull request.
6. Run the workflow manually with `dry_run: true`. Read the printed
   command. Nothing is spent.
7. Run it manually with `dry_run: false` once. Review the pull request it
   opens.
8. Only then create the repository variable `AUTONOMY_MODE=autonomous` to
   arm the schedule.

## Kill Switch

Fastest first:

1. **Delete the `AUTONOMY_MODE` repository variable.** Instant, no commit,
   no CI wait. The next scheduled run skips.
2. **Disable the workflow** in the Actions tab.
3. **Revoke `ANTHROPIC_API_KEY`** at the Anthropic Console. Slowest of the
   three, but the only one that also invalidates a leaked copy of the key.

Setting `Status: MANUAL` here also stops everything, but it needs a commit
and a merge, so it is the record of the decision rather than the emergency
stop.

## The Honest Limits

- **"24/7" means "every N hours, best effort."** GitHub Actions cron has a
  five-minute floor, is routinely delayed under load, and GitHub disables
  scheduled workflows after 60 days of repository inactivity. This is a
  periodic batch runner, not a daemon.
- **The spend ledger is a record, not a control.** A run writes its ledger
  row into the pull request it opens, so until that merges, a later run
  reads a stale total. The per-period check is a soft guard. The hard
  guarantees are the per-run cap and the Console limit.
