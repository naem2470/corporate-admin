# Installing Integrations

How to connect an MCP server, API, or SDK, update it, or remove it. Read
`CREDENTIALS.md` first: it is the rule everything below follows.

## Three Kinds

| Kind | What It Is | Installs As |
|------|-----------|-------------|
| MCP server | Gives the agent tools directly | Entry in root `.mcp.json` |
| API | An endpoint called from a script with a key | A card naming the base URL and auth method |
| SDK | A library used in code | A per-project dependency (see below; avoid unless needed) |

## Tier Rule

Same rule as skills (`../skills/INSTALLING.md`): two or more departments
needing it is 1. Company, stored here as `[name].md`; exactly one is
2. Department, stored in `../departments/[dept]/integrations/[name].md`;
one seat needing it is 3. Role, stored by the same rule and assigned in
`../_company/org-chart.md`.

Start narrow. Moving one `.md` file to promote an integration from
department to company tier is cheap: move the file, update the `.mcp.json`
entry's context if needed, and update every row that cites it. Guessing
wide early costs more than moving it later.

## The Root-Only Caveat

Read this before installing an MCP server. Claude Code reads `.mcp.json`
only from the exact directory it was launched in, with no exceptions and
no directory scoping. This means **every MCP server's technical config
lives in one root `.mcp.json`, regardless of which tier its card sits in.**

A card in `../departments/[dept]/integrations/` does not restrict who can
call that server. What actually governs use is the department's own
`## Integrations` section in its `CONTEXT.md`, which is a documented
policy an agent follows, not a technical wall Claude Code enforces. Be
honest with yourself about that difference when deciding what an
integration is allowed to touch.

## Installing an MCP Server

1. Pick the server. Prefer one launched with `npx -y` or `uvx`, so nothing
   needs installing into the workspace itself.
2. Add an entry to root `.mcp.json` (create the file if it does not exist
   yet), using `${VAR_NAME}` for every credential, never a literal value:
   ```json
   {
     "mcpServers": {
       "example": {
         "type": "stdio",
         "command": "npx",
         "args": ["-y", "@scope/example-mcp-server"],
         "env": { "EXAMPLE_API_KEY": "${EXAMPLE_API_KEY}" }
       }
     }
   }
   ```
3. Set the real value as an environment variable outside this repo, per
   `CREDENTIALS.md`.
4. Approve the server when Claude Code prompts for it.
5. Write an integration card from `_template.md`.
6. Add it to the consuming department's `## Integrations` section.

## Installing an API

No `.mcp.json` entry; APIs are called from scripts, not exposed as agent
tools. Write a card recording the base URL, the auth method, and the
credential name (never the value). Wire it into the consuming
department's `## Integrations` section the same way.

## Installing an SDK

Only if a department's work genuinely needs code, not just documentation
and agent tool calls. Adding a dependency manifest (`package.json`,
`requirements.txt`) changes this workspace from dependency-free to one
that needs installing. Prefer an MCP server or a plain API call first;
reach for an SDK only when neither fits.

## Account Connectors Are Different

Some integrations, like the Google Workspace connectors, come from the
claude.ai account itself: they appear automatically, need no install, and
cannot be scoped, versioned, or committed here since they follow whoever
is logged in, not this workspace. Write a card for these anyway. It exists
to record what the company relies on, not to configure anything.

## Updating

Change the `.mcp.json` entry or the card's recorded base URL/auth method.
Re-confirm the credential name still matches what the provider expects.

## Removing

In this order: delete the `.mcp.json` entry, delete the card, delete the
rows citing it in every department's `## Integrations` section, then
revoke the credential per `CREDENTIALS.md`. A dangling reference to a
removed integration is worse than no integration: an agent will look for
it and find nothing, or worse, find a stale credential still valid.
