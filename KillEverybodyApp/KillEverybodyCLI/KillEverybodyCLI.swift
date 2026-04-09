import Darwin
import Foundation

/// Headless CLI: same enumeration as the GUI app (user-session kill modes), for terminals and CI on macOS.
@main
enum KillEverybodyCLI {
    static func main() {
        var aggressive = false
        var dryRun = true
        var jsonOut = false
        var policyPath: String?
        var confirmed = false
        var showHelp = false

        var argv = Array(CommandLine.arguments.dropFirst())
        while !argv.isEmpty {
            let a = argv.removeFirst()
            switch a {
            case "--help", "-h":
                showHelp = true
            case "--aggressive", "-a":
                aggressive = true
            case "--moderate", "-m":
                aggressive = false
            case "--execute":
                dryRun = false
            case "--dry-run":
                dryRun = true
            case "--json":
                jsonOut = true
            case "--policy":
                guard let p = argv.first else {
                    fputs("killeverybody-cli: --policy needs a path\n", stderr)
                    exit(2)
                }
                argv.removeFirst()
                policyPath = p
            case "--yes":
                confirmed = true
            default:
                fputs("killeverybody-cli: unknown argument \(a)\n", stderr)
                showHelp = true
            }
        }

        if showHelp {
            printHelp()
            exit(0)
        }

        if !dryRun, !confirmed {
            fputs(
                "killeverybody-cli: refusing --execute without --yes (this sends SIGKILL). Use --dry-run to list only.\n",
                stderr
            )
            exit(2)
        }

        let protected = loadProtectedBundleIDs(policyPath: policyPath)
        let list = ProcessEnumerator.collectUserKillCandidates(
            aggressive: aggressive,
            protectedBundleIDs: protected,
            excludingPID: getpid()
        )

        if jsonOut {
            printJSON(candidates: list, aggressive: aggressive, dryRun: dryRun)
        } else {
            printText(candidates: list, aggressive: aggressive, dryRun: dryRun)
        }

        if dryRun {
            exit(0)
        }

        let pids = list.map(\.pid)
        let failures = KillExecutor.killLocally(pids: pids)
        if failures.isEmpty {
            fputs("killeverybody-cli: SIGKILL sent to \(pids.count) process(es).\n", stderr)
            exit(0)
        }
        for (pid, err) in failures {
            fputs("killeverybody-cli: kill \(pid): \(err)\n", stderr)
        }
        exit(1)
    }

    private static func loadProtectedBundleIDs(policyPath: String?) -> Set<String> {
        var s = MenubarProtectionPresets.bundleIDs
        guard let policyPath else { return s }
        let url = URL(fileURLWithPath: policyPath)
        guard let data = try? Data(contentsOf: url) else {
            fputs("killeverybody-cli: cannot read policy file: \(policyPath)\n", stderr)
            exit(2)
        }
        do {
            let doc = try PolicyDocument.decodeDocument(from: data)
            s.formUnion(doc.exemptBundleIDs)
            s.formUnion(doc.menubarStyleBundleIDs)
        } catch {
            fputs("killeverybody-cli: invalid policy JSON: \(error)\n", stderr)
            exit(2)
        }
        return s
    }

    private static func printText(candidates: [KillCandidate], aggressive: Bool, dryRun: Bool) {
        let mode = aggressive ? "aggressive (denylist only)" : "moderate (exempt · LSUIElement · menubar presets)"
        print("mode: \(mode)")
        print("action: \(dryRun ? "dry-run (no signals sent)" : "execute (SIGKILL)")")
        print("count: \(candidates.count)")
        for c in candidates {
            var line = "\(c.pid)\t\(c.name)"
            if let b = c.bundleID { line += "\t\(b)" }
            if let p = c.path { line += "\t\(p)" }
            print(line)
        }
    }

    private static func printJSON(candidates: [KillCandidate], aggressive: Bool, dryRun: Bool) {
        struct Row: Encodable {
            let pid: Int32
            let name: String
            let bundleID: String?
            let path: String?
            let reason: String
        }
        struct Payload: Encodable {
            let mode: String
            let dryRun: Bool
            let count: Int
            let candidates: [Row]
        }
        let rows = candidates.map {
            Row(pid: $0.pid, name: $0.name, bundleID: $0.bundleID, path: $0.path, reason: $0.reason)
        }
        let payload = Payload(
            mode: aggressive ? "aggressive" : "moderate",
            dryRun: dryRun,
            count: candidates.count,
            candidates: rows
        )
        let enc = JSONEncoder()
        enc.outputFormatting = [.sortedKeys]
        if let data = try? enc.encode(payload), let s = String(data: data, encoding: .utf8) {
            print(s)
        }
    }

    private static func printHelp() {
        print(
            """
            killeverybody-cli — list or kill user-session processes (same logic as the GUI app).

            Usage:
              killeverybody-cli [options]

            Options:
              -m, --moderate     Moderate mode: denylist + exempt bundles + LSUIElement + menubar presets (default)
              -a, --aggressive   Aggressive mode: denylist only
                  --dry-run      Print candidates only (default)
                  --execute      Send SIGKILL (requires --yes)
                  --yes          Confirm execute
                  --policy PATH  Merge exempt + menubar bundle IDs from policy JSON (app export format)
                  --json         JSON output (still obeys dry-run / execute)
              -h, --help         This message

            Does not read GUI UserDefaults; use --policy to match saved exemptions.

            Exit: 0 on success, 1 if any kill failed, 2 on usage or policy errors.
            """
        )
    }
}
