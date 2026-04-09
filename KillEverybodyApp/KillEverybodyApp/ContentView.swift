import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// 메뉴에서 설정 시트를 열기 위한 상태(⌘, 포함).
final class MainWindowState: ObservableObject {
    @Published var showSettings = false
}

struct ContentView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var mainWindow: MainWindowState

    @State private var isWorking = false
    @State private var statusMessage: String?
    @State private var pendingCandidates: [KillCandidate] = []
    @State private var showCountConfirm = false

    @State private var newExemptID = ""
    @State private var newMenubarID = ""
    @State private var policyAlertTitle = ""
    @State private var policyAlertMessage = ""
    @State private var showPolicyAlert = false
    @State private var pendingImportDoc: PolicyDocument?
    @State private var showImportConfirm = false

    private let yellowKill = Color(red: 0.92, green: 0.74, blue: 0.12)

    var body: some View {
        VStack(spacing: 20) {
            Text("다 죽일까요?")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Text("시스템에 꼭 필요한 프로세스(denylist)는 빼요. 저장 안 한 작업은 날아갈 수 있어요.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Button {
                    startKill(aggressive: true)
                } label: {
                    Text("다죽이기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
                .disabled(isWorking)

                Text("시스템 필수만 빼고, 메뉴 막대·에이전트·설정 예외는 적용하지 않아요.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    startKill(aggressive: false)
                } label: {
                    Text("적당히 죽이기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(yellowKill)
                .foregroundStyle(.black)
                .controlSize(.large)
                .disabled(isWorking)

                Text("메뉴 막대·예외 번들·LSUIElement 등 기존 보호를 유지해요.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("종료") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut(.cancelAction)
                .padding(.top, 4)
            }
            .frame(maxWidth: 280)
            .padding(.bottom, 12)
        }
        .frame(minWidth: 320, maxWidth: 400)
        .padding(24)
        .sheet(isPresented: Binding(
            get: { mainWindow.showSettings },
            set: { mainWindow.showSettings = $0 }
        )) {
            settingsSheet
        }
        .alert("정말 종료할까요?", isPresented: $showCountConfirm) {
            Button("취소", role: .cancel) {
                pendingCandidates = []
            }
            Button("kill -9 실행", role: .destructive) {
                performKill()
            }
        } message: {
            Text("\(pendingCandidates.count)개 프로세스에 SIGKILL을 보냅니다. 저장되지 않은 작업은 사라질 수 있습니다.")
        }
        .alert(policyAlertTitle, isPresented: $showPolicyAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(policyAlertMessage)
        }
        .alert("정책을 덮어쓸까요?", isPresented: $showImportConfirm) {
            Button("취소", role: .cancel) {
                pendingImportDoc = nil
            }
            Button("덮어쓰기", role: .destructive) {
                if let doc = pendingImportDoc {
                    settings.applyImportedPolicy(doc)
                    pendingImportDoc = nil
                    policyAlertTitle = "가져오기 완료"
                    policyAlertMessage = "예외·메뉴 막대 번들 목록을 바꿨어요."
                    showPolicyAlert = true
                }
            }
        } message: {
            Text("지금 목록이 JSON 파일 내용으로 바뀝니다.")
        }
    }

    private var settingsSheet: some View {
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { mainWindow.showSettings = false }
                }
            }
        }
        .frame(minWidth: 440, minHeight: 560)
    }

    private func startKill(aggressive: Bool) {
        isWorking = true
        statusMessage = nil
        let protected = settings.protectedBundleIDs()
        DispatchQueue.global(qos: .userInitiated).async {
            let list = ProcessEnumerator.collectUserKillCandidates(
                aggressive: aggressive,
                protectedBundleIDs: protected
            )
            DispatchQueue.main.async {
                isWorking = false
                if list.isEmpty {
                    statusMessage = "지금은 종료할 프로세스가 없어요."
                    return
                }
                pendingCandidates = list
                showCountConfirm = true
            }
        }
    }

    private func performKill() {
        let pids = pendingCandidates.map(\.pid)
        pendingCandidates = []
        guard !pids.isEmpty else { return }

        isWorking = true
        statusMessage = nil

        DispatchQueue.global(qos: .userInitiated).async {
            let fails = KillExecutor.killLocally(pids: pids)
            let msg: String
            if fails.isEmpty {
                msg = "SIGKILL 전송 완료"
            } else {
                msg = "일부 실패: " + fails.prefix(5).map { "\($0.0): \($0.1)" }.joined(separator: "; ")
            }
            DispatchQueue.main.async {
                isWorking = false
                statusMessage = msg
            }
        }
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
                    policyAlertTitle = "저장했어요"
                    policyAlertMessage = url.path
                    showPolicyAlert = true
                } catch {
                    policyAlertTitle = "저장 실패"
                    policyAlertMessage = error.localizedDescription
                    showPolicyAlert = true
                }
            }
        } catch {
            policyAlertTitle = "보내기 실패"
            policyAlertMessage = error.localizedDescription
            showPolicyAlert = true
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
                    policyAlertTitle = "버전이 더 새 파일이에요"
                    policyAlertMessage = "이 앱이 모르는 formatVersion입니다. 앱을 업데이트한 뒤 다시 시도해 주세요."
                    showPolicyAlert = true
                    return
                }
                pendingImportDoc = doc
                showImportConfirm = true
            } catch {
                policyAlertTitle = "읽기 실패"
                policyAlertMessage = error.localizedDescription
                showPolicyAlert = true
            }
        }
    }
}
