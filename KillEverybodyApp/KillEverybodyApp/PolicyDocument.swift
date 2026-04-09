import Foundation

/// 정책 가져오기·보내기용 JSON (버전 호환용 필드 포함).
struct PolicyDocument: Codable, Equatable {
    var formatVersion: Int
    var exemptBundleIDs: [String]
    var menubarStyleBundleIDs: [String]

    static let currentFormatVersion = 1

    static func encodeDocument(exempt: [String], menubarStyle: [String]) throws -> Data {
        let doc = PolicyDocument(
            formatVersion: currentFormatVersion,
            exemptBundleIDs: exempt,
            menubarStyleBundleIDs: menubarStyle
        )
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try enc.encode(doc)
    }

    static func decodeDocument(from data: Data) throws -> PolicyDocument {
        try JSONDecoder().decode(PolicyDocument.self, from: data)
    }
}
