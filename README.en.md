<div align="center">
  <img src="docs/readme-app-icon.png" width="256" height="256" alt="killeverybody app icon" />
</div>

<div align="center">

# killeverybody <br>

[한국어](README.md) | [English](README.en.md) | [日本語](README.ja.md)

A macOS utility that force-quits running processes with **SIGKILL**. It skips what the system actually needs, and you choose between **kill almost everything** and **kill with the usual safeguards**.

Inspired by kippler’s Windows utility **AllKill** (*다죽여*): [http://kippler.com/allkill/](http://kippler.com/allkill/)

</div>

---

## Install

1. Grab the latest DMG from **[Releases](https://github.com/devuterian/killeverybody/releases)** (`KillEverybody-macOS.dmg`).
2. Open the disk image and drag **killeverybody.app** into **Applications**.
3. Launch the app.

**Gatekeeper:** This build is produced in CI and may be **unsigned / not notarized**. If macOS blocks it, use **Right-click → Open** once, or allow it under **System Settings → Privacy & Security**.

**Updates:** Use **killeverybody → Check for Updates…** (Sparkle). To grab a build by hand, use **Open Latest Release…** from the same menu.

---

## How it works

1. The window asks **whether you really want to wipe things out** (wording may vary by language; the Korean build uses a short, direct question).
2. **Kill (aggressive)** — Kills your login session’s processes except a **hardcoded system denylist**. It does **not** honor your exempt bundles, menu-bar presets, or LSUIElement-style skips.
3. **Kill (moderate)** — Same idea, but keeps the **normal protections**: denylist, bundles you exempt in Settings, menu-bar-style bundles, LSUIElement heuristics, and built-in presets.
4. You get a **confirmation** with a process count before anything is killed. Unsaved work can vanish.
5. **Quit** just exits the app.

Open **Settings…** from the **killeverybody** menu (⌘,) for exempt bundle IDs, menu-bar-style bundles, and policy JSON import/export.

---

## Limitations

- Menu-bar apps aren’t classified perfectly. **Moderate** mode is there to reduce collateral damage; **aggressive** is not subtle.
- This tool does **not** promise a stable or safe system.

---

## Source & contributing

Repo: [github.com/devuterian/killeverybody](https://github.com/devuterian/killeverybody)

- Build notes: [`docs/build.md`](docs/build.md)
- Contributing & Sparkle signing: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Smoke checklist: [`docs/smoke-test.md`](docs/smoke-test.md)
- Behavior summary: [`SPEC.md`](SPEC.md)

Issues: [github.com/devuterian/killeverybody/issues](https://github.com/devuterian/killeverybody/issues)

---

## License

[MIT License](LICENSE). Read the full text; this is a high-risk tool and the disclaimer matters.

---

<div align="center">

The repo layout and operating docs are based on [LPFchan/repo-template](https://github.com/LPFchan/repo-template).<br>
Thanks for open-sourcing the template.

</div>
