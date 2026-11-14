import Foundation

/// How a reading page uses a pane that is taller than the design's 432 × 720 pane: an iPad in
/// portrait, a tall iPhone, a tall Stage Manager window. Pure arithmetic over the numbers the
/// `PaneLayout` already gives; it is not a layout system of its own.
///
/// Three things happen with the extra height, and nothing else:
/// - **Unfolded** (two panes): the type may grow a little, as far as the tier's measure allows
///   (`typeBoost`), and a page whose text is shorter than its column is set lower, toward the
///   scene, instead of floating at the top with an empty band beneath it (`balancedOffset`).
/// - **Folded** (one pane): the picture band takes a share of the extra height
///   (`foldedPictureHeight`); the words keep the rest and stay directly under the picture.
///
/// On the reference pane itself every function returns the designed value, so the locked
/// screens are unchanged.
public enum PageFit {
    /// Average width of a character of the reading face, as a fraction of its point size.
    /// An estimate for Atkinson Hyperlegible Next at reading weights, spaces included.
    public static let averageCharacterEm: Double = 0.5

    /// Height the pane has beyond the design's proportions at its scale. Zero on the reference
    /// pane and on any pane that is as squat as, or squatter than, the design.
    public static func extraHeight(paneHeight: Double, scale: Double) -> Double {
        guard paneHeight > 0, scale > 0 else { return 0 }
        return max(0, paneHeight - ReferenceCanvas.paneHeight * scale)
    }

    /// About how many characters fit on a line.
    public static func charactersPerLine(columnWidth: Double, fontSize: Double) -> Double {
        guard columnWidth > 0, fontSize > 0 else { return 0 }
        return columnWidth / (fontSize * averageCharacterEm)
    }

    /// The comfortable measure of a tier, in characters per line: short lines for new readers,
    /// 45 to 65 for the oldest tier (the classic range for continuous reading).
    public static func measure(for tier: Tier) -> ClosedRange<Double> {
        switch tier {
        case .low: return 24...40
        case .medium: return 32...56
        case .advanced: return 45...65
        }
    }

    /// Factor (1 or more) by which the tier's type may grow on a tall two-pane layout.
    ///
    /// The type never grows past the layout's own limit (`maximumScale`, the 1.3 × cap of a
    /// derived layout), never faster than the pane is taller than the design, and never so far
    /// that a line would fall under the tier's shortest comfortable measure. It is 1 when the
    /// layout has no limit (the Duo and the simulated canvas, which follow the locked design
    /// exactly), when the pane is folded, and when there is no extra height.
    ///
    /// - Parameters:
    ///   - baseFontSize: the tier's designed body size in reference points (23.5, 19.5, 16.5).
    ///   - paneScale: the pane's scale from the reference pane.
    ///   - columnWidth: the text column's width in points.
    ///   - extraHeight: see `extraHeight(paneHeight:scale:)`.
    ///   - maximumScale: `PaneLayout.maximumReferenceScale`.
    public static func typeBoost(
        tier: Tier,
        posture: DisplayPosture,
        baseFontSize: Double,
        paneScale: Double,
        columnWidth: Double,
        extraHeight: Double,
        maximumScale: Double?
    ) -> Double {
        guard posture == .unfolded,
              let maximumScale, maximumScale > 0,
              paneScale > 0, baseFontSize > 0, columnWidth > 0, extraHeight > 0 else {
            return 1
        }
        let byCap = maximumScale / paneScale
        let byHeight = 1 + extraHeight / (ReferenceCanvas.paneHeight * paneScale)
        let shortest = measure(for: tier).lowerBound
        let largestFont = columnWidth / (shortest * averageCharacterEm)
        let byMeasure = largestFont / (baseFontSize * paneScale)
        let boost = min(byCap, min(byHeight, byMeasure))
        // Steps of a hundredth, so a one-point change of window size does not re-wrap the page.
        return max(1, (boost * 100).rounded(.down) / 100)
    }

    /// How far below its designed top a short page of text is set on a tall two-pane layout.
    ///
    /// - Parameters:
    ///   - free: height of the column the text leaves empty (capacity − text height).
    ///   - extra: see `extraHeight(paneHeight:scale:)`.
    /// - Returns: 0 when the text fills its column or the pane has the design's proportions;
    ///   otherwise a little under half of the free space (the optical centre sits above the
    ///   geometric one), and never more than half of the extra height — so the first line
    ///   never drifts far from the title above it.
    public static func balancedOffset(free: Double, extra: Double) -> Double {
        guard free > 0, extra > 0 else { return 0 }
        return (min(free * opticalShare, extra * 0.5)).rounded()
    }

    /// Share of the free space left above a balanced text block.
    public static let opticalShare: Double = 0.42

    /// Share of a folded pane's extra height that goes to the picture band.
    public static let foldedPictureShare: Double = 0.4

    /// Height of the picture band at the top of a single pane.
    ///
    /// - Parameters:
    ///   - designed: the designed band at the pane's scale (340 reference points × scale).
    ///   - paneWidth, paneHeight: the pane in points.
    ///   - extra: see `extraHeight(paneHeight:scale:)`.
    /// - Returns: the designed band plus its share of the extra height; on a wide pane (an
    ///   iPad in portrait) at least a generous landscape shape; never more than 56% of the
    ///   pane, so the words always keep the larger part of a tall screen.
    public static func foldedPictureHeight(designed: Double, paneWidth: Double, paneHeight: Double, extra: Double) -> Double {
        let roomy = min(paneWidth * 0.62, paneHeight * 0.5)
        let grown = designed + max(0, extra) * foldedPictureShare
        let band = max(grown, roomy)
        guard paneHeight > 0 else { return band }
        return max(designed, min(band, paneHeight * 0.56))
    }
}
