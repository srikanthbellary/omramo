import SwiftUI
import OmramoCore

// MARK: - Wordmark in the nav (§4.4 "Wordmark in nav")

/// OM | RA | MO with the middle in the accent colour. The name comes only from `Brand`.
struct WordmarkView: View {
    var body: some View {
        let mark = FoldMark()
        HStack(spacing: 0) {
            Text(verbatim: mark.leading)
            Text(verbatim: mark.middle)
                .foregroundStyle(Color(rgba: Tokens.Palette.wordmarkAccent))
            Text(verbatim: mark.trailing)
        }
        .typeRole(Tokens.UIType.navWordmark)
        .foregroundStyle(Color(rgba: Tokens.Palette.ink))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: Brand.displayName))
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Cover (§5.13)

struct CoverView: View {
    @Environment(\.pane) private var pane
    let story: Story
    var radius: Double = Tokens.Radius.storyCover

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: pane.pt(radius), style: .continuous)
        CoverArtView(story: story)
            .clipShape(shape)
            .overlay(shape.strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5))
            .shadow(color: Color(rgba: Tokens.Surfaces.coverShadow), radius: pane.pt(13), x: 0, y: pane.pt(12))
            .shadow(color: Color(rgba: Tokens.Surfaces.coverShadow.opacity(0.16)), radius: pane.pt(2.5), x: 0, y: pane.pt(2))
    }
}

// MARK: - Story card

/// Cover 116 × 134 with the tier pill, then title (up to three lines) and origin.
struct StoryCardView: View {
    @Environment(\.pane) private var pane
    let story: Story

    var body: some View {
        let width = pane.pt(Tokens.Size.storyCoverWidth)
        VStack(alignment: .leading, spacing: 0) {
            CoverView(story: story)
                .frame(width: width, height: pane.pt(Tokens.Size.storyCoverHeight))
                .overlay(alignment: .topLeading) {
                    TierPill(tier: story.tier)
                        .padding(pane.pt(7))
                }
            // TODO(M4): finished tick (24 pt white disc) at the cover's bottom right.

            Text(verbatim: story.title)
                .typeRole(Tokens.UIType.storyCardTitle)
                .foregroundStyle(Color(rgba: Tokens.Palette.ink))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.top, pane.pt(9))

            HStack(spacing: pane.pt(5)) {
                PinIcon(color: Color(hex: story.region.pinColor, fallback: Tokens.Palette.mint), width: 8)
                Text(verbatim: story.region.label)
                    .typeRole(Tokens.UIType.storyCardPlace)
                    .foregroundStyle(Color(rgba: Tokens.Palette.ink.opacity(0.6)))
                    .lineLimit(1)
            }
            .padding(.top, pane.pt(5))
        }
        .frame(width: width, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(story.title). Level: \(story.tier.displayName). From \(story.region.label)."))
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Keep reading card

/// 372 × 186 card: story art, tier pill, title, Continue button, page and progress.
struct KeepReadingCard: View {
    @Environment(\.pane) private var pane
    let keepReading: KeepReading

    var body: some View {
        let story = keepReading.story
        let shape = RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.keepReadingCover), style: .continuous)
        ZStack(alignment: .topLeading) {
            CoverArtView(story: story)
            // Shade under the bottom row so white text reads on any art.
            LinearGradient(
                colors: [Color(rgba: Tokens.Palette.night.opacity(0)), Color(rgba: Tokens.Palette.night.opacity(0.72))],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 0) {
                TierPill(tier: story.tier, height: Tokens.Size.pillHeightKeepReading)
                Text(verbatim: story.title)
                    .typeRole(Tokens.UIType.keepReadingTitle)
                    .foregroundStyle(Color(hex: story.theme.textColor, fallback: Tokens.Palette.ink))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(width: pane.pt(190), alignment: .leading)
                    .padding(.top, pane.pt(10))
                Spacer(minLength: 0)
                HStack(spacing: pane.pt(12)) {
                    PrimaryButtonLabel(title: "Continue", icon: .book, height: 42, fontSize: 15)
                    VStack(alignment: .leading, spacing: pane.pt(7)) {
                        HStack(spacing: pane.pt(5)) {
                            Text(verbatim: "Page \(keepReading.page) of \(keepReading.pageCount)")
                            Spacer(minLength: pane.pt(4))
                            PinIcon(color: Color.white.opacity(0.9), width: 8)
                            Text(verbatim: story.region.label)
                        }
                        .typeRole(Tokens.UIType.chip)
                        .lineLimit(1)
                        .foregroundStyle(Color.white)

                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.3))
                                Capsule().fill(Color.white)
                                    .frame(width: proxy.size.width * CGFloat(keepReading.fraction))
                            }
                        }
                        .frame(height: pane.pt(5))
                    }
                }
            }
            .padding(.horizontal, pane.pt(18))
            .padding(.vertical, pane.pt(16))
        }
        .clipShape(shape)
        .overlay(shape.strokeBorder(Color.white.opacity(0.4), lineWidth: 0.5))
        .shadow(color: Color(rgba: Tokens.Surfaces.coverShadow), radius: pane.pt(13), x: 0, y: pane.pt(12))
        .contentShape(shape)
    }
}

