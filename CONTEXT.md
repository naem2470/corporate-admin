# Corporate Admin

Org-chart-driven administration for the company. One department per
folder under `departments/`; new departments get added as the business
grows.

## Task Routing

| Task Type | Go To | Description |
|-----------|-------|--------------|
| First-time setup | `setup/questionnaire.md` | Onboarding questions that populate `_company/company-info.md` |
| Onboard a new employee | `setup/employee-onboarding.md` | Seat checklist; hands off to `scripts/onboard.sh` for the mechanical half |
| Finance (bookkeeping, expenses, invoices, taxes) | `departments/finance/CONTEXT.md` | Track money in/out and recordkeeping |
| Add a new department | `departments/_template/CONTEXT.md`, then `_company/EXTENSIONS.md` | Blank pattern to copy and fill in |
| Install, update, or remove a skill | `skills/INSTALLING.md` | Three-tier install process and wiring syntax |
| Install, update, or remove an integration | `integrations/INSTALLING.md`, then `integrations/CREDENTIALS.md` | Three-tier install process, MCP/API/SDK distinctions, root-only caveat |
| Check or activate AI spend budgets | `_company/budget.md` | Dormant by default; see Shared Resources below |

## Shared Resources

| Resource | Location | Contains |
|----------|----------|----------|
| Org chart | `_company/org-chart.md` | Current roles, who fills them, reporting lines, role skill and integration assignments |
| Company info | `_company/company-info.md` | Legal name, entity type, state, EIN, fiscal year |
| Founder preferences | `_company/founder-preferences.md` | Running record of founder's decisions/preferences across departments |
| Workspace conventions | `_company/EXTENSIONS.md` | Why department CONTEXT.md has Role/Trigger sections plus learnings.md, tiered skills, and script-enforced checks |
| Budget and cost control | `_company/budget.md` | AI/agent spend policy; `Status: INACTIVE` by default |
| Autonomous operation | `_company/autonomy.md` | Unattended department runs; `Status: MANUAL` by default, needs a second key outside git to arm |
| Skills library | `skills/CONTEXT.md` | Company-wide skills; pointer to `skills/INSTALLING.md` |
| Integrations library | `integrations/CONTEXT.md` | Company-wide MCP/API/SDK integrations; pointer to `integrations/INSTALLING.md` and `integrations/CREDENTIALS.md` |
| Scripts | `scripts/README.md` | Onboarding scripts and the `validate.sh` keystone shared by the pre-commit hook and CI |
