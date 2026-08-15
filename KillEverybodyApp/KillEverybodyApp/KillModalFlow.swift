import AppKit
import SwiftUI

/// 앱 전역 설정 저장소(한 인스턴스).
enum KillEverybodySession {
    static let settings = SettingsStore()
}

/// 메인 창 없이 투명 윈도우에 `NSAlert`를 띄워 킬 플로를 돌립니다.
final class KillModalFlow: NSObject, NSWindowDelegate {
    static let shared = KillModalFlow()

    private var settings: SettingsStore!
    private var settingsWindow: NSWindow?

    private struct KillResultSummary {
        let attemptedCount: Int
        let failureDetails: [(pid: Int32, reason: String)]
        let agentFailureDetails: [LaunchAgentSuppressor.Failure]

        var successCount: Int { attemptedCount - failureDetails.count }
        var failedPIDs: [pid_t] { failureDetails.map(\.pid) }
        var needsAdminRetry: Bool { !failureDetails.isEmpty }
        var hasFailures: Bool { !failureDetails.isEmpty || !agentFailureDetails.isEmpty }
    }

    func attachAndStart(settings: SettingsStore) {
        self.settings = settings
        DispatchQueue.main.async { self.showMainPrompt() }
    }

    private func showMainPrompt() {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "다 죽일까요?"
        alert.informativeText = ""
        alert.alertStyle = .warning
        alert.icon = NSApp.applicationIconImage
        
        let killAllBtn = alert.addButton(withTitle: "다죽이기")
        killAllBtn.hasDestructiveAction = true
        
        alert.addButton(withTitle: "적당히 죽이기")
        
        let cancelBtn = alert.addButton(withTitle: "종료")
        cancelBtn.keyEquivalent = "\u{1b}" // ESC 키를 종료에 할당
        alert.addButton(withTitle: "예외 앱…")

        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            startKill(aggressive: true)
        case .alertSecondButtonReturn:
            startKill(aggressive: false)
        case .alertThirdButtonReturn:
            NSApp.terminate(nil)
        case NSApplication.ModalResponse(
            rawValue: NSApplication.ModalResponse.alertFirstButtonReturn.rawValue + 3
        ):
            showSettingsWindow()
        default:
            showMainPrompt()
        }
    }

    private func startKill(aggressive: Bool) {
        let protected = settings.protectedBundleIDs()
        DispatchQueue.global(qos: .userInitiated).async {
            let list = ProcessEnumerator.collectUserKillCandidates(
                aggressive: aggressive,
                protectedBundleIDs: protected
            )
            DispatchQueue.main.async {
                self.presentAfterEnumerate(list: list)
            }
        }
    }

    private func presentAfterEnumerate(list: [KillCandidate]) {
        NSApp.activate(ignoringOtherApps: true)

        if list.isEmpty {
            NSApp.terminate(nil)
            return
        }

        let pids = list.map(\.pid)
        let bundleIDs = Set(list.compactMap(\.bundleID))
        DispatchQueue.global(qos: .userInitiated).async {
            let agentFailures = LaunchAgentSuppressor.bootout(bundleIDs: bundleIDs)
            let summary = KillResultSummary(
                attemptedCount: pids.count,
                failureDetails: KillExecutor.killLocally(pids: pids),
                agentFailureDetails: agentFailures
            )
            DispatchQueue.main.async {
                self.showKillResult(summary: summary)
            }
        }
    }

    private func showKillResult(summary: KillResultSummary) {
        NSApp.activate(ignoringOtherApps: true)

        guard summary.hasFailures else {
            NSApp.terminate(nil)
            return
        }

        let processMessage = summary.failureDetails.prefix(5)
            .map { "\($0.0): \($0.1)" }
            .joined(separator: "; ")
        let agentMessage = summary.agentFailureDetails.prefix(3)
            .map { "\($0.label): \($0.reason)" }
            .joined(separator: "; ")
        let details = [processMessage, agentMessage].filter { !$0.isEmpty }.joined(separator: "\n")

        let alert = NSAlert()
        alert.messageText = "일부 앱이 남았어요"
        alert.informativeText = "\(summary.successCount)개 성공, \(summary.failureDetails.count)개 종료 실패, \(summary.agentFailureDetails.count)개 자동 실행 해제 실패.\n\(details)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "확인")
        if summary.needsAdminRetry {
            let retry = alert.addButton(withTitle: "관리자 권한으로 재시도")
            retry.hasDestructiveAction = true
        }

        let response = alert.runModal()
        if summary.needsAdminRetry, response == .alertSecondButtonReturn {
            retryFailedKillsWithAdmin(summary: summary)
            return
        }
        NSApp.terminate(nil)
    }

    private func retryFailedKillsWithAdmin(summary: KillResultSummary) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try KillExecutor.killWithAdmin(pids: summary.failedPIDs)
                DispatchQueue.main.async {
                    self.showAdminRetryResult(error: nil, retriedCount: summary.failedPIDs.count)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAdminRetryResult(error: error, retriedCount: summary.failedPIDs.count)
                }
            }
        }
    }

    private func showAdminRetryResult(error: Error?, retriedCount: Int) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        if let error {
            alert.messageText = "관리자 재시도 실패"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
        } else {
            alert.messageText = "관리자 권한으로 다시 보냈어요"
            alert.informativeText = "\(retriedCount)개 프로세스에 추가 종료 요청을 보냈습니다."
            alert.alertStyle = .informational
        }
        alert.addButton(withTitle: "확인")
        _ = alert.runModal()
        NSApp.terminate(nil)
    }

    private func showSettingsWindow() {
        if let settingsWindow {
            settingsWindow.makeKeyAndOrderFront(nil)
            return
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 680, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "예외 앱"
        window.minSize = NSSize(width: 560, height: 460)
        window.contentView = NSHostingView(
            rootView: SettingsRootView().environmentObject(settings)
        )
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)
        settingsWindow = window
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        DispatchQueue.main.async { self.showMainPrompt() }
        return false
    }
}
