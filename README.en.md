<div align="center">

<img src="docs/readme-app-icon.png" width="220" alt="killeverybody app icon" />

# killeverybody

### Clear out running Mac apps and their child processes in one go.

[한국어](README.md) | **English** | [日本語](README.ja.md)

This document covers **v3.0.0**.

Inspired by kippler’s Windows utility [AllKill](http://kippler.com/allkill/) (*다죽여*).

</div>

---

## Read this first

> **Warning:** This app sends `SIGKILL` to target processes. Any unsaved work in those apps may be lost.

**다죽이기 (Kill Everything)** and **적당히 죽이기 (Kill Moderately)** start immediately, without another confirmation. That behavior is intentional. Try the `killeverybody-cli` dry run included in the DMG first.

```bash
/Volumes/killeverybody/killeverybody-cli --dry-run
```

## Features

| Feature | What it does |
| --- | --- |
| **다죽이기 (Kill Everything)** | Kills running apps and their child processes. Only the fixed system denylist and killeverybody itself are spared; saved exemptions do not apply. |
| **적당히 죽이기 (Kill Moderately)** | Uses the same scope, but skips apps you exempted, apps treated as menu-bar utilities, built-in presets, and `LSUIElement` apps. |
| **예외 앱… (Exempt Apps…)** | Shows apps with their icons and lets you search by name, bundle ID, or path. Filters cover `전체 앱` (all), `실행 중` (running), and `로그인 시 실행` (open at login). |
| **Relaunch suppression** | Unloads matching third-party LaunchAgents for the current login session. They can load normally again after the next login. |
| **Automatic updates** | Sparkle checks GitHub Releases and automatically downloads and installs an update when possible. |

When every kill succeeds, killeverybody quits cleanly without showing a result dialog. If something fails, it shows the result and offers an administrator retry when relevant.

## Install and update

Requires **macOS 13 Ventura or later**.

1. Download `KillEverybody-macOS.dmg` from the [latest release](https://github.com/devuterian/killeverybody/releases/latest).
2. Open the DMG and move `killeverybody.app` to **Applications**.
3. Launch the app.

The current GitHub Actions build is **not Apple Developer ID signed or notarized**. If macOS blocks it, use **Right-click → Open** once, or allow it under **System Settings → Privacy & Security**.

Sparkle checks for a new version in the background when the app starts. Use **업데이트 확인… (Check for Updates…)** from the app menu to check manually, or **최신 릴리즈 열기… (Open Latest Release…)** to download it in a browser. Sparkle verifies update DMGs with an EdDSA signature.

## How to use it

1. Launching the app opens a native macOS-style **“다 죽일까요? (Kill everybody?)”** alert.
2. Choose **다죽이기 (Kill Everything)** when you really want to clear out everything in scope.
3. To keep selected apps alive, check them under **예외 앱… (Exempt Apps…)**, then choose **적당히 죽이기 (Kill Moderately)**.
4. Choose **종료 (Quit)**, or press `Esc`, to close only killeverybody.

### Apps that survive 적당히 죽이기

Choose **예외 앱… (Exempt Apps…)** to open a separate settings window.

- Installed and running apps appear with their icons.
- Search by app name, bundle ID, or path.
- On the first launch only, macOS login apps are checked as initial exemptions. Reading that list does not ask for an administrator password.
- Checkbox changes are saved immediately.
- Under **고급 (Advanced)**, you can enter a bundle ID directly or mark a bundle as a menu-bar-style app.
- Export the current exemption and menu-bar policy as JSON, or import it later.

## CLI and dry runs

`killeverybody-cli` in the DMG defaults to a dry run. It prints candidates and sends no signals.

```bash
# Kill Moderately candidates
/Volumes/killeverybody/killeverybody-cli --dry-run

# Kill Everything candidates
/Volumes/killeverybody/killeverybody-cli --aggressive --dry-run

# JSON output
/Volumes/killeverybody/killeverybody-cli --dry-run --json

# Apply policy JSON exported by the app
/Volumes/killeverybody/killeverybody-cli --policy ./killeverybody-policy.json --dry-run
```

The CLI does not read the app’s saved settings automatically. Export a policy JSON from the app and pass it with `--policy` to use the same exemptions. An actual kill requires both `--execute` and `--yes`.

## Scope and limitations

- Targets are **running apps owned by the current user and their child processes**. It does not kill every shell or background process merely because it has the same UID.
- Core system processes and killeverybody itself are excluded by a fixed denylist.
- App helpers are grouped under their outermost app bundle when exemptions are evaluated.
- Relaunch suppression only unloads matching third-party entries found in `~/Library/LaunchAgents` and `/Library/LaunchAgents` for the current GUI session. It does not edit plists or login items.
- Menu-bar app detection uses public-API heuristics and is not perfect.
- Apps managed directly by macOS, such as Finder, may launch again.
- This tool does not guarantee data preservation or system stability. Save important work first.

## Build

Open `KillEverybodyApp/KillEverybodyApp.xcodeproj` in Xcode and run the **KillEverybodyApp** scheme. To build from the command line:

```bash
cd KillEverybodyApp
xcodebuild -scheme KillEverybodyApp -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

Build the CLI with the **KillEverybodyCLI** scheme. See [`docs/build.md`](docs/build.md) for more details.

## Source and contributing

- Repository: [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)
- Contributing and Sparkle setup: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Manual smoke test: [`docs/smoke-test.md`](docs/smoke-test.md)
- Behavior spec: [`SPEC.md`](SPEC.md)
- Bugs and questions: [Issues](https://github.com/devuterian/killeverybody/issues)

## License

[MIT License](LICENSE). This is a high-risk utility, so please read the disclaimer too.

---

<div align="center">

The repository workflow and documentation structure are based on [LPFchan/repo-template](https://github.com/LPFchan/repo-template).<br>
Thanks for making the template public.

</div>
