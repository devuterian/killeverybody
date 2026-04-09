import Foundation

enum PlistHelpers {
    /// 번들 경로(…/Foo.app)에서 LSUIElement 여부.
    static func isLSUIElement(bundleURL: URL) -> Bool {
        let plist = bundleURL.appendingPathComponent("Contents/Info.plist")
        guard let dict = NSDictionary(contentsOf: plist) as? [String: Any] else { return false }
        if let v = dict["LSUIElement"] as? Bool { return v }
        if let n = dict["LSUIElement"] as? NSNumber { return n.boolValue }
        return false
    }

    /// 실행 파일 경로에서 .app 번들 루트를 찾는다.
    static func bundleRoot(fromExecutablePath path: String) -> URL? {
        var url = URL(fileURLWithPath: path)
        while url.path != "/" {
            if url.pathExtension.lowercased() == "app" {
                return url
            }
            url.deleteLastPathComponent()
        }
        return nil
    }
}
