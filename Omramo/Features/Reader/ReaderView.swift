import SwiftUI
import OmramoCore

/// Full reading experience. Reached only through the entitlement gate; still
/// checks every page so a lapsed subscription locks pages past the sample
/// instead of trusting the route.
struct ReaderView: View {
    let bookID: BookID

    @Environment(CatalogStore.self) private var catalog
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(AppNavigator.self) private var navigator

    @State private var model: ReaderModel?

    var body: some View {
        Group {
            if let model {
                ReaderContentView(model: model)
            } else if let book = catalog.book(id: bookID) {
                Color.clear.onAppear {
                    model = ReaderModel(book: book, catalog: catalog)
                }
            } else {
                ContentUnavailableView("That title is not in the library right now.", systemImage: "book.closed")
            }
        }
        .background(BookshelfBackground())
    }
}

private struct ReaderContentView: View {
    let model: ReaderModel

    @Environment(EntitlementStore.self) private var entitlements
    @Environment(AppNavigator.self) private var navigator

    private var modeBinding: Binding<SpreadMode> {
        Binding(get: { model.mode }, set: { model.setMode($0) })
    }

    var body: some View {
        Group {
            switch model.content {
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
                    Label("The book did not open", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(failure.message)
                } actions: {
                    if failure.isRetryable {
                        Button("Try again") { Task { await model.load() } }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .foregroundStyle(OmramoPalette.onShelf)
            case .loaded(let content):
                // The position lives in the model, not in this layout, so a
                // compact <-> regular change re-derives the spread from the
                // same page index and mode instead of resetting either.
                OpenBookSpread { arrangement, pageWidth in
                    VStack(spacing: 12) {
                        spread(content, arrangement: arrangement, pageWidth: pageWidth)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .black.opacity(0.4), radius: 24, y: 12)
                            .contentShape(Rectangle())
                            .gesture(turnGesture(in: arrangement))
                        ReaderControls(model: model, arrangement: arrangement, pageWidth: pageWidth)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
            }
        }
        .navigationTitle(model.book.title.resolved(in: .telugu))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Spread", selection: modeBinding) {
                        ForEach(model.availableModes, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                } label: {
                    Label("Spread", systemImage: "rectangle.split.2x1")
                }
            }
        }
        .task { await model.load() }
    }

    @ViewBuilder
    private func spread(_ content: ReaderContent, arrangement: PaneArrangement, pageWidth: CGFloat) -> some View {
        if let spread = model.spread(for: arrangement) {
            switch arrangement {
            case .single:
                // A real compact reader: the chosen mode still applies. Synced
                // stacks both editions on one page; illustrated keeps the art
                // band inline.
                switch model.mode {
                case .synced(let secondary):
                    pane(content, index: spread.leftIndex, language: .primary, showsIllustration: true, companion: secondary)
                case .facingPages, .illustrated:
                    pane(content, index: spread.leftIndex, language: .primary, showsIllustration: true)
                }
            case .dual(let spineWidth):
                BookPanes(pageWidth: pageWidth, spineWidth: spineWidth) {
                    pane(content, index: spread.leftIndex, language: .primary, showsIllustration: model.mode != .illustrated)
                } right: {
                    rightPane(content, spread: spread)
                }
            }
        } else {
            BlankPageView()
        }
    }

    @ViewBuilder
    private func rightPane(_ content: ReaderContent, spread: Spread) -> some View {
        switch model.mode {
        case .facingPages:
            if let right = spread.rightIndex {
                pane(content, index: right, language: .primary, showsIllustration: true)
            } else {
                BlankPageView()
            }
        case .synced(let secondary):
            pane(content, index: spread.leftIndex, language: secondary, showsIllustration: true)
        case .illustrated:
            if isUnlocked(spread.leftIndex), let page = content.primary.page(at: spread.leftIndex) {
                ArtPane(page: page, fallback: content.book.poster)
            } else {
                BlankPageView()
            }
        }
    }

    /// Every page passes through the gate. Sample pages are always free.
    @ViewBuilder
    private func pane(_ content: ReaderContent, index: Int, language: Language, showsIllustration: Bool, companion: Language? = nil) -> some View {
        if !isUnlocked(index) {
            LockedPageView(pageNumber: index + 1) {
                navigator.presentPaywall(for: content.book.id)
            }
        } else if let edition = content.edition(for: language), let page = edition.page(at: index) {
            PageView(
                page: page,
                language: language,
                showsIllustration: showsIllustration,
                companion: companionPage(content, index: index, language: companion)
            )
        } else {
            BlankPageView()
        }
    }

    private func companionPage(_ content: ReaderContent, index: Int, language: Language?) -> CompanionPage? {
        guard let language, let page = content.edition(for: language)?.page(at: index) else { return nil }
        return CompanionPage(page: page, language: language)
    }

    private func isUnlocked(_ index: Int) -> Bool {
        EntitlementGate.canRead(pageIndex: index, in: model.book, state: entitlements.effectiveState)
    }

    private func turnGesture(in arrangement: PaneArrangement) -> some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                withAnimation(.easeInOut(duration: 0.25)) {
                    if value.translation.width < 0 {
                        model.turnForward(in: arrangement)
                    } else {
                        model.turnBack(in: arrangement)
                    }
                }
            }
    }
}

/// Previous, position, next. Sits under the book so thumbs reach it in
/// either hand. With two panes the row is split the same way as the pages:
/// back and the position label under the left page, next under the right,
/// and nothing over the fold.
private struct ReaderControls: View {
    let model: ReaderModel
    let arrangement: PaneArrangement
    let pageWidth: CGFloat

    var body: some View {
        switch arrangement {
        case .single:
            HStack {
                backButton
                Spacer()
                positionLabel
                Spacer()
                forwardButton
            }
            .padding(.horizontal, 8)
        case .dual(let spineWidth):
            HStack(spacing: 0) {
                HStack {
                    backButton
                    positionLabel
                    Spacer()
                }
                .frame(width: pageWidth)
                Spacer()
                    .frame(width: spineWidth)
                HStack {
                    Spacer()
                    forwardButton
                }
                .frame(width: pageWidth)
            }
        }
    }

    private var backButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { model.turnBack(in: arrangement) }
        } label: {
            Image(systemName: "chevron.left")
                .frame(width: 44, height: 44)
        }
        .disabled(!model.canTurnBack(in: arrangement))
        .foregroundStyle(OmramoPalette.onShelf)
        .accessibilityLabel(Text("Previous page"))
    }

    private var forwardButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { model.turnForward(in: arrangement) }
        } label: {
            Image(systemName: "chevron.right")
                .frame(width: 44, height: 44)
        }
        .disabled(!model.canTurnForward(in: arrangement))
        .foregroundStyle(OmramoPalette.onShelf)
        .accessibilityLabel(Text("Next page"))
    }

    private var positionLabel: some View {
        Text(model.positionLabel(for: arrangement))
            .font(OmramoType.pageNumber)
            .foregroundStyle(OmramoPalette.onShelf)
            .monospacedDigit()
    }
}

#Preview("Reader, subscribed") {
    let environment = AppEnvironment.preview(subscribed: true)
    return NavigationStack {
        ReaderView(bookID: BookID("godavari-oddu"))
    }
    .environment(environment.catalog)
    .environment(environment.entitlements)
    .environment(environment.navigator)
    .task { await environment.catalog.load() }
}
