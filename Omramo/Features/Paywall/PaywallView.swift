import SwiftUI
import OmramoCore

/// The hard paywall. One subscription, two plans, no per title purchase.
/// Presented full screen over the sample or the reader; closing without a
/// plan returns to where the reader was.
struct PaywallView: View {
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(AppNavigator.self) private var navigator
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var selectedPlan: SubscriptionPlan = .yearly

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    benefits
                    plans
                    actions
                    footer
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .frame(maxWidth: horizontalSizeClass == .regular ? 560 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .background(OmramoPalette.paper.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Not now") {
                        navigator.finishPaywall(subscribed: false)
                    }
                    .foregroundStyle(OmramoPalette.inkSoft)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await entitlements.loadOffersIfNeeded() }
        .onChange(of: entitlements.effectiveState.allowsReading) { _, allowsReading in
            // Covers Ask to Buy approvals and the developer override arriving
            // while the paywall is up.
            if allowsReading {
                navigator.finishPaywall(subscribed: true)
            }
        }
        .interactiveDismissDisabled()
    }

    private var header: some View {
        VStack(spacing: 16) {
            FoldMarkView(isOpen: true, scale: 0.55)
                .padding(.top, 8)
            Text("Read every book in \(Brand.displayName)")
                .font(OmramoType.displayTitle)
                .foregroundStyle(OmramoPalette.ink)
                .multilineTextAlignment(.center)
            Text("One subscription. The whole shelf, in Telugu with English and Hindi editions as they arrive.")
                .font(OmramoType.cardSubtitle)
                .foregroundStyle(OmramoPalette.inkSoft)
                .multilineTextAlignment(.center)
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 12) {
            benefit("books.vertical.fill", "Every title in the catalog, with no per book purchases")
            benefit("rectangle.split.2x1.fill", "Open book reading across both Duo panes")
            benefit("character.book.closed.fill", "Telugu first, with paired literary editions side by side")
            benefit("sparkles", "New illustrated serials as they are published")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func benefit(_ symbol: String, _ text: String) -> some View {
        Label {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(OmramoPalette.ink)
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(OmramoPalette.saffron)
        }
    }

    @ViewBuilder
    private var plans: some View {
        switch entitlements.offers {
        case .idle, .loading:
            ProgressView("Checking plans")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
        case .empty:
            ContentUnavailableView("Plans are not available yet", systemImage: "cart", description: Text("Please try again in a moment."))
        case .failed(let failure):
            VStack(spacing: 12) {
                Text(failure.message)
                    .font(.subheadline)
                    .foregroundStyle(OmramoPalette.inkSoft)
                    .multilineTextAlignment(.center)
                Button("Try again") { Task { await entitlements.loadOffers() } }
                    .buttonStyle(.bordered)
            }
            .padding(.vertical, 12)
        case .loaded(let offers):
            VStack(spacing: 12) {
                ForEach(offers) { offer in
                    PlanCard(offer: offer, isSelected: offer.plan == selectedPlan) {
                        selectedPlan = offer.plan
                    }
                }
            }
            .onAppear {
                if !offers.contains(where: { $0.plan == selectedPlan }), let first = offers.first {
                    selectedPlan = first.plan
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    if await entitlements.purchase(selectedPlan) {
                        navigator.finishPaywall(subscribed: true)
                    }
                }
            } label: {
                Group {
                    if entitlements.isPurchasing {
                        ProgressView().tint(OmramoPalette.paper)
                    } else {
                        Text("Subscribe and keep reading")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(OmramoPalette.saffron)
            .disabled(entitlements.isPurchasing || entitlements.offers.value == nil)

            Button {
                Task { await entitlements.restore() }
            } label: {
                if entitlements.isRestoring {
                    ProgressView()
                } else {
                    Text("Restore purchases")
                }
            }
            .font(.subheadline)
            .disabled(entitlements.isRestoring)

            if let message = entitlements.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Text("Payment is charged to your Apple Account. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel any time in Settings.")
                .font(.caption2)
                .foregroundStyle(OmramoPalette.inkSoft)
                .multilineTextAlignment(.center)

            #if DEBUG
            DeveloperOverride()
            #endif
        }
    }
}

/// One selectable plan. Prices come from the store, never from code.
private struct PlanCard: View {
    let offer: SubscriptionOffer
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? OmramoPalette.saffron : OmramoPalette.inkSoft)
                VStack(alignment: .leading, spacing: 3) {
                    Text(offer.plan == .yearly ? "Yearly" : "Monthly")
                        .font(.headline)
                        .foregroundStyle(OmramoPalette.ink)
                    Text(offer.displayName)
                        .font(.caption)
                        .foregroundStyle(OmramoPalette.inkSoft)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(offer.displayPrice)
                        .font(.headline)
                        .foregroundStyle(OmramoPalette.ink)
                    Text(offer.periodDescription)
                        .font(.caption)
                        .foregroundStyle(OmramoPalette.inkSoft)
                }
            }
            .padding(16)
            .background(OmramoPalette.paperShade, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? OmramoPalette.saffron : .clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityLabel(Text("\(offer.plan == .yearly ? "Yearly" : "Monthly"), \(offer.displayPrice) \(offer.periodDescription)"))
    }
}

#if DEBUG
/// Debug builds only. Lets anyone on a simulator walk the locked loop end to
/// end without a StoreKit configuration or a sandbox account.
private struct DeveloperOverride: View {
    @Environment(EntitlementStore.self) private var entitlements

    var body: some View {
        DisclosureGroup("Developer") {
            VStack(alignment: .leading, spacing: 8) {
                Button("Simulate an active subscription") {
                    entitlements.setDebugOverride(.subscribed(plan: .yearly, renewsOn: nil))
                }
                Button("Clear simulated subscription") {
                    entitlements.setDebugOverride(nil)
                }
                Text("Debug builds only. Use the StoreKit configuration attached to the scheme for real StoreKit 2 testing.")
                    .font(.caption2)
                    .foregroundStyle(OmramoPalette.inkSoft)
            }
            .font(.footnote)
            .padding(.top, 6)
        }
        .font(.caption)
        .foregroundStyle(OmramoPalette.inkSoft)
        .padding(.top, 8)
    }
}
#endif

#Preview("Paywall") {
    let environment = AppEnvironment.preview()
    return PaywallView()
        .environment(environment.entitlements)
        .environment(environment.navigator)
}
