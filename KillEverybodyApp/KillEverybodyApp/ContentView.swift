import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct SettingsRootView: View {
    var body: some View {
        TabView {
            ExceptionAppsView()
                .tabItem { Label("예외 앱", systemImage: "checklist") }
            AdvancedSettingsView()
                .tabItem { Label("고급", systemImage: "gearshape") }
        }
        .padding(20)
        .frame(minWidth: 560, minHeight: 460)
    }
}

private enum AppListFilter: String, CaseIterable, Identifiable {
    case all = "전체 앱"
    case running = "실행 중"
    case loginItems = "로그인 시 실행"

    var id: String { rawValue }
}

private struct ExceptionAppsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @State private var applications: [ApplicationInfo] = []
    @State private var searchText = ""
    @State private var filter = AppListFilter.all
    @State private var isLoading = true

    private var filteredApplications: [ApplicationInfo] {
        applications.filter { app in
            let matchesFilter: Bool
            switch filter {
            case .all: matchesFilter = true
            case .running: matchesFilter = app.isRunning
            case .loginItems: matchesFilter = app.isLoginItem
            }
            guard matchesFilter else { return false }
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else { return true }
            return app.name.localizedCaseInsensitiveContains(query)
                || app.bundleID.localizedCaseInsensitiveContains(query)
                || app.url.path.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("적당히 죽이기에서 살아남을 앱")
                    .font(.title2.weight(.semibold))
                Spacer()
                Text("\(settings.exemptBundleIDs.count)개 보호 중")
                    .foregroundStyle(.secondary)
            }

            Picker("목록", selection: $filter) {
                ForEach(AppListFilter.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Group {
                if isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("앱 목록을 불러오는 중…")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredApplications.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Text(searchText.isEmpty ? "앱이 없어요" : "검색 결과가 없어요")
                            .font(.headline)
                        Text(searchText.isEmpty ? "다른 목록을 선택해 보세요." : "앱 이름, 번들 ID, 경로로 다시 찾아보세요.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredApplications) { app in
                        Toggle(isOn: Binding(
                            get: { settings.isExempt(app.bundleID) },
                            set: { settings.setExempt(app.bundleID, enabled: $0) }
                        )) {
                            HStack(spacing: 10) {
                                Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.path))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(app.name)
                                        .lineLimit(1)
                                    Text(app.bundleID)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                if app.isLoginItem {
                                    Label("로그인", systemImage: "power")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if app.isRunning {
                                    Text("실행 중")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                            .contentShape(Rectangle())
                            .help(app.url.path)
                        }
                        .toggleStyle(.checkbox)
                    }
                    .listStyle(.inset)
                }
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "앱 이름, 번들 ID, 경로")
        }
        .task { loadApplications() }
    }

    private func loadApplications() {
        guard isLoading else { return }
        let loginIDs = settings.loginItemBundleIDs
        DispatchQueue.global(qos: .userInitiated).async {
            let loaded = ApplicationCatalog.load(loginItemBundleIDs: loginIDs)
            DispatchQueue.main.async {
                applications = loaded
                isLoading = false
            }
        }
    }
}

private struct AdvancedSettingsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @State private var newExemptID = ""
    @State private var newMenubarID = ""

    var body: some View {
        Form {
            Section("번들 ID 직접 추가") {
                TextField("예: com.apple.Safari", text: $newExemptID)
                Button("예외에 추가") {
                    settings.addExempt(newExemptID)
                    newExemptID = ""
                }
                .disabled(newExemptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section("메뉴 막대로 취급할 번들") {
                Text("LSUIElement가 아니어도 메뉴 막대 앱처럼 보호하고 싶을 때 사용해요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("번들 ID", text: $newMenubarID)
                Button("추가") {
                    settings.addMenubarStyle(newMenubarID)
                    newMenubarID = ""
                }
                .disabled(newMenubarID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if !settings.menubarStyleBundleIDs.isEmpty {
                    List {
                        ForEach(settings.menubarStyleBundleIDs, id: \.self) { id in
                            Text(id).textSelection(.enabled)
                        }
                        .onDelete(perform: settings.removeMenubarStyle)
                    }
                    .frame(minHeight: 100)
                }
            }

            Section("정책 파일") {
                HStack {
                    Button("정책 보내기…", action: exportPolicyFile)
                    Button("정책 가져오기…", action: importPolicyFile)
                }
            }
        }
        .formStyle(.grouped)
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
                guard doc.formatVersion <= PolicyDocument.currentFormatVersion else {
                    showPolicyAlert(title: "버전이 더 새 파일이에요", message: "앱을 업데이트한 뒤 다시 시도해 주세요.")
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
                }
            } catch {
                showPolicyAlert(title: "읽기 실패", message: error.localizedDescription)
            }
        }
    }
}
