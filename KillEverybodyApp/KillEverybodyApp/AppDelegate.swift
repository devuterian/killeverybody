import AppKit
import Sparkle

/// Sparkle 업데이터. `applicationDidFinishLaunching` 이후에 기동해 XPC/헬퍼 준비 타이밍을 맞춥니다.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var updaterController: SPUStandardUpdaterController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }
}
