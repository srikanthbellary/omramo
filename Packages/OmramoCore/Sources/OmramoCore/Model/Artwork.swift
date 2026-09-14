import Foundation

/// A poster or page illustration. The prototype ships no image binaries; each
/// artwork is a small descriptor the app renders as procedural placeholder art.
/// When real illustrations land, set `assetName` and the same descriptor keeps
/// the colour story for loading and fallback states.
public struct Artwork: Codable, Hashable, Sendable {
    /// Visual theme the placeholder renderer draws.
    public enum Motif: String, Codable, CaseIterable, Hashable, Sendable {
        case river
        case stars
        case temple
        case boat
        case forest
        case lantern
        case map
        case village
        case monsoon
        case festival
    }

    public var motif: Motif
    /// Two or more hex colours (`#RRGGBB`), darkest first.
    public var colors: [HexColor]
    /// Name of an image asset in the app bundle once a real illustration exists.
    public var assetName: String?

    public init(motif: Motif, colors: [HexColor], assetName: String? = nil) {
        self.motif = motif
        self.colors = colors
        self.assetName = assetName
    }

    public var isPlaceholder: Bool { assetName == nil }
}

/// A validated `#RRGGBB` colour. Kept as a value type so the core stays free of
/// UIKit while the app maps it to `Color` in one place.
public struct HexColor: Codable, Hashable, Sendable, CustomStringConvertible {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// Parses `#RRGGBB` or `RRGGBB`. Returns `nil` for anything else.
    public init?(_ string: String) {
        var hex = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6, let value = UInt32(hex, radix: 16) else { return nil }
        red = UInt8((value >> 16) & 0xFF)
        green = UInt8((value >> 8) & 0xFF)
        blue = UInt8(value & 0xFF)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let color = HexColor(raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "\"\(raw)\" is not a #RRGGBB colour."
            )
        }
        self = color
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

    public var description: String {
        String(format: "#%02X%02X%02X", red, green, blue)
    }
}
