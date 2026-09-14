import SwiftUI
import OmramoCore

/// The wow moment. The title opens as a two page book across both panes;
/// on a compact outer display it is one page with a page turn. Ends at the
/// hard paywall.
struct SampleSpreadView: View {
    let bookID: BookID

    @Environment(CatalogStore.self) private var catalog
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(AppNavigator.self) private var navigator

    @State private var content: LoadState<ReaderContent> = .idle
    @State private var mode: SpreadMode = .facingPages
    @State private var singlePaneIndex = 0

    var body: some View {
        Group {
            if let book = catalog.book(id: bookID) {
                spreadBody(for: book)
            } else {
                ContentUnavailableView("That title is not in the library right now.", systemImage: "book.closed")
            }
        }
        .background(BookshelfBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .task(id: bookID) { await load() }
    }

    @ViewBuilder
    private func spreadBody(for book: Book) -> some View {
        VStack(spacing: 0) {
            switch content {
            case .idle, .loading:
                ProgressView("Opening the book")
                    .tint(OmramoPalette.paper)
                    .foregroundStyle(OmramoPalette.paper)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                ContentUnavailableView("This title has no pages yet.", systemImage: "doc")
                    .foregroundStyle(OmramoPalette.paper)
            case .failed(let failure):
                ContentUnavailableView {
                    Label("The sample did not open", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(failure.message)
                } actions: {
                    if failure.isRetryable {
                        Button("Try again") { Task { await load() } }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .foregroundStyle(OmramoPalette.paper)
            case .loaded(let reader):
                OpenBookSpread { arrangement, pageWidth in
                    sampleSpread(reader, arrangement: arrangement, pageWidth: pageWidth)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .shadow(color: .black.opacity(0.4), radius: 24, y: 12)

                SampleFooter(
                    book: book,
                    modes: SpreadMode.available(for: book).filter { $0 != .illustrated },
                    mode: $mode,
                    decision: entitlements.decision
                ) {
                    navigator.openReader(for: book.id, decision: entitlements.decision)
                }
            }
        }
        .navigationTitle(book.title.resolved(in: .telugu))
    }

    @ViewBuilder
    private func sampleSpread(_ reader: ReaderContent, arrangement: PaneArrangement, pageWidth: CGFloat) -> some View {
        let sampleCount = min(reader.book.sample.pageCount, reader.pageCount)
        switch arrangement {
        case .single:
            // Outer display: one page at a time, swipe or tap to turn within the sample.
            TabView(selection: $singlePaneIndex) {
                ForEach(0..<sampleCount, id: \.self) { index in
                    if let page = reader.primary.page(at: index) {
                        PageView(page: page, language: .primary)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        case .dual(let spineWidth):
            BookPanes(pageWidth: pageWidth, spineWidth: spineWidth) {
                if let page = reader.primary.page(at: 0) {
                    PageView(page: page, language: .primary)
                } else {
                    BlankPageView()
                }
            } right: {
                switch mode {
                case .synced(let secondary):
                    if let edition = reader.edition(for: secondary), let page = edition.page(at: 0) {
                        PageView(page: page, language: secondary)
                    } else {
                        BlankPageView()
                    }
                case .facingPages, .illustrated:
                    if sampleCount > 1, let page = reader.primary.page(at: 1) {
                        PageView(page: page, language: .primary)
                    } else {
                        BlankPageView()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func load() async {
        guard let book = catalog.book(id: bookID) else { return }
        content = .loading
        do {
            let reader = try await catalog.loadReaderContent(for: book)
            content = reader.pageCount == 0 ? .empty : .loaded(reader)
        } catch {
            content = .failed(LoadFailure(error))
        }
    }
}

/// Sample controls plus the gate. Copy is deliberate: readers learn here that
/// one subscription opens every title.
private struct SampleFooter: View {
    let book: Book
    let modes: [SpreadMode]
    @Binding var mode: SpreadMode
    let decision: AccessDecision
    let onContinue: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        VStack(spacing: 14) {
            if horizontalSizeClass == .regular, modes.count > 1 {
                Picker("Spread", selection: $mode) {
                    ForEach(modes, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 360)
            }

            VStack(spacing: 6) {
                Text("You have read the free sample of \(book.title.resolved(in: .english))")
                    .font(OmramoType.cardTitle)
                    .foregroundStyle(OmramoPalette.paper)
                    .multilineTextAlignment(.center)
                Text("Subscribe once and read every title in Omramo, in every edition.")
                    .font(OmramoType.cardSubtitle)
                    .foregroundStyle(OmramoPalette.paper.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            Button(action: onContinue) {
                Group {
                    switch decision {
                    case .wait:
                        ProgressView()
                            .tint(OmramoPalette.paper)
                    case .showPaywall:
                        Text("Subscribe to continue reading")
                    case .allow:
                        Text("Continue reading")
                    }
                }
                .frame(maxWidth: 360)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(OmramoPalette.saffron)
            .disabled(decision == .wait)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(OmramoPalette.ink.opacity(0.25))
    }
}

#Preview("Sample") {
    let environment = AppEnvironment.preview()
    return NavigationStack {
        SampleSpreadView(bookID: BookID("godavari-oddu"))
    }
    .environment(environment.catalog)
    .environment(environment.entitlements)
    .environment(environment.navigator)
    .task { await environment.catalog.load() }
}
