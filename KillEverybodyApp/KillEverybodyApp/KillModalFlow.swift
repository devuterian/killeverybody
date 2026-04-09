import AppKit

/// 앱 전역 설정 저장소(한 인스턴스).
enum KillEverybodySession {
    static let settings = SettingsStore()
}

/// 메인 창 없이 `NSAlert.runModal()`만으로 킬 플로를 돌립니다.
final class KillModalFlow {
    static let shared = KillModalFlow()

    private var settings: SettingsStore!

    func attachAndStart(settings: SettingsStore) {
        self.settings = settings
        DispatchQueue.main.async { self.showMainPrompt() }
    }

    private func showMainPrompt() {
        let alert = NSAlert()
        alert.messageText = "다 죽일까요?"
        alert.informativeText = "강한 종료는 더 많은 앱이 대상이 될 수 있어요."
        alert.alertStyle = .warning
        alert.icon = NSApp.applicationIconImage
        alert.addButton(withTitle: "다죽이기")
        alert.addButton(withTitle: "적당히 죽이기")
        alert.addButton(withTitle: "종료")

        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            startKill(aggressive: true)
        case .alertSecondButtonReturn:
            startKill(aggressive: false)
        case .alertThirdButtonReturn:
            NSApp.terminate(nil)
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
        if list.isEmpty {
            let alert = NSAlert()
            alert.messageText = "알림"
            alert.informativeText = "지금은 종료할 프로세스가 없어요."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "확인")
            alert.runModal()
            showMainPrompt()
            return
        }

        let confirm = NSAlert()
        confirm.messageText = "정말 종료할까요?"
        confirm.informativeText =
            "\(list.count)개 프로세스에 SIGKILL을 보냅니다. 저장되지 않은 작업은 사라질 수 있습니다."
        confirm.alertStyle = .warning
        confirm.addButton(withTitle: "취소")
        confirm.addButton(withTitle: "kill -9 실행")

        let r = confirm.runModal()
        if r == .alertFirstButtonReturn {
            showMainPrompt()
            return
        }

        let pids = list.map(\.pid)
        DispatchQueue.global(qos: .userInitiated).async {
            let fails = KillExecutor.killLocally(pids: pids)
            DispatchQueue.main.async {
                if !fails.isEmpty {
                    let msg = fails.prefix(5).map { "\($0.0): \($0.1)" }.joined(separator: "; ")
                    let failAlert = NSAlert()
                    failAlert.messageText = "일부 실패"
                    failAlert.informativeText = msg
                    failAlert.alertStyle = .warning
                    failAlert.addButton(withTitle: "확인")
                    failAlert.runModal()
                }
                self.showMainPrompt()
            }
        }
    }
}
