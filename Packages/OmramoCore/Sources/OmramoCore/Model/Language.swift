import Foundation

/// The literary editions Omramo ships. Telugu is the core edition; Hindi and
/// English are preloaded translations of the same title, never live machine
/// translation. Conforming to `CodingKeyRepresentable` lets `[Language: String]`
/// encode as a plain JSON object keyed by the language code.
public enum Language: String, Codable, CaseIterable, Hashable, Sendable, CodingKeyRepresentable {
    case telugu = "te"
    case hindi = "hi"
    case english = "en"

    /// Name of the language written in the language itself.
    public var nativeName: String {
        switch self {
        case .telugu: return "తెలుగు"
        case .hindi: return "हिन्दी"
        case .english: return "English"
        }
    }

    /// Name of the language in English, for settings and diagnostics.
    public var englishName: String {
        switch self {
        case .telugu: return "Telugu"
        case .hindi: return "Hindi"
        case .english: return "English"
        }
    }

    /// The edition every title is authored in first.
    public static let primary: Language = .telugu
}

/// Text that exists in one or more editions. Lookups fall back to the primary
/// language so the catalog never renders an empty title.
public struct LocalizedText: Codable, Hashable, Sendable {
    public var values: [Language: String]

    public init(_ values: [Language: String]) {
        self.values = values
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode([Language: String].self)
        guard values[.primary] != nil else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Localized text is missing the primary (\(Language.primary.rawValue)) value."
            )
        }
        self.values = values
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }

    /// Returns the text in `language`, falling back to the primary edition.
    public func resolved(in language: Language) -> String {
        values[language] ?? values[.primary] ?? ""
    }

    public subscript(language: Language) -> String? {
        values[language]
    }
}
