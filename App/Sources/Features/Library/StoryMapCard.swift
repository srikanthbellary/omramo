import SwiftUI
import OmramoCore

/// One pin on the story map.
struct StoryMapPin: Identifiable {
    enum Status {
        /// A story in the catalog.
        case story
        /// The story being read now (a position is saved).
        case readingNow
    }

    let id: StoryID
    let label: String
    let color: Color
    let point: GeoPoint
    let state: Status
    /// False on a crowded map, where only the story being read is named (`StoryMapRules`).
    var showsLabel = true

    /// Real pins from the catalog: one for every story that has a `region.pin`. The story
    /// being read comes last, so its pin and label are drawn over the others.
    static func pins(for library: Library, readingNow: StoryID?) -> [StoryMapPin] {
        let placed = library.stories.filter { $0.region.pin != nil }
        let pins: [StoryMapPin] = placed.compactMap { story in
            guard let point = story.region.pin else { return nil }
            let isReadingNow = story.id == readingNow
            return StoryMapPin(
                id: story.id,
                label: story.region.label,
                color: Color(hex: story.region.pinColor, fallback: Tokens.Palette.mint),
                point: point,
                state: isReadingNow ? .readingNow : .story,
                showsLabel: StoryMapRules.showsLabel(isReadingNow: isReadingNow, pinCount: placed.count)
            )
        }
        return pins.filter { $0.state == .story } + pins.filter { $0.state == .readingNow }
    }
}

/// The dotted world map of the design source (`art-brand.js`): hand-plotted land runs every
/// 5° of latitude. Stylised, not survey-accurate.
enum WorldMap {
    /// (latitude, [(from longitude, to longitude)])
    static let land: [(Double, [(Double, Double)])] = [
        (75, [(-120, -80), (-55, -20), (90, 110)]),
        (70, [(-160, -85), (-52, -22), (20, 30), (60, 180)]),
        (65, [(-165, -62), (-50, -38), (-22, -14), (10, 40), (45, 180)]),
        (60, [(-162, -95), (-78, -62), (-48, -43), (5, 30), (30, 165)]),
        (55, [(-130, -60), (-8, 0), (8, 160)]),
        (50, [(-126, -58), (-5, 2), (3, 142)]),
        (45, [(-124, -64), (0, 138), (140, 144)]),
        (40, [(-123, -72), (-9, 2), (8, 28), (28, 128), (138, 142)]),
        (35, [(-120, -76), (-6, 10), (28, 122), (133, 140)]),
        (30, [(-115, -82), (-9, 34), (35, 120)]),
        (25, [(-110, -98), (-82, -80), (-14, 56), (58, 118)]),
        (20, [(-105, -88), (-17, 50), (70, 108)]),
        (15, [(-96, -84), (-17, 48), (74, 82), (94, 108), (120, 123)]),
        (10, [(-86, -62), (-15, 50), (76, 80), (98, 108), (122, 126)]),
        (5, [(-78, -52), (-8, 46), (96, 118)]),
        (0, [(-80, -50), (10, 42), (100, 104), (110, 118), (120, 132)]),
        (-5, [(-80, -36), (12, 40), (104, 112), (120, 150)]),
        (-10, [(-76, -37), (13, 40), (142, 148)]),
        (-15, [(-74, -39), (12, 40), (46, 50), (124, 146)]),
        (-20, [(-70, -40), (13, 36), (44, 50), (116, 148)]),
        (-25, [(-70, -48), (15, 34), (44, 47), (114, 152)]),
        (-30, [(-71, -51), (17, 31), (116, 152)]),
        (-35, [(-72, -55), (19, 26), (118, 124), (136, 150)]),
        (-40, [(-73, -62), (144, 148), (172, 176)]),
        (-45, [(-74, -66), (168, 172)]),
        (-50, [(-74, -68)]),
    ]

    /// "More cultures later" markers of the design (no titles promised).
    static let later: [GeoPoint] = [
        GeoPoint(lat: 27, lon: 31), GeoPoint(lat: 35, lon: 105), GeoPoint(lat: 17, lon: -90),
        GeoPoint(lat: 32, lon: 53), GeoPoint(lat: 39, lon: 23), GeoPoint(lat: 33, lon: 44),
    ]

    /// The design's projection: longitude −170…180 across the width, latitude 78…−54 down the height.
    static func project(_ point: GeoPoint, in size: CGSize) -> CGPoint {
        CGPoint(
            x: CGFloat((point.lon + 170) / 350) * size.width,
            y: CGFloat((78 - point.lat) / 132) * size.height
        )
    }
}

