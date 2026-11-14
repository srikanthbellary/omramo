import Foundation
import Observation
import OmramoCore

/// Composition root: builds the long-lived objects once and hands them to the views.
@MainActor
@Observable
final class AppEnvironment {
    private(set) var library: LoadState<Library> = .idle
    let router: AppRouter
    let progress: ReadingProgressStore
    /// Text size, bookmarks, seen cards and friends met.
    let memory: ReaderMemoryStore
    /// Pages read by calendar day, and stories finished (never a time or a duration).
    let log: ReadingLogStore
    let layoutProvider: any PaneLayoutProvider
    /// Font files that could not be found or registered; empty when all is well.
    let fontProblems: [String]

    init() {
        fontProblems = FontRegistrar.registerBundledFonts()
        router = AppRouter()
        layoutProvider = PaneLayoutProviders.current()
        let loaded = AppEnvironment.loadedContent()

        #if DEBUG
        if DebugLaunch.hasFlag(DebugLaunch.demoStateArgument), case .loaded(let content) = loaded {
            // Screenshots: a small, made-up reading history, kept in memory only.
            let demo = DebugLaunch.demoState(for: content)
            progress = ReadingProgressStore(seed: demo.progress)
            memory = ReaderMemoryStore(seed: demo.memory)
            log = ReadingLogStore(seed: demo.log)
        } else if DebugLaunch.hasFlag(DebugLaunch.resetStateArgument) {
            // UI tests: start from nothing and write nothing to the device.
            progress = ReadingProgressStore(fileURL: nil)
            memory = ReaderMemoryStore(fileURL: nil)
            log = ReadingLogStore(fileURL: nil)
        } else {
            progress = ReadingProgressStore()
            memory = ReaderMemoryStore()
            log = ReadingLogStore()
        }
        #else
        progress = ReadingProgressStore()
        memory = ReaderMemoryStore()
        log = ReadingLogStore()
        #endif

        library = loaded

        #if DEBUG
        for problem in fontProblems {
            print("[Omramo] font problem: \(problem)")
        }
        if let storyID = DebugLaunch.storyID() {
            if case .loaded(let content) = loaded, content.story(id: storyID) != nil {
                router.open(storyID)
            } else {
                print("[Omramo] -OmramoOpenStory: '\(storyID.rawValue)' is not in the catalog")
            }
        }
        #endif
    }

    /// Loads and validates the bundled stories. The files are small, so this runs at launch
    /// on the main actor. TODO(M6): move off the main actor once real art sizes are known.
    func loadContent() {
        library = .loading
        library = AppEnvironment.loadedContent()
    }

    private static func loadedContent() -> LoadState<Library> {
        do {
            let repository = try BundledContent.repository()
            return .loaded(try repository.loadLibrary(validator: StoryValidator(mode: .development)))
        } catch {
            return .failed(message: error.localizedDescription)
        }
    }
}

/// A thing in the library that a story can be opened from: where the reader grows out of, and
/// shrinks back into.
enum HeroSource: Hashable {
    /// The large "Keep reading" card.
    case keepReading
    /// A story's cover under "Stories by level".
    case cover(StoryID)
    /// A story's row or cover on the shelf card.
    case shelf(StoryID)
}

/// Which screen is showing. Per-window state; the stores are shared.
@MainActor
@Observable
final class AppRouter {
    enum Route: Equatable {
        case library
        case reader(StoryID)
    }

    private(set) var route: Route = .library
    /// The rectangle (window coordinates) the reader opens out of and closes into; nil for a
    /// plain cross-fade.
    private(set) var heroRect: CGRect?

    /// What the open story was opened from.
    @ObservationIgnored private var heroSource: HeroSource?
    /// Where each library element is on screen now. Kept up to date by the library, which
    /// stays laid out under the reader, so closing a story after a rotation still lands on
    /// its cover. Not observed: a cover moving must not redraw anything.
    @ObservationIgnored private var frames: [HeroSource: CGRect] = [:]
    @ObservationIgnored private var closeTask: Task<Void, Never>?

    /// The library reports where a cover is.
    func report(_ frame: CGRect, for source: HeroSource) {
        frames[source] = frame
    }

    /// Opens a story. With a source, the reader grows out of that cover.
    func open(_ storyID: StoryID, from source: HeroSource? = nil) {
        closeTask?.cancel()
        closeTask = nil
        heroSource = source
        heroRect = source.flatMap { frames[$0] }
        route = .reader(storyID)
    }

