import Foundation

/// A single page of one edition. Pages across editions of the same title are
/// paired by `number`, which is what lets two panes stay in sync.
public struct Page: Codable, Hashable, Identifiable, Sendable {
    /// One based, matching how a printed book is numbered.
    public var number: Int
    public var text: String
    public var illustration: Artwork?
    public var caption: String?

    public init(number: Int, text: String, illustration: Artwork? = nil, caption: String? = nil) {
        self.number = number
        self.text = text
        self.illustration = illustration
        self.caption = caption
    }

    public var id: Int { number }

    /// Zero based position in the edition.
    public var index: Int { number - 1 }
}

/// All pages of one title in one language.
public struct Edition: Codable, Hashable, Sendable {
    public var bookID: BookID
    public var language: Language
    public var pages: [Page]

    public init(bookID: BookID, language: Language, pages: [Page]) {
        self.bookID = bookID
        self.language = language
        self.pages = pages
    }

    public var pageCount: Int { pages.count }

    public func page(at index: Int) -> Page? {
        guard pages.indices.contains(index) else { return nil }
        return pages[index]
    }

    /// Pages are expected to be numbered 1...n in order. Content authored by
    /// hand can drift, so the repository validates before handing pages out.
    public func validateNumbering() throws {
        for (offset, page) in pages.enumerated() where page.number != offset + 1 {
            throw ContentError.invalidPageNumbering(bookID: bookID, language: language, expected: offset + 1, found: page.number)
        }
    }
}
