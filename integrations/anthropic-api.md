# Anthropic API

The API `scripts/run-department.sh` calls to run a department headless, when
`../_company/autonomy.md` is `Status: AUTONOMOUS`. Not connected today: this
card exists to record the decision ahead of it, same as
`../departments/finance/integrations/accounting-banking.md` did before its
provider was chosen.

- **Kind:** API
- **Can Read:** Nothing external. The prompt it receives is whatever
  `run-department.sh` assembles from that department's own `CONTEXT.md` and
  `learnings.md`.
- **Can Write:** One file into the calling department's `output/`, via the
  agent's own `Write`/`Edit` tools. Never git, never a merge; the workflow
  around it opens the pull request.
- **Credential Required:** `ANTHROPIC_API_KEY`
- **Where The Value Lives:** A GitHub Actions repository secret named
  `ANTHROPIC_API_KEY`. Not a password manager entry, not `.env.local`: the
  only consumer of this credential is CI, never a person's machine.

## Setup

1. In the Anthropic Console, set an account-level spend limit before
   creating a key. This is the one cap that survives a bug in this
   repo's own scripts, so it exists before the key that could spend
   against it does.
2. Create an API key scoped to this use.
3. Add it as a GitHub Actions secret named `ANTHROPIC_API_KEY` (repository
   secret, Settings -> Secrets and variables -> Actions), not a repository
   variable and not a file in this repo.
4. Follow `../_company/autonomy.md`'s Activation Checklist for the
   remaining steps: it also gates a repository variable, a department
   opt-in row, and a dry run before anything real executes.

## Why Not The Pro Subscription

The subscription that runs Claude Code interactively does not work here.
`claude --help` documents that under `--bare`, authentication is "strictly
`ANTHROPIC_API_KEY` or `apiKeyHelper`", and OAuth or keychain login is
never read. Headless CI has no browser to authenticate against in the
first place. Unattended runs bill per-token against an API key, a real and
recurring cost line, not something the existing subscription covers.

## Approval Gate

Three things require explicit founder approval before they happen, all
documented in full in `../_company/autonomy.md`:

- Flipping `../_company/autonomy.md`'s `Status:` to `AUTONOMOUS`.
- Creating the `AUTONOMY_MODE` repository variable, which arms the
  schedule once `Status:` is already `AUTONOMOUS`.
- Raising any department's Per-Run Cap or Period Budget in the Department
  Autonomy table.

Reading this card, or running `scripts/run-department.sh --dry-run`,
requires no approval: neither spends anything.
