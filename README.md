# Corporate Admin

A template for running a company's day-to-day administration as a
living org chart inside [Claude Code](https://claude.com/claude-code).
Each department (finance, and whatever else your company needs) is a
self-contained folder Claude reads and runs like a seat on an org chart:
its own scope, its own memory of past corrections, its own skills and
integrations, with a human staying in the loop at defined checkpoints.

This repo ships as a blank template: no company data, dependency-free
(bash + git only), and every automated/unattended feature switched off
by default. You fill it in for your own company by copying it and
running setup.

## Quick start

1. Clone this repo (or use it as a template to create your own).
2. Open it in Claude Code and type `setup`, or run `scripts/onboard.sh`
   from a terminal. Either walks through `setup/questionnaire.md` to
   fill in `_company/company-info.md`, `_company/org-chart.md`, and the
   rest of `_company/`.
3. Run `bash scripts/validate.sh` anytime to check the workspace is
   internally consistent. The same script also runs via a pre-commit
   hook and in CI on every pull request.

See [CLAUDE.md](CLAUDE.md) for the full folder map and task-routing
table, and [CONTEXT.md](CONTEXT.md) for the same routing from an
agent's point of view.

## What's in here

- `departments/` -- one folder per department (`_template/` is the
  blank pattern to copy for a new one; `finance/` ships as a working
  example).
- `_company/` -- shared context every department reads: org chart,
  company info, founder preferences, budget and autonomy controls (both
  dormant by default).
- `skills/` and `integrations/` -- company-wide skill and integration
  libraries, plus per-department equivalents.
- `scripts/` -- onboarding and the `validate.sh` keystone. See
  `scripts/README.md`.
- `.github/workflows/` -- CI validation, a daily digest, and an
  opt-in autonomous department runner (ships inert; see
  `_company/autonomy.md`).

## License

[MIT](LICENSE)
