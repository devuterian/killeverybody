import AppKit
import Darwin
import Foundation

enum KillScope: String, CaseIterable, Identifiable {
    case guiOnly
    case userProcesses
    case adminUserProcesses

    var id: String { rawValue }

    var title: String {
        switch self {
        case .guiOnly: return "GUI 앱만"
        case .userProcesses: return "현재 사용자 프로세스 전체"
        case .adminUserProcesses: return "관리자 권한(실험적)"
        }
    }

    var detail: String {
        switch self {
        case .guiOnly:
            return "실행 중인 앱(NSWorkspace)만 대상으로 합니다. 시스템 필수·에이전트·메뉴바 성격(LSUIElement) 앱은 제외합니다."
        case .userProcesses:
            return "현재 로그인 사용자 UID와 같은 프로세스를 대상으로 합니다. 시스템 denylist·에이전트·예외 번들은 제외합니다."
        case .adminUserProcesses:
            return "대상 목록은 「현재 사용자 프로세스 전체」와 동일합니다. kill에 관리자 암호를 사용합니다. 비권장·실험용입니다."
        }
    }

    var usesAdminShell: Bool {
        self == .adminUserProcesses
    }
}

struct KillCandidate: Identifiable, Hashable {
    let id: Int32
    var pid: pid_t { id }
    let name: String
    let path: String?
    let bundleID: String?
    let reason: String

    var subtitle: String {
        var parts: [String] = []
        if let p = path { parts.append(p) }
        if let b = bundleID { parts.append(b) }
        return parts.joined(separator: " · ")
    }
}

enum ProcessEnumerator {
    private static let ownPID = getpid()
    private static var ownBundleID: String? { Bundle.main.bundleIdentifier }

    static func collectCandidates(scope: KillScope, exemptBundleIDs: Set<String>) -> [KillCandidate] {
        switch scope {
        case .guiOnly:
            return collectGUI(exemptBundleIDs: exemptBundleIDs)
        case .userProcesses, .adminUserProcesses:
            return collectUserProcesses(exemptBundleIDs: exemptBundleIDs)
        }
    }

    private static func collectGUI(exemptBundleIDs: Set<String>) -> [KillCandidate] {
        var out: [KillCandidate] = []
        let apps = NSWorkspace.shared.runningApplications

        for app in apps {
            if app.isTerminated { continue }
            let pid = app.processIdentifier
            if pid == ownPID { continue }
            if let bid = app.bundleIdentifier, bid == ownBundleID { continue }
            if let bid = app.bundleIdentifier, exemptBundleIDs.contains(bid) {
                continue
            }

            let name = app.localizedName ?? app.bundleURL?.lastPathComponent ?? "pid \(pid)"
            let path = app.executableURL?.path ?? ProcPath.path(for: pid)
            let comm = (path as NSString?)?.lastPathComponent ?? name

            if DenyList.isDenied(comm: comm, path: path) {
                continue
            }

            if let burl = app.bundleURL {
                if PlistHelpers.isLSUIElement(bundleURL: burl) {
                    continue
                }
            } else if let exec = path, let bundleRoot = PlistHelpers.bundleRoot(fromExecutablePath: exec) {
                if PlistHelpers.isLSUIElement(bundleURL: bundleRoot) {
                    continue
                }
            }

            out.append(
                KillCandidate(
                    id: pid,
                    name: name,
                    path: path,
                    bundleID: app.bundleIdentifier,
                    reason: "GUI 앱"
                )
            )
        }

        out.sort { $0.pid < $1.pid }
        return out
    }

    private static func collectUserProcesses(exemptBundleIDs: Set<String>) -> [KillCandidate] {
        let uid = getuid()
        var rows = parsePS()
        rows.sort { $0.pid < $1.pid }

        var out: [KillCandidate] = []
        for row in rows {
            if row.pid == ownPID { continue }
            if row.uid != uid { continue }

            let path = ProcPath.path(for: row.pid) ?? ""
            let comm = path.isEmpty ? row.comm : (path as NSString).lastPathComponent

            if DenyList.isDenied(comm: comm, path: path.isEmpty ? nil : path) {
                continue
            }

            var bundleID: String?
            if !path.isEmpty, let bundleRoot = PlistHelpers.bundleRoot(fromExecutablePath: path) {
                if let dict = NSDictionary(contentsOf: bundleRoot.appendingPathComponent("Contents/Info.plist")) as? [String: Any],
                   let bid = dict["CFBundleIdentifier"] as? String
                {
                    bundleID = bid
                    if exemptBundleIDs.contains(bid) {
                        continue
                    }
                    if PlistHelpers.isLSUIElement(bundleURL: bundleRoot) {
                        continue
                    }
                }
            }

            let displayName: String
            if let bid = bundleID, let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bid) {
                displayName = FileManager.default.displayName(atPath: url.path)
            } else if !comm.isEmpty {
                displayName = comm
            } else {
                displayName = "pid \(row.pid)"
            }

            out.append(
                KillCandidate(
                    id: row.pid,
                    name: displayName,
                    path: path.isEmpty ? nil : path,
                    bundleID: bundleID,
                    reason: "UID \(uid)"
                )
            )
        }

        return out
    }

    private struct PSRow {
        let pid: pid_t
        let uid: uid_t
        let comm: String
    }

    private static func parsePS() -> [PSRow] {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/ps")
        p.arguments = ["-axo", "pid=,uid=,comm="]
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = Pipe()

        do {
            try p.run()
        } catch {
            return []
        }
        p.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let s = String(data: data, encoding: .utf8) else { return [] }

        var rows: [PSRow] = []
        for line in s.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            let parts = trimmed.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
            guard parts.count >= 3,
                  let pid = Int32(parts[0]),
                  let u = UInt32(parts[1])
            else { continue }
            let comm = String(parts[2])
            rows.append(PSRow(pid: pid, uid: uid_t(u), comm: comm))
        }
        return rows
    }
}

enum ProcPath {
    static func path(for pid: pid_t) -> String? {
        let max = 4096 // PROC_PIDPATHINFO_MAXSIZE
        var buf = [CChar](repeating: 0, count: max)
        let n = buf.withUnsafeMutableBufferPointer { ptr in
            proc_pidpath(pid, ptr.baseAddress!, UInt32(max))
        }
        guard n > 0 else { return nil }
        return String(cString: buf)
    }
}
