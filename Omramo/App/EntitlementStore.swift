import Foundation
import Observation
import OmramoCore

/// Single source of truth for "can this person read". Wraps whichever
/// `EntitlementBackend` the app was launched with and keeps listening for
/// store updates so a renewal or refund is reflected while reading.
@Observable
@MainActor
final class EntitlementStore {
    private(set) var state: EntitlementState = .unknown
    private(set) var offers: LoadState<[SubscriptionOffer]> = .idle
    private(set) var isPurchasing = false
    private(set) var isRestoring = false
    var errorMessage: String?

    private let backend: any EntitlementBackend
    private var updatesTask: Task<Void, Never>?

    /// Developer override used from the paywall footer to walk the locked
    /// loop on a simulator without a StoreKit configuration. Only Debug
    /// builds compile a setter, so Release can never leave `nil`. Declared
    /// outside `#if` so the Observable macro tracks it.
    private(set) var debugOverride: EntitlementState?

    init(backend: any EntitlementBackend) {
        self.backend = backend
    }

    var decision: AccessDecision {
        EntitlementGate.decision(for: effectiveState)
    }

    var effectiveState: EntitlementState {
        debugOverride ?? state
    }

    /// Call once at launch. Safe to call again; it just refreshes.
    func start() async {
        await refresh()
        if updatesTask == nil {
            updatesTask = Task { [weak self, backend] in
                for await newState in backend.entitlementUpdates() {
                    guard let self, !Task.isCancelled else { return }
                    self.state = newState
                }
            }
        }
    }

    func refresh() async {
        state = await backend.currentEntitlement()
    }

    func loadOffersIfNeeded() async {
        guard case .idle = offers else { return }
        await loadOffers()
    }

    func loadOffers() async {
        offers = .loading
        do {
            let loaded = try await backend.loadOffers()
            offers = loaded.isEmpty ? .empty : .loaded(loaded)
        } catch {
            offers = .failed(LoadFailure(message: Self.message(for: error, fallback: "The App Store is not reachable right now. Please try again.")))
        }
    }

    private static func message(for error: Error, fallback: String) -> String {
        (error as? LocalizedError)?.errorDescription ?? fallback
    }

    /// Returns `true` when reading is unlocked as a result of this call.
    func purchase(_ plan: SubscriptionPlan) async -> Bool {
        guard !isPurchasing else { return false }
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        do {
            switch try await backend.purchase(plan) {
            case .subscribed(let newState):
                state = newState
                return newState.allowsReading
            case .pending:
                errorMessage = "Your purchase is waiting for approval. Reading unlocks as soon as it goes through."
                return false
            case .cancelled:
                return false
            }
        } catch {
            errorMessage = Self.message(for: error, fallback: "The purchase did not go through. Please try again.")
            return false
        }
    }

    func restore() async {
        guard !isRestoring else { return }
        isRestoring = true
        errorMessage = nil
        defer { isRestoring = false }
        do {
            state = try await backend.restore()
            if !state.allowsReading {
                errorMessage = "No active subscription was found for this Apple Account."
            }
        } catch {
            errorMessage = Self.message(for: error, fallback: "Restore did not complete. Please try again.")
        }
    }

    #if DEBUG
    func setDebugOverride(_ override: EntitlementState?) {
        debugOverride = override
    }
    #endif
}
