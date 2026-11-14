import Foundation

/// The one place the product is named. `Configuration/Brand.xcconfig` must agree with
/// `displayName` (a unit test checks this).
public enum Brand {
    public static let displayName = "Omramo"
    public static let wordmark = "OMRAMO"
    public static let tagline = "A magical book that you read."
    public static let domain = "omramo.com"
    public static let privacyURLString = "https://omramo.com/privacy"
    public static let termsURLString = "https://omramo.com/terms"
    public static let originalStoryCredit = "Original story written by us (Omramo)"
}

/// The wordmark split in three for the fold: OM | RA | MO. The hinge runs through "RA".
public struct FoldMark: Equatable, Sendable {
    public let leading: String
    public let middle: String
    public let trailing: String

    public init(wordmark: String = Brand.wordmark) {
        let letters = Array(wordmark)
        let third = letters.count / 3
        let remainder = letters.count - third * 3
        // Any extra letters go to the middle part, so the hinge stays in the centre.
        let middleCount = third + remainder
        leading = String(letters[0..<third])
        middle = String(letters[third..<(third + middleCount)])
        trailing = String(letters[(third + middleCount)...])
    }

    /// The part left of the hinge when unfolded ("OMR").
    public var leftOfHinge: String {
        let letters = Array(middle)
        return leading + String(letters[0..<(letters.count / 2)])
    }

    /// The part right of the hinge when unfolded ("AMO").
    public var rightOfHinge: String {
        let letters = Array(middle)
        return String(letters[(letters.count / 2)...]) + trailing
    }
}
