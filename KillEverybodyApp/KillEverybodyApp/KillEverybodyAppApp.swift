import AppKit
import SwiftUI

private let releasesURLString = "https://github.com/devuterian/killeverybody/releases"

@main
struct KillEverybodyAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = SettingsStore()
    @StateObject private var mainWindow = MainWindowState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(mainWindow)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appSettings) {
                Button("설정…") {
                    mainWindow.showSettings = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }
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
