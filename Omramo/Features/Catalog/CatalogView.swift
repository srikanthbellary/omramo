import SwiftUI
import OmramoCore

/// Free browsing. Posters, titles and descriptions only; tapping opens the
/// two page sample, never the full book.
struct CatalogView: View {
    @Environment(CatalogStore.self) private var catalog
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(AppNavigator.self) private var navigator

    private let columns = [GridItem(.adaptive(minimum: 170, maximum: 240), spacing: 20, alignment: .top)]

    var body: some View {
        Group {
            switch catalog.state {
            case .idle, .loading:
                ProgressView("Opening the library")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                ContentUnavailableView(
                    "No titles yet",
                    systemImage: "books.vertical",
                    description: Text("New Telugu stories are on their way.")
                )
            case .failed(let failure):
                ContentUnavailableView {
                    Label("The library did not open", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(failure.message)
                } actions: {
                    if failure.isRetryable {
                        Button("Try again") {
                            Task { await catalog.load() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            case .loaded(let books):
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 28) {
                        ForEach(books) { book in
                            Button {
                                navigator.showSample(for: book.id)
                            } label: {
                                BookCard(book: book)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(Text("Opens a two page sample"))
                        }
                    }
                    .padding(20)
                }
                .background(OmramoPalette.paper)
            }
        }
        .navigationTitle(Brand.displayName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AccessBadge(state: entitlements.effectiveState)
            }
        }
    }
}

/// Quiet status pill so readers always know whether they are browsing free
/// or reading with all access.
struct AccessBadge: View {
    let state: EntitlementState

    var body: some View {
        switch state {
        case .unknown:
            ProgressView()
                .controlSize(.small)
        case .notSubscribed:
            Text("Browsing free")
                .font(.caption.weight(.medium))
                .foregroundStyle(OmramoPalette.inkSoft)
        case .subscribed:
            Label("All access", systemImage: "checkmark.seal.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(OmramoPalette.saffron)
        }
    }
}

#Preview("Catalog") {
    let environment = AppEnvironment.preview()
    return NavigationStack {
        CatalogView()
    }
    .environment(environment.catalog)
    .environment(environment.entitlements)
    .environment(environment.navigator)
    .task { await environment.catalog.load() }
}
