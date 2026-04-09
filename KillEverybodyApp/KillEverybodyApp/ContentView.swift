import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var settings: SettingsStore

    @State private var scope: KillScope = .guiOnly
    @State private var candidates: [KillCandidate] = []
    @State private var isWorking = false
    @State private var statusMessage: String?
    @State private var showKillConfirm = false
    @State private var showSettings = false
    @State private var newExemptID = ""
    @State private var newMenubarID = ""
    @State private var policyAlertTitle = ""
    @State private var policyAlertMessage = ""
    @State private var showPolicyAlert = false
    @State private var pendingImportDoc: PolicyDocument?
    @State private var showImportConfirm = false

    var body: some View {
        NavigationSplitView {
            Form {
                Section {
                    Text(
                        "메뉴 막대·에이전트·보호 번들(예외·직접 지정·앱에 넣어 둔 프리셋)과 시스템 denylist는 빼고, 미리본 뒤에만 강제 종료합니다."
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }

                Section("범위") {
                    Picker("종료 범위", selection: $scope) {
                        ForEach(KillScope.allCases) { s in
                            Text(s.title).tag(s)
                        }
                    }
                    .pickerStyle(.inline)
                    Text(scope.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        refreshCandidates()
                    } label: {
                        Label("대상 수집", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .disabled(isWorking)

                    if scope.usesAdminShell {
                        Label("관리자 모드는 암호 입력 창이 뜹니다.", systemImage: "exclamationmark.shield")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                if let statusMessage {
                    Section {
                        Text(statusMessage)
                            .font(.caption)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("killeverybody")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("설정", systemImage: "gearshape")
                    }
                }
            }
        } detail: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("종료 대상 (\(candidates.count)개)")
                        .font(.headline)
                    Spacer()
                    Button("강제 종료 실행") {
                        showKillConfirm = true
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(candidates.isEmpty || isWorking)
                }
                .padding([.horizontal, .top])

                if candidates.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("대상 없음")
                            .font(.headline)
                        Text("범위를 고른 뒤 「대상 수집」을 누르세요.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    Table(candidates) {
                        TableColumn("PID") { row in
                            Text("\(row.pid)")
                                .monospacedDigit()
                        }
                        .width(min: 56, ideal: 64)
                        TableColumn("이름") { row in
                            Text(row.name)
                        }
                        .width(min: 120, ideal: 180)
                        TableColumn("경로 / 번들") { row in
                            VStack(alignment: .leading, spacing: 2) {
                                if let p = row.path {
                                    Text(p)
                                        .font(.caption)
                                        .lineLimit(2)
                                        .textSelection(.enabled)
                                }
                                if let b = row.bundleID {
                                    Text(b)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .textSelection(.enabled)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: 720, minHeight: 480)
        .sheet(isPresented: $showSettings) {
            settingsSheet
        }
        .alert("정말 강제 종료할까요?", isPresented: $showKillConfirm) {
            Button("취소", role: .cancel) {}
            Button("kill -9 실행", role: .destructive) {
                performKill()
            }
        } message: {
            Text("\(candidates.count)개 프로세스에 SIGKILL을 보냅니다. 저장되지 않은 작업은 사라질 수 있습니다.")
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
                    Button("닫기") { showSettings = false }
                }
            }
        }
        .frame(minWidth: 440, minHeight: 560)
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

    private func refreshCandidates() {
        isWorking = true
        statusMessage = nil
        let protected = settings.protectedBundleIDs()
        let currentScope = scope
        DispatchQueue.global(qos: .userInitiated).async {
            let list = ProcessEnumerator.collectCandidates(scope: currentScope, protectedBundleIDs: protected)
            DispatchQueue.main.async {
                candidates = list
                isWorking = false
                statusMessage = "수집 완료: \(list.count)개"
            }
        }
    }

    private func performKill() {
        let pids = candidates.map(\.pid)
        guard !pids.isEmpty else { return }
        isWorking = true
        statusMessage = nil

        if scope.usesAdminShell {
            Task { @MainActor in
                defer {
                    isWorking = false
                    refreshCandidates()
                }
                do {
                    try KillExecutor.killWithAdmin(pids: pids)
                    statusMessage = "관리자 kill 완료"
                } catch {
                    statusMessage = error.localizedDescription
                }
            }
            return
        }

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
                refreshCandidates()
            }
        }
    }
}
