# Scripts

Bash only, no dependency manifest. `integrations/INSTALLING.md` is explicit
that adding a `package.json` or `requirements.txt` changes this workspace
from dependency-free to one that needs installing -- these scripts use only
git and coreutils, on purpose, so that stays true.

| Script | Run it when | What it does |
|--------|-------------|--------------|
| `onboard.sh` | Right after cloning, or any time you want a health check | Checks prerequisites, sets up `.env.local`, installs git hooks, runs `validate.sh`, prints your seat and next steps. Idempotent. |
| `validate.sh` | Anytime, and automatically via the pre-commit hook and CI | The keystone. Twelve checks against the conventions this workspace is built on. Same script, same rules, whether run by a person, a hook, or `.github/workflows/validate.yml`. |
| `install-hooks.sh` | Called by `onboard.sh`; run directly to reinstall | Points `core.hooksPath` at `.githooks/` so `pre-commit` is version-controlled instead of sitting untracked in `.git/hooks/`. |
| `new-department.sh <name>` | Adding a department | Copies `departments/_template/` to `departments/<name>/` and prints the three follow-up edits (Role/Trigger, org-chart row, routing row) the template can't make for you. |
| `run-department.sh <name> [--dry-run]` | Called by `.github/workflows/autonomous-run.yml`; safe to run by hand anytime | Runs a department headless through the Anthropic API, gated behind `../_company/autonomy.md`'s two keys and that department's own opt-in row. Exits 0 and does nothing if either key is closed, which is the shipped state. `--dry-run` prints the command it would run and spends nothing. |

## `validate.sh` usage

```
scripts/validate.sh              # run every check
scripts/validate.sh --quiet      # findings only, no "[ok]" lines
scripts/validate.sh --only NAME  # run a single check; --help lists names
```

Exit 0 means every check passed. Exit 1 means at least one failed; failures
print as `path:line: message` so they're clickable in a terminal.

## Adding a check

Every rule lives in `validate.sh`, not in the CI workflow. Add a
`check_<name>()` function that returns 0 (pass) or 1 (fail, after calling
`fail "..."` for each finding), then add one `run_check <name> "<description>"`
line near the bottom of the file. CI picks it up automatically -- there is
nothing to change in `.github/workflows/validate.yml`.

## `lib/common.sh`

Sourced by every script above, plus `.githooks/pre-commit`. Holds shared
output helpers (`ok`/`warn`/`fail`/`say`), `repo_root()`, `departments()`
(lists real departments, excluding `_template` -- the same exclusion rule
`CLAUDE.md` uses for the `status`/`skills`/`integrations` triggers), and
`SECRET_PATTERN` (one pattern, shared by `validate.sh`'s check 11 and the
pre-commit hook, so the two can't quietly disagree about what looks like a
secret).
