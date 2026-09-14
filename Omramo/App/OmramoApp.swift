import SwiftUI

@main
struct OmramoApp: App {
    @State private var environment = AppEnvironment.live()

    var body: some Scene {
        // A single WindowGroup keeps the locked loop simple. The generated
        // scene manifest enables multiple scenes, so a second window can open
        // on the Duo inner display without further code; each window gets its
        // own navigation state while sharing the catalog and entitlement stores.
        WindowGroup {
            RootView()
                .environment(environment.catalog)
                .environment(environment.entitlements)
                .environment(environment.navigator)
                .environment(environment.settings)
                .task {
                    await environment.entitlements.start()
                }
        }
    }
}
