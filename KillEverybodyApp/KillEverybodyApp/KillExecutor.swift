import AppKit
import Darwin
import Foundation

enum KillExecutor {
    private static let chunkSize = 80

    static func killLocally(pids: [pid_t]) -> [(pid_t, String)] {
        var failures: [(pid_t, String)] = []
        for pid in pids {
            if kill(pid, SIGKILL) != 0 {
                let err = String(cString: strerror(errno))
                failures.append((pid, err))
            }
        }
        return failures
    }

    /// osascript 관리자 권한. 긴 인자는 청크로 나눈다.
    static func killWithAdmin(pids: [pid_t]) throws {
        guard !pids.isEmpty else { return }

        for chunk in pids.chunked(into: chunkSize) {
            let args = chunk.map { String($0) }.joined(separator: " ")
            let shell = "/bin/kill -9 \(args)"
            let escaped = shell.replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            let source = "do shell script \"\(escaped)\" with administrator privileges"
            var error: NSDictionary?
            guard let script = NSAppleScript(source: source) else {
                throw KillError.scriptCreationFailed
            }
            _ = script.executeAndReturnError(&error)
            if let error, error.count > 0 {
                let msg = (error[NSAppleScript.errorMessage] as? String) ?? String(describing: error)
                throw KillError.appleScriptFailed(msg)
            }
        }
    }
}

enum KillError: LocalizedError {
    case scriptCreationFailed
    case appleScriptFailed(String)

    var errorDescription: String? {
        switch self {
        case .scriptCreationFailed:
            return "AppleScript를 만들 수 없습니다."
        case .appleScriptFailed(let s):
            return s
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        var out: [[Element]] = []
        var i = startIndex
        while i < endIndex {
            let j = index(i, offsetBy: size, limitedBy: endIndex) ?? endIndex
            out.append(Array(self[i ..< j]))
            i = j
        }
        return out
    }
}
