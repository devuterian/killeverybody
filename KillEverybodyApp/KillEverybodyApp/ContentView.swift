import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct SettingsRootView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        TabView {
            ExceptionAppsView()
                .tabItem { Label(settings.text(.exceptionsTab), systemImage: "checklist") }
            AdvancedSettingsView()
                .tabItem { Label(settings.text(.advancedTab), systemImage: "gearshape") }
        }
        .padding(20)
        .frame(minWidth: 560, minHeight: 460)
    }
}

private enum AppListFilter: String, CaseIterable, Identifiable {
    case all
    case running
    case loginItems

    var id: String { rawValue }

    var titleKey: AppText {
        switch self {
        case .all: return .allApps
        case .running: return .running
        case .loginItems: return .loginItems
        }
    }
}

private struct ExceptionAppsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @State private var applications: [ApplicationInfo] = []
    @State private var searchText = ""
    @State private var filter = AppListFilter.all
    @State private var isLoading = true
    @State private var terminatingBundleIDs: Set<String> = []

    private var filteredApplications: [ApplicationInfo] {
        let filtered = applications.filter { app in
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
        return filtered.sorted(by: comesBefore)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(settings.text(.appsToSpare))
                    .font(.title2.weight(.semibold))
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(settings.format(.protectedCount, settings.exemptBundleIDs.count))
                        .foregroundStyle(.secondary)
                    Menu {
                        ForEach(AppListSortOrder.allCases) { order in
                            Toggle(
                                settings.text(order.titleKey),
                                isOn: Binding(
                                    get: { settings.appListSortOrder == order },
                                    set: { selected in
                                        if selected { settings.appListSortOrder = order }
                                    }
                                )
                            )
                        }
                    } label: {
                        Label(settings.text(.sort), systemImage: "arrow.up.arrow.down.circle")
                            .labelStyle(.iconOnly)
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()
                    .help(settings.text(.sort))
                }
            }

            Picker(settings.text(.allApps), selection: $filter) {
                ForEach(AppListFilter.allCases) { item in
                    Text(settings.text(item.titleKey)).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Group {
                if isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text(settings.text(.loadingApps))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredApplications.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Text(settings.text(searchText.isEmpty ? .noApps : .noSearchResults))
                            .font(.headline)
                        Text(settings.text(searchText.isEmpty ? .chooseAnotherList : .tryAnotherSearch))
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
                                    Label(settings.text(.loginBadge), systemImage: "power")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                if terminatingBundleIDs.contains(app.bundleID) {
                                    HStack(spacing: 5) {
                                        ProgressView()
                                            .controlSize(.small)
                                        Text(settings.text(.quitting))
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                } else if app.isRunning {
                                    Text(settings.text(.running))
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                            .contentShape(Rectangle())
                            .help(app.url.path)
                        }
                        .toggleStyle(.checkbox)
                        .contextMenu {
                            Button(role: .destructive) {
                                forceQuit(app)
                            } label: {
                                Label(settings.text(.forceQuitThisApp), systemImage: "xmark.octagon")
                            }
                            .disabled(
                                !app.isRunning
                                    || app.bundleID == Bundle.main.bundleIdentifier
                                    || terminatingBundleIDs.contains(app.bundleID)
                            )
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: settings.text(.searchPrompt))
        }
        .task { refreshApplications(showLoading: true) }
    }

    private func comesBefore(_ lhs: ApplicationInfo, _ rhs: ApplicationInfo) -> Bool {
        let lhsProtected = settings.isExempt(lhs.bundleID)
        let rhsProtected = settings.isExempt(rhs.bundleID)
        switch settings.appListSortOrder {
        case .protectedFirst where lhsProtected != rhsProtected:
            return lhsProtected
        case .unprotectedFirst where lhsProtected != rhsProtected:
            return !lhsProtected
        default:
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    private func refreshApplications(showLoading: Bool = false) {
        if showLoading { isLoading = true }
        let loginIDs = settings.loginItemBundleIDs
        DispatchQueue.global(qos: .userInitiated).async {
            let loaded = ApplicationCatalog.load(loginItemBundleIDs: loginIDs)
            DispatchQueue.main.async {
                applications = loaded
                isLoading = false
            }
        }
    }

    private func forceQuit(_ app: ApplicationInfo) {
        guard app.isRunning, terminatingBundleIDs.insert(app.bundleID).inserted else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            let candidates = ProcessEnumerator.collectApplicationKillCandidates(bundleID: app.bundleID)
            let agentFailures = LaunchAgentSuppressor.bootout(bundleIDs: [app.bundleID])
            let failures = KillExecutor.killLocally(pids: candidates.map(\.pid))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                terminatingBundleIDs.remove(app.bundleID)
                guard !failures.isEmpty || !agentFailures.isEmpty else {
                    applications = applications.map { item in
                        guard item.bundleID == app.bundleID else { return item }
                        return ApplicationInfo(
                            bundleID: item.bundleID,
                            name: item.name,
                            url: item.url,
                            isRunning: false,
                            isLoginItem: item.isLoginItem
                        )
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        refreshApplications()
                    }
                    return
                }
                refreshApplications()
                let alert = NSAlert()
                alert.messageText = settings.text(.forceQuitFailed)
                alert.informativeText = settings.format(
                    .forceQuitFailureDetail,
                    app.name,
                    failures.count,
                    agentFailures.count
                )
                alert.alertStyle = .warning
                alert.addButton(withTitle: settings.text(.ok))
                alert.runModal()
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
            Section(settings.text(.language)) {
                Picker(settings.text(.language), selection: $settings.appLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.segmented)
                Text(settings.text(.languageHint))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(settings.text(.addBundleID)) {
                TextField(settings.text(.bundleIDExample), text: $newExemptID)
                Button(settings.text(.addToExceptions)) {
                    settings.addExempt(newExemptID)
                    newExemptID = ""
                }
                .disabled(newExemptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section(settings.text(.menubarBundles)) {
                Text(settings.text(.menubarHint))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(settings.text(.bundleID), text: $newMenubarID)
                Button(settings.text(.add)) {
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

            Section(settings.text(.policyFile)) {
                HStack {
                    Button(settings.text(.exportPolicy), action: exportPolicyFile)
                    Button(settings.text(.importPolicy), action: importPolicyFile)
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
        alert.addButton(withTitle: settings.text(.ok))
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
                    showPolicyAlert(title: settings.text(.saved), message: url.path)
                } catch {
                    showPolicyAlert(title: settings.text(.saveFailed), message: error.localizedDescription)
                }
            }
        } catch {
            showPolicyAlert(title: settings.text(.exportFailed), message: error.localizedDescription)
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
                    showPolicyAlert(title: settings.text(.newerPolicy), message: settings.text(.updateThenRetry))
                    return
                }
                let confirm = NSAlert()
                confirm.messageText = settings.text(.overwritePolicy)
                confirm.informativeText = settings.text(.overwritePolicyDetail)
                confirm.alertStyle = .warning
                confirm.addButton(withTitle: settings.text(.cancel))
                confirm.addButton(withTitle: settings.text(.overwrite))
                if confirm.runModal() == .alertSecondButtonReturn {
                    settings.applyImportedPolicy(doc)
                }
            } catch {
                showPolicyAlert(title: settings.text(.readFailed), message: error.localizedDescription)
            }
        }
    }
}
