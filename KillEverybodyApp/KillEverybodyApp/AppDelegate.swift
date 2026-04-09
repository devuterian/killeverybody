import AppKit
import Carbon
import OSLog
import Sparkle

/// Sparkle 업데이터. `applicationDidFinishLaunching` 이후에 기동해 XPC/헬퍼 준비 타이밍을 맞춥니다.
final class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
    private var updaterController: SPUStandardUpdaterController?
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "killeverybody", category: "Sparkle")
    /// `kAEOpenApplication`은 첫 실행에도 올 수 있어, 두 번째부터를 「다시 실행」으로 본다.
    private var openApplicationEventCount = 0

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleOpenApplicationEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kCoreEventClass),
            andEventID: AEEventID(kAEOpenApplication)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if let key = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String, !key.isEmpty {
            log.info("Sparkle SUPublicEDKey present (length \(key.count))")
        } else {
            log.error("Sparkle SUPublicEDKey missing or empty — EdDSA updates will fail. Rebuild with INFOPLIST_KEY_SUPublicEDKey set.")
        }
        if let feed = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String, !feed.isEmpty {
            log.info("Sparkle SUFeedURL: \(feed, privacy: .public)")
        }

        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )

        KillModalFlow.shared.attachAndStart(settings: KillEverybodySession.settings)
    }

    /// Dock 아이콘 클릭 등 → 업데이트 확인.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        checkForUpdates()
        NSApp.activate(ignoringOtherApps: true)
        return true
    }

    @objc private func handleOpenApplicationEvent(_ event: NSAppleEventDescriptor?, withReplyEvent: NSAppleEventDescriptor?) {
        openApplicationEventCount += 1
        guard openApplicationEventCount > 1 else { return }
        DispatchQueue.main.async { [weak self] in
            self?.checkForUpdates()
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }

    // MARK: - SPUUpdaterDelegate (Console / log stream 진단용)

    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        log.error("didAbortWithError: \(error.localizedDescription, privacy: .public)")
    }

    func updater(_ updater: SPUUpdater, didFinishUpdateCycleFor updateCheck: SPUUpdateCheck, error: Error?) {
        if let error {
            log.error("didFinishUpdateCycleFor error: \(error.localizedDescription, privacy: .public)")
        }
    }
}
