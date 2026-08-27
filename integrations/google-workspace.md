# Google Workspace

Gmail, Google Drive, and Google Calendar, connected through the claude.ai
account rather than through this workspace. Every department gets these
automatically.

- **Kind:** Account connector
- **Can Read:** Email, drive files, calendar events, whatever the
  connected Google account can already see.
- **Can Write:** Draft/send email, create/edit drive files, create/update
  calendar events, again scoped to what the account can already do.
- **Credential Required:** None. No API key, no `.mcp.json` entry.
- **Where The Value Lives:** N/A. Authentication follows whichever Google
  account is connected to the claude.ai login running this workspace, not
  anything stored here.

## Setup

Nothing to set up in this workspace. If the connectors are not appearing,
connect them from claude.ai account settings, not from any file here.

## The Honest Caveat

This is the one integration in this framework where the "tier" a card
sits in is purely descriptive. Because these connectors follow the logged-
in account rather than the workspace, there is no way to grant Finance
access to Calendar while withholding it from another department, and no
`.mcp.json` entry to point at. Access control here is a matter of which
account is logged in when this workspace runs, not anything this workspace
configures. If that ever becomes a real constraint (for example, wanting a
department to use a dedicated Google account instead of the founder's
personal one), that is a claude.ai account decision, not a change to this
workspace.

## Approval Gate

Sending an email or creating a calendar event on someone else's behalf
should be confirmed before it goes out. Reading is unrestricted.
