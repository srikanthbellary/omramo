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
    let layoutProvider: any PaneLayoutProvider
    /// Font files that could not be found or registered; empty when all is well.
    let fontProblems: [String]

    init() {
        fontProblems = FontRegistrar.registerBundledFonts()
        router = AppRouter()
        progress = ReadingProgressStore()
        memory = ReaderMemoryStore()
        layoutProvider = PaneLayoutProviders.current()
        loadContent()

        #if DEBUG
        for problem in fontProblems {
            print("[Omramo] font problem: \(problem)")
        }
        if let storyID = DebugLaunch.storyID() {
            if case .loaded(let loaded) = library, loaded.story(id: storyID) != nil {
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
        do {
            let repository = try BundledContent.repository()
            library = .loaded(try repository.loadLibrary(validator: StoryValidator(mode: .development)))
        } catch {
            library = .failed(message: error.localizedDescription)
        }
    }
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

    func open(_ storyID: StoryID) {
        route = .reader(storyID)
    }

    func showLibrary() {
        route = .library
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

    static func value(after flag: String, in arguments: [String] = ProcessInfo.processInfo.arguments) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              index + 1 < arguments.count else { return nil }
        let raw = arguments[index + 1]
        guard !raw.isEmpty, !raw.hasPrefix("-") else { return nil }
        return raw
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
}
#endif
