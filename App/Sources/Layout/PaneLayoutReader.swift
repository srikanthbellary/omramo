import SwiftUI
import OmramoCore

// MARK: - Environment

private struct PaneLayoutKey: EnvironmentKey {
    static let defaultValue = PaneLayout.placeholder
}

private struct WindowSafeAreaKey: EnvironmentKey {
    static let defaultValue = EdgeInsets()
}

private struct WindowSizeKey: EnvironmentKey {
    static let defaultValue = CGSize.zero
}

private struct PaneContextKey: EnvironmentKey {
    static let defaultValue = PaneContext(side: .single, size: .zero, scale: 1, safeArea: EdgeInsets(), source: .derived)
}

extension EnvironmentValues {
    /// The resolved layout of the whole window. Set by `PaneLayoutReader`.
    var paneLayout: PaneLayout {
        get { self[PaneLayoutKey.self] }
        set { self[PaneLayoutKey.self] = newValue }
    }

    /// The window's safe-area insets (zero on the letterboxed reference canvas). Set by
    /// `PaneLayoutReader`.
    var windowSafeArea: EdgeInsets {
        get { self[WindowSafeAreaKey.self] }
        set { self[WindowSafeAreaKey.self] = newValue }
    }

    /// The whole window's size, safe areas included. Set by `PaneLayoutReader`.
    var windowSize: CGSize {
        get { self[WindowSizeKey.self] }
        set { self[WindowSizeKey.self] = newValue }
    }

    /// The pane a view is drawn in. Set by `TwoPane`.
    var pane: PaneContext {
        get { self[PaneContextKey.self] }
        set { self[PaneContextKey.self] = newValue }
    }
}

/// What a view inside a pane needs to place itself: the pane's size, and the scale from the
/// reference pane of docs/DESIGN.md to this pane. Views never look at the device.
struct PaneContext: Equatable {
    enum Side: Equatable {
        case leading
        case trailing
        /// The only pane (folded).
        case single
    }

    var side: Side
    var size: CGSize
    /// Multiply a DESIGN.md value (points on the reference pane) by this.
    var scale: CGFloat
    /// The part of the window's safe area that touches this pane.
    var safeArea: EdgeInsets
    /// Where the layout came from (a simulated canvas draws the hinge and has no safe area).
    var source: PaneLayout.Source

    /// A DESIGN.md measurement in this pane's points.
    func pt(_ reference: Double) -> CGFloat {
        CGFloat(reference) * scale
    }

    /// Width of the design's 432-point pane at this pane's scale.
    var contentWidth: CGFloat {
        min(size.width, CGFloat(ReferenceCanvas.paneWidth) * scale)
    }

    /// Extra margin on each side when the pane is wider than the design's pane (an iPad pane).
    /// Text columns and cards sit in a centred band `contentWidth` wide; glass chrome stays at
    /// the pane's own edges, as on any large-screen app.
    var contentInset: CGFloat {
        max(0, (size.width - contentWidth) / 2)
    }

    /// True for the one pane of a folded or narrow window.
    var isSingle: Bool {
        side == .single
    }

    /// Top of the top controls: the design position, moved down if the system's safe area
    /// (status bar, Dynamic Island) needs more room.
    func controlTop(folded: Bool = false) -> CGFloat {
        let designed = pt(folded ? Tokens.Spacing.topControlFolded : Tokens.Spacing.topControl)
        return max(designed, safeArea.top + pt(4))
    }

    /// Distance from the pane's bottom edge for bottom chrome whose designed inset is `reference`.
    func bottomInset(_ reference: Double) -> CGFloat {
        max(pt(reference), safeArea.bottom + pt(6))
    }
}

// MARK: - Reader

/// Measures the window, asks the provider and the pure resolver, and publishes the
/// `PaneLayout` through the environment. A change of size or posture gives a new value and
/// SwiftUI lays out again.
struct PaneLayoutReader<Content: View>: View {
    let provider: any PaneLayoutProvider
    var resolver = PaneLayoutResolver()
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            let layout = resolver.resolve(PaneLayoutProviders.input(from: provider, size: proxy.size, safeArea: proxy.safeAreaInsets))
            // The letterboxed reference canvas is a picture of a device: it has no real safe
            // area. A simulation that fills the window is laid out on the real screen.
            let safeArea = PaneLayoutProviders.isLetterboxed(layout, in: proxy.size) ? EdgeInsets() : proxy.safeAreaInsets
            content()
                .environment(\.paneLayout, layout)
                .environment(\.windowSafeArea, safeArea)
                .environment(\.windowSize, proxy.size)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        // Scenes are full-bleed: the canvas is the whole window, as in the designs, where
        // the 432 × 720 pane includes the status-bar and home-indicator areas.
        .ignoresSafeArea()
        .background(Color.black.ignoresSafeArea())
    }
}

