# Installing Skills

How to add a skill to this company, update it, or remove it. A skill is a
folder containing a `SKILL.md` file that gives an agent domain knowledge it
would not otherwise have.

## Three Tiers

| Tier | Lives In | Use When |
|------|----------|----------|
| 1. Company | `[name]/` (this folder) | Two or more departments need it |
| 2. Department | `../departments/[dept]/skills/[name]/` | Exactly one department needs it |
| 3. Role | (stored by the two rules above) | One seat needs it. See below. |

The role tier is an assignment, not a storage location. A role-scoped skill
still lives in the company or department folder; what makes it role-scoped
is a row in `../_company/org-chart.md` saying that seat loads it. This
means nothing is duplicated when a seat changes hands.

Start narrow. A skill can be promoted from department to company later by
moving the folder and updating the rows that cite it. Guessing wide early
costs more than moving it later.

## Installing

1. **Find the source.** Options, in order of preference:
   - Already on this machine: `~/.claude/skills/[name]/`
   - A GitHub repo (clone it, then copy the skill folder out)
   - Anthropic's published skill collections
2. **Pick the tier** using the table above.
3. **Copy the whole folder in.** All of it: `SKILL.md` plus any
   `scripts/`, `sections/`, `references/`, and license files. Copy real
   files. Do not use a symlink, junction, or shortcut. The point of copying
   is that this workspace keeps working when moved to another machine or
   handed to an employee, and a link breaks exactly that.
4. **Check the frontmatter.** Open `SKILL.md` and confirm it starts with a
   block like this, carrying at minimum `name` and `description`:
   ```
   ---
   name: skill-name
   description: What this skill provides and when to use it
   ---
   ```
   If there is no frontmatter, the file is not a skill. It may still be
   useful as a plain reference doc, in which case put it in the consuming
   department's folder rather than here.
5. **Wire it into the department that uses it.** Add a row to that
   department's `CONTEXT.md` Inputs table. A skill nobody cites is a skill
   nobody reads.
6. **If it is role-scoped**, add it to the Role Skill & Integration
   Assignments table in `../_company/org-chart.md`, by name.

## Wiring Syntax

From a department's `CONTEXT.md`, citing a company-tier skill:

```
| Skill | `../../skills/[name]/SKILL.md` | [section or Full file] | [what it provides] |
```

From a department's `CONTEXT.md`, citing its own department-tier skill:

```
| Skill | `skills/[name]/SKILL.md` | [section or Full file] | [what it provides] |
```

**Cite sections, not whole files, when a skill is long.** Some skills run
hundreds of lines and only one part is relevant. Write the section name in
the Section/Scope column:

```
| Skill | `../../skills/bookkeeping/SKILL.md` | "Reconciliation" section | How to match transactions to statements |
```

Reserve `Full file` for genuinely short skills. Every irrelevant line
loaded is attention spent on the wrong thing.

## What Not To Install

Skills about Claude Code itself: skill-creator, mcp-builder, and anything
whose subject is how to build agents or configure tooling. Those belong in
your global `~/.claude/skills/`, not in the company. This folder is for
domain knowledge the business actually runs on.

## Updating

Re-copy the folder from its source, replacing what is there. Then re-read
any Inputs rows citing specific section names, since sections get renamed
between versions and a stale section name means an agent silently reads
nothing.

## Removing

1. Delete the skill folder.
2. Delete every Inputs row in every department `CONTEXT.md` that cites it.
3. Delete any row in the org chart's Role Skill & Integration Assignments
   that names it.

A dangling reference to a deleted skill is worse than no skill, because an
agent will look for it and find nothing.

## These Are Not Slash Commands

Skills installed here are reference documents. An agent reads one when a
department's Inputs table points at it. They cannot be invoked as
`/skill-name`, and they will not appear in the skills list Claude Code
shows you.

This is by design. Claude Code only registers skills at
`~/.claude/skills/[name]/SKILL.md`, one level deep. Skills bundled inside a
workspace sit several levels deeper, which is what makes this workspace
portable: it carries its own knowledge instead of depending on what happens
to be installed on the machine.

**If a skill ever earns being invocable anywhere**, install it separately
into `~/.claude/skills/[name]/`. That is a global install on one machine,
outside this workspace, and it needs fuller frontmatter (`triggers` and
`allowed-tools` in addition to `name` and `description`). The copy in this
workspace stays the source of truth that travels with the company.

## Handing A Department To An Employee

Nothing to install. They get the folder, the skills come with it, and the
department's `CONTEXT.md` already says which ones to read and when. Check
the Role Skill & Integration Assignments table in `../_company/org-chart.md`
to confirm the seat's list is current before handing it over.
