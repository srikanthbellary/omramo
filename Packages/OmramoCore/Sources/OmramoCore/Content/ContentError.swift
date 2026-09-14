import Foundation

/// Failures the content layer can surface. Every case has a reader facing
/// message so views never show a raw decoding error.
public enum ContentError: Error, Equatable, Sendable {
    case missingResource(String)
    case unreadable(String, underlying: String)
    case unsupportedSchema(found: Int, supported: Int)
    case unknownBook(BookID)
    case editionNotAvailable(BookID, Language)
    case invalidPageNumbering(bookID: BookID, language: Language, expected: Int, found: Int)
    case pageCountMismatch(bookID: BookID, language: Language, expected: Int, found: Int)

    public var userMessage: String {
        switch self {
        case .missingResource, .unreadable, .unsupportedSchema:
            return "This copy of Omramo could not load its library. Please reinstall the app."
        case .unknownBook:
            return "That title is not in the library right now."
        case .editionNotAvailable(_, let language):
            return "The \(language.englishName) edition of this title is not ready yet."
        case .invalidPageNumbering, .pageCountMismatch:
            return "This title has a page problem. We are on it."
        }
    }
}

extension ContentError: LocalizedError {
    public var errorDescription: String? { userMessage }
}
