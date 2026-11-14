import SwiftUI
import OmramoCore

/// Gathers the raw facts the pure `PaneLayoutResolver` needs (docs/ARCHITECTURE.md §5.3).
@MainActor
protocol PaneLayoutProvider {
    func input(for size: CGSize) -> PaneLayoutInput
}

/// Default on every device today: supplies the size only, so the resolver derives the posture.
/// An ordinary iPhone in portrait gets the single-pane (folded) layout.
struct DerivedPaneLayoutProvider: PaneLayoutProvider {
    func input(for size: CGSize) -> PaneLayoutInput {
        PaneLayoutInput(canvasWidth: Double(size.width), canvasHeight: Double(size.height))
    }
}

/// Debug only: draws the reference Duo canvas (two panes and a black hinge band, or one pane)
/// scaled to fit any window, so layouts can be checked against docs/design/ before hardware.
///
/// `folded` on a window that is one pane anyway — any iPhone, a narrow iPad window — is not
/// drawn as a small picture of a device: the folded Duo *is* an ordinary phone screen, so the
/// app lays out the real window, edge to edge, with its real safe areas. Only a window wide
/// enough for two panes (an iPad in landscape) gets the letterboxed reference pane, which is
/// what to compare with `10-folded.png`.
struct SimulatedDuoProvider: PaneLayoutProvider {
    let simulation: PaneLayoutInput.Simulation

    func input(for size: CGSize) -> PaneLayoutInput {
        let plain = PaneLayoutInput(canvasWidth: Double(size.width), canvasHeight: Double(size.height))
        if simulation == .folded, PaneLayoutResolver().resolve(plain).posture == .folded {
            return plain
        }
        return PaneLayoutInput(
            canvasWidth: Double(size.width),
            canvasHeight: Double(size.height),
            simulation: simulation
        )
    }
}

// TODO(M7): DuoSDKPaneLayoutProvider — the only file that may reference Duo APIs. It will fill
// `reportedHinge` / `reportedPosture` from the system. The API names are unknown (PRD Q4).

@MainActor
enum PaneLayoutProviders {
    /// Launch argument that selects a simulated posture: `-OmramoPosture unfolded` or `folded`.
    static let postureArgument = "-OmramoPosture"

    static func current(arguments: [String] = ProcessInfo.processInfo.arguments) -> any PaneLayoutProvider {
        #if DEBUG
        if let simulation = simulation(from: arguments) {
            return SimulatedDuoProvider(simulation: simulation)
        }
        #endif
        return DerivedPaneLayoutProvider()
    }

    static func simulation(from arguments: [String]) -> PaneLayoutInput.Simulation? {
        guard let index = arguments.firstIndex(of: postureArgument), index + 1 < arguments.count else {
            return nil
        }
        return PaneLayoutInput.Simulation(rawValue: arguments[index + 1])
    }
}
