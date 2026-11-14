import Foundation
import Observation
import OmramoCore

/// Reading position per story, kept in a small JSON file in Application Support.
/// Nothing here leaves the device, and no times or durations are stored.
@MainActor
@Observable
final class ReadingProgressStore {
    private(set) var file: ReadingProgressFile
    private let fileURL: URL?

    /// - Parameter fileURL: where to keep the file. Pass nil for an in-memory store (tests, previews).
    init(fileURL: URL? = ReadingProgressStore.defaultFileURL()) {
        self.fileURL = fileURL
        self.file = ReadingProgressStore.load(from: fileURL)
    }

    /// An in-memory store that already holds positions (the debug demo state, tests).
    init(seed: ReadingProgressFile) {
        self.fileURL = nil
        self.file = seed
    }

    func position(for storyID: StoryID) -> ReadingPosition? {
        file.position(for: storyID)
    }

    /// The story to offer under "Keep reading", if any.
    var lastPosition: ReadingPosition? {
        guard let storyID = file.lastStoryID else { return nil }
        return file.position(for: storyID)
    }

    func record(_ position: ReadingPosition) {
        file.record(position)
        save()
    }

    func clear(storyID: StoryID) {
        file.clear(storyID: storyID)
        save()
    }

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
            // Losing a bookmark is not worth interrupting a child's reading for.
            #if DEBUG
            print("[Omramo] could not save reading progress: \(error)")
            #endif
        }
    }

    private static func load(from fileURL: URL?) -> ReadingProgressFile {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else {
            return ReadingProgressFile()
        }
        guard let stored = try? JSONDecoder().decode(ReadingProgressFile.self, from: data),
              stored.schemaVersion <= ReadingProgressFile.currentSchemaVersion else {
            // Unreadable or from a newer app version: start fresh rather than crash.
            return ReadingProgressFile()
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
            .appendingPathComponent("reading-progress.json")
    }
}
