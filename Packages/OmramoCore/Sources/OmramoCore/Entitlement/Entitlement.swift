import Foundation

/// The one subscription that unlocks the whole catalog. There is no per title
/// purchase in Omramo by design; both plans belong to a single subscription
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
public enum EntitlementState: Equatable, Sendable {
    /// Not yet checked with the store. Views wait instead of flashing a paywall.
    case unknown
    case notSubscribed
    case subscribed(plan: SubscriptionPlan?, renewsOn: Date?)

    public var allowsReading: Bool {
        if case .subscribed = self { return true }
        return false
    }
}

/// The hard paywall rule, kept as a pure function so it is testable and used
/// identically by every screen that gates content.
public enum AccessDecision: Equatable, Sendable {
    case allow
    case showPaywall
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
}

/// Result of a purchase attempt the UI can act on without knowing StoreKit.
public enum PurchaseOutcome: Equatable, Sendable {
    case subscribed(EntitlementState)
    case pending
    case cancelled
}

/// Store facade the app talks to. StoreKit 2 and the simulator only stand in
/// both implement this, so the paywall and reader never import StoreKit.
@MainActor
public protocol EntitlementProviding: AnyObject {
    var state: EntitlementState { get }
    var isBusy: Bool { get }
    var lastErrorMessage: String? { get }
    func refresh() async
    func purchase(_ plan: SubscriptionPlan) async -> PurchaseOutcome
    func restorePurchases() async
}
