# Accounting / Banking

Not yet connected. This card exists to record the decision ahead of it and
the handling rules that apply no matter which way it is decided, since
Finance is the highest-consequence department in this workspace.

- **Kind:** API (most likely) or MCP server, depending on what the chosen
  provider offers
- **Can Read:** Transactions, balances, invoices, statements, once
  connected
- **Can Write:** Depends entirely on provider and credential scope chosen
  below; default to none until a real need for write access appears
- **Credential Required:** Not yet chosen
- **Where The Value Lives:** Not yet chosen

## The Decision Ahead

Pick one, when ready:

- **QuickBooks** or **Xero**: full accounting software, API access to
  books already kept there
- **Plaid**: bank-account read access without holding bank credentials
  directly
- **Direct bank API**: if the bank offers one; usually the least
  standardized option

Whichever is chosen, install it following `../../../integrations/INSTALLING.md`,
then fill in the fields above and this section's rules.

## Handling Rules (Apply Regardless of Provider)

Least privilege and one-credential-per-integration follow
`../../../integrations/CREDENTIALS.md` like every other integration.
Finance-specific on top of that: **no credential that can move money gets
set up without an explicit approval gate below**, filled in at connection
time, naming exactly what requires sign-off before the agent acts.

## Setup

(Pending provider decision. See `../../../integrations/INSTALLING.md`.)

## Approval Gate

Any action that moves money, pays a bill, or files something with a tax
authority requires explicit founder approval before it happens. Reading
transactions and generating summaries does not.
