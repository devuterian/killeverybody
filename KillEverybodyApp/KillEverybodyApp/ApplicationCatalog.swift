import AppKit
import CoreServices
import Foundation

struct ApplicationInfo: Identifiable, Hashable {
    var id: String { bundleID }
    let bundleID: String
    let name: String
    let url: URL
    let isRunning: Bool
    let isLoginItem: Bool
}

enum LoginItemProvider {
    static func applicationURLs() -> [URL]? {
        // `sfltool dumpbtm` requires an administrator password on current macOS.
        // This read-only compatibility API exposes the visible login-app list
        // without requesting authorization.
        let listKind = kLSSharedFileListSessionLoginItems.takeUnretainedValue()
        guard let managedList = LSSharedFileListCreate(nil, listKind, nil) else { return nil }
        let list = managedList.takeRetainedValue()
        var seed: UInt32 = 0
        guard let managedSnapshot = LSSharedFileListCopySnapshot(list, &seed) else { return nil }
        let snapshot = managedSnapshot.takeRetainedValue()
        var urls: Set<URL> = []
        for index in 0..<CFArrayGetCount(snapshot) {
            let item = unsafeBitCast(
                CFArrayGetValueAtIndex(snapshot, index),
                to: LSSharedFileListItem.self
            )
            if let managedURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil) {
                let url = managedURL.takeRetainedValue() as URL
                if url.pathExtension.lowercased() == "app" {
                    urls.insert(url.standardizedFileURL)
                }
            }
        }
        return Array(urls)
    }

    static func bundleIDs(from urls: [URL]) -> Set<String> {
        Set(urls.compactMap { url in
            let root = PlistHelpers.topLevelApplicationRoot(from: url.path) ?? url
            return PlistHelpers.bundleIdentifier(bundleURL: root)
        })
    }
}

enum ApplicationCatalog {
    static func load(loginItemBundleIDs: Set<String>) -> [ApplicationInfo] {
        let workspace = NSWorkspace.shared
        let runningRoots = workspace.runningApplications.compactMap { app -> URL? in
            guard let path = app.executableURL?.path ?? app.bundleURL?.path else { return nil }
            return PlistHelpers.topLevelApplicationRoot(from: path) ?? app.bundleURL
        }
        let runningIDs = Set(runningRoots.compactMap(PlistHelpers.bundleIdentifier))

        var urls = Set(runningRoots)
        let roots = [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            URL(fileURLWithPath: "/System/Applications", isDirectory: true),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true),
        ]
        let keys: [URLResourceKey] = [.isDirectoryKey, .isApplicationKey]
        for root in roots where FileManager.default.fileExists(atPath: root.path) {
            guard let enumerator = FileManager.default.enumerator(
                at: root,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) else { continue }
            for case let url as URL in enumerator where url.pathExtension.lowercased() == "app" {
                urls.insert(url)
            }
        }

        var byBundleID: [String: ApplicationInfo] = [:]
        for url in urls {
            guard let bundleID = PlistHelpers.bundleIdentifier(bundleURL: url), !bundleID.isEmpty else { continue }
            let bundle = Bundle(url: url)
            let name = (bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
                ?? url.deletingPathExtension().lastPathComponent
            let info = ApplicationInfo(
                bundleID: bundleID,
                name: name,
                url: url,
                isRunning: runningIDs.contains(bundleID),
                isLoginItem: loginItemBundleIDs.contains(bundleID)
            )
            if let current = byBundleID[bundleID] {
                if preferred(url: info.url, over: current.url) {
                    byBundleID[bundleID] = info
                }
            } else {
                byBundleID[bundleID] = info
            }
        }

        return byBundleID.values.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    private static func preferred(url: URL, over current: URL) -> Bool {
        let score: (URL) -> Int = { value in
            if value.path.hasPrefix("/Applications/") { return 0 }
            if value.path.hasPrefix(FileManager.default.homeDirectoryForCurrentUser.path + "/Applications/") { return 1 }
            if value.path.hasPrefix("/System/Applications/") { return 2 }
            return 3
        }
        return score(url) < score(current)
    }
}
