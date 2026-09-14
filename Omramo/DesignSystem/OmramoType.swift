import SwiftUI

/// Type roles. System fonts are used so Telugu, Devanagari and Latin all fall
/// back to their platform faces (Telugu Sangam MN, Devanagari Sangam MN) with
/// Dynamic Type support and no bundled font files.
enum OmramoType {
    /// Telugu display titles on posters and page headers.
    static let displayTitle = Font.system(.title, design: .serif, weight: .semibold)
    static let cardTitle = Font.system(.headline, design: .serif, weight: .semibold)
    static let cardSubtitle = Font.system(.subheadline, design: .default, weight: .regular)
    /// Body copy on a page. Serif for the printed book feel.
    static let pageBody = Font.system(.title3, design: .serif, weight: .regular)
    static let pageCaption = Font.system(.footnote, design: .serif, weight: .regular).italic()
    static let pageNumber = Font.system(.caption, design: .serif, weight: .regular)
    static let markLetters = Font.system(size: 34, weight: .heavy, design: .rounded)
}

extension View {
    /// Telugu needs more leading than Latin at the same point size.
    func pageTextStyle() -> some View {
        self
            .font(OmramoType.pageBody)
            .lineSpacing(8)
            .foregroundStyle(OmramoPalette.ink)
            .multilineTextAlignment(.leading)
    }
}
