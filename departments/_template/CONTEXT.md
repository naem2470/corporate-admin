# [Department Name]

[One sentence: what this department is responsible for.]

## Role

- **Scope:** [What this department owns]
- **Reports To:** [Founder, or another role]
- **Filled By:** [Who currently does this work]

## Trigger

[on-demand | recurring, with cadence if recurring]

## Integrations

| Integration | Card | Allowed Use |
|-------------|------|-------------|
| [Name] | `[../../integrations/[name].md or integrations/[name].md]` | [what this department may do with it, delete row if none] |

This table is a documented policy, not a technical restriction: see
`../../integrations/INSTALLING.md`'s root-only caveat for why.

## Inputs

| Source | File/Location | Section/Scope | Why |
|--------|--------------|---------------|-----|
| Company info | `../../_company/company-info.md` | Full file | Legal/identity facts |
| Founder preferences | `../../_company/founder-preferences.md` | Full file | Standing preferences |
| This department | `learnings.md` | Full file | Patterns from past runs |
| Skill | `[skills/[name]/SKILL.md or ../../skills/[name]/SKILL.md]` | [section or Full file] | [what it provides, delete row if none installed] |
| User | (conversation) | [what the human provides this run] | [why it's needed, delete row if this department takes no human input] |

## Process

1. Read `learnings.md` and `../../_company/founder-preferences.md` first.
2. [Step two]
3. Save to `output/`

## Checkpoints

| After Step | Agent Presents | Human Decides |
|------------|---------------|---------------|
| [step #] | [what to show] | [what to choose] |

`../../_company/budget.md` is `Status: INACTIVE` by default and adds
nothing here. If it is ever activated for this department, add this row
to the table above:
`| [step #] | Spend so far this period vs. the budget.md limit | Continue, adjust limit, or stop |`

## Outputs

| Artifact | Location | Format |
|----------|----------|--------|
| [Name] | `output/[slug]-[type].md` | [Format] |

## After a Run

Append a dated entry to `learnings.md` if anything is worth remembering for
next time.
