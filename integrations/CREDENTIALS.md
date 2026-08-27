# Credential Policy

The one rule everything else here follows: no real secret value ever
enters this repo, in any file, at any time. Not in `.mcp.json`, not in an
integration card, not in a comment, not "just temporarily" while testing.
A value typed into a tracked file can end up in git history even after
it is deleted from the working copy.

## Where Values Actually Live

- A password manager, or
- A Windows user environment variable set outside this repo.

`.mcp.json` (when one exists) references credentials as `${VAR_NAME}`.
Claude Code expands that from the environment of the process that
launched it, so the name is safe to commit and the value never gets near
git. Integration cards record the credential's *name* only, plus where to
find the real value, never the value itself.

## Least Privilege

- If a department only reads data, use a read-only credential for it.
  Read-only cannot be misused to write, even by accident.
- One credential per integration. If a credential is shared across
  several integrations, revoking it for one reason breaks all of them.

## Rotation and Revocation

When someone leaves a seat, or a credential is suspected compromised:

1. Revoke or rotate the credential at the provider (the bank, the
   accounting tool, the API vendor), not just in your own notes.
2. Update the value in the password manager or environment variable.
3. Confirm the integration still works with the new value before
   considering the rotation done.

A shared credential across multiple people is worse than a per-seat one:
rotating it means updating it everywhere at once and briefly breaks
everyone, instead of one clean swap.

## Before Any Commit Touching Integrations

Run `git status` and read the list. If anything unexpected is staged,
treat it as a possible leak until you have confirmed otherwise, not the
other way around.

## If A Secret Does Get Committed

1. **Rotate the credential first.** A rotated key makes the leaked value
   worthless immediately. This is the actual fix.
2. **Scrub git history second.** This is cleanup, not the fix. Skipping
   step 1 and only doing step 2 leaves the old value valid and exposed for
   as long as it takes to notice.
