import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// 메뉴에서 설정 시트를 열기 위한 상태(⌘, 포함).
final class MainWindowState: ObservableObject {
    @Published var showSettings = false
}

/// SwiftUI 호스트에서 `NSWindow`를 잡아 시트형 `NSAlert`에 넘깁니다.
private struct WindowHostReader: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.isHidden = true
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            window = nsView.window
        }
    }
}

private struct MainPromptOnCloseObservers: ViewModifier {
    @Binding var showKillFailureAlert: Bool
    @Binding var showPolicyAlert: Bool
    @Binding var showImportConfirm: Bool
    @Binding var showSettings: Bool
    @Binding var isWorking: Bool
    let tryPresent: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: showKillFailureAlert) { open in
                if !open { tryPresent() }
            }
            .onChange(of: showPolicyAlert) { open in
                if !open { tryPresent() }
            }
            .onChange(of: showImportConfirm) { open in
                if !open { tryPresent() }
            }
            .onChange(of: showSettings) { open in
                if !open { tryPresent() }
            }
            .onChange(of: isWorking) { working in
                if !working { tryPresent() }
            }
    }
}

struct ContentView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var mainWindow: MainWindowState

    @State private var hostWindow: NSWindow?
    @State private var isMainAlertShowing = false

    @State private var isWorking = false
    @State private var pendingCandidates: [KillCandidate] = []
    @State private var showCountConfirm = false
    @State private var showNoTargetsAlert = false
    @State private var showKillFailureAlert = false
    @State private var killFailureMessage = ""

    @State private var newExemptID = ""
    @State private var newMenubarID = ""
    @State private var policyAlertTitle = ""
    @State private var policyAlertMessage = ""
    @State private var showPolicyAlert = false
    @State private var pendingImportDoc: PolicyDocument?
    @State private var showImportConfirm = false

    var body: some View {
        mainChromeSheetAndKillAlerts
    }

    private var mainChromeSheetAndKillAlerts: some View {
        mainChromeSheetAndEarlyAlerts
            .alert("알림", isPresented: $showNoTargetsAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("지금은 종료할 프로세스가 없어요.")
            }
            .alert("일부 실패", isPresented: $showKillFailureAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(killFailureMessage)
            }
    }

    private var mainChromeSheetAndEarlyAlerts: some View {
        mainChromeWithObservers
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

    private var mainChromeWithObservers: some View {
        mainChromeStack
            .frame(minWidth: 320, minHeight: 200)
            .onAppear { tryPresentMainKillAlert() }
            .onChange(of: hostWindow) { _ in tryPresentMainKillAlert() }
            .onChange(of: showCountConfirm) { open in
                if !open { tryPresentMainKillAlert() }
            }
            .onChange(of: showNoTargetsAlert) { open in
                if !open { tryPresentMainKillAlert() }
            }
            .modifier(MainPromptOnCloseObservers(
                showKillFailureAlert: $showKillFailureAlert,
                showPolicyAlert: $showPolicyAlert,
                showImportConfirm: $showImportConfirm,
                showSettings: Binding(
                    get: { mainWindow.showSettings },
                    set: { mainWindow.showSettings = $0 }
                ),
                isWorking: $isWorking,
                tryPresent: { tryPresentMainKillAlert() }
            ))
    }

    private var mainChromeStack: some View {
        ZStack {
            Color(nsColor: .underPageBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("killeverybody")
                    .font(.headline)
                Text("메뉴의 「설정…」에서 예외를 바꿀 수 있어요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            WindowHostReader(window: $hostWindow)
                .frame(width: 0, height: 0)
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

    private func tryPresentMainKillAlert() {
        guard let window = hostWindow else { return }
        guard !isMainAlertShowing, !isWorking else { return }
        guard !showCountConfirm, !showNoTargetsAlert, !showKillFailureAlert else { return }
        guard !showPolicyAlert, !showImportConfirm, !mainWindow.showSettings else { return }

        presentMainKillAlert(on: window)
    }

    private func presentMainKillAlert(on window: NSWindow) {
        guard !isMainAlertShowing else { return }
        isMainAlertShowing = true

        let alert = NSAlert()
        alert.messageText = "다 죽일까요?"
        alert.informativeText = "강한 종료는 더 많은 앱이 대상이 될 수 있어요."
        alert.alertStyle = .warning
        alert.icon = NSApp.applicationIconImage
        alert.addButton(withTitle: "다죽이기")
        alert.addButton(withTitle: "적당히 죽이기")
        alert.addButton(withTitle: "종료")

        alert.beginSheetModal(for: window) { response in
            isMainAlertShowing = false
            switch response {
            case .alertFirstButtonReturn:
                startKill(aggressive: true)
            case .alertSecondButtonReturn:
                startKill(aggressive: false)
            case .alertThirdButtonReturn:
                NSApplication.shared.terminate(nil)
            default:
                tryPresentMainKillAlert()
            }
        }
    }

    private func startKill(aggressive: Bool) {
        isWorking = true
        let protected = settings.protectedBundleIDs()
        DispatchQueue.global(qos: .userInitiated).async {
            let list = ProcessEnumerator.collectUserKillCandidates(
                aggressive: aggressive,
                protectedBundleIDs: protected
            )
            DispatchQueue.main.async {
                isWorking = false
                if list.isEmpty {
                    showNoTargetsAlert = true
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

        DispatchQueue.global(qos: .userInitiated).async {
            let fails = KillExecutor.killLocally(pids: pids)
            DispatchQueue.main.async {
                isWorking = false
                if !fails.isEmpty {
                    killFailureMessage = fails.prefix(5).map { "\($0.0): \($0.1)" }.joined(separator: "; ")
                    showKillFailureAlert = true
                } else {
                    tryPresentMainKillAlert()
                }
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
