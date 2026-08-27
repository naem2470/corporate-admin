# Finance

Day-to-day money in, money out, and financial recordkeeping.

> First-draft workflow: edit this to match how you actually want Finance
> run. Nobody has confirmed these steps against real practice yet.

## Role

- **Scope:** Track expenses and income, reconcile against bank records,
  flag anything due (invoices to send, bills to pay, taxes coming up),
  produce a period summary.
- **Reports To:** Founder
- **Filled By:** Founder

## Trigger

Recurring, monthly. Adjust if a different cadence fits better.

## Integrations

| Integration | Card | Allowed Use |
|-------------|------|-------------|
| Google Workspace | `../../integrations/google-workspace.md` | Read/draft as needed for department correspondence |
| Accounting/banking | `integrations/accounting-banking.md` | Not yet connected; read-only once connected, per that card's Approval Gate |

This table is a documented policy, not a technical restriction: see
`../../integrations/INSTALLING.md`'s root-only caveat for why.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Company info | `../../_company/company-info.md` | Full file | Entity/fiscal-year facts |
| Founder preferences | `../../_company/founder-preferences.md` | Full file | Standing preferences |
| This department | `learnings.md` | Full file | Patterns from past runs |
| User | (conversation) | Period's transactions/statements | The raw data for this run |

## Process

1. Read `learnings.md` and `../../_company/founder-preferences.md` first.
2. Collect the period's transactions (bank/card statements, invoices sent,
   bills received) from whoever fills this department's Role.
3. Categorize each transaction (income, expense type).
4. Reconcile against bank/statement totals; flag any mismatch.
5. Flag anything due soon: unpaid invoices, unpaid bills, upcoming tax
   deadlines.
6. Write the period summary to `output/`.

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| 6 | Draft period summary: categorized totals, flagged mismatches, upcoming due items | Whether the categorization and flags are correct before treating the summary as final |

`../../_company/budget.md` is `Status: INACTIVE` by default and adds
nothing here. If it is ever activated for this department, add this row
to the table above:
`| [step #] | Spend so far this period vs. the budget.md limit | Continue, adjust limit, or stop |`

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| Period finance summary | `output/[year-month]-finance-summary.md` | Categorized totals, reconciliation notes, upcoming due items |

## After a Run

Append a dated entry to `learnings.md` if anything is worth remembering for
next time (a recurring category the founder always corrects, a preferred
level of detail, a recurring due date).
