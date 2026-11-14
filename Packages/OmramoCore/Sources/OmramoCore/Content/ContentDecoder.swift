import Foundation

/// Decodes content JSON with a schema-version check and clear errors.
/// (docs/ARCHITECTURE.md calls this `StoryDecoder`; it also decodes the catalog and landmarks.)
public enum ContentDecoder {
    /// The newest `schemaVersion` this build understands.
    public static let supportedSchemaVersion = 1

    public static func decodeStory(_ data: Data, file: String = "story.json") throws -> Story {
        try decode(Story.self, from: data, file: file)
    }

    public static func decodeLandmarks(_ data: Data, file: String = "landmarks.json") throws -> LandmarkCatalog {
        try decode(LandmarkCatalog.self, from: data, file: file)
    }

    public static func decodeCatalog(_ data: Data, file: String = "catalog.json") throws -> Catalog {
        try decode(Catalog.self, from: data, file: file)
    }

    /// Reads only `schemaVersion`. Throws `ContentError` if it is missing or unsupported.
    @discardableResult
    public static func checkSchemaVersion(_ data: Data, file: String) throws -> Int {
        let probe: VersionProbe
        do {
            probe = try JSONDecoder().decode(VersionProbe.self, from: data)
        } catch let error as DecodingError {
            throw ContentError.malformed(file: file, detail: describe(error))
        } catch {
            throw ContentError.malformed(file: file, detail: "the file is not valid JSON (\(error))")
        }
        guard probe.schemaVersion >= 1, probe.schemaVersion <= supportedSchemaVersion else {
            throw ContentError.unsupportedSchemaVersion(
                file: file,
                found: probe.schemaVersion,
                supported: supportedSchemaVersion
            )
        }
        return probe.schemaVersion
    }

    private struct VersionProbe: Decodable {
        let schemaVersion: Int
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data, file: String) throws -> T {
        // Version first: a newer file may have a shape this build cannot decode at all,
        // and the reader should be told "update the app", not "missing field".
        try checkSchemaVersion(data, file: file)
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch let error as DecodingError {
            throw ContentError.malformed(file: file, detail: describe(error))
        } catch {
            throw ContentError.malformed(file: file, detail: "the file is not valid JSON (\(error))")
        }
    }

    /// A one-line description of a decoding failure that names the field.
    static func describe(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, let context):
            let parent = pathString(context.codingPath)
            let location = parent.isEmpty ? key.stringValue : parent + "." + key.stringValue
            return "missing required field \"\(location)\""
        case .valueNotFound(_, let context):
            return "missing value at \"\(pathString(context.codingPath))\""
        case .typeMismatch(_, let context):
            return "wrong type at \"\(pathString(context.codingPath))\": \(context.debugDescription)"
        case .dataCorrupted(let context):
            let location = pathString(context.codingPath)
            if location.isEmpty {
                return "the file is not valid JSON (\(context.debugDescription))"
            }
            return "invalid value at \"\(location)\": \(context.debugDescription)"
        @unknown default:
            return String(describing: error)
        }
    }

    /// `spreads[0].blocks[1].runs[2]`
    static func pathString(_ path: [CodingKey]) -> String {
        var result = ""
        for key in path {
            if let index = key.intValue {
                result += "[\(index)]"
            } else {
                if !result.isEmpty { result += "." }
                result += key.stringValue
            }
        }
        return result
    }
}
