# Employee Onboarding

A human checklist, not a script. Editing `_company/org-chart.md`'s tables is
a judgment call about roles and reporting lines, not something to automate.
For everything that *is* mechanical (env setup, git hooks, health check),
send them to `scripts/onboard.sh` instead -- step 4 below.

## Adding a Seat

1. **Repo access.** Add them as a collaborator on the GitHub repo (Settings
   -> Collaborators), or to the org if this repo lives under one.

2. **Org chart row.** Add a row to the roster table in
   `_company/org-chart.md`:

   ```
   | [Role] | [Their Name] | [Who they report to] | `../departments/[dept]/` |
   ```

   If the role needs its own department workflow that doesn't exist yet,
   run `scripts/new-department.sh [dept-name]` first.

3. **Credentials, least privilege.** Before they touch anything with an
   integration, read `integrations/CREDENTIALS.md`. The two rules that
   matter most here: give them their **own** credential, not a shared one
   (rotating a shared credential breaks everyone at once instead of one
   clean swap), and scope it to **read-only** unless their role genuinely
   needs to write.

4. **Have them run onboarding.** They clone the repo and run:

   ```
   bash scripts/onboard.sh
   ```

   This sets up `.env.local`, installs the pre-commit hook, runs
   `scripts/validate.sh`, and prints the current roster back to them so
   they can confirm step 2 landed correctly.

5. **Role Skill & Integration Assignments.** If their seat needs a specific
   skill or integration (not "all of them"), add a row to that table in
   `_company/org-chart.md` too -- see `skills/INSTALLING.md` and
   `integrations/INSTALLING.md` for the tier rules this table encodes.

6. **Confirm.** Ask them to run `bash scripts/validate.sh` themselves and
   paste the output. A clean run (or only the known placeholder failure, if
   `setup` hasn't been run in this workspace yet) means they're set up
   correctly.

## Removing a Seat

Do this in order -- credential rotation first, bookkeeping second, per
`integrations/CREDENTIALS.md`'s Rotation and Revocation section:

1. **Revoke or rotate every credential they held**, at the provider, not
   just in a notes file. Since step 3 above gave them a per-seat
   credential, this does not affect anyone else.
2. Remove their row from `_company/org-chart.md`'s roster table and from
   the Role Skill & Integration Assignments table.
3. Remove their GitHub repo access.
4. If anything they owned has no other seat covering it (a department with
   `Filled By` naming only them), decide who picks it up before they leave,
   not after.
