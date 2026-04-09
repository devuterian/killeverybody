import Combine
import Foundation

final class SettingsStore: ObservableObject {
    private let exemptKey = "exemptBundleIDs"

    @Published var exemptBundleIDs: [String] {
        didSet { save() }
    }

    init() {
        if let saved = UserDefaults.standard.stringArray(forKey: exemptKey), !saved.isEmpty {
            exemptBundleIDs = saved
        } else {
            exemptBundleIDs = []
        }
    }

    func addExempt(_ id: String) {
        let t = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !exemptBundleIDs.contains(t) else { return }
        exemptBundleIDs.append(t)
    }

    func removeExempt(at offsets: IndexSet) {
        exemptBundleIDs.remove(atOffsets: offsets)
    }

    private func save() {
        UserDefaults.standard.set(exemptBundleIDs, forKey: exemptKey)
    }
}
