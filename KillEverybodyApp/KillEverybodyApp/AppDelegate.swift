import AppKit
import Sparkle

/// Sparkle 업데이터(주기적 확인·다운로드). 메뉴의 「업데이트 확인…」에서 사용합니다.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private(set) lazy var updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
