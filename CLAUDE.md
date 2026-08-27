# Corporate Admin

Runs the day-to-day administration of the company as a living org chart. Each
department is a self-contained workflow; new departments get added over time
as the business grows.

## Folder Map

```
corporate-admin/
├── CLAUDE.md               (you are here)
├── CONTEXT.md              (start here for task routing)
├── scripts/                (onboarding + the validate.sh keystone; see scripts/README.md)
├── .github/workflows/      (CI: validate.yml gates PRs, daily-digest.yml posts the roundup,
│                            autonomous-run.yml runs departments headless, ships inert)
├── setup/                  (onboarding questionnaire, employee-onboarding.md)
├── _company/               (shared context: org chart, company info, founder prefs, extensions, budget)
├── skills/                 (company-wide skill library, see skills/INSTALLING.md)
├── integrations/           (company-wide MCP/API/SDK library, see integrations/INSTALLING.md)
└── departments/
    ├── _template/          (blank pattern: CONTEXT.md, learnings.md, skills/, integrations/, output/)
    └── finance/             (money in/out, recordkeeping; has integrations/accounting-banking.md)
```

## Departments

Department count is open-ended. There is no fixed list: copy
`departments/_template/` to `departments/[new-department]/` whenever a new
department is needed and fill it in. See `_company/org-chart.md` for the
current roster.

## Triggers

| Keyword | Action |
|---------|--------|
| `setup` | Run the onboarding questionnaire in `setup/questionnaire.md` |
| `status` | Show completion status for all departments |
| `skills` | List installed skills by tier |
| `integrations` | List installed integrations by tier |
| `onboard` | Run `scripts/onboard.sh` -- a new person's one-command setup |
| `validate` | Run `scripts/validate.sh` -- the convention-check keystone, also run by the pre-commit hook and CI |

### How `skills` and `integrations` work

Skills are directories; integration cards are flat files. Scan
`skills/*/` and `departments/*/skills/*/` (excluding `_template`) for
skills. Scan `integrations/*.md` and `departments/*/integrations/*.md`
(excluding `_template`), skipping `CONTEXT.md`, `CREDENTIALS.md`,
`INSTALLING.md`, and `_template.md`, for integrations. Render each found
item under its tier and department. Role tier is not a folder; read it
from `_company/org-chart.md`'s Role Skill & Integration Assignments table
instead. See `skills/INSTALLING.md` or `integrations/INSTALLING.md` to
add one.

### How `status` works

Scan `departments/*/output/` folders (excluding `_template`). Render each
department COMPLETE (has files besides `.gitkeep`) or PENDING (does not).

## Routing

| Task | Go To |
|------|-------|
| Onboard / fill in company info | `setup/questionnaire.md` |
| Onboard a new employee | `setup/employee-onboarding.md`, then `scripts/onboard.sh` |
| Anything finance-related (bookkeeping, expenses, invoices, taxes) | `departments/finance/CONTEXT.md` |
| Add a new department | `departments/_template/CONTEXT.md`, then `_company/EXTENSIONS.md`, or run `scripts/new-department.sh [name]` |
| Install, update, or remove a skill | `skills/INSTALLING.md` |
| Install, update, or remove an integration | `integrations/INSTALLING.md`, then `integrations/CREDENTIALS.md` |
| Check or activate AI spend budgets | `_company/budget.md` (inactive by default) |
| Check or activate autonomous, unattended department runs | `_company/autonomy.md` (manual by default) |

## What to Load

| Task | Load These | Do NOT Load |
|------|-----------|-------------|
| Run Finance | `departments/finance/CONTEXT.md`, `departments/finance/learnings.md`, `_company/company-info.md`, `_company/founder-preferences.md` | Other departments, `_company/EXTENSIONS.md` |
| Add a department | `departments/_template/`, `_company/EXTENSIONS.md`, `_company/org-chart.md` | Existing departments' `output/` |
| Install a skill | `skills/INSTALLING.md`, the target department's `CONTEXT.md` | Other departments |
| Install an integration | `integrations/INSTALLING.md`, `integrations/CREDENTIALS.md`, the target department's `CONTEXT.md` | Other departments |

## Department Handoffs

Each department writes its output to its own `output/` folder. Each
department also keeps a `learnings.md` it reads at the start of a run and
appends to at the end. See `_company/EXTENSIONS.md` for the full set of
workspace conventions this is part of.