extension PaneLayoutProviders {
    /// The provider's facts, plus the window's side insets (used only by a simulation that
    /// fills the window: its panes start inside the Dynamic Island and the rounded corners).
    static func input(from provider: any PaneLayoutProvider, size: CGSize, safeArea: EdgeInsets) -> PaneLayoutInput {
        var input = provider.input(for: size)
        input.safeAreaLeading = Double(safeArea.leading)
        input.safeAreaTrailing = Double(safeArea.trailing)
        return input
    }

    /// True when a simulated layout is drawn smaller than the window, as a picture of a device.
    static func isLetterboxed(_ layout: PaneLayout, in size: CGSize) -> Bool {
        guard layout.source == .simulated else { return false }
        return abs(layout.canvas.width - Double(size.width)) > 0.5 || abs(layout.canvas.height - Double(size.height)) > 0.5
    }
}

// MARK: - TwoPane

/// Places a backdrop across the whole canvas (including under the hinge) and the pane
/// contents in their rectangles. Folded, it shows the single-pane composition instead.
/// Features supply both compositions; they never test device models or size classes.
struct TwoPane<Backdrop: View, Leading: View, Trailing: View, Folded: View>: View {
    @Environment(\.paneLayout) private var layout
    @Environment(\.windowSafeArea) private var safeArea

    private let backdrop: Backdrop
    private let leading: Leading
    private let trailing: Trailing
    private let folded: Folded

    init(
        @ViewBuilder backdrop: () -> Backdrop,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder folded: () -> Folded
    ) {
        self.backdrop = backdrop()
        self.leading = leading()
        self.trailing = trailing()
        self.folded = folded()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            backdrop
                .frame(width: CGFloat(layout.canvas.width), height: CGFloat(layout.canvas.height))
                .clipped()
                .offset(x: CGFloat(layout.canvas.x), y: CGFloat(layout.canvas.y))

            if layout.posture == .unfolded, let trailingRect = layout.trailing {
                pane(leading, in: layout.leading, side: .leading)
                pane(trailing, in: trailingRect, side: .trailing)
                if layout.source == .simulated, let hinge = layout.hinge {
                    // On hardware the hinge has no pixels. In simulation it is drawn black,
                    // as in the screenshots.
                    Color.black
                        .frame(width: CGFloat(hinge.width), height: CGFloat(hinge.height))
                        .offset(x: CGFloat(hinge.x), y: CGFloat(hinge.y))
                        .accessibilityHidden(true)
                }
            } else {
                pane(folded, in: layout.leading, side: .single)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func pane<V: View>(_ view: V, in rect: LayoutRect, side: PaneContext.Side) -> some View {
        let context = PaneContext(
            side: side,
            size: CGSize(width: rect.width, height: rect.height),
            scale: CGFloat(layout.referenceScale),
            safeArea: insets(for: side),
            source: layout.source
        )
        return view
            .environment(\.pane, context)
            .frame(width: CGFloat(rect.width), height: CGFloat(rect.height), alignment: .topLeading)
            .clipped()
            .offset(x: CGFloat(rect.x), y: CGFloat(rect.y))
    }

    /// Each pane gets the window insets on the edges it touches. How the Duo reports safe
    /// areas per pane is unverified (docs/ARCHITECTURE.md §5.5).
    private func insets(for side: PaneContext.Side) -> EdgeInsets {
        switch side {
        case .single:
            return safeArea
        case .leading:
            // A pane that already starts inside the window's side inset has none of its own.
            let leading = max(0, safeArea.leading - CGFloat(layout.leading.x))
            return EdgeInsets(top: safeArea.top, leading: leading, bottom: safeArea.bottom, trailing: 0)
        case .trailing:
            let end = CGFloat(layout.trailing?.maxX ?? layout.canvas.maxX)
            let trailing = max(0, safeArea.trailing - max(0, CGFloat(layout.canvas.maxX) - end))
            return EdgeInsets(top: safeArea.top, leading: 0, bottom: safeArea.bottom, trailing: trailing)
        }
    }
}
