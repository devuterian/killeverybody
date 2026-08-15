# LOG-20260815-001: Exception Apps And Relaunch Control

Opened: 2026-08-15 20-58-00 KST
Recorded by agent: root

## Metadata

- Run type: orchestrator
- Goal: add searchable app exemptions, app-centered kill scope, relaunch suppression, and graceful self-termination
- Related ids: DEC-20260815-001

## Task

Implement the accepted behavior on top of GitHub main without running a destructive full-session kill.

## Scope

- In scope: macOS app and CLI sources, Xcode target membership, smoke checks, product and user documentation
- Out of scope: permanent login-item changes, system LaunchDaemon changes, a real full-session kill

## Entry 2026-08-15 20-58-00 KST

- Action: cloned GitHub main into a clean checkout and created codex/exception-apps.
- Files touched: none
- Checks run: GitHub commit comparison, clean checkout status
- Output: based work on v2.2.0 commit 32d9e9b while preserving the older dirty checkout
- Blockers: none
- Next: inspect current UI and candidate enumeration

## Entry 2026-08-15 21-00-00 KST

- Action: built and opened the current app without pressing a kill button; ran CLI dry-run.
- Files touched: none
- Checks run: Xcode app and CLI builds, Computer Use inspection, moderate and aggressive JSON dry-runs
- Output: confirmed the modal alert disabled Settings and the UID-wide moderate scan included more than 400 candidates
- Blockers: none
- Next: implement the accepted app-centered design

## Entry 2026-08-15 21-05-00 KST

- Action: implemented app-tree enumeration, outer-app helper grouping, first-run login-item exemptions, searchable icon list, session LaunchAgent bootout, and normal self-termination.
- Files touched: app sources, CLI source, Xcode project, smoke script
- Checks run: swiftc smoke check and unsigned Xcode builds
- Output: builds passed
- Blockers: CoreSimulator version warning is unrelated to the macOS targets
- Next: verify UI, policy behavior, and relaunch suppression

## Entry 2026-08-15 21-10-00 KST

- Action: verified the new UI and isolated relaunch behavior.
- Files touched: temporary test LaunchAgent and app, removed after the test
- Checks run: login-app filter, Beeper search, settings-to-prompt return, policy dry-run, isolated KeepAlive LaunchAgent bootout
- Output: 26 login apps were checked on first seed; moderate policy excluded all Beeper helpers while aggressive still included them; the test KeepAlive job and process stayed unloaded after bootout
- Blockers: none
- Next: align repo truth and user documentation, then run final checks

## Entry 2026-08-15 21-35-00 KST

- Action: replaced the password-prompting `sfltool dumpbtm` login-item query with read-only SharedFileList enumeration; upgraded Sparkle and hardened the GitHub Release appcast flow.
- Files touched: application catalog, app delegate, Info.plist, Swift package resolution, release workflow, smoke check, release documentation, truth/status docs
- Checks run: live GitHub release/appcast/Actions-secret inspection, current Sparkle documentation and release inspection, permissionless SharedFileList enumeration harness
- Output: 27 visible login-item records were read without authorization; GitHub has the matching secret and the live v2.1.1 appcast remains signed; the next tag will use Sparkle's official `generate_appcast` and reject a tag/version mismatch
- Blockers: current public release is v2.1.1 while this branch is v2.2.0 build 17; publication still requires a later commit/tag operation
- Next: build, launch without an authorization prompt, inspect Sparkle runtime logs, and validate the workflow mechanically

## Entry 2026-08-15 21-45-00 KST

- Action: rebuilt and installed the user preview, launched it through the real UI, exercised the login-items filter, and tested Sparkle 2.9.5 appcast generation against an isolated DMG.
- Files touched: no additional product files beyond the final diagnostics and smoke-test updates
- Checks run: Release Xcode build, `scripts/smoke-check.sh`, plist lint, package/framework version inspection, codesign verification, Computer Use launch/filter inspection, process check for `sfltool`, live background appcast check, YAML parse, extracted shell syntax check, `git diff --check`, isolated `generate_appcast`
- Output: no authorization dialog and no `sfltool` process; 26 unique login apps remained visible; Sparkle 2.9.5 loaded and checked the signed GitHub feed; the workflow now fails on missing signatures, wrong download URLs, malformed XML, version/tag mismatch, or an EdDSA key mismatch warning
- Blockers: no implementation blocker; publication remains intentionally unperformed because no commit/push/tag was requested
- Next: hand off the refreshed preview app and branch state

## Entry 2026-08-15 22-18-00 KST

- Action: designated the accumulated feature release as 3.0.0 build 18 and ran the full non-destructive release validation requested by the operator.
- Files touched: Xcode version settings, changelog, status, current worklog
- Checks run: fresh Release app and CLI builds, smoke typecheck, moderate/aggressive JSON dry-runs, Beeper policy split, execute-without-confirmation refusal, isolated KeepAlive LaunchAgent bootout, ad-hoc bundle signing verification, permission-process inspection, release-like DMG creation, Sparkle 2.9.5 `generate_appcast`, tag/version guard, YAML parse, extracted shell syntax, diff whitespace check
- Output: app bundle reported 3.0.0/18; moderate and aggressive dry-runs sent no signals; Beeper was absent from moderate and present in aggressive; the isolated agent unloaded and stayed gone; appcast inferred version 18, short version 3.0.0, and the v3.0.0 GitHub asset URL
- Blockers: Computer Use could not re-inspect the final 3.0.0 window after the Mac locked; the same UI code was inspected immediately before the version-only change, and the final app launched without `sfltool`
- Next: commit, push, merge through CI, tag v3.0.0, and verify the public GitHub Release assets and appcast
