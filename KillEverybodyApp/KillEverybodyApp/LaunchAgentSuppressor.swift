import Darwin
import Foundation

enum LaunchAgentSuppressor {
    struct Failure {
        let label: String
        let reason: String
    }

    /// 선택된 앱을 KeepAlive하는 서드파티 LaunchAgent를 현재 GUI 세션에서만 내린다.
    /// plist나 로그인 항목 자체는 바꾸지 않으므로 다음 로그인 때 원래대로 다시 올라온다.
    static func bootout(bundleIDs: Set<String>) -> [Failure] {
        guard !bundleIDs.isEmpty else { return [] }
        let directories = [
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents"),
            URL(fileURLWithPath: "/Library/LaunchAgents", isDirectory: true),
        ]
        var failures: [Failure] = []
        for directory in directories {
            guard let urls = try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            for url in urls where url.pathExtension == "plist" {
                guard let plist = NSDictionary(contentsOf: url) as? [String: Any],
                      let label = plist["Label"] as? String,
                      !label.hasPrefix("com.apple."),
                      let program = programPath(from: plist),
                      let appRoot = PlistHelpers.topLevelApplicationRoot(from: program),
                      let bundleID = PlistHelpers.bundleIdentifier(bundleURL: appRoot),
                      bundleIDs.contains(bundleID)
                else { continue }

                if let reason = bootout(label: label) {
                    failures.append(Failure(label: label, reason: reason))
                }
            }
        }
        return failures
    }

    private static func programPath(from plist: [String: Any]) -> String? {
        if let program = plist["Program"] as? String { return program }
        return (plist["ProgramArguments"] as? [String])?.first
    }

    private static func bootout(label: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["bootout", "gui/\(getuid())/\(label)"]
        let error = Pipe()
        process.standardOutput = Pipe()
        process.standardError = error
        do {
            try process.run()
        } catch {
            return error.localizedDescription
        }
        let data = error.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus != 0 else { return nil }
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? "launchctl 종료 코드 \(process.terminationStatus)"
    }
}
