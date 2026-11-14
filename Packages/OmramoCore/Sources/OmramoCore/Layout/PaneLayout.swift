import Foundation

/// How the device is being held, as far as layout cares.
public enum DisplayPosture: String, Equatable, Hashable, Sendable {
    /// One pane: the Duo outer screen, or any ordinary iPhone.
    case folded
    /// Two panes either side of a hinge (or a virtual gutter).
    case unfolded
}

/// A rectangle in points. (Plain numbers: the core has no CoreGraphics dependency.)
public struct LayoutRect: Equatable, Hashable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public static let zero = LayoutRect(x: 0, y: 0, width: 0, height: 0)

    public var maxX: Double { x + width }
    public var maxY: Double { y + height }
}

/// The reference canvas the designs were drawn on. An assumption, not an Apple specification
/// (docs/DESIGN.md §2). Positions in DESIGN.md are expressed against the reference pane; the
/// app never uses these as real device sizes.
public enum ReferenceCanvas {
    public static let paneWidth: Double = 432
    public static let paneHeight: Double = 720
    public static let hingeWidth: Double = 28
    public static let unfoldedWidth: Double = paneWidth * 2 + hingeWidth
}

/// Everything a screen needs to lay itself out. Screens never ask what device they are on.
public struct PaneLayout: Equatable, Hashable, Sendable {
    public enum Source: String, Equatable, Hashable, Sendable {
        /// Posture or hinge reported by the system (the Duo SDK adapter, M7).
        case system
        /// Derived from the window size alone.
        case derived
        /// A debug simulation of the Duo.
        case simulated
    }

    public var posture: DisplayPosture
    /// The area the screen draws in, in the window's coordinates.
    public var canvas: LayoutRect
    /// The only pane when folded.
    public var leading: LayoutRect
    /// Nil when folded.
    public var trailing: LayoutRect?
    /// The region with no pixels or no touch between the panes. Nil when folded.
    public var hinge: LayoutRect?
    public var source: Source
    /// Upper limit for `referenceScale`, or nil for none. Set when the layout is derived from a
    /// window's size (an iPad, Split View, Stage Manager): on a large window the design keeps
    /// its own proportions and gains room around it, instead of being blown up like a stretched
    /// phone screen. Never set for the Duo itself or for the simulated reference canvas.
    public var maximumReferenceScale: Double?
    /// Lower limit for `referenceScale`, or nil for none (round 4). Set only when a simulated
    /// unfolded Duo fills a window that is much squatter than the design's panes (an iPhone
    /// held sideways): the design then keeps a readable size and each pane simply shows less
    /// of a page at a time, instead of the whole design shrinking to fit the height. The
    /// scale never exceeds what the pane's width allows.
    public var minimumReferenceScale: Double?

    public init(
        posture: DisplayPosture,
        canvas: LayoutRect,
        leading: LayoutRect,
        trailing: LayoutRect?,
        hinge: LayoutRect?,
        source: Source,
        maximumReferenceScale: Double? = nil,
        minimumReferenceScale: Double? = nil
    ) {
        self.posture = posture
        self.canvas = canvas
        self.leading = leading
        self.trailing = trailing
        self.hinge = hinge
        self.source = source
        self.maximumReferenceScale = maximumReferenceScale
        self.minimumReferenceScale = minimumReferenceScale
    }

    /// Scale from the 432 × 720 reference pane to the real pane, for positions in DESIGN.md.
    public var referenceScale: Double {
        guard leading.width > 0, leading.height > 0 else { return 1 }
        let byWidth = leading.width / ReferenceCanvas.paneWidth
        var fit = min(byWidth, leading.height / ReferenceCanvas.paneHeight)
        if let lowest = minimumReferenceScale, lowest > 0 {
            fit = max(fit, min(lowest, byWidth))
        }
        if let limit = maximumReferenceScale, limit > 0 {
            return min(fit, limit)
        }
        return fit
    }

    /// True when a pane is shorter than the design's pane at this layout's scale (only a
    /// layout with a `minimumReferenceScale` can be): the reader then shows less of a page on
    /// each screen and the scene is drawn squat.
    public var isSquat: Bool {
        leading.height + 0.5 < ReferenceCanvas.paneHeight * referenceScale
    }

    /// Width of the design's pane at this layout's scale. A pane wider than this (an iPad pane)
    /// centres its text column and cards in a band this wide; chrome stays at the pane's edges.
    public var contentWidth: Double {
        min(leading.width, ReferenceCanvas.paneWidth * referenceScale)
    }

    /// A single empty pane; used before the first measurement.
    public static let placeholder = PaneLayout(
        posture: .folded,
        canvas: .zero,
        leading: .zero,
        trailing: nil,
        hinge: nil,
        source: .derived
    )
}

