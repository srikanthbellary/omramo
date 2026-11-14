import Foundation
import Observation
import OmramoCore

/// What the reader remembers besides the reading position: the "Aa" text size, one bookmark per
/// story, which tap-to-see and character cards have been seen, and which characters have been
/// met. A small JSON file in Application Support, next to the reading progress.
/// Nothing here leaves the device, and no times or durations are stored.
@MainActor
@Observable
final class ReaderMemoryStore {
    private(set) var file: ReaderMemoryFile
    private let fileURL: URL?

    /// - Parameter fileURL: where to keep the file. Pass nil for an in-memory store (tests, previews).
    init(fileURL: URL? = ReaderMemoryStore.defaultFileURL()) {
        self.fileURL = fileURL
        self.file = ReaderMemoryStore.load(from: fileURL)
    }

    /// An in-memory store that already holds a memory (the debug demo state, tests).
    init(seed: ReaderMemoryFile) {
        self.fileURL = nil
        self.file = seed
    }

    // MARK: Text size

    /// The chosen step, or nil when none has been chosen yet.
    var textSize: TextSizeStep? {
        file.textSize
    }

    func setTextSize(_ step: TextSizeStep) {
        guard file.textSize != step else { return }
        file.textSize = step
        save()
    }

    // MARK: Bookmark

    func bookmark(for storyID: StoryID) -> ReadingPosition? {
        file.bookmark(for: storyID)
    }

    func setBookmark(_ position: ReadingPosition) {
        file.setBookmark(position)
        save()
    }

    func removeBookmark(for storyID: StoryID) {
        guard file.bookmark(for: storyID) != nil else { return }
        file.removeBookmark(for: storyID)
        save()
    }

    // MARK: Seen cards and friends met

    func hasSeen(_ ref: StoryCardRef, in storyID: StoryID) -> Bool {
        file.hasSeen(ref, in: storyID)
    }

    func markSeen(_ ref: StoryCardRef, in storyID: StoryID) {
        if file.markSeen(ref, in: storyID) {
            save()
        }
    }

    func recordMet(_ characters: [CharacterID], in storyID: StoryID) {
        guard !characters.isEmpty else { return }
        if !file.recordMet(characters, in: storyID).isEmpty {
            save()
        }
    }

    func friends(in storyID: StoryID) -> [CharacterID] {
        file.friends(in: storyID)
    }

    // MARK: File

    private func save() {
        guard let fileURL else { return }
        do {
            let data = try JSONEncoder().encode(file)
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Losing a "seen" mark is not worth interrupting a child's reading for.
            #if DEBUG
            print("[Omramo] could not save reader memory: \(error)")
            #endif
        }
    }

    private static func load(from fileURL: URL?) -> ReaderMemoryFile {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else {
            return ReaderMemoryFile()
        }
        guard let stored = try? JSONDecoder().decode(ReaderMemoryFile.self, from: data),
              stored.schemaVersion <= ReaderMemoryFile.currentSchemaVersion else {
            // Unreadable or from a newer app version: start fresh rather than crash.
            return ReaderMemoryFile()
        }
        return stored
    }

    nonisolated static func defaultFileURL() -> URL? {
        guard let support = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return nil
        }
        return support
            .appendingPathComponent("Omramo", isDirectory: true)
            .appendingPathComponent("reader-memory.json")
    }
}
