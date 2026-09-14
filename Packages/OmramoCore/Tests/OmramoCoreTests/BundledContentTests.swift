import XCTest
@testable import OmramoCore

/// Contract tests for the bundled prototype content. These run on Linux CI
/// and catch hand authored JSON drift before it reaches the simulator.
final class BundledContentTests: XCTestCase {
    private let repository = BundledContentRepository()

    func testCatalogHasThreeTitlesWithTenPagesEach() async throws {
        let catalog = try await repository.loadCatalog()
        XCTAssertEqual(catalog.schemaVersion, Catalog.supportedSchemaVersion)
        XCTAssertEqual(catalog.books.count, 3)
        for book in catalog.books {
            XCTAssertEqual(book.pageCount, 10, "\(book.id) should have 10 pages")
            XCTAssertEqual(book.sample.pageCount, 2, "\(book.id) sample should fill one Duo spread")
            XCTAssertFalse(book.title.resolved(in: .telugu).isEmpty)
            XCTAssertFalse(book.title.resolved(in: .english).isEmpty)
            XCTAssertFalse(book.description.resolved(in: .telugu).isEmpty)
        }
    }

    func testBookIDsAreUnique() async throws {
        let catalog = try await repository.loadCatalog()
        let ids = catalog.books.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testEveryTitleShipsTeluguAndEnglishAndPlansHindi() async throws {
        let catalog = try await repository.loadCatalog()
        for book in catalog.books {
            XCTAssertEqual(book.readyLanguages, [.telugu, .english], "\(book.id)")
            XCTAssertEqual(book.pairableLanguages, [.english], "\(book.id)")
            XCTAssertEqual(book.edition(for: .hindi)?.status, .planned, "\(book.id)")
            XCTAssertNil(book.edition(for: .hindi)?.file, "\(book.id)")
        }
    }

    func testEditionsArePairedPageForPage() async throws {
        let catalog = try await repository.loadCatalog()
        for book in catalog.books {
            let telugu = try await repository.loadEdition(bookID: book.id, language: .telugu)
            let english = try await repository.loadEdition(bookID: book.id, language: .english)
            XCTAssertEqual(telugu.pageCount, book.pageCount, "\(book.id) te")
            XCTAssertEqual(english.pageCount, book.pageCount, "\(book.id) en")
            XCTAssertEqual(telugu.pages.map(\.number), english.pages.map(\.number), "\(book.id) numbering")
            for (te, en) in zip(telugu.pages, english.pages) {
                XCTAssertFalse(te.text.isEmpty, "\(book.id) te page \(te.number)")
                XCTAssertFalse(en.text.isEmpty, "\(book.id) en page \(en.number)")
                XCTAssertEqual(te.illustration?.motif, en.illustration?.motif, "\(book.id) page \(te.number) art should be shared")
            }
        }
    }

    func testTeluguPagesActuallyContainTeluguScript() async throws {
        let catalog = try await repository.loadCatalog()
        let teluguBlock = Unicode.Scalar(0x0C00)!...Unicode.Scalar(0x0C7F)!
        for book in catalog.books {
            let edition = try await repository.loadEdition(bookID: book.id, language: .telugu)
            for page in edition.pages {
                let hasTelugu = page.text.unicodeScalars.contains { teluguBlock.contains($0) }
                XCTAssertTrue(hasTelugu, "\(book.id) te page \(page.number) has no Telugu script")
            }
        }
    }

    func testEnglishCopyHasNoEmDashes() async throws {
        let catalog = try await repository.loadCatalog()
        for book in catalog.books {
            XCTAssertFalse(book.title.resolved(in: .english).contains("\u{2014}"))
            XCTAssertFalse(book.description.resolved(in: .english).contains("\u{2014}"))
            let edition = try await repository.loadEdition(bookID: book.id, language: .english)
            for page in edition.pages {
                XCTAssertFalse(page.text.contains("\u{2014}"), "\(book.id) en page \(page.number)")
            }
        }
    }

    func testSampleSliceNeverIncludesPaidPages() async throws {
        let catalog = try await repository.loadCatalog()
        for book in catalog.books {
            let telugu = try await repository.loadEdition(bookID: book.id, language: .telugu)
            let english = try await repository.loadEdition(bookID: book.id, language: .english)
            let teSample = telugu.limited(toPageCount: book.sample.pageCount)
            let enSample = english.limited(toPageCount: book.sample.pageCount)
            XCTAssertEqual(teSample.pageCount, book.sample.pageCount, "\(book.id) te sample")
            XCTAssertEqual(enSample.pageCount, book.sample.pageCount, "\(book.id) en sample")
            XCTAssertNil(teSample.page(at: book.sample.pageCount), "\(book.id) must not leak page \(book.sample.pageCount + 1)")
            XCTAssertTrue(teSample.pages.allSatisfy { $0.index < book.sample.pageCount })
        }
    }

    func testPlannedEditionIsReportedNotCrashed() async throws {
        let catalog = try await repository.loadCatalog()
        let book = try XCTUnwrap(catalog.books.first)
        do {
            _ = try await repository.loadEdition(bookID: book.id, language: .hindi)
            XCTFail("Hindi is planned, loading it should fail")
        } catch let error as ContentError {
            XCTAssertEqual(error, .editionNotAvailable(book.id, .hindi))
            XCTAssertFalse(error.userMessage.isEmpty)
        }
    }

    func testUnknownBookIsReported() async {
        do {
            _ = try await repository.loadEdition(bookID: BookID("does-not-exist"), language: .telugu)
            XCTFail("Unknown book should fail")
        } catch let error as ContentError {
            XCTAssertEqual(error, .unknownBook(BookID("does-not-exist")))
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testMissingCatalogBecomesNonRetryableFailure() async {
        let repository = BundledContentRepository(contentRoot: URL(fileURLWithPath: "/nonexistent/omramo"))
        do {
            _ = try await repository.loadCatalog()
            XCTFail("Missing catalog should fail")
        } catch {
            let failure = LoadFailure(error)
            XCTAssertFalse(failure.isRetryable)
            XCTAssertFalse(failure.message.isEmpty)
        }
    }
}
