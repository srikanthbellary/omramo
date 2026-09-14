import Foundation
import OmramoCore

/// Composition root. Everything with a real dependency is created here and
/// nowhere else, so previews and UI tests can swap the store and content.
@MainActor
struct AppEnvironment {
    let catalog: CatalogStore
    let entitlements: EntitlementStore
    let navigator: AppNavigator

    /// Launch argument that swaps StoreKit for the in memory store. Handy for
    /// UI tests and for running on a simulator without a StoreKit configuration.
    static let simulatedStoreArgument = "-OmramoSimulatedStore"

    static func live() -> AppEnvironment {
        let arguments = ProcessInfo.processInfo.arguments
        let backend: any EntitlementBackend
        if arguments.contains(simulatedStoreArgument) {
            backend = SimulatedEntitlementBackend()
        } else {
            backend = StoreKitEntitlementBackend()
        }
        return AppEnvironment(
            catalog: CatalogStore(repository: BundledContentRepository()),
            entitlements: EntitlementStore(backend: backend),
            navigator: AppNavigator()
        )
    }

    /// Bundled content with a simulated store, optionally already subscribed.
    static func preview(subscribed: Bool = false) -> AppEnvironment {
        AppEnvironment(
            catalog: CatalogStore(repository: BundledContentRepository()),
            entitlements: EntitlementStore(backend: SimulatedEntitlementBackend(initialState: subscribed ? .subscribed(plan: .yearly, renewsOn: nil) : .notSubscribed)),
            navigator: AppNavigator()
        )
    }
}
