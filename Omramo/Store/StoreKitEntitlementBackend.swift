import Foundation
import StoreKit
import OmramoCore

/// StoreKit 2 implementation of the store facade. Stateless: StoreKit owns the
/// transaction history, this type only translates it to `EntitlementState`.
///
/// Product identifiers live in `SubscriptionPlan` and must match
/// `Configuration/Omramo.storekit` (local testing) and App Store Connect.
/// No keys or shared secrets are needed for StoreKit 2 on device verification.
struct StoreKitEntitlementBackend: EntitlementBackend {
    func loadOffers() async throws -> [SubscriptionOffer] {
        let products: [Product]
        do {
            products = try await Product.products(for: SubscriptionPlan.productIDs)
        } catch {
            throw EntitlementError.storeUnavailable(String(describing: error))
        }
        return SubscriptionPlan.allCases.compactMap { plan in
            guard let product = products.first(where: { $0.id == plan.productID }) else { return nil }
            return SubscriptionOffer(
                plan: plan,
                displayName: product.displayName,
                displayPrice: product.displayPrice,
                periodDescription: Self.periodDescription(for: product)
            )
        }
    }

    func currentEntitlement() async -> EntitlementState {
        var best: EntitlementState = .notSubscribed
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.revocationDate == nil,
                  let plan = SubscriptionPlan(productID: transaction.productID) else { continue }
            let candidate = EntitlementState.subscribed(plan: plan, renewsOn: transaction.expirationDate)
            // Prefer the entitlement that runs longest when both plans overlap
            // during an upgrade.
            switch best {
            case .subscribed(_, let existing?) where existing >= (transaction.expirationDate ?? .distantPast):
                continue
            default:
                best = candidate
            }
        }
        return best
    }

    func purchase(_ plan: SubscriptionPlan) async throws -> PurchaseOutcome {
        let products: [Product]
        do {
            products = try await Product.products(for: [plan.productID])
        } catch {
            throw EntitlementError.storeUnavailable(String(describing: error))
        }
        guard let product = products.first else {
            throw EntitlementError.productUnavailable(plan)
        }

        let result: Product.PurchaseResult
        do {
            result = try await product.purchase()
        } catch {
            throw EntitlementError.storeUnavailable(String(describing: error))
        }

        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw EntitlementError.verificationFailed
            }
            await transaction.finish()
            return .subscribed(await currentEntitlement())
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    func restore() async throws -> EntitlementState {
        do {
            try await AppStore.sync()
        } catch {
            throw EntitlementError.storeUnavailable(String(describing: error))
        }
        return await currentEntitlement()
    }

    func entitlementUpdates() -> AsyncStream<EntitlementState> {
        AsyncStream { continuation in
            let task = Task {
                for await result in Transaction.updates {
                    if case .verified(let transaction) = result {
                        await transaction.finish()
                    }
                    continuation.yield(await currentEntitlement())
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func periodDescription(for product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return "" }
        switch (period.unit, period.value) {
        case (.month, 1): return "per month"
        case (.year, 1): return "per year"
        case (.week, 1): return "per week"
        case (.day, 1): return "per day"
        case (.month, let n): return "every \(n) months"
        case (.year, let n): return "every \(n) years"
        case (.week, let n): return "every \(n) weeks"
        case (.day, let n): return "every \(n) days"
        default: return ""
        }
    }
}