    /// Back to the library. The reader closes into the cover it came from, where that cover
    /// is now. The view that is leaving uses the transition it was last drawn with, so the
    /// target rectangle is set first and the route follows a moment later.
    func showLibrary() {
        guard route != .library else { return }
        let target = heroSource.flatMap { frames[$0] }
        heroSource = nil
        if target == heroRect {
            route = .library
            return
        }
        heroRect = target
        closeTask?.cancel()
        closeTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(20))
            guard !Task.isCancelled else { return }
            self?.route = .library
        }
    }
}

#if DEBUG
/// Debug launch arguments used from `simctl launch` or the scheme's Arguments tab.
enum DebugLaunch {
    /// Opens a story at launch: `-OmramoOpenStory monkey-and-crocodile`.
    static let openStoryArgument = "-OmramoOpenStory"
    /// Opens a tap-to-see or character card on that story: `-OmramoOpenCard river-bank`.
    static let openCardArgument = "-OmramoOpenCard"
    /// Requests a device orientation: `-OmramoOrientation landscape` or `portrait`.
    static let orientationArgument = "-OmramoOrientation"
    /// Starts with empty, in-memory stores (nothing is read from or written to the device):
    /// every story opens on page 1. For UI tests.
    static let resetStateArgument = "-OmramoResetState"
    /// Starts with a small made-up reading history in memory (a streak, a story finished, one
    /// in progress, friends met), so the library can be photographed with its cards filled.
    static let demoStateArgument = "-OmramoDemoState"

    static func value(after flag: String, in arguments: [String] = ProcessInfo.processInfo.arguments) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              index + 1 < arguments.count else { return nil }
        let raw = arguments[index + 1]
        guard !raw.isEmpty, !raw.hasPrefix("-") else { return nil }
        return raw
    }

    /// True when a flag that takes no value is present.
    static func hasFlag(_ flag: String, in arguments: [String] = ProcessInfo.processInfo.arguments) -> Bool {
        arguments.contains(flag)
    }

    static func storyID(from arguments: [String] = ProcessInfo.processInfo.arguments) -> StoryID? {
        value(after: openStoryArgument, in: arguments).map { StoryID($0) }
    }

    static func cardID(from arguments: [String] = ProcessInfo.processInfo.arguments) -> String? {
        value(after: openCardArgument, in: arguments)
    }

    /// "landscape" or "portrait", if passed.
    static func orientation(from arguments: [String] = ProcessInfo.processInfo.arguments) -> String? {
        value(after: orientationArgument, in: arguments)
    }

    /// The made-up history of `-OmramoDemoState`: the first story finished, the last one in
    /// progress on its fifth page, three days of reading in a row ending today, and everyone
    /// from the first two stories met. Built from the catalog, so it holds only real ids.
    @MainActor
    static func demoState(
        for library: Library,
        today: ReadingDay = ReadingDay(date: Date(), calendar: Calendar.current)
    ) -> (progress: ReadingProgressFile, memory: ReaderMemoryFile, log: ReadingLogFile) {
        var progress = ReadingProgressFile()
        var memory = ReaderMemoryFile()
        var log = ReadingLogFile()
        let stories = library.stories

        if let first = stories.first {
            // Read over the two days before today, and finished.
            for (index, spread) in first.spreads.enumerated() {
                let day = today.adding(days: index < first.spreads.count / 2 ? -2 : -1)
                log.recordPageRead(storyID: first.id, spreadID: spread.id, on: day)
            }
            log.markFinished(first.id)
            memory.recordMet(first.characters.map(\.id), in: first.id)
        }
        if stories.count > 2, let middle = stories.dropFirst().first {
            memory.recordMet(middle.characters.map(\.id), in: middle.id)
        }
        if stories.count > 1, let last = stories.last {
            let pages = Array(last.spreads.prefix(5))
            for spread in pages.dropLast() {
                log.recordPageRead(storyID: last.id, spreadID: spread.id, on: today)
            }
            if let place = pages.last {
                progress.record(ReadingPosition(storyID: last.id, spreadID: place.id, blockID: place.blocks.first?.id))
            }
            if let hero = last.characters.first {
                memory.recordMet([hero.id], in: last.id)
            }
        }
        return (progress, memory, log)
    }
}
#endif
