import SwiftUI
import OmramoCore

/// Splash, then the catalog. The paywall is presented from here as a full
/// screen cover so it can interrupt either the sample or the reader.
struct RootView: View {
    @Environment(AppNavigator.self) private var navigator
    @Environment(CatalogStore.self) private var catalog
    @Environment(EntitlementStore.self) private var entitlements

    @State private var showsSplash = true

    var body: some View {
        @Bindable var navigator = navigator

        ZStack {
            NavigationStack(path: $navigator.path) {
                CatalogView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .sample(let bookID):
                            SampleSpreadView(bookID: bookID)
                        case .reader(let bookID):
                            ReaderView(bookID: bookID)
                        }
                    }
            }
            .tint(OmramoPalette.saffron)

            if showsSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .fullScreenCover(item: $navigator.paywallBookID, onDismiss: { navigator.paywallDidDismiss() }) { _ in
            PaywallView()
        }
        .task {
            await catalog.loadIfNeeded()
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation(.easeOut(duration: 0.45)) {
                showsSplash = false
            }
        }
    }
}

/// OM | RA | MO opening into a book, then out of the way. Kept short: the
/// wow moment is the sample, not the splash.
struct SplashView: View {
    @State private var isOpen = false

    var body: some View {
        ZStack {
            OmramoPalette.paper.ignoresSafeArea()
            VStack(spacing: 28) {
                OmRaMoMark(isOpen: isOpen)
                Text("Omramo")
                    .font(OmramoType.displayTitle)
                    .foregroundStyle(OmramoPalette.ink)
                    .opacity(isOpen ? 1 : 0)
                Text("తెలుగు కథలు, తెరిచిన పుస్తకంలా")
                    .font(OmramoType.cardSubtitle)
                    .foregroundStyle(OmramoPalette.inkSoft)
                    .opacity(isOpen ? 1 : 0)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(350))
            isOpen = true
        }
        .accessibilityAddTraits(.isModal)
    }
}

#Preview("Root") {
    let environment = AppEnvironment.preview()
    return RootView()
        .environment(environment.catalog)
        .environment(environment.entitlements)
        .environment(environment.navigator)
}
