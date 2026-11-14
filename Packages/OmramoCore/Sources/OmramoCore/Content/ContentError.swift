import Foundation

/// Why content could not be loaded. Messages are written to be read by a person.
public enum ContentError: Error, Equatable, Sendable {
    /// A file or folder that should exist does not.
    case fileNotFound(path: String)
    /// The file exists but could not be read.
    case unreadable(path: String, reason: String)
    /// The file was written for a newer (or impossible) schema than this build supports.
    case unsupportedSchemaVersion(file: String, found: Int, supported: Int)
    /// The JSON is broken or does not match the schema. `detail` names the field.
    case malformed(file: String, detail: String)
    /// The JSON decoded, but it breaks content rules.
    case invalid(file: String, issues: [ValidationIssue])
}

extension ContentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Content file not found: \(path)"
        case .unreadable(let path, let reason):
            return "Content file could not be read: \(path) (\(reason))"
        case .unsupportedSchemaVersion(let file, let found, let supported):
            if found > supported {
                return "\(file) uses content schema version \(found), but this version of the app "
                    + "only understands version \(supported). Update the app to read it."
            }
            return "\(file) has content schema version \(found), which is not valid. "
                + "Supported version: \(supported)."
        case .malformed(let file, let detail):
            return "\(file) is not valid story data: \(detail)"
        case .invalid(let file, let issues):
            let lines = issues.map { "  - " + $0.description }.joined(separator: "\n")
            return "\(file) breaks \(issues.count) content rule(s):\n\(lines)"
        }
    }
}

/// Loading state for any screen that waits for content.
public enum LoadState<Value: Sendable>: Sendable {
    case idle
    case loading
    case loaded(Value)
    case failed(message: String)

    public var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }
}
