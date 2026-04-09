import AppKit
import SwiftUI

private let releasesURLString = "https://github.com/devuterian/killeverybody/releases"

@main
struct KillEverybodyAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // macOS 13 이상에서 Settings 씬이 기본적으로 열리는 것을 방지하기 위해 사용
        // AppDelegate의 applicationDidFinishLaunching에서 필요한 메인 UI를 띄웁니다.
        Settings {
            SettingsRootView()
                .environmentObject(KillEverybodySession.settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appInfo) {
                Button("업데이트 확인…") {
                    appDelegate.checkForUpdates()
                }
                Button("최신 릴리즈 열기…") {
                    if let url = URL(string: releasesURLString) {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
}