// MARK: - Level filter (§5.14)

/// All / Low / Medium / Advanced. Height 38, track ink 7%, selected segment white.
struct LevelFilterView: View {
    @Environment(\.pane) private var pane
    @Binding var selection: LibraryFilter

    var body: some View {
        HStack(spacing: 0) {
            ForEach(LibraryFilter.allCases, id: \.self) { filter in
                segment(filter)
            }
        }
        .padding(pane.pt(3))
        .frame(height: pane.pt(Tokens.Size.segmentedFilterHeight))
        .background(
            Color(rgba: Tokens.Surfaces.segmentTrack),
            in: RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.segmentedFilter), style: .continuous)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(verbatim: "Stories by level"))
    }

    private func color(for filter: LibraryFilter, selected: Bool) -> Color {
        if let tier = filter.tier {
            return Color(rgba: Tokens.TierColors.colors(for: tier).pillText)
        }
        return Color(rgba: selected ? Tokens.Palette.ink : Tokens.Palette.ink.opacity(0.7))
    }

    private func segment(_ filter: LibraryFilter) -> some View {
        let selected = filter == selection
        let tint = color(for: filter, selected: selected)
        let shape = RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.segment), style: .continuous)
        return Button {
            selection = filter
        } label: {
            HStack(spacing: pane.pt(6)) {
                if let tier = filter.tier {
                    TierGlyph(tier: tier, color: tint)
                }
                Text(verbatim: filter.displayName)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .typeRole(Tokens.UIType.segmentLabel)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if selected {
                    shape
                        .fill(Color.white)
                        .shadow(color: Color(rgba: Tokens.Surfaces.coverShadow.opacity(0.14)), radius: pane.pt(4), x: 0, y: pane.pt(2))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: filter.tier == nil ? "All levels" : "Level: \(filter.displayName)"))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

// MARK: - Tab bar (§5.15)

/// Floating glass capsule with three items. Only Library is live in M1.
/// TODO(M4): "My shelf" tab, and "Grown-ups" behind the grown-up gate. Until then those two
/// items are drawn, as in the design, but do nothing and are hidden from assistive technology.
struct LibraryTabBar: View {
    @Environment(\.pane) private var pane

    var body: some View {
        HStack(spacing: pane.pt(2)) {
            item(.home, "Library", selected: true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "Library"))
                .accessibilityAddTraits([.isSelected, .isButton])
            item(.shelf, "My shelf", selected: false)
                .accessibilityHidden(true)
            item(.lock, "Grown-ups", selected: false)
                .accessibilityHidden(true)
        }
        .padding(pane.pt(5))
        .frame(height: pane.pt(Tokens.Size.tabBarHeight))
        .glass(.light, fill: Tokens.Glass.tabBarFill, in: Capsule(style: .continuous))
    }

    private func item(_ icon: OmramoIcon.Name, _ title: String, selected: Bool) -> some View {
        let tint = Color(rgba: selected ? Tokens.Palette.violetStrong : Tokens.Palette.ink.opacity(0.55))
        return VStack(spacing: pane.pt(4)) {
            OmramoIcon(name: icon)
            Text(verbatim: title)
                .typeRole(Tokens.UIType.tabLabel)
                .lineLimit(1)
        }
        .foregroundStyle(tint)
        .frame(width: pane.pt(Tokens.Size.tabItemWidth))
        .frame(maxHeight: .infinity)
        .background {
            if selected {
                RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.tabItem), style: .continuous)
                    .fill(Color(rgba: Tokens.Surfaces.tabSelected))
            }
        }
    }
}
