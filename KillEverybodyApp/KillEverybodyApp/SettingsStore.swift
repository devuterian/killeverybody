import Combine
import Foundation

final class SettingsStore: ObservableObject {
    private let exemptKey = "exemptBundleIDs"
    private let menubarKey = "menubarStyleBundleIDs"
    private let didSeedLoginItemsKey = "didSeedLoginItems"

    @Published var exemptBundleIDs: [String] {
        didSet { save() }
    }

    @Published var menubarStyleBundleIDs: [String] {
        didSet { save() }
    }

    @Published private(set) var loginItemBundleIDs: Set<String>

    init() {
        let d = UserDefaults.standard
        var exempt = d.stringArray(forKey: exemptKey) ?? []
        let loginURLs = LoginItemProvider.applicationURLs()
        let loginIDs = loginURLs.map(LoginItemProvider.bundleIDs) ?? []
        if !d.bool(forKey: didSeedLoginItemsKey), loginURLs != nil {
            exempt = Array(Set(exempt).union(loginIDs)).sorted()
            d.set(true, forKey: didSeedLoginItemsKey)
            d.set(exempt, forKey: exemptKey)
        }
        exemptBundleIDs = exempt
        loginItemBundleIDs = loginIDs
        if let m = d.stringArray(forKey: menubarKey), !m.isEmpty {
            menubarStyleBundleIDs = m
        } else {
            menubarStyleBundleIDs = []
        }
    }

    /// 종료에서 제외할 번들 ID (예외 + 사용자 지정 메뉴바 취급 + 내장 프리셋).
    func protectedBundleIDs() -> Set<String> {
        Set(exemptBundleIDs)
            .union(menubarStyleBundleIDs)
            .union(MenubarProtectionPresets.bundleIDs)
    }

    func addExempt(_ id: String) {
        let t = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !exemptBundleIDs.contains(t) else { return }
        exemptBundleIDs.append(t)
    }

    func removeExempt(at offsets: IndexSet) {
        exemptBundleIDs.remove(atOffsets: offsets)
    }

    func isExempt(_ id: String) -> Bool {
        exemptBundleIDs.contains(id)
    }

    func setExempt(_ id: String, enabled: Bool) {
        if enabled {
            addExempt(id)
        } else {
            exemptBundleIDs.removeAll { $0 == id }
        }
    }

    func addMenubarStyle(_ id: String) {
        let t = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !menubarStyleBundleIDs.contains(t) else { return }
        menubarStyleBundleIDs.append(t)
    }

    func removeMenubarStyle(at offsets: IndexSet) {
        menubarStyleBundleIDs.remove(atOffsets: offsets)
    }

    func applyImportedPolicy(_ doc: PolicyDocument) {
        exemptBundleIDs = doc.exemptBundleIDs
        menubarStyleBundleIDs = doc.menubarStyleBundleIDs
    }

    func exportPolicyData() throws -> Data {
        try PolicyDocument.encodeDocument(exempt: exemptBundleIDs, menubarStyle: menubarStyleBundleIDs)
    }

    private func save() {
        let d = UserDefaults.standard
        d.set(exemptBundleIDs, forKey: exemptKey)
        d.set(menubarStyleBundleIDs, forKey: menubarKey)
    }
}
