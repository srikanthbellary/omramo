import SwiftUI
import StoreKit
import OmramoCore

/// The account adjacent surface for v1. There is no account: payment is the
/// Apple Account through StoreKit 2, so Settings only needs appearance, the
/// two standard subscription actions, and the legal links. No profile page.
struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(EntitlementStore.self) private var entitlements
    @Environment(\.dismiss) private var dismiss

    @State private var showsManageSubscriptions = false
    @State private var restoreMessage: String?

    private var appearanceBinding: Binding<AppearanceMode> {
        Binding(get: { settings.appearance }, set: { settings.setAppearance($0) })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Appearance", selection: appearanceBinding) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }

                Section {
                    SubscriptionStatusRow(state: entitlements.effectiveState)

                    Button {
                        Task { await restore() }
                    } label: {
                        HStack {
                            Text("Restore Purchases")
                            Spacer()
                            if entitlements.isRestoring {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(entitlements.isRestoring)

                    Button("Manage Subscription") {
                        showsManageSubscriptions = true
                    }
                } header: {
                    Text("Subscription")
                } footer: {
                    if let restoreMessage {
                        Text(restoreMessage)
                    } else {
                        Text("Billing is handled by the App Store through your Apple Account. Cancel or change plans any time; access continues to the end of the paid period.")
                    }
                }

                Section {
                    Link(destination: Brand.privacyURL) {
                        LinkRow(title: "Privacy Policy", destination: Brand.domain)
                    }
                    Link(destination: Brand.termsURL) {
                        LinkRow(title: "Terms of Use", destination: Brand.domain)
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("\(Brand.displayName) \(Self.versionString)")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            // StoreKit's system sheet: cancel, switch plans, see renewal date.
            // Uses the App Store or the scheme's StoreKit configuration; with
            // the simulated backend it has nothing to show and closes itself.
            .manageSubscriptionsSheet(isPresented: $showsManageSubscriptions)
        }
        .tint(OmramoPalette.saffron)
    }

    private func restore() async {
        restoreMessage = nil
        await entitlements.restore()
        if entitlements.effectiveState.allowsReading {
            restoreMessage = "Your subscription is active on this device."
        } else if let message = entitlements.errorMessage {
            restoreMessage = message
        }
    }

    private static var versionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "0"
        let build = info?["CFBundleVersion"] as? String ?? "0"
        return "\(version) (\(build))"
    }
}

/// One line that says what the reader has, in plain words.
private struct SubscriptionStatusRow: View {
    let state: EntitlementState

    var body: some View {
        HStack {
            Text("Status")
            Spacer()
            switch state {
            case .unknown:
                ProgressView()
                    .controlSize(.small)
            case .notSubscribed:
                Text("Browsing free")
                    .foregroundStyle(.secondary)
            case .subscribed(let plan, let renewsOn):
                VStack(alignment: .trailing, spacing: 2) {
                    Text(planTitle(plan))
                        .foregroundStyle(OmramoPalette.saffron)
                    if let renewsOn {
                        Text("Renews \(renewsOn.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func planTitle(_ plan: SubscriptionPlan?) -> String {
        switch plan {
        case .monthly: return "All access, monthly"
        case .yearly: return "All access, yearly"
        case nil: return "All access"
        }
    }
}

private struct LinkRow: View {
    let title: String
    let destination: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text(destination)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Image(systemName: "arrow.up.right")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Settings, subscribed") {
    let environment = AppEnvironment.preview(subscribed: true)
    return SettingsView()
        .environment(environment.settings)
        .environment(environment.entitlements)
}
