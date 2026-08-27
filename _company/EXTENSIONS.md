# Workspace Conventions

This workspace layers seven conventions on top of the basic department
(Inputs/Process/Outputs) shape used throughout this repo. They compound:
each builds on the ones before it, but each is also independently
useful on its own.

## 1. Department Role + Trigger

Every department `CONTEXT.md` opens with two sections before the standard
Inputs/Process/Outputs:

- **Role**: Scope (what this department is responsible for), Reports To
  (who it answers to in the org chart), Filled By (who currently does this
  work: the founder today, an employee later).
- **Trigger**: `on-demand` or `recurring` (with a cadence). Recurring
  departments can be wired to the `/schedule` cron skill so they actually
  run on that cadence instead of only running when asked.

This turns a department folder into an org-chart seat, not just a stage:
you can see who owns it and when it runs without opening the process
itself.

## 2. Curated `learnings.md`

Every department keeps a `learnings.md` next to its `CONTEXT.md`. An agent
running that department:

1. Reads `learnings.md` before starting (patterns and corrections from past
   runs).
2. Appends a dated entry at the end of a run if something worth remembering
   came up (a correction, a preference, a recurring gotcha).

This is a deliberately curated file, not a re-read of past `output/`
artifacts: docs over outputs. Agents do not learn style or process from
old outputs; they learn from what got explicitly written to
`learnings.md`.

Preferences that apply company-wide (not just one department) go in
`founder-preferences.md` instead, which every department also reads.

## 3. Three-Tier Skills

A simpler baseline would bundle skills into one workspace-level `skills/`
folder. This workspace splits that into three tiers; `../skills/INSTALLING.md`
is canonical for the full rule, promotion guidance, and wiring syntax. In
short:

- **Company** (`../skills/[name]/`): used by two or more departments.
- **Department** (`../departments/[dept]/skills/[name]/`): used by exactly
  one.
- **Role**: not a third folder. A role-scoped skill still lives in one of
  the two tiers above; a row in `org-chart.md`'s Role Skill &
  Integration Assignments table names which seat loads it. This keeps a
  departing or arriving employee's skill set a one-table lookup instead of
  a folder reorganization.

One finding worth stating plainly: skills bundled this way are read-on-
demand reference docs, not slash commands. Claude Code only registers
skills it finds at `~/.claude/skills/[name]/SKILL.md`, one level deep.
Anything bundled inside this workspace sits deeper than that and is never
auto-registered, which is what makes the workspace portable: it carries
its own knowledge rather than depending on what happens to be installed on
whatever machine runs it.

## 4. Integrations (MCP / API / SDK)

Same three-tier shape as skills, documented in full in
`../integrations/INSTALLING.md`, plus a security layer skills do not need:

- **Company** (`../integrations/[name].md`): used by two or more
  departments.
- **Department** (`../departments/[dept]/integrations/[name].md`): used by
  exactly one.
- **Role**: an assignment in the same widened org-chart table as skills,
  not a separate folder.

**The root-only constraint** (Claude Code reads MCP configuration only
from the exact launch directory, with no directory walk either way,
verified against the installed binary) is documented in full in
`../integrations/INSTALLING.md`'s Root-Only Caveat section. It means an
MCP server's real technical configuration always lives in one root
`.mcp.json` regardless of which tier its card sits in, and a department's
`## Integrations` section is a documented access policy an agent follows,
not a technical wall Claude Code enforces.

**Credentials are reference-only**: no real secret value ever enters this
repo. `../integrations/CREDENTIALS.md` is the rule; `.gitignore` is the
backstop.

## 5. Budget and Cost Control

Dormant by default, tracking AI/agent spend only, not company operating
spend, which stays with Finance. `budget.md` is canonical for the
activation checklist, data sources, and the enforcement split between
interactive checkpoints and scheduled hard stops; see it for the full
rule.

## 6. Script-Enforced Conventions

Conventions 1 through 5 above, plus this workspace's own quality
guardrails (`CONTEXT.md` under 80 lines, no em dashes, `.gitkeep` in
empty `output/` folders), used to be prose only: true because someone
read the docs, not because anything checked. `../scripts/validate.sh`
now enforces the checkable parts of all of it, in one script rather
than scattered across this file.

The same script runs three places, on purpose, so local and CI can never
quietly disagree about what counts as valid: a person can run it directly,
`.githooks/pre-commit` runs it before every commit, and
`.github/workflows/validate.yml` runs it on every pull request. See
`../scripts/README.md` for the full check list and how to add one.

This is a floor, not a ceiling. It catches structural drift (a missing
`learnings.md`, a broken Inputs-table reference, a secret-shaped string)
mechanically. It does not replace a human reading a PR for whether the
content is actually right.

## 7. Autonomous Operation

Every department above still assumes a human drives it, in a live
conversation. `autonomy.md` adds the option to let a department run on a
schedule with nobody watching, and ships switched off: `Status: MANUAL`,
same dormancy contract as `budget.md`. Turning it on needs two separate
keys open at once, one in git and one a GitHub repo variable outside git,
plus a per-department opt-in row naming a spend cap and a tool allowlist.
An autonomous run may only write into its own department's `output/` and
open a pull request; it can never merge one. See `autonomy.md` for the
full contract, `budget.md`'s new Autonomous Runs section for the spend
caps, and `../integrations/anthropic-api.md` for the credential this all
runs on.

## Why

The founder wants departments to behave like an org chart of AI agents,
each with a defined seat, a memory of how they've been corrected before,
and a documented set of skills and integrations that seat can draw on,
while a human (the founder today, employees later) stays in the loop at
each department's checkpoints, and while nothing that touches money,
external accounts, or its own running cost pretends to be more
locked-down than it actually is. These conventions capture that without
changing the basic Inputs/Process/Outputs department shape used
throughout this repo.
