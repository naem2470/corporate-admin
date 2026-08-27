# Company Integrations Library

MCP servers, APIs, and SDKs available to every department. Tier 1 of
three; see `INSTALLING.md` for the full tier rule, the root-only limit on
MCP configuration, and how to add, update, or remove one. Read
`CREDENTIALS.md` before installing anything.

## Current Contents

| Integration | Kind | Notes |
|-------------|------|-------|
| `google-workspace.md` | Account connector | Gmail, Drive, Calendar. No install, no credential. |
| `anthropic-api.md` | API | Not connected. Powers autonomous runs once `_company/autonomy.md` is active. |

## Task Routing

| Task Type | Go To | Description |
|-----------|-------|--------------|
| Install, update, or remove an integration | `INSTALLING.md` | Full process, MCP/API/SDK distinctions, wiring |
| Credential handling rules | `CREDENTIALS.md` | Reference-only policy, rotation, leak response |
