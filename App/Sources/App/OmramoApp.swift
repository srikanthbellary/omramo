import SwiftUI
import UIKit
import OmramoCore

@main
struct OmramoApp: App {
    @State private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appEnvironment)
                .environment(appEnvironment.router)
                .environment(appEnvironment.progress)
                // The reading scenes carry their own light; Appearance (dark mode) for the
                // library is design gap G7. Until it is designed the app is light only.
                .preferredColorScheme(.light)
        }
    }
}

/// Switches between the app's screens. There is no navigation bar: every screen draws its own
/// chrome on the panes.
struct RootView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(AppRouter.self) private var router

    var body: some View {
        PaneLayoutReader(provider: appEnvironment.layoutProvider) {
            switch appEnvironment.library {
            case .idle, .loading:
                // TODO(M6): designed loading state (gap G10) and the splash (screen 01).
                AuroraBackdrop(aurora: .light)
            case .failed(let message):
                ContentFailureView(message: message)
            case .loaded(let library):
                screen(for: router.route, in: library)
            }
        }
        .statusBarHidden(false)
        #if DEBUG
        .task {
            await DebugLaunch.applyRequestedOrientation()
        }
        #endif
    }

    @ViewBuilder
    private func screen(for route: AppRouter.Route, in library: Library) -> some View {
        switch route {
        case .library:
            LibraryScreen(library: library)
        case .reader(let storyID):
            if let story = library.story(id: storyID) {
                ReaderScreen(
                    story: story,
                    landmarks: library.landmarks,
                    progress: appEnvironment.progress,
                    memory: appEnvironment.memory,
                    router: router
                )
                    // A new story is a new reader: do not carry state across.
                    .id(storyID)
            } else {
                LibraryScreen(library: library)
            }
        }
    }
}

/// Shown when the bundled content cannot be loaded. A developer-facing message for now.
/// TODO(M6): designed error state (gap G10).
struct ContentFailureView: View {
    let message: String

    var body: some View {
        ZStack {
            Color(rgba: Tokens.Palette.surfaceLight)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(verbatim: "The stories could not be opened.")
                        .font(.headline)
                    Text(verbatim: message)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                }
                .foregroundStyle(Color(rgba: Tokens.Palette.ink))
                .padding(32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 40)
        }
    }
}

#if DEBUG
extension DebugLaunch {
    /// Ask the window scene to rotate. Used from `simctl` so iPad landscape shots do not
    /// depend on Simulator's GUI (which needs Accessibility permission).
    @MainActor
    static func applyRequestedOrientation() async {
        let mask: UIInterfaceOrientationMask
        switch orientation() {
        case "landscape": mask = .landscape
        case "portrait": mask = .portrait
        default: return
        }
        // The scene may not be connected on the first frame.
        for attempt in 0..<8 {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            if !scenes.isEmpty {
                for scene in scenes {
                    scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { error in
                        print("[Omramo] -OmramoOrientation failed: \(error)")
                    }
                }
                try? await Task.sleep(for: .milliseconds(350))
                return
            }
            try? await Task.sleep(for: .milliseconds(100 + attempt * 50))
        }
        print("[Omramo] -OmramoOrientation: no window scene yet")
    }
}
#endif
