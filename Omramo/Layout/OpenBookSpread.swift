import SwiftUI
import OmramoCore

/// The one place the app decides between one pane and two.
///
/// Apple's Duo guidance is two adaptive foundations, compact width for the
/// outer display and regular width for the inner display, decided by size
/// class rather than pose or hinge angle. `SpreadLayoutPolicy` applies that
/// rule to the measured width and this view hands the result to its content.
///
/// Xcode 27.1 seam: when the iOS 27.1 SDK is available, the dual branch can be
/// expressed as `ArrangementView { left } secondary: { right }
/// .arrangementViewStyle(.split).axes(.horizontal)` and the spine gap replaced
/// by `GeometryProxy.reservedRegions(kind: .division)`. Callers stay unchanged.
struct OpenBookSpread<Content: View>: View {
    var policy: SpreadLayoutPolicy = .standard
    @ViewBuilder var content: (PaneArrangement, CGFloat) -> Content

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { proxy in
            let arrangement = policy.arrangement(
                availableWidth: proxy.size.width,
                isRegularWidth: horizontalSizeClass == .regular
            )
            let pageWidth = policy.pageWidth(availableWidth: proxy.size.width, arrangement: arrangement)
            content(arrangement, pageWidth)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

/// Two pages around a spine. Only used inside the dual branch of
/// `OpenBookSpread`; the spine is the reserved fold region and never holds text.
struct BookPanes<Left: View, Right: View>: View {
    let pageWidth: CGFloat
    let spineWidth: CGFloat
    @ViewBuilder var left: () -> Left
    @ViewBuilder var right: () -> Right

    var body: some View {
        HStack(spacing: 0) {
            left()
                .frame(width: pageWidth)
            BookSpine()
                .frame(width: spineWidth)
            right()
                .frame(width: pageWidth)
        }
    }
}

/// The fold. A soft shadow on both sides sells the open book without drawing
/// anything a real hinge would hide.
struct BookSpine: View {
    var body: some View {
        ZStack {
            OmramoPalette.spine
            HStack(spacing: 0) {
                LinearGradient(colors: [OmramoPalette.ink.opacity(0.35), .clear], startPoint: .trailing, endPoint: .leading)
                LinearGradient(colors: [OmramoPalette.ink.opacity(0.35), .clear], startPoint: .leading, endPoint: .trailing)
            }
            .blendMode(.multiply)
        }
        .accessibilityHidden(true)
    }
}

/// Bookshelf backdrop behind spreads so the pages read as paper on a surface.
struct BookshelfBackground: View {
    var body: some View {
        LinearGradient(
            colors: [OmramoPalette.shelf, OmramoPalette.spine.opacity(0.85)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
