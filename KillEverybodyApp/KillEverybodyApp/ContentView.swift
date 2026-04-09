import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: SettingsStore

    @State private var scope: KillScope = .guiOnly
    @State private var candidates: [KillCandidate] = []
    @State private var isWorking = false
    @State private var statusMessage: String?
    @State private var showKillConfirm = false
    @State private var showSettings = false
    @State private var newExemptID = ""

    var body: some View {
        NavigationSplitView {
            Form {
                Section {
                    Text(
                        "메뉴바·에이전트로 간주되는 앱(LSUIElement)과 시스템 denylist, 사용자 예외 번들은 종료하지 않습니다. 미리보기 후에만 실행됩니다."
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
            .navigationTitle("KillEverybody")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("예외 번들", systemImage: "gearshape")
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
            exemptSheet
        }
        .alert("정말 강제 종료할까요?", isPresented: $showKillConfirm) {
            Button("취소", role: .cancel) {}
            Button("kill -9 실행", role: .destructive) {
                performKill()
            }
        } message: {
            Text("\(candidates.count)개 프로세스에 SIGKILL을 보냅니다. 저장되지 않은 작업은 사라질 수 있습니다.")
        }
    }

    private var exemptSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("번들 ID (예: com.apple.Safari)", text: $newExemptID)
                    Button("추가") {
                        settings.addExempt(newExemptID)
                        newExemptID = ""
                    }
                    .disabled(newExemptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                Section("예외 목록") {
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
                        .frame(minHeight: 140)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("예외 번들 ID")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { showSettings = false }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 320)
    }

    private func refreshCandidates() {
        isWorking = true
        statusMessage = nil
        let exempt = Set(settings.exemptBundleIDs)
        let currentScope = scope
        DispatchQueue.global(qos: .userInitiated).async {
            let list = ProcessEnumerator.collectCandidates(scope: currentScope, exemptBundleIDs: exempt)
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