/// Raw facts gathered by the app layer.
public struct PaneLayoutInput: Equatable, Hashable, Sendable {
    /// A debug override that draws the reference Duo canvas on any device.
    public enum Simulation: String, Equatable, Hashable, Sendable {
        case unfolded
        case folded
    }

    public var canvasWidth: Double
    public var canvasHeight: Double
    /// From the Duo SDK when available, else nil.
    public var reportedHinge: LayoutRect?
    /// From the Duo SDK when available, else nil.
    public var reportedPosture: DisplayPosture?
    public var simulation: Simulation?
    /// Round 4. With `simulation == .unfolded`: lay the two panes out over the **whole
    /// window** (a thin gutter for the hinge, the scene full-bleed) instead of drawing the
    /// 892 × 720 reference canvas letterboxed. False keeps the letterboxed reference canvas,
    /// for comparison with the locked screens. Ignored for any other input.
    public var simulationFillsWindow: Bool
    /// The window's safe-area insets on its leading and trailing edges (the Dynamic Island
    /// and the rounded corners of an iPhone held sideways). Used only by a simulation that
    /// fills the window: the scene still runs edge to edge, the panes start inside the insets.
    public var safeAreaLeading: Double
    public var safeAreaTrailing: Double

    public init(
        canvasWidth: Double,
        canvasHeight: Double,
        reportedHinge: LayoutRect? = nil,
        reportedPosture: DisplayPosture? = nil,
        simulation: Simulation? = nil,
        simulationFillsWindow: Bool = false,
        safeAreaLeading: Double = 0,
        safeAreaTrailing: Double = 0
    ) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.reportedHinge = reportedHinge
        self.reportedPosture = reportedPosture
        self.simulation = simulation
        self.simulationFillsWindow = simulationFillsWindow
        self.safeAreaLeading = safeAreaLeading
        self.safeAreaTrailing = safeAreaTrailing
    }
}

/// Turns raw facts into a `PaneLayout`. A pure function (docs/ARCHITECTURE.md §5.2).
public struct PaneLayoutResolver: Equatable, Sendable {
    /// Narrowest pane worth treating as a pane when deriving from size (assumption).
    public var minimumPaneWidth: Double = 360
    /// Shortest window worth splitting when deriving from size (assumption). An ordinary
    /// iPhone in landscape is wide enough but far too short for two reading panes.
    public var minimumPaneHeight: Double = 600
    /// Matches the design's hinge gap.
    public var virtualGutter: Double = ReferenceCanvas.hingeWidth
    /// A window taller than it is wide (an iPad in portrait) is split only when it is at least
    /// this wide, so each pane is comfortably wider than the design's pane (assumption, Mi).
    /// A 13-inch iPad in portrait (1024–1032 pt) qualifies; an 11-inch one (820–834 pt) reads
    /// in one well-padded pane instead of two cramped ones.
    public var minimumPortraitSplitWidth: Double = 980
    /// Largest scale of the design on a derived layout (assumption, Mi): type and chrome grow
    /// to 1.3 × the reference size and no further.
    public var maximumDerivedScale: Double = 1.3
    /// Width of the hinge gutter drawn when a simulated unfolded Duo fills the window
    /// (round 4): thin, so a phone's screen is not spent on a picture of a hinge.
    public var filledSimulationGutter: Double = 12
    /// A simulated unfolded Duo that fills a squat window keeps the design at full size as
    /// long as its panes are at least this tall, and scales down in proportion below that
    /// (assumption, round 4): an iPhone held sideways (about 440 pt tall) shows the design at
    /// about 0.85 ×, not at the 0.61 × that fitting the whole 720 pt pane would give.
    public var filledSimulationFullScaleHeight: Double = 520

    public init() {}

