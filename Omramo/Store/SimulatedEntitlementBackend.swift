import Foundation
import OmramoCore

/// Stand-in store for previews, UI tests and simulators without a StoreKit
/// configuration. Purchases succeed after a short delay so the paywall's busy
/// state is visible. Prices are placeholders and are labelled as such. Pass
/// `persistTo:` to keep the entitlement across launches.
actor SimulatedEntitlementBackend: EntitlementBackend {
    static let storageKey = "omramo.simulated.entitlement"

    private var state: EntitlementState
    private var continuations: [UUID: AsyncStream<EntitlementState>.Continuation] = [:]
    private let purchaseDelay: Duration
    private let defaults: UserDefaults?

    init(
        initialState: EntitlementState = .notSubscribed,
        purchaseDelay: Duration = .milliseconds(600),
        persistTo defaults: UserDefaults? = nil
    ) {
        self.defaults = defaults
        self.purchaseDelay = purchaseDelay
        if let stored = EntitlementState.fromPersisted(defaults?.data(forKey: Self.storageKey)) {
            self.state = stored
        } else {
            self.state = initialState
        }
    }

    func loadOffers() async throws -> [SubscriptionOffer] {
        [
            SubscriptionOffer(plan: .monthly, displayName: Brand.allAccessName, displayPrice: "Sample price", periodDescription: "per month"),
            SubscriptionOffer(plan: .yearly, displayName: Brand.allAccessName, displayPrice: "Sample price", periodDescription: "per year")
        ]
    }

    func currentEntitlement() async -> EntitlementState {
        state
    }

    func purchase(_ plan: SubscriptionPlan) async throws -> PurchaseOutcome {
        try await Task.sleep(for: purchaseDelay)
        let renewal = Calendar.current.date(byAdding: plan == .monthly ? .month : .year, value: 1, to: Date())
        state = .subscribed(plan: plan, renewsOn: renewal)
        persist()
        broadcast()
        return .subscribed(state)
    }

    func restore() async throws -> EntitlementState {
        state
    }

    nonisolated func entitlementUpdates() -> AsyncStream<EntitlementState> {
        AsyncStream { continuation in
            let id = UUID()
            Task { await self.register(id: id, continuation: continuation) }
            continuation.onTermination = { _ in
                Task { await self.unregister(id: id) }
            }
        }
    }

    /// Test hook: flip the store from outside, like a refund or renewal.
    func setState(_ newState: EntitlementState) {
        state = newState
        persist()
        broadcast()
    }

    private func persist() {
        guard let defaults else { return }
        if let data = state.persistedData {
            defaults.set(data, forKey: Self.storageKey)
        } else {
            defaults.removeObject(forKey: Self.storageKey)
        }
    }

    private func register(id: UUID, continuation: AsyncStream<EntitlementState>.Continuation) {
        continuations[id] = continuation
    }

    private func unregister(id: UUID) {
        continuations[id] = nil
    }

    private func broadcast() {
        for continuation in continuations.values {
            continuation.yield(state)
        }
    }
}
