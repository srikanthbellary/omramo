import Foundation

/// The one subscription that unlocks the whole catalog. There is no per title
/// purchase by design; both plans belong to a single subscription
/// group so upgrading or downgrading never double bills.
public enum SubscriptionPlan: String, CaseIterable, Hashable, Sendable, Identifiable {
    case monthly
    case yearly

    public var id: String { rawValue }

    /// App Store product identifier. These are public identifiers, not secrets,
    /// and must match `Configuration/Omramo.storekit` and App Store Connect.
    public var productID: String {
        switch self {
        case .monthly: return "com.omramo.allaccess.monthly"
        case .yearly: return "com.omramo.allaccess.yearly"
        }
    }

    public static let subscriptionGroupID = "omramo.allaccess"

    public static var productIDs: [String] { allCases.map(\.productID) }

    public init?(productID: String) {
        guard let plan = Self.allCases.first(where: { $0.productID == productID }) else { return nil }
        self = plan
    }
}

/// What the reader is allowed to do right now.
public enum EntitlementState: Equatable, Sendable, Codable {
    /// Not yet checked with the store. Views wait instead of flashing a paywall.
    case unknown
    case notSubscribed
    case subscribed(plan: SubscriptionPlan?, renewsOn: Date?)

    public var allowsReading: Bool {
        if case .subscribed = self { return true }
        return false
    }

    /// Encodes a known state for `UserDefaults`. `.unknown` is never written
    /// so a relaunch does not freeze the gate on "wait".
    public var persistedData: Data? {
        guard self != .unknown else { return nil }
        return try? JSONEncoder().encode(self)
    }

    /// Restores a persisted state. Bad or missing data is `nil` so the caller
    /// can fall back to its default.
    public static func fromPersisted(_ data: Data?) -> EntitlementState? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(EntitlementState.self, from: data)
    }
}

/// The hard paywall rule, kept as a pure function so it is testable and used
/// identically by every screen that gates content.
public enum AccessDecision: Equatable, Sendable {
    case allow
    case showPaywall
    case wait
}

/// The next screen in the locked loop. Catalog, sample and paywall all ask
/// the gate instead of choosing a destination themselves.
public enum LoopDestination: Equatable, Sendable {
    case sample
    case paywall
    case reader
    case wait
}

public enum EntitlementGate {
    public static func decision(for state: EntitlementState) -> AccessDecision {
        switch state {
        case .unknown: return .wait
        case .notSubscribed: return .showPaywall
        case .subscribed: return .allow
        }
    }

    /// Pages inside the free sample never need a subscription.
    public static func canRead(pageIndex: Int, in book: Book, state: EntitlementState) -> Bool {
        if pageIndex < book.sample.pageCount { return true }
        return decision(for: state) == .allow
    }

    /// Catalog tap. Sample pages are free, so an unknown store still opens
    /// the sample instead of blocking the shelf. All access opens the reader.
    public static func destinationFromCatalog(for state: EntitlementState) -> LoopDestination {
        switch decision(for: state) {
        case .allow: return .reader
        case .showPaywall, .wait: return .sample
        }
    }

    /// Continue from the sample. This is the hard gate: paywall, reader, or wait.
    public static func destinationFromSample(for state: EntitlementState) -> LoopDestination {
        switch decision(for: state) {
        case .allow: return .reader
        case .showPaywall: return .paywall
        case .wait: return .wait
        }
    }
}

/// Result of a purchase attempt the UI can act on without knowing StoreKit.
public enum PurchaseOutcome: Equatable, Sendable {
    case subscribed(EntitlementState)
    /// Waiting on Ask to Buy or a payment method. Entitlement arrives later.
    case pending
    case cancelled
}

/// A purchasable plan with store supplied display strings. Prices are never
/// hardcoded in the app; they come from StoreKit or the simulator stand in.
public struct SubscriptionOffer: Hashable, Sendable, Identifiable {
    public var plan: SubscriptionPlan
    public var displayName: String
    public var displayPrice: String
    public var periodDescription: String

    public init(plan: SubscriptionPlan, displayName: String, displayPrice: String, periodDescription: String) {
        self.plan = plan
        self.displayName = displayName
        self.displayPrice = displayPrice
        self.periodDescription = periodDescription
    }

    public var id: SubscriptionPlan { plan }
}

/// Failures from the store layer with copy the paywall can show directly.
public enum EntitlementError: Error, Equatable, Sendable, LocalizedError {
    case productUnavailable(SubscriptionPlan)
    case verificationFailed
    case storeUnavailable(String)

    public var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return "That plan is not available right now. Please try again in a moment."
        case .verificationFailed:
            return "We could not verify this purchase with the App Store."
        case .storeUnavailable:
            return "The App Store is not reachable right now. Please check your connection and try again."
        }
    }
}

/// Store facade the app talks to. StoreKit 2 and the simulator only stand in
/// both implement this, so the paywall and reader never import StoreKit.
public protocol EntitlementBackend: Sendable {
    func loadOffers() async throws -> [SubscriptionOffer]
    func currentEntitlement() async -> EntitlementState
    func purchase(_ plan: SubscriptionPlan) async throws -> PurchaseOutcome
    func restore() async throws -> EntitlementState
    /// Emits whenever the store reports a change (renewal, revocation, Ask to Buy approval).
    func entitlementUpdates() -> AsyncStream<EntitlementState>
}