/// Story map card (§5.21): 372 × 214, dotted world map, one pin per story, legend.
struct StoryMapCard: View {
    @Environment(\.pane) private var pane
    let pins: [StoryMapPin]

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: pane.pt(Tokens.Radius.card), style: .continuous)
        GeometryReader { proxy in
            // The map sits 14 pt inside the card and is 344 × 150 on the 372-wide design card.
            let unit = proxy.size.width / CGFloat(Tokens.Spacing.cardWidth)
            let mapSize = CGSize(width: 344 * unit, height: 150 * unit)
            ZStack(alignment: .topLeading) {
                // linear-gradient(160deg, …): mostly downward, leaning right.
                LinearGradient(
                    gradient: Gradient(tokens: Tokens.Gradients.mapCard),
                    startPoint: UnitPoint(x: 0.33, y: 0),
                    endPoint: UnitPoint(x: 0.67, y: 1)
                )

                ZStack(alignment: .topLeading) {
                    dots(unit: unit)
                    ForEach(pins) { pin in
                        pinView(pin, unit: unit, mapSize: mapSize)
                    }
                }
                .frame(width: mapSize.width, height: mapSize.height, alignment: .topLeading)
                .offset(x: 14 * unit, y: 14 * unit)

                legend(unit: unit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.leading, 18 * unit)
                    .padding(.bottom, 14 * unit)
            }
        }
        .clipShape(shape)
        .shadow(color: Color(rgba: Tokens.Surfaces.coverShadow.opacity(0.3)), radius: pane.pt(17), x: 0, y: pane.pt(16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilitySummary))
    }

    private var accessibilitySummary: String {
        // One mention of each place, however many stories come from it.
        var seen = Set<String>()
        let places = pins.map(\.label).filter { seen.insert($0).inserted }.joined(separator: ", ")
        return places.isEmpty ? "Map of the world." : "Map of the world. Stories from: \(places)."
    }

    private func dots(unit: CGFloat) -> some View {
        let storyPoints = pins.map(\.point)
        return Canvas { context, size in
            let dot = Color.white.opacity(0.3)
            let radius = 1.5 * unit
            for (latitude, runs) in WorldMap.land {
                for (from, to) in runs {
                    var longitude = (from / 5).rounded(.up) * 5
                    while longitude <= to {
                        let center = WorldMap.project(GeoPoint(lat: latitude, lon: longitude), in: size)
                        context.fill(
                            Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                            with: .color(dot)
                        )
                        longitude += 5
                    }
                }
            }
            // "More cultures later": small dashed rings.
            for point in WorldMap.later where StoryMapRules.isClear(point, of: storyPoints) {
                let center = WorldMap.project(point, in: size)
                let ring = 3.6 * unit
                context.stroke(
                    Path(ellipseIn: CGRect(x: center.x - ring, y: center.y - ring, width: ring * 2, height: ring * 2)),
                    with: .color(Color.white.opacity(0.75)),
                    style: StrokeStyle(lineWidth: 1.3 * unit, dash: [2 * unit, 1.6 * unit])
                )
            }
        }
    }

    private func pinView(_ pin: StoryMapPin, unit: CGFloat, mapSize: CGSize) -> some View {
        let center = WorldMap.project(pin.point, in: mapSize)
        // Keep the label inside the map.
        let labelX = min(max(center.x, 48 * unit), mapSize.width - 48 * unit)
        return ZStack {
            if pin.state == .readingNow {
                Circle()
                    .fill(pin.color.opacity(0.22))
                    .frame(width: 26 * unit, height: 26 * unit)
                    .position(center)
                Circle()
                    .stroke(pin.color.opacity(0.7), lineWidth: 1.2 * unit)
                    .frame(width: 16 * unit, height: 16 * unit)
                    .position(center)
            }
            Circle()
                .fill(pin.color)
                .overlay(Circle().stroke(Color.white, lineWidth: 1.8 * unit))
                .frame(width: 10 * unit, height: 10 * unit)
                .position(center)
            if pin.showsLabel {
                Text(verbatim: pin.label)
                    .typeRole(Tokens.UIType.mapPinLabel)
                    .foregroundStyle(Color(rgba: Tokens.Palette.ink))
                    .lineLimit(1)
                    .padding(.horizontal, 7 * unit)
                    .frame(height: 20 * unit)
                    .background(Color.white, in: Capsule(style: .continuous))
                    .fixedSize()
                    .position(x: labelX, y: center.y + 24 * unit)
            }
        }
        .frame(width: mapSize.width, height: mapSize.height)
    }

    /// Legend row, as designed. TODO(M4): a pin does not yet look different once its story
    /// is finished (the tick on the cover and the shelf card show that); a story's pin is
    /// drawn in its own colour, and ringed while it is the one being read.
    private func legend(unit: CGFloat) -> some View {
        HStack(spacing: 14 * unit) {
            HStack(spacing: 6 * unit) {
                Circle()
                    .fill(Color(rgba: Tokens.Palette.mint))
                    .frame(width: 8 * unit, height: 8 * unit)
                Text(verbatim: "Read")
            }
            HStack(spacing: 6 * unit) {
                Circle()
                    .fill(Color(rgba: Tokens.Palette.mapPinJapan))
                    .frame(width: 8 * unit, height: 8 * unit)
                    .background(
                        Circle()
                            .fill(Color(rgba: Tokens.Palette.mapPinJapan.opacity(0.3)))
                            .frame(width: 14 * unit, height: 14 * unit)
                    )
                Text(verbatim: "Reading now")
            }
            HStack(spacing: 6 * unit) {
                Circle()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1.3 * unit, dash: [2 * unit, 1.6 * unit]))
                    .frame(width: 8 * unit, height: 8 * unit)
                Text(verbatim: "More cultures later")
            }
        }
        .typeRole(Tokens.UIType.mapLegend)
        .foregroundStyle(Color.white.opacity(0.78))
        .lineLimit(1)
    }
}
