import Foundation

/// Where a tap-to-see, landmark or character card opens (docs/ARCHITECTURE.md §5.5).
///
/// The card never covers the word that was tapped: with two panes it takes the pane the word is
/// *not* on, so the child's line stays in view with its place marker. Folded, there is only one
/// pane, so the card rises from the bottom (assumption A2, design gap G4).
public enum CardPlacement: Equatable, Hashable, Sendable {
    /// The card covers this whole pane.
    case pane(TextBlock.Pane)
    /// The card rises from the bottom of the only pane.
    case bottomSheet

    /// - Parameters:
    ///   - posture: how the window is laid out now.
    ///   - wordPane: the pane the tapped word is shown on now. (With continuation screens that
    ///     is not always the pane the paragraph was authored for.)
    public static func resolve(posture: DisplayPosture, wordPane: TextBlock.Pane) -> CardPlacement {
        switch posture {
        case .folded:
            return .bottomSheet
        case .unfolded:
            return .pane(wordPane.opposite)
        }
    }

    /// True when the card hides this pane completely.
    public func covers(_ pane: TextBlock.Pane) -> Bool {
        self == .pane(pane)
    }
}

extension TextBlock.Pane {
    public var opposite: TextBlock.Pane {
        self == .leading ? .trailing : .leading
    }
}