    public func resolve(_ input: PaneLayoutInput) -> PaneLayout {
        let width = max(0, input.canvasWidth)
        let height = max(0, input.canvasHeight)
        let window = LayoutRect(x: 0, y: 0, width: width, height: height)

        // 1. Simulation (debug only): exactly the requested reference layout, letterboxed —
        // or, when asked, the two panes over the whole window.
        if let simulation = input.simulation {
            if simulation == .unfolded, input.simulationFillsWindow {
                return filledUnfolded(window, leadingInset: input.safeAreaLeading, trailingInset: input.safeAreaTrailing)
            }
            return simulated(simulation, in: window)
        }

        // 2. The system reported a hinge rectangle: panes are the areas either side of it.
        if input.reportedPosture != .folded, let hinge = input.reportedHinge, hinge.x > 0, hinge.maxX < width, hinge.width >= 0 {
            return PaneLayout(
                posture: .unfolded,
                canvas: window,
                leading: LayoutRect(x: 0, y: 0, width: hinge.x, height: height),
                trailing: LayoutRect(x: hinge.maxX, y: 0, width: width - hinge.maxX, height: height),
                hinge: LayoutRect(x: hinge.x, y: 0, width: hinge.width, height: height),
                source: .system
            )
        }

        // 3. The system reported a posture but no hinge.
        if let posture = input.reportedPosture {
            switch posture {
            case .unfolded:
                return split(window, gutter: 0, source: .system)
            case .folded:
                return single(window, source: .system)
            }
        }

        // 4. No system information: derive from size. Landscape windows split as soon as two
        // panes and the virtual gutter fit; portrait windows only when they are wide enough
        // for two generous panes. Anything else — an iPhone, a narrow Split View or Stage
        // Manager window, an 11-inch iPad in portrait — is one pane.
        let wideEnough = width >= 2 * minimumPaneWidth + virtualGutter
        let shapeAllowsSplit = width > height || width >= minimumPortraitSplitWidth
        if wideEnough && shapeAllowsSplit && height >= minimumPaneHeight {
            return split(window, gutter: virtualGutter, source: .derived)
        }
        return single(window, source: .derived)
    }

    private func scaleLimit(for source: PaneLayout.Source) -> Double? {
        source == .derived ? maximumDerivedScale : nil
    }

    private func single(_ canvas: LayoutRect, source: PaneLayout.Source) -> PaneLayout {
        PaneLayout(
            posture: .folded,
            canvas: canvas,
            leading: canvas,
            trailing: nil,
            hinge: nil,
            source: source,
            maximumReferenceScale: scaleLimit(for: source)
        )
    }

    private func split(_ canvas: LayoutRect, gutter: Double, source: PaneLayout.Source) -> PaneLayout {
        let paneWidth = max(0, (canvas.width - gutter) / 2)
        return PaneLayout(
            posture: .unfolded,
            canvas: canvas,
            leading: LayoutRect(x: canvas.x, y: canvas.y, width: paneWidth, height: canvas.height),
            trailing: LayoutRect(x: canvas.x + paneWidth + gutter, y: canvas.y, width: paneWidth, height: canvas.height),
            hinge: LayoutRect(x: canvas.x + paneWidth, y: canvas.y, width: gutter, height: canvas.height),
            source: source,
            maximumReferenceScale: scaleLimit(for: source)
        )
    }

    /// The simulated unfolded Duo over the whole window: the canvas is the window (the scene
    /// is full-bleed, under the gutter and out to every edge), the panes are the two halves
    /// either side of a thin centred gutter, each starting inside the window's side inset.
    private func filledUnfolded(_ window: LayoutRect, leadingInset: Double, trailingInset: Double) -> PaneLayout {
        let gutter = min(filledSimulationGutter, window.width)
        let middle = window.width / 2
        // The same inset on both sides, so the two panes are always equally wide.
        let side = min(max(0, max(leadingInset, trailingInset)), max(0, middle - gutter / 2))
        let paneWidth = max(0, middle - gutter / 2 - side)
        let leading = LayoutRect(x: side, y: 0, width: paneWidth, height: window.height)
        let trailing = LayoutRect(x: middle + gutter / 2, y: 0, width: paneWidth, height: window.height)
        let minimum = filledSimulationFullScaleHeight > 0 ? min(1, window.height / filledSimulationFullScaleHeight) : 1
        return PaneLayout(
            posture: .unfolded,
            canvas: window,
            leading: leading,
            trailing: trailing,
            hinge: LayoutRect(x: middle - gutter / 2, y: 0, width: gutter, height: window.height),
            source: .simulated,
            minimumReferenceScale: minimum
        )
    }

    private func simulated(_ simulation: PaneLayoutInput.Simulation, in window: LayoutRect) -> PaneLayout {
        let referenceWidth: Double
        switch simulation {
        case .unfolded: referenceWidth = ReferenceCanvas.unfoldedWidth
        case .folded: referenceWidth = ReferenceCanvas.paneWidth
        }
        let referenceHeight = ReferenceCanvas.paneHeight
        let scale = min(window.width / referenceWidth, window.height / referenceHeight)
        let canvasWidth = referenceWidth * scale
        let canvasHeight = referenceHeight * scale
        let canvas = LayoutRect(
            x: (window.width - canvasWidth) / 2,
            y: (window.height - canvasHeight) / 2,
            width: canvasWidth,
            height: canvasHeight
        )
        switch simulation {
        case .folded:
            return single(canvas, source: .simulated)
        case .unfolded:
            return split(canvas, gutter: ReferenceCanvas.hingeWidth * scale, source: .simulated)
        }
    }
}
