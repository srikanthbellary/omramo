import Foundation

// Reading log, streak and shelf (docs/IMPLEMENTATION_PLAN.md M4; docs/ARCHITECTURE.md §10).
//
// What is remembered: **which page of which story was read on which calendar day**, and which
// stories were finished. Never a time of day, never a duration, never a timer: the app counts
// pages read, not screen time. A day is stored as year / month / day numbers, so it cannot
// carry a time, and it never changes when the device's time zone does.

/// A calendar day as the child saw it on the device: plain year, month and day numbers.
public struct ReadingDay: Codable, Hashable, Comparable, Sendable, CustomStringConvertible {
    public var year: Int
    public var month: Int
    public var day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// The day that `date` falls on in `calendar` (its time zone decides). The time of day is
    /// dropped here and is never stored anywhere.
    public init(date: Date, calendar: Calendar) {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: parts.year ?? 1970, month: parts.month ?? 1, day: parts.day ?? 1)
    }

    public var description: String {
        let m = month < 10 ? "0\(month)" : "\(month)"
        let d = day < 10 ? "0\(day)" : "\(day)"
        return "\(year)-\(m)-\(d)"
    }

    public static func < (lhs: ReadingDay, rhs: ReadingDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    /// Days since 1 January 1970 in the proleptic Gregorian calendar. Pure arithmetic: no
    /// clock and no time zone are involved, so "the day after" is always exactly one more.
    public var ordinal: Int {
        let y = month <= 2 ? year - 1 : year
        let era = (y >= 0 ? y : y - 399) / 400
        let yearOfEra = y - era * 400
        let shiftedMonth = month > 2 ? month - 3 : month + 9
        let dayOfYear = (153 * shiftedMonth + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146097 + dayOfEra - 719468
    }

    public init(ordinal: Int) {
        let z = ordinal + 719468
        let era = (z >= 0 ? z : z - 146096) / 146097
        let dayOfEra = z - era * 146097
        let yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36524 - dayOfEra / 146096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let shiftedMonth = (5 * dayOfYear + 2) / 153
        let day = dayOfYear - (153 * shiftedMonth + 2) / 5 + 1
        let month = shiftedMonth < 10 ? shiftedMonth + 3 : shiftedMonth - 9
        let year = yearOfEra + era * 400 + (month <= 2 ? 1 : 0)
        self.init(year: year, month: month, day: day)
    }

    public func adding(days: Int) -> ReadingDay {
        ReadingDay(ordinal: ordinal + days)
    }

    /// 0 = Monday … 6 = Sunday.
    public var weekdayFromMonday: Int {
        // 1 January 1970 was a Thursday (3 when Monday is 0).
        let shifted = (ordinal + 3) % 7
        return shifted >= 0 ? shifted : shifted + 7
    }
}

/// One page read: the day, the story and the page (spread). Nothing else.
public struct PageRead: Codable, Hashable, Sendable {
    public var day: ReadingDay
    public var storyID: StoryID
    public var spreadID: SpreadID

    public init(day: ReadingDay, storyID: StoryID, spreadID: SpreadID) {
        self.day = day
        self.storyID = storyID
        self.spreadID = spreadID
    }
}

/// The reading log as stored on the device.
public struct ReadingLogFile: Codable, Hashable, Sendable {
    public static let currentSchemaVersion = 1
    /// Entries older than this many days before the newest are dropped when a page is added:
    /// the streak and the shelf never look further back, and the file stays small.
    public static let daysKept = 400

    public var schemaVersion: Int
    /// In the order the pages were read.
    public var entries: [PageRead]
    /// Stories read to the end, in the order they were first finished.
    public var finished: [StoryID]
    /// Pages read in entries that have been dropped, so "pages read" stays a true total.
    public var earlierPages: Int

    public init(
        schemaVersion: Int = ReadingLogFile.currentSchemaVersion,
        entries: [PageRead] = [],
        finished: [StoryID] = [],
        earlierPages: Int = 0
    ) {
        self.schemaVersion = schemaVersion
        self.entries = entries
        self.finished = finished
        self.earlierPages = earlierPages
    }

    /// Records one page read. Called once for each forward turn of the round button that
    /// leaves a page (and once for the last page when the story is finished) — never for a
    /// continuation screen of the same page, for going back, or for opening a story.
    /// Reading the same page again on another turn counts again (rule per PRD Q14: "every
    /// forward turn counts").
    public mutating func recordPageRead(storyID: StoryID, spreadID: SpreadID, on day: ReadingDay) {
        entries.append(PageRead(day: day, storyID: storyID, spreadID: spreadID))
        let cutoff = day.ordinal - ReadingLogFile.daysKept
        if let first = entries.first, first.day.ordinal < cutoff {
            let kept = entries.filter { $0.day.ordinal >= cutoff }
            earlierPages += entries.count - kept.count
            entries = kept
        }
    }

    /// Marks a story as read to the end. Returns true the first time.
    @discardableResult
    public mutating func markFinished(_ storyID: StoryID) -> Bool {
        guard !finished.contains(storyID) else { return false }
        finished.append(storyID)
        return true
    }

    public func isFinished(_ storyID: StoryID) -> Bool {
        finished.contains(storyID)
    }

    /// Every day on which at least one page was read.
    public var readingDays: Set<ReadingDay> {
        Set(entries.map(\.day))
    }

    public func pagesRead(on day: ReadingDay) -> Int {
        entries.reduce(0) { $0 + ($1.day == day ? 1 : 0) }
    }

    /// All pages ever read.
    public var totalPagesRead: Int {
        earlierPages + entries.count
    }
}

/// Days in a row. A day counts when at least one page was read on it.
public enum StreakCalculator {
    /// The run of consecutive reading days that ends today — or, if nothing has been read yet
    /// today, the run that ended yesterday: the streak is still alive until today is over, and
    /// the app never tells a child they have "lost" anything.
    public static func currentStreak(days: Set<ReadingDay>, today: ReadingDay) -> Int {
        var cursor = today.ordinal
        if !days.contains(today) {
            cursor -= 1
        }
        var count = 0
        while days.contains(ReadingDay(ordinal: cursor)) {
            count += 1
            cursor -= 1
        }
        return count
    }

    /// The longest run of consecutive reading days in the log.
    public static func longestStreak(days: Set<ReadingDay>) -> Int {
        var best = 0
        for day in days where !days.contains(day.adding(days: -1)) {
            var length = 1
            var next = day.adding(days: 1)
            while days.contains(next) {
                length += 1
                next = next.adding(days: 1)
            }
            best = max(best, length)
        }
        return best
    }

    /// The seven days, Monday to Sunday, of the week that holds `day`.
    public static func week(containing day: ReadingDay) -> [ReadingDay] {
        let monday = day.adding(days: -day.weekdayFromMonday)
        return (0..<7).map { monday.adding(days: $0) }
    }
}

/// One circle of the streak card's week row.
public struct StreakDay: Equatable, Hashable, Sendable, Identifiable {
    public var day: ReadingDay
    /// "M", "T", "W", "T", "F", "S", "S".
    public var letter: String
    public var isRead: Bool
    public var isToday: Bool
    /// Later than today: drawn empty, never as a miss.
    public var isFuture: Bool

    public var id: ReadingDay { day }
}

/// What the streak card shows. Gentle by construction: it has words for "nothing yet" and for
/// a run of days, and no words at all for a missed day.
public struct StreakSummary: Equatable, Sendable {
    public var count: Int
    public var week: [StreakDay]
    public var readToday: Bool

    public static let letters = ["M", "T", "W", "T", "F", "S", "S"]

    public init(log: ReadingLogFile, today: ReadingDay) {
        let days = log.readingDays
        count = StreakCalculator.currentStreak(days: days, today: today)
        readToday = days.contains(today)
        week = StreakCalculator.week(containing: today).enumerated().map { index, day in
            StreakDay(
                day: day,
                letter: StreakSummary.letters[index],
                isRead: days.contains(day),
                isToday: day == today,
                isFuture: day > today
            )
        }
    }

    /// "3 days in a row". Never a warning, never a countdown.
    public var title: String {
        switch count {
        case 0: return "Your reading days"
        case 1: return "1 day of reading"
        default: return "\(count) days in a row"
        }
    }

    /// The short chip beside the wordmark; nil when there is nothing to show yet.
    public var chipText: String? {
        switch count {
        case 0: return nil
        case 1: return "1 day"
        default: return "\(count) days"
        }
    }

    public static let caption = "A day counts when you read a page"
}

/// The shelf: the story to keep reading, the stories finished, and pages read.
public struct ShelfState: Equatable, Sendable {
    /// A story with a saved place.
    public struct InProgress: Equatable, Sendable, Identifiable {
        public var storyID: StoryID
        /// 1-based.
        public var page: Int
        public var pageCount: Int

        public var id: StoryID { storyID }

        public var fraction: Double {
            pageCount > 0 ? min(1, Double(page) / Double(pageCount)) : 0
        }
    }

    /// The story read most recently, if it still has a saved place.
    public var keepReading: InProgress?
    /// Other stories with a saved place, in catalog order.
    public var alsoReading: [InProgress]
    /// Finished stories that are in the catalog, in the order they were finished.
    public var finished: [StoryID]
    public var pagesRead: Int

    public init(stories: [Story], progress: ReadingProgressFile, log: ReadingLogFile) {
        var others: [InProgress] = []
        var current: InProgress?
        for story in stories {
            guard let position = progress.position(for: story.id) else { continue }
            let pager = Pager(story: story)
            guard let page = pager.pageNumber(of: position.spreadID) else { continue }
            let entry = InProgress(storyID: story.id, page: page, pageCount: pager.pageCount)
            if story.id == progress.lastStoryID {
                current = entry
            } else {
                others.append(entry)
            }
        }
        keepReading = current
        alsoReading = others
        let known = Set(stories.map(\.id))
        finished = log.finished.filter { known.contains($0) }
        pagesRead = log.totalPagesRead
    }

    public var isEmpty: Bool {
        keepReading == nil && alsoReading.isEmpty && finished.isEmpty && pagesRead == 0
    }

    /// "2 stories finished · 25 pages read"; nil when nothing has been read.
    public var summary: String? {
        guard pagesRead > 0 || !finished.isEmpty else { return nil }
        let stories = finished.count == 1 ? "1 story finished" : "\(finished.count) stories finished"
        let pages = pagesRead == 1 ? "1 page read" : "\(pagesRead) pages read"
        return finished.isEmpty ? pages : "\(stories) · \(pages)"
    }
}

/// A character the reader has met, for "Friends you have met".
public struct FriendMet: Equatable, Hashable, Sendable, Identifiable {
    public var storyID: StoryID
    public var character: StoryCharacter

    public var id: String { storyID.rawValue + "/" + character.id.rawValue }

    /// The short name under the face: "Monkey", "Anansi", "Tortoise".
    public var shortName: String {
        FriendMet.shortName(for: character.name)
    }

    /// Drops a leading "the" or a title ("Father", "Princess") and capitalises what is left,
    /// so a name fits under a 56-point face. "Kweku Tsin" and "Mother Crocodile" stay whole.
    public static func shortName(for name: String) -> String {
        var words = name.split(separator: " ").map(String.init)
        if let first = words.first, words.count > 1, ["the", "father", "princess"].contains(first.lowercased()) {
            words.removeFirst()
        }
        if words.count > 1, name.count > 12, let first = words.first, first.lowercased() != "mother" {
            // "Urashima Taro" → "Urashima".
            words = [first]
        }
        let joined = words.joined(separator: " ")
        guard let initial = joined.first else { return name }
        return initial.uppercased() + String(joined.dropFirst())
    }

    /// Everyone met so far, story by story in catalog order, each in the order they were met.
    public static func all(stories: [Story], memory: ReaderMemoryFile) -> [FriendMet] {
        var result: [FriendMet] = []
        for story in stories {
            for id in memory.friends(in: story.id) {
                if let character = story.character(id: id) {
                    result.append(FriendMet(storyID: story.id, character: character))
                }
            }
        }
        return result
    }
}
