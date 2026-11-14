import Foundation

/// Where stories come from. Bundled now; a downloaded folder later through the same protocol.
public protocol ContentRepository: Sendable {
    func loadCatalog() throws -> Catalog
    func loadLandmarks() throws -> LandmarkCatalog
    func loadStory(id: StoryID) throws -> Story
    /// The manuscript the story text is checked against, or nil when there is none.
    func loadManuscript(id: StoryID) throws -> String?
    /// Whether an image named by an `ArtRef.file` of this story exists.
    func storyArtExists(id: StoryID, file: String) -> Bool
    /// Whether an image named by a landmark's `ArtRef.file` exists.
    func landmarkArtExists(file: String) -> Bool
}

extension ContentRepository {
    /// Loads the catalog, the landmarks and every story, and validates all of it.
    /// Throws `ContentError.invalid` if any rule is broken with severity `error`.
    public func loadLibrary(validator: StoryValidator = StoryValidator()) throws -> Library {
        let catalog = try loadCatalog()
        let landmarks = try loadLandmarks()

        let landmarkReport = validator.validate(landmarks: landmarks)
        if !landmarkReport.isValid {
            throw ContentError.invalid(file: "landmarks/landmarks.json", issues: landmarkReport.errors)
        }

        var stories: [Story] = []
        var loadedIDs: [StoryID: StoryID] = [:]
        for id in catalog.stories where loadedIDs[id] == nil {
            let story = try loadStory(id: id)
            loadedIDs[id] = story.id
            let report = validator.validate(
                story: story,
                landmarks: landmarks,
                manuscript: try loadManuscript(id: id)
            )
            if !report.isValid {
                throw ContentError.invalid(file: "stories/\(id)/story.json", issues: report.errors)
            }
            stories.append(story)
        }

        let catalogReport = validator.validate(catalog: catalog, loadedStoryIDs: loadedIDs)
        if !catalogReport.isValid {
            throw ContentError.invalid(file: "catalog.json", issues: catalogReport.errors)
        }
        return Library(catalogVersion: catalog.catalogVersion, stories: stories, landmarks: landmarks)
    }
}

/// Reads any folder with the standard layout (docs/ARCHITECTURE.md §6.2):
///
///     catalog.json
///     landmarks/landmarks.json
///     sources/<story-id>.txt
///     stories/<story-id>/story.json
public struct DirectoryContentRepository: ContentRepository {
    public let root: URL

    public init(root: URL) {
        self.root = root
    }

    public var catalogURL: URL {
        root.appendingPathComponent("catalog.json")
    }

    public var landmarksURL: URL {
        root.appendingPathComponent("landmarks").appendingPathComponent("landmarks.json")
    }

    public func storyURL(id: StoryID) -> URL {
        root.appendingPathComponent("stories").appendingPathComponent(id.rawValue).appendingPathComponent("story.json")
    }

    public func manuscriptURL(id: StoryID) -> URL {
        root.appendingPathComponent("sources").appendingPathComponent(id.rawValue + ".txt")
    }

    public func loadCatalog() throws -> Catalog {
        try ContentDecoder.decodeCatalog(read(catalogURL), file: "catalog.json")
    }

    public func loadLandmarks() throws -> LandmarkCatalog {
        try ContentDecoder.decodeLandmarks(read(landmarksURL), file: "landmarks/landmarks.json")
    }

    public func loadStory(id: StoryID) throws -> Story {
        try ContentDecoder.decodeStory(read(storyURL(id: id)), file: "stories/\(id)/story.json")
    }

    public func loadManuscript(id: StoryID) throws -> String? {
        let url = manuscriptURL(id: id)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try read(url)
        guard let text = String(data: data, encoding: .utf8) else {
            throw ContentError.unreadable(path: url.path, reason: "the file is not UTF-8 text")
        }
        return text
    }

    public func storyArtExists(id: StoryID, file: String) -> Bool {
        let url = root.appendingPathComponent("stories").appendingPathComponent(id.rawValue).appendingPathComponent(file)
        return FileManager.default.fileExists(atPath: url.path)
    }

    public func landmarkArtExists(file: String) -> Bool {
        let url = root.appendingPathComponent("landmarks").appendingPathComponent(file)
        return FileManager.default.fileExists(atPath: url.path)
    }

    /// The raw bytes of a content file. Public so tests and tools can read the same files.
    public func read(_ url: URL) throws -> Data {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ContentError.fileNotFound(path: url.path)
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            throw ContentError.unreadable(path: url.path, reason: error.localizedDescription)
        }
    }
}

/// The content shipped inside this package (`Sources/OmramoCore/Resources/Content`).
/// The app and the tests both read it from here, so there is one copy.
public enum BundledContent {
    /// The `Content` folder inside the package's resource bundle, or nil if it is missing.
    public static var rootURL: URL? {
        if let base = Bundle.module.resourceURL {
            let candidate = base.appendingPathComponent("Content")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
        }
        return Bundle.module.url(forResource: "Content", withExtension: nil)
    }

    public static func repository() throws -> DirectoryContentRepository {
        guard let root = rootURL else {
            throw ContentError.fileNotFound(path: "Content (in the OmramoCore resource bundle)")
        }
        return DirectoryContentRepository(root: root)
    }
}
