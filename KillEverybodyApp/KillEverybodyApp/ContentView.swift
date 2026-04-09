import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// 시스템 「설정…」(⌘,) 창 전용. 메인 킬 UI는 `KillModalFlow`의 `NSAlert`만 사용합니다.
struct SettingsRootView: View {
    @EnvironmentObject private var settings: SettingsStore

    @State private var newExemptID = ""
    @State private var newMenubarID = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("예외 번들 ID") {
                    Text("종료 목록에 넣지 않을 앱.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("번들 ID (예: com.apple.Safari)", text: $newExemptID)
                    Button("추가") {
                        settings.addExempt(newExemptID)
                        newExemptID = ""
                    }
                    .disabled(newExemptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if settings.exemptBundleIDs.isEmpty {
                        Text("비어 있음")
                            .foregroundStyle(.secondary)
                    } else {
                        List {
                            ForEach(settings.exemptBundleIDs, id: \.self) { id in
                                Text(id)
                                    .textSelection(.enabled)
                            }
                            .onDelete(perform: settings.removeExempt)
                        }
                        .frame(minHeight: 100)
                    }
                }

                Section("메뉴 막대로 취급할 번들") {
                    Text("LSUIElement가 아니어도 메뉴 막대 앱처럼 빼고 싶을 때.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("번들 ID", text: $newMenubarID)
                    Button("추가") {
                        settings.addMenubarStyle(newMenubarID)
                        newMenubarID = ""
                    }
                    .disabled(newMenubarID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if settings.menubarStyleBundleIDs.isEmpty {
                        Text("비어 있음 (앱에 넣어 둔 프리셋은 그대로 적용됨)")
                            .foregroundStyle(.secondary)
                    } else {
                        List {
                            ForEach(settings.menubarStyleBundleIDs, id: \.self) { id in
                                Text(id)
                                    .textSelection(.enabled)
                            }
                            .onDelete(perform: settings.removeMenubarStyle)
                        }
                        .frame(minHeight: 100)
                    }
                }

                Section("정책 파일 (JSON)") {
                    Button("정책 보내기…") {
                        exportPolicyFile()
                    }
                    Button("정책 가져오기…") {
                        importPolicyFile()
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("설정")
        }
        .frame(minWidth: 440, minHeight: 560)
    }

    private func showPolicyAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "확인")
        alert.runModal()
    }

    private func exportPolicyFile() {
        do {
            let data = try settings.exportPolicyData()
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.nameFieldStringValue = "killeverybody-policy.json"
            panel.begin { response in
                guard response == .OK, let url = panel.url else { return }
                do {
                    try data.write(to: url, options: .atomic)
                    showPolicyAlert(title: "저장했어요", message: url.path)
                } catch {
                    showPolicyAlert(title: "저장 실패", message: error.localizedDescription)
                }
            }
        } catch {
            showPolicyAlert(title: "보내기 실패", message: error.localizedDescription)
        }
    }

    private func importPolicyFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                let data = try Data(contentsOf: url)
                let doc = try PolicyDocument.decodeDocument(from: data)
                if doc.formatVersion > PolicyDocument.currentFormatVersion {
                    showPolicyAlert(
                        title: "버전이 더 새 파일이에요",
                        message: "이 앱이 모르는 formatVersion입니다. 앱을 업데이트한 뒤 다시 시도해 주세요."
                    )
                    return
                }
                let confirm = NSAlert()
                confirm.messageText = "정책을 덮어쓸까요?"
                confirm.informativeText = "지금 목록이 JSON 파일 내용으로 바뀝니다."
                confirm.alertStyle = .warning
                confirm.addButton(withTitle: "취소")
                confirm.addButton(withTitle: "덮어쓰기")
                if confirm.runModal() == .alertSecondButtonReturn {
                    settings.applyImportedPolicy(doc)
                    showPolicyAlert(title: "가져오기 완료", message: "예외·메뉴 막대 번들 목록을 바꿨어요.")
                }
            } catch {
                showPolicyAlert(title: "읽기 실패", message: error.localizedDescription)
            }
        }
    }
}
