import AppKit
import OSLog
import Sparkle

/// Sparkle 업데이터. `applicationDidFinishLaunching` 이후에 기동해 XPC/헬퍼 준비 타이밍을 맞춥니다.
final class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
    private var updaterController: SPUStandardUpdaterController?
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "killeverybody", category: "Sparkle")

    func applicationDidFinishLaunching(_ notification: Notification) {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
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
