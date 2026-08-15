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
            return "실행 중인 앱만 대상으로 합니다. 시스템 필수·에이전트·메뉴 막대 쪽(설정·프리셋·LSUIElement)은 제외합니다."
        case .userProcesses:
            return "현재 로그인 사용자 UID와 같은 프로세스를 대상으로 합니다. denylist·에이전트·보호 번들은 제외합니다."
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
    private static var ownBundleID: String? { Bundle.main.bundleIdentifier }

    static func collectCandidates(
        scope: KillScope,
        protectedBundleIDs: Set<String>,
        excludingPID: pid_t = getpid()
    ) -> [KillCandidate] {
        switch scope {
        case .guiOnly:
            return collectGUI(protectedBundleIDs: protectedBundleIDs, excludingPID: excludingPID)
        case .userProcesses, .adminUserProcesses:
            return collectUserProcesses(
                protectedBundleIDs: protectedBundleIDs,
                respectUserAndAgentProtection: true,
                excludingPID: excludingPID
            )
        }
    }

    /// 메인 창 두 모드: `aggressive`면 denylist만 제외, `moderate`면 예외·LSUIElement·메뉴바 보호 유지.
    static func collectUserKillCandidates(
        aggressive: Bool,
        protectedBundleIDs: Set<String>,
        excludingPID: pid_t = getpid()
    ) -> [KillCandidate] {
        collectApplicationProcesses(
            protectedBundleIDs: protectedBundleIDs,
            respectUserAndAgentProtection: !aggressive,
            excludingPID: excludingPID
        )
    }

    /// 예외 목록의 한 앱만 강제 종료할 때 사용한다. 선택한 앱과 자식 프로세스만 반환한다.
    static func collectApplicationKillCandidates(
        bundleID: String,
        excludingPID: pid_t = getpid()
    ) -> [KillCandidate] {
        collectApplicationProcesses(
            protectedBundleIDs: [],
            respectUserAndAgentProtection: false,
            targetBundleID: bundleID,
            excludingPID: excludingPID
        )
    }

    /// 실행 중인 앱을 루트로 삼아 그 자식 프로세스까지 모은다.
    /// 같은 UID라는 이유만으로 시스템 에이전트나 셸 전체를 대상으로 삼지는 않는다.
    private static func collectApplicationProcesses(
        protectedBundleIDs: Set<String>,
        respectUserAndAgentProtection: Bool,
        targetBundleID: String? = nil,
        excludingPID: pid_t
    ) -> [KillCandidate] {
        let uid = getuid()
        let rows = parsePS().filter { $0.uid == uid }
        let rowsByPID = Dictionary(uniqueKeysWithValues: rows.map { ($0.pid, $0) })
        let childrenByParent = Dictionary(grouping: rows, by: \.ppid)
        var candidatesByPID: [pid_t: KillCandidate] = [:]

        for app in NSWorkspace.shared.runningApplications {
            let seedPID = app.processIdentifier
            guard seedPID != excludingPID,
                  !app.isTerminated,
                  app.activationPolicy != .prohibited
            else { continue }
            if let ownBundleID, app.bundleIdentifier == ownBundleID { continue }

            let executablePath = app.executableURL?.path ?? ProcPath.path(for: seedPID)
            let appRoot = executablePath.flatMap(PlistHelpers.topLevelApplicationRoot)
                ?? app.bundleURL
            let ownerBundleID = appRoot.flatMap(PlistHelpers.bundleIdentifier)
                ?? app.bundleIdentifier
            if let targetBundleID,
               ownerBundleID != targetBundleID,
               app.bundleIdentifier != targetBundleID
            {
                continue
            }
            let name = appRoot.map { FileManager.default.displayName(atPath: $0.path) }
                ?? app.localizedName
                ?? "pid \(seedPID)"

            if let executablePath {
                let comm = URL(fileURLWithPath: executablePath).lastPathComponent
                if DenyList.isDenied(comm: comm, path: executablePath) { continue }
            }

            if respectUserAndAgentProtection {
                if let ownerBundleID, protectedBundleIDs.contains(ownerBundleID) { continue }
                if let bundleID = app.bundleIdentifier, protectedBundleIDs.contains(bundleID) { continue }
                if let appRoot, PlistHelpers.isLSUIElement(bundleURL: appRoot) { continue }
                if let bundleURL = app.bundleURL, PlistHelpers.isLSUIElement(bundleURL: bundleURL) { continue }
            }

            var pending = [seedPID]
            var seen: Set<pid_t> = []
            while let pid = pending.popLast() {
                guard seen.insert(pid).inserted, pid != excludingPID else { continue }
                pending.append(contentsOf: childrenByParent[pid, default: []].map(\.pid))
                guard let row = rowsByPID[pid] else { continue }

                let path = ProcPath.path(for: pid)
                let comm = path.map { URL(fileURLWithPath: $0).lastPathComponent } ?? row.comm
                if DenyList.isDenied(comm: comm, path: path) { continue }
                candidatesByPID[pid] = KillCandidate(
                    id: pid,
                    name: pid == seedPID ? name : comm,
                    path: path,
                    bundleID: ownerBundleID,
                    reason: "앱 \(name)"
                )
            }
        }

        return candidatesByPID.values.sorted { $0.pid < $1.pid }
    }

    private static func collectGUI(protectedBundleIDs: Set<String>, excludingPID: pid_t) -> [KillCandidate] {
        var out: [KillCandidate] = []
        let apps = NSWorkspace.shared.runningApplications

        for app in apps {
            if app.isTerminated { continue }
            let pid = app.processIdentifier
            if pid == excludingPID { continue }
            if let bid = app.bundleIdentifier, bid == ownBundleID { continue }
            if let bid = app.bundleIdentifier, protectedBundleIDs.contains(bid) {
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

    private static func collectUserProcesses(
        protectedBundleIDs: Set<String>,
        respectUserAndAgentProtection: Bool,
        excludingPID: pid_t
    ) -> [KillCandidate] {
        let uid = getuid()
        var rows = parsePS()
        rows.sort { $0.pid < $1.pid }

        var out: [KillCandidate] = []
        for row in rows {
            if row.pid == excludingPID { continue }
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
                    if respectUserAndAgentProtection {
                        if protectedBundleIDs.contains(bid) {
                            continue
                        }
                        if PlistHelpers.isLSUIElement(bundleURL: bundleRoot) {
                            continue
                        }
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
        let ppid: pid_t
        let uid: uid_t
        let comm: String
    }

    private static func parsePS() -> [PSRow] {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/ps")
        p.arguments = ["-axo", "pid=,ppid=,uid=,comm="]
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = Pipe()

        do {
            try p.run()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        guard let s = String(data: data, encoding: .utf8) else { return [] }

        var rows: [PSRow] = []
        for line in s.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            let parts = trimmed.split(separator: " ", maxSplits: 3, omittingEmptySubsequences: true)
            guard parts.count >= 4,
                  let pid = Int32(parts[0]),
                  let ppid = Int32(parts[1]),
                  let u = UInt32(parts[2])
            else { continue }
            let comm = String(parts[3])
            rows.append(PSRow(pid: pid, ppid: ppid, uid: uid_t(u), comm: comm))
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
