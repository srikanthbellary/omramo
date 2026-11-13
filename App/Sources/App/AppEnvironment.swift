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
    let layoutProvider: any PaneLayoutProvider
    /// Font files that could not be found or registered; empty when all is well.
    let fontProblems: [String]

    init() {
        fontProblems = FontRegistrar.registerBundledFonts()
        router = AppRouter()
        progress = ReadingProgressStore()
        layoutProvider = PaneLayoutProviders.current()
        loadContent()

        #if DEBUG
        for problem in fontProblems {
            print("[Omramo] font problem: \(problem)")
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
