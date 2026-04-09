import AppKit
import SwiftUI

private let releasesURLString = "https://github.com/devuterian/killeverybody/releases"

@main
struct KillEverybodyAppApp: App {
    @StateObject private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appInfo) {
                Button("최신 릴리즈 열기…") {
                    if let url = URL(string: releasesURLString) {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
}
