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

/// Debug only: lays the app out as the Duo would, on any device, so layouts can be checked
/// before hardware.
///
/// `unfolded` fills the **whole window** with the two panes and a thin hinge gutter (round 4):
/// the scene runs edge to edge and the panes start inside the window's side safe areas. On an
/// iPhone the app also turns to landscape (`DebugLaunch.applyRequestedOrientation`), because an
/// unfolded Duo is wider than it is tall; the panes are then shorter than the design's, so the
/// design keeps a readable size and each screen shows less of a page (`PaneLayout.isSquat`).
/// Pass `letterboxed: true` (launch argument `-OmramoPosture reference`) for the old picture of
/// the 892 × 720 reference canvas, which is what to compare with the locked screens.
///
/// `folded` on a window that is one pane anyway — any iPhone, a narrow iPad window — is not
/// drawn as a small picture of a device: the folded Duo *is* an ordinary phone screen, so the
/// app lays out the real window, edge to edge, with its real safe areas. Only a window wide
/// enough for two panes (an iPad in landscape) gets the letterboxed reference pane, which is
/// what to compare with `10-folded.png`.
struct SimulatedDuoProvider: PaneLayoutProvider {
    let simulation: PaneLayoutInput.Simulation
    /// True draws the unfolded reference canvas letterboxed instead of filling the window.
    var letterboxed = false

    func input(for size: CGSize) -> PaneLayoutInput {
        let plain = PaneLayoutInput(canvasWidth: Double(size.width), canvasHeight: Double(size.height))
        if simulation == .folded, PaneLayoutResolver().resolve(plain).posture == .folded {
            return plain
        }
        return PaneLayoutInput(
            canvasWidth: Double(size.width),
            canvasHeight: Double(size.height),
            simulation: simulation,
            simulationFillsWindow: simulation == .unfolded && !letterboxed
        )
    }
}

// TODO(M7): DuoSDKPaneLayoutProvider — the only file that may reference Duo APIs. It will fill
// `reportedHinge` / `reportedPosture` from the system. The API names are unknown (PRD Q4).

@MainActor
enum PaneLayoutProviders {
    /// Launch argument that selects a simulated posture: `-OmramoPosture unfolded` or `folded`
    /// (`reference` = the unfolded reference canvas, letterboxed, as before round 4).
    static let postureArgument = "-OmramoPosture"
    /// The value of `postureArgument` for the letterboxed reference canvas.
    static let referencePosture = "reference"

    static func current(arguments: [String] = ProcessInfo.processInfo.arguments) -> any PaneLayoutProvider {
        #if DEBUG
        if let simulation = simulation(from: arguments) {
            return SimulatedDuoProvider(simulation: simulation)
        }
        if isReferencePosture(arguments) {
            return SimulatedDuoProvider(simulation: .unfolded, letterboxed: true)
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

    /// The raw value after `-OmramoPosture`, if any. Not main-actor: a plain string lookup.
    nonisolated static func simulationValue(from arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: "-OmramoPosture"), index + 1 < arguments.count else {
            return nil
        }
        return arguments[index + 1]
    }

    /// True for `-OmramoPosture reference`.
    static func isReferencePosture(_ arguments: [String]) -> Bool {
        guard let index = arguments.firstIndex(of: postureArgument), index + 1 < arguments.count else {
            return false
        }
        return arguments[index + 1] == referencePosture
    }
}
