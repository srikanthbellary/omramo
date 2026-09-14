import Foundation

/// The one appearance preference. System follows the device; Light and Dark
/// pin the app. Stored by raw value so the key survives renames of cases'
/// display text.
public enum AppearanceMode: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public static let storageKey = "appearance.mode"
    public static let `default`: AppearanceMode = .system

    public var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    /// Lenient restore: unknown or missing values fall back to System.
    public init(stored rawValue: String?) {
        self = rawValue.flatMap(AppearanceMode.init(rawValue:)) ?? .default
    }
}
