import Foundation
import Observation
import OmramoCore

/// The reading log: which page of which story was read on which calendar day, and which stories
/// were finished (M4 subset). A small JSON file in Application Support, next to the reading
/// progress. Nothing here leaves the device.
///
/// **No time of day, no duration and no timer is stored or shown.** The clock is read only to
/// learn which calendar day it is; what is kept is three numbers (year, month, day).
@MainActor
@Observable
final class ReadingLogStore {
    private(set) var file: ReadingLogFile
    private let fileURL: URL?
    /// Which calendar day it is on this device. Injected so tests can choose the day.
    private let currentDay: @MainActor () -> ReadingDay

    /// - Parameters:
    ///   - fileURL: where to keep the file. Pass nil for an in-memory store (tests, previews).
    ///   - currentDay: nil reads the device's calendar.
    init(fileURL: URL? = ReadingLogStore.defaultFileURL(), currentDay: (@MainActor () -> ReadingDay)? = nil) {
        self.fileURL = fileURL
        self.currentDay = currentDay ?? { ReadingDay(date: Date(), calendar: Calendar.current) }
        self.file = ReadingLogStore.load(from: fileURL)
    }

    /// An in-memory store that already holds a log (the debug demo state, tests).
    init(seed: ReadingLogFile, currentDay: (@MainActor () -> ReadingDay)? = nil) {
        self.fileURL = nil
        self.currentDay = currentDay ?? { ReadingDay(date: Date(), calendar: Calendar.current) }
        self.file = seed
    }

    var today: ReadingDay {
        currentDay()
    }

    /// One page read today: called once for each forward turn that leaves a page.
    func recordPageRead(storyID: StoryID, spreadID: SpreadID) {
        file.recordPageRead(storyID: storyID, spreadID: spreadID, on: currentDay())
        save()
    }

    func markFinished(_ storyID: StoryID) {
        if file.markFinished(storyID) {
            save()
        }
    }

    func isFinished(_ storyID: StoryID) -> Bool {
        file.isFinished(storyID)
    }

    /// What the streak card shows today.
    var streak: StreakSummary {
        StreakSummary(log: file, today: currentDay())
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
            // Losing a tick on the streak card is not worth interrupting a child's reading for.
            #if DEBUG
            print("[Omramo] could not save the reading log: \(error)")
            #endif
        }
    }

    private static func load(from fileURL: URL?) -> ReadingLogFile {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else {
            return ReadingLogFile()
        }
        guard let stored = try? JSONDecoder().decode(ReadingLogFile.self, from: data),
              stored.schemaVersion <= ReadingLogFile.currentSchemaVersion else {
            // Unreadable or from a newer app version: start fresh rather than crash.
            return ReadingLogFile()
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
            .appendingPathComponent("reading-log.json")
    }
}
