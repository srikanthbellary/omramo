import Foundation
import Observation
import SwiftUI
import OmramoCore

/// App wide preferences. Small on purpose: one appearance setting today.
/// Persisted in `UserDefaults` and applied at the root with
/// `preferredColorScheme`, so every window follows the same choice.
@Observable
@MainActor
final class AppSettings {
    private(set) var appearance: AppearanceMode

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.appearance = AppearanceMode(stored: defaults.string(forKey: AppearanceMode.storageKey))
    }

    func setAppearance(_ mode: AppearanceMode) {
        appearance = mode
        defaults.set(mode.rawValue, forKey: AppearanceMode.storageKey)
    }
}

extension AppearanceMode {
    /// `nil` means follow the system, which is what `preferredColorScheme` expects.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
