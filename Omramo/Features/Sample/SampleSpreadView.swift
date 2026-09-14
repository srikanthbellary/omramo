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
            } else if catalog.state.isIdle || catalog.state.isLoading {
                ProgressView("Opening the book")
                    .tint(OmramoPalette.onShelf)
                    .foregroundStyle(OmramoPalette.onShelf)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView("That title is not in the library right now.", systemImage: "book.closed")
            }
        }
        .background(BookshelfBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .task(id: bookID) {
            await catalog.loadIfNeeded()
            await load()
        }
    }

    @ViewBuilder
    private func spreadBody(for book: Book) -> some View {
        VStack(spacing: 0) {
            switch content {
            case .idle, .loading:
                ProgressView("Opening the book")
                    .tint(OmramoPalette.onShelf)
                    .foregroundStyle(OmramoPalette.onShelf)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                ContentUnavailableView("This title has no pages yet.", systemImage: "doc")
                    .foregroundStyle(OmramoPalette.onShelf)
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
                .foregroundStyle(OmramoPalette.onShelf)
            case .loaded(let reader):
                // Footer lives inside the spread so it can split around the
                // fold the same way the pages do. The chosen mode is view
                // state and survives a compact <-> regular change.
                OpenBookSpread { arrangement, pageWidth in
                    VStack(spacing: 0) {
                        sampleSpread(reader, arrangement: arrangement, pageWidth: pageWidth)
                            .shadow(color: .black.opacity(0.4), radius: 24, y: 12)
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                        SampleFooter(
                            book: book,
                            modes: SpreadMode.available(for: book).filter { $0 != .illustrated },
                            mode: $mode,
                            decision: entitlements.decision,
                            arrangement: arrangement,
                            pageWidth: pageWidth
                        ) {
                            navigator.openReader(for: book.id, state: entitlements.effectiveState)
                        }
                    }
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
            // Outer display: a real one pane reader. Swipe between the sample
            // pages; synced mode stacks the second edition under the first.
            TabView(selection: $singlePaneIndex) {
                ForEach(0..<sampleCount, id: \.self) { index in
                    if let page = reader.primary.page(at: index) {
                        PageView(page: page, language: .primary, companion: companion(reader, index: index))
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

    private func companion(_ reader: ReaderContent, index: Int) -> CompanionPage? {
        guard case .synced(let secondary) = mode,
              let page = reader.edition(for: secondary)?.page(at: index) else { return nil }
        return CompanionPage(page: page, language: secondary)
    }

    private func load() async {
        guard let book = catalog.book(id: bookID) else { return }
        content = .loading
        do {
            let reader = try await catalog.loadSampleContent(for: book)
            content = reader.pageCount == 0 ? .empty : .loaded(reader)
        } catch {
            content = .failed(LoadFailure(error))
        }
    }
}

/// Sample controls plus the gate. Copy is deliberate: readers learn here that
/// one subscription opens every title. With two panes the footer follows the
/// pages: message under the left page, controls under the right, fold empty.
private struct SampleFooter: View {
    let book: Book
    let modes: [SpreadMode]
    @Binding var mode: SpreadMode
    let decision: AccessDecision
    let arrangement: PaneArrangement
    let pageWidth: CGFloat
    let onContinue: () -> Void

    var body: some View {
        Group {
            switch arrangement {
            case .single:
                VStack(spacing: 14) {
                    modePicker
                    message(alignment: .center)
                    continueButton
                }
                .padding(.horizontal, 20)
            case .dual(let spineWidth):
                HStack(alignment: .top, spacing: 0) {
                    message(alignment: .leading)
                        .frame(width: pageWidth, alignment: .leading)
                    Spacer()
                        .frame(width: spineWidth)
                    VStack(spacing: 14) {
                        modePicker
                        continueButton
                    }
                    .frame(width: pageWidth)
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.25))
    }

    @ViewBuilder
    private var modePicker: some View {
        if modes.count > 1 {
            Picker("Spread", selection: $mode) {
                ForEach(modes, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 360)
        }
    }

    private func message(alignment: TextAlignment) -> some View {
        VStack(alignment: alignment == .center ? .center : .leading, spacing: 6) {
            Text("You have read the free sample of \(book.title.resolved(in: .english))")
                .font(OmramoType.cardTitle)
                .foregroundStyle(OmramoPalette.onShelf)
                .multilineTextAlignment(alignment)
            Text("Subscribe once and read every title in \(Brand.displayName), in every edition.")
                .font(OmramoType.cardSubtitle)
                .foregroundStyle(OmramoPalette.onShelf.opacity(0.8))
                .multilineTextAlignment(alignment)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
    }

    private var continueButton: some View {
        Button(action: onContinue) {
            Group {
                switch decision {
                case .wait:
                    ProgressView()
                        .tint(OmramoPalette.onShelf)
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
