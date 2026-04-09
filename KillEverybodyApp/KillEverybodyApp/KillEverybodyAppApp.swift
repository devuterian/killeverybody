import AppKit
import SwiftUI

private let releasesURLString = "https://github.com/devuterian/killeverybody/releases"

@main
struct KillEverybodyAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
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
