import SwiftUI
import OmramoCore

/// Free browsing. Posters, titles and descriptions only. Tapping opens the
/// two page sample unless the reader already has all access.
///
/// On the inner display the shelf is two panes, like everything else in the
/// app: titles alternate left and right and the fold region stays empty. On
/// the outer display it is one adaptive grid.
struct CatalogView: View {
    @Environment(CatalogStore.self) private var catalog
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(AppNavigator.self) private var navigator

    @State private var showsSettings = false

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
                OpenBookSpread { arrangement, pageWidth in
                    ScrollView {
                        switch arrangement {
                        case .single:
                            shelf(books)
                                .padding(20)
                        case .dual(let spineWidth):
                            HStack(alignment: .top, spacing: 0) {
                                shelf(Self.pane(books, side: 0))
                                    .padding(20)
                                    .frame(width: pageWidth)
                                Spacer()
                                    .frame(width: spineWidth)
                                shelf(Self.pane(books, side: 1))
                                    .padding(20)
                                    .frame(width: pageWidth)
                            }
                        }
                    }
                }
                .background(OmramoPalette.paper)
            }
        }
        .navigationTitle(Brand.displayName)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showsSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                AccessBadge(state: entitlements.effectiveState)
            }
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView()
        }
    }

    private func shelf(_ books: [Book]) -> some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 28) {
            ForEach(books) { book in
                Button {
                    navigator.openTitle(for: book.id, state: entitlements.effectiveState)
                } label: {
                    BookCard(book: book)
                }
                .buttonStyle(.plain)
                .accessibilityHint(Text(entitlements.effectiveState.allowsReading ? "Opens the book" : "Opens a two page sample"))
            }
        }
    }

    /// Alternate titles between the two panes so both shelves fill evenly.
    private static func pane(_ books: [Book], side: Int) -> [Book] {
        books.enumerated().filter { $0.offset % 2 == side }.map(\.element)
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
    .environment(environment.settings)
    .task { await environment.catalog.load() }
}
