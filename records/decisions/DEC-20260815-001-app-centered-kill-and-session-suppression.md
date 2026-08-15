# DEC-20260815-001: Use App-Centered Killing And Session-Only Relaunch Suppression

Opened: 2026-08-15 20-58-00 KST
Recorded by agent: root

## Metadata

- Status: accepted
- Deciders: operator
- Related ids: LOG-20260815-001

## Decision

- Collect kill candidates from running macOS apps and their child process trees instead of every process with the current UID.
- Aggressive mode ignores user exemptions. Moderate mode protects exempt apps, menu-bar presets, and LSUIElement apps.
- Group helpers under the outermost application bundle.
- Stop matching third-party LaunchAgents only for the current GUI session. Do not edit their plist files or permanently disable login items.
- Run immediately after a kill button press. Quit killeverybody after success and show a result only on failure.

## Context

The previous UID-wide scan returned hundreds of system agents and shells. It also sent SIGKILL once without handling the LaunchAgents that immediately restarted apps. The modal main alert disabled the Settings menu, so the existing exception editor was difficult to reach.

## Options Considered

### Keep UID-Wide Enumeration

- Upside: literal interpretation of killing every user process.
- Downside: includes unrelated system agents, shells, and services.

### Use Running Apps And Their Descendants

- Upside: matches the operator's app-centered intent and keeps helpers grouped with their parent app.
- Downside: non-app daemons are intentionally outside the normal kill scope.

### Permanently Disable Login Items

- Upside: prevents relaunch across logins.
- Downside: changes persistent user configuration and exceeds the requested session cleanup.

### Boot Out Matching LaunchAgents For This Session

- Upside: prevents immediate KeepAlive relaunch without changing persistent settings.
- Downside: macOS-managed system apps can still restart.

## Rationale

The app-centered model removes the largest source of accidental collateral damage while preserving the two requested modes. Session-only bootout fixes the observed relaunch mechanism without silently rewriting the user's login configuration.

## Consequences

- Exception selections apply to an app and all of its helpers in moderate mode.
- Aggressive mode remains intentionally destructive and ignores user exceptions.
- System apps managed by macOS may relaunch.
- CLI dry-run remains the default verification path.
