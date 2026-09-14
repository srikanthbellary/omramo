import Foundation
import Observation
import OmramoCore

/// Screens reachable by push. The paywall is a modal, not a route, because it
/// interrupts whatever the reader was about to open.
enum AppRoute: Hashable {
    case sample(BookID)
    case reader(BookID)
}

/// Owns the navigation path and the paywall presentation so the entitlement
/// gate is applied in exactly one place.
@Observable
@MainActor
final class AppNavigator {
    var path: [AppRoute] = []
    /// Non nil while the paywall is presented. Holds the title that triggered it.
    var paywallBookID: BookID?
    /// Set when the paywall ends in a subscription so `onDismiss` can push the reader.
    private var pendingReaderBookID: BookID?

    /// Catalog tap. Sample first when browsing free; all access opens the reader.
    func openTitle(for bookID: BookID, state: EntitlementState) {
        switch EntitlementGate.destinationFromCatalog(for: state) {
        case .reader:
            revealReader(for: bookID)
        case .sample, .paywall, .wait:
            showSample(for: bookID)
        }
    }

    func showSample(for bookID: BookID) {
        if case .sample(bookID) = path.last { return }
        path.append(.sample(bookID))
    }

    /// Continue from the sample. Allowed readers go straight in; everyone else
    /// sees the paywall and, if they subscribe, lands in the reader afterwards.
    func openReader(for bookID: BookID, state: EntitlementState) {
        switch EntitlementGate.destinationFromSample(for: state) {
        case .reader:
            revealReader(for: bookID)
        case .paywall:
            presentPaywall(for: bookID)
        case .sample, .wait:
            break
        }
    }

    func presentPaywall(for bookID: BookID) {
        paywallBookID = bookID
    }

    /// Called by the paywall. `subscribed` is the outcome; navigation happens
    /// once the cover has finished dismissing.
    func finishPaywall(subscribed: Bool) {
        // Idempotent: a purchase can report success through both the button
        // and the entitlement change, and only the first call may decide.
        guard let bookID = paywallBookID else { return }
        pendingReaderBookID = subscribed ? bookID : nil
        paywallBookID = nil
    }

    func paywallDidDismiss() {
        guard let bookID = pendingReaderBookID else { return }
        pendingReaderBookID = nil
        revealReader(for: bookID)
    }

    /// Puts the full reader on top. If the sample of the same title is already
    /// showing, it is replaced so Back returns to the catalog.
    func revealReader(for bookID: BookID) {
        if case .reader(bookID) = path.last { return }
        if case .sample(bookID) = path.last {
            path[path.count - 1] = .reader(bookID)
            return
        }
        path.append(.reader(bookID))
    }

    func popToCatalog() {
        path.removeAll()
    }
}
