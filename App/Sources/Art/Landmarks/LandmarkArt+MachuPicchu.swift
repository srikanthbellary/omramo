import SwiftUI
import OmramoCore

// Machu Picchu by day: our own drawing (no photograph, nothing traced).
// The Inca town on its saddle of the ridge: grey stone houses without roofs (gabled end walls)
// and green terraces stepping down either side, the steep sugar-loaf peak behind it, and the
// far blue-green Andes with a wisp of cloud. Card background #1F4A44.

extension LandmarkArt {
    /// machu-picchu: the roofless stone town and its terraces on the ridge, the steep green
    /// peak behind, far Andes and a wisp of cloud, by day.
    static func paintMachuPicchu(_ context: inout GraphicsContext) {
        machuSky(&context)
        machuFarAndes(&context)
        machuPeaks(&context)
        let ridge = machuRidgeShape()
        machuRidge(&context, ridge)
        machuTerraces(&context, ridge)
        machuTown(&context)
        machuNearRock(&context)
        machuFinish(&context)
    }

    // MARK: Sky and the far plane

    static func machuSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x3F8FD0), 0),
            (Art.color(0x7FBFE6), 0.28),
            (Art.color(0xCDE9EE), 0.48),
            (Art.color(0xFFE9C4), 0.6),
            (Art.color(0xFFE9C4), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: 236, rise: 80, hex: 0xFFE2B0, alpha: 0.35)
        // The light comes from the upper left: a soft bloom, no disc (the corner stays quiet).
        Art.glow(&context, 30, 110, 210, Art.color(0xFFF1D0), alpha: 0.28)
    }

    static func machuFarAndes(_ context: inout GraphicsContext) {
        let farthest = Kit.peaks(width: 480, y: 214, amp: 84, seed: 23, bottom: 300, sharp: 0.7, x0: -24)
        Art.fill(&context, farthest, Art.color(0x9CC3D2, 0.75))
        let far = Kit.peaks(width: 480, y: 228, amp: 58, seed: 9, bottom: 300, sharp: 0.5, x0: -24)
        Art.fill(&context, far, Art.color(0x6FA8A4))
        haze(&context, top: 110, bottom: 252, hex: 0xFFE9C4, alpha: 0.34)

        // Wisps of cloud lying across the far mountains, and one small cloud high on the right.
        Art.blurred(&context, radius: 3, opacity: 0.8) { g in
            var wisps = Path()
            wisps.addPath(cloudBand(-16, 198, width: 150, height: 14))
            wisps.addPath(cloudBand(296, 186, width: 156, height: 12))
            wisps.addPath(cloudBand(60, 172, width: 80, height: 7))
            Art.fill(&g, wisps, Art.color(0xFFFFFF))
        }
        Kit.cloud(&context, 348, 98, scale: 0.5, color: Art.color(0xFFFFFF, 0.9))
        Kit.birds(&context, 300, 132, scale: 0.5, color: Art.color(0x2E5560, 0.5))
    }

    // MARK: The peaks behind the town

    static func machuPeaks(_ context: inout GraphicsContext) {
        let forest: Kit.Stops = [
            (Art.color(0x74B266), 0),
            (Art.color(0x4C8C58), 0.55),
            (Art.color(0x3A7452), 1),
        ]

        // The small peak to the left of the great one.
        let small = Art.svg("M92,240 C114,216 130,178 146,158 C152,150 160,150 166,160 C178,184 192,216 208,240 Z")
        Kit.solid(&context, small, stops: forest, light: 0.22, shade: 0.2)
        let smallShade = Art.svg("M156,152 C162,184 170,214 180,240 L212,240 L212,150 Z")
        Art.clipped(&context, to: small) { g in
            Art.fill(&g, smallShade, ArtStyle.coolShade.opacity(0.18))
            Art.stipple(&g, in: CGRect(x: 92, y: 150, width: 116, height: 90), count: 40, seed: 63, color: Art.color(0x2F6A48), alpha: 0.2, size: 1...2.4)
        }

        // The great sugar-loaf peak: steep sides, a rounded top, lit on the left.
        let big = Art.svg("M146,240 C166,204 186,152 204,98 C210,76 220,54 232,52 C244,52 252,72 260,98 C272,142 294,198 322,240 Z")
        Kit.solid(&context, big, stops: forest, light: 0.28, shade: 0.16, rim: 2)
        let bigShade = Art.svg("M232,52 C240,100 250,170 262,240 L330,240 L330,52 Z")
        let rockFaces = Art.svg("M216,82 L208,120 M224,70 L220,104 M202,128 L192,168 M228,112 L224,150 M210,150 L204,186")
        let gullies = Art.svg("M244,84 C250,120 258,160 268,204 M254,112 C262,150 276,190 292,226 M236,150 C240,180 244,206 248,232")
        let ledges = Art.svg("M222,66 L240,66 M218,74 L244,75")
        Art.clipped(&context, to: big) { g in
            Art.fill(&g, bigShade, ArtStyle.coolShade.opacity(0.2))
            Art.stipple(&g, in: CGRect(x: 146, y: 52, width: 176, height: 188), count: 120, seed: 71, color: Art.color(0x2F6A48), alpha: 0.22, size: 1...2.6)
            Art.stroke(&g, rockFaces, Art.color(0xD6CFB4, 0.45), width: 2.2)
            Art.stroke(&g, gullies, Art.color(0x24544A, 0.35), width: 1.4)
            Art.stroke(&g, ledges, Art.color(0xD6CFB4, 0.5), width: 0.9)
        }

        // Morning mist at the foot of the peaks, so the town stands clear in front of them.
        Art.blurred(&context, radius: 6, opacity: 0.7) { g in
            Art.fill(&g, Art.ellipse(210, 242, 176, 9), Art.color(0xFFF6E4))
        }
    }

    // MARK: The ridge

    static func machuRidgeShape() -> Path {
        Art.svg("M-24,268 C40,246 100,236 150,234 L300,234 C350,238 400,252 456,274 L456,428 L-24,428 Z")
    }

    static func machuRidge(_ context: inout GraphicsContext, _ ridge: Path) {
        let grass: [(Color, CGFloat)] = [
            (Art.color(0x8CC46E), 0),
            (Art.color(0x5E9E5C), 0.3),
            (Art.color(0x2F6A50), 0.7),
            (Art.color(0x1F4A44), 1),
        ]
        fillVertical(&context, ridge, grass, from: 234, to: unitHeight)
        model(&context, ridge, light: 0.16, shade: 0.16)
        // The crest of the saddle catches the light.
        let crest = Art.svg("M-24,268 C40,246 100,236 150,234 L300,234")
        Art.stroke(&context, crest, Art.color(0xE6F5B0, 0.55), width: 1.2)

        // The open green in the middle of the town, with one small tree.
        let plaza = Art.svg("M168,263 L262,259 L276,281 L160,286 Z")
        Art.fill(&context, plaza, Art.color(0xA9D97C, 0.85))
        let plazaEdge = Art.svg("M160,286 L276,281 L262,259")
        Art.stroke(&context, plazaEdge, Art.color(0x3A7452, 0.45), width: 1)
        ArtStyle.contactShadow(&context, 221, 276.5, 6, 1.6, alpha: 0.3)
        Art.stroke(&context, Art.line(218, 276, 218, 270), Art.color(0x5A4A3A), width: 1)
        var crown = Path()
        crown.addEllipse(in: CGRect(x: 213, y: 263, width: 8, height: 7))
        crown.addEllipse(in: CGRect(x: 216.5, y: 265, width: 6, height: 5.5))
        Art.fill(&context, crown, Art.color(0x3F7F4E))
        Art.fill(&context, Art.ellipse(216, 265.4, 2.2, 1.6), Art.color(0xC4E890, 0.6))
    }

    // MARK: Terraces

    /// The top edges of a flight of terraces: `count` curves, each 10 units below the last,
    /// from the picture's edge (`edgeX`, `edgeY`) in to (`endX`, `endY`); the inner end moves
    /// by `endStep` with every step down.
    static func machuTerraceSteps(
        edgeX: CGFloat,
        edgeY: CGFloat,
        endX: CGFloat,
        endY: CGFloat,
        endStep: CGFloat,
        count: Int
    ) -> Path {
        var path = Path()
        for index in 0..<max(0, count) {
            let drop: CGFloat = CGFloat(index) * 10
            let yA: CGFloat = edgeY + drop
            let xB: CGFloat = endX + endStep * CGFloat(index)
            let yB: CGFloat = endY + drop
            let midX: CGFloat = (edgeX + xB) / 2
            let midY: CGFloat = (yA + yB) / 2 - 3
            path.move(to: pt(edgeX, yA))
            path.addQuadCurve(to: pt(xB, yB), control: pt(midX, midY))
        }
        return path
    }

    static func machuTerraces(_ context: inout GraphicsContext, _ ridge: Path) {
        var steps = Path()
        steps.addPath(machuTerraceSteps(edgeX: -24, edgeY: 268, endX: 112, endY: 246, endStep: -6, count: 5))
        steps.addPath(machuTerraceSteps(edgeX: 456, edgeY: 274, endX: 336, endY: 250, endStep: 6, count: 4))
        let riser = steps.applying(CGAffineTransform(translationX: 0, y: 2.4))
        let shade = steps.applying(CGAffineTransform(translationX: 0, y: 5))
        Art.clipped(&context, to: ridge) { g in
            // Each step: a stone wall holding the earth, its shade on the step below, and the
            // lit lip of grass along its top.
            Art.stroke(&g, shade, ArtStyle.coolShade.opacity(0.2), width: 1.6)
            Art.stroke(&g, riser, Art.color(0xBDB8A2), width: 3.6, cap: .butt)
            Art.stroke(&g, steps, Art.color(0xDDF2A4, 0.8), width: 1.1)
        }
    }

    // MARK: The town

    /// One roofless house: a lit gable wall at its near end, the long side wall, and the peak
    /// of the far gable standing above it. `house` is (x, base y, length of the side wall,
    /// height of the walls).
    static func machuHouse(
        _ house: (CGFloat, CGFloat, CGFloat, CGFloat),
        gables: inout Path,
        walls: inout Path,
        farGables: inout Path,
        openings: inout Path,
        shadows: inout Path,
        courses: inout Path
    ) {
        let x: CGFloat = house.0
        let base: CGFloat = house.1
        let w: CGFloat = house.2
        let h: CGFloat = house.3
        let g: CGFloat = h * 1.15
        let rise: CGFloat = g * 0.6
        let top: CGFloat = base - h
        let wallTop: CGFloat = top + h * 0.12
        let endX: CGFloat = x + g + w

        gables.addPath(Art.polygon([pt(x, base), pt(x, top), pt(x + g / 2, top - rise), pt(x + g, top), pt(x + g, base)]))
        walls.addRect(CGRect(x: x + g, y: wallTop, width: w, height: base - wallTop))
        farGables.addPath(Art.polygon([pt(endX - g, wallTop), pt(endX - g / 2, top - rise), pt(endX, wallTop)]))

        // A doorway in the gable, narrower at the top as the Inca built them, and two windows.
        let doorTop: CGFloat = base - h * 0.58
        let doorFootL: CGFloat = x + g * 0.34
        let doorHeadL: CGFloat = x + g * 0.4
        let doorHeadR: CGFloat = x + g * 0.6
        let doorFootR: CGFloat = x + g * 0.66
        openings.addPath(Art.polygon([pt(doorFootL, base), pt(doorHeadL, doorTop), pt(doorHeadR, doorTop), pt(doorFootR, base)]))
        let windowY: CGFloat = top + h * 0.42
        let windowH: CGFloat = h * 0.26
        openings.addRect(CGRect(x: x + g + w * 0.3 - 0.9, y: windowY, width: 1.8, height: windowH))
        openings.addRect(CGRect(x: x + g + w * 0.7 - 0.9, y: windowY, width: 1.8, height: windowH))

        shadows.addPath(Art.polygon([pt(endX, base), pt(endX, base - h * 0.5), pt(endX + h * 0.8, base)]))
        let courseY: CGFloat = top + h * 0.72
        courses.move(to: pt(x + g, courseY))
        courses.addLine(to: pt(endX, courseY))
    }

    static func machuTown(_ context: inout GraphicsContext) {
        // Four rows of houses stepping down the saddle, smaller the farther away they stand,
        // either side of the green.
        let houses: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (150, 246, 14, 6), (182, 246, 18, 6), (218, 246, 12, 6), (246, 246, 18, 6), (280, 246, 12, 6),
            (124, 257, 18, 8), (160, 257, 16, 8), (196, 257, 20, 8), (238, 257, 14, 8), (272, 257, 20, 8), (310, 257, 12, 8),
            (96, 272, 18, 10), (130, 272, 16, 10), (284, 272, 20, 10), (322, 272, 16, 10),
            (112, 290, 22, 12), (190, 293, 26, 12), (290, 290, 24, 12),
        ]
        var gables = Path()
        var walls = Path()
        var farGables = Path()
        var openings = Path()
        var shadows = Path()
        var courses = Path()
        for house in houses {
            machuHouse(house, gables: &gables, walls: &walls, farGables: &farGables, openings: &openings, shadows: &shadows, courses: &courses)
        }

        Art.fill(&context, shadows, ArtStyle.coolShade.opacity(0.24))
        Art.fill(&context, farGables, Art.color(0xCFC9B4))
        Art.fill(&context, walls, Art.color(0xBDB8A6))
        model(&context, walls, light: 0.1, shade: 0.2)
        Art.stroke(&context, courses, Art.color(0x8F8A78, 0.45), width: 0.5, cap: .butt)
        Art.fill(&context, gables, Art.color(0xE6E0CC))
        model(&context, gables, light: 0.22, shade: 0.14)
        Art.fill(&context, openings, Art.color(0x46525C, 0.85))

        // A warm edge on the lit gables' left side.
        var edges = Path()
        for house in houses {
            let h: CGFloat = house.3
            let g: CGFloat = h * 1.15
            let top: CGFloat = house.1 - h
            edges.move(to: pt(house.0 + 0.3, house.1))
            edges.addLine(to: pt(house.0 + 0.3, top))
            edges.addLine(to: pt(house.0 + g / 2, top - g * 0.6))
        }
        Art.stroke(&context, edges, ArtStyle.warmLight.opacity(0.7), width: 0.7)
    }

    // MARK: The near plane

    static func machuNearRock(_ context: inout GraphicsContext) {
        // A dark shoulder of rock and grass at the right edge, where the viewer stands.
        let rock = Art.svg("M456,206 C436,214 418,238 406,276 C396,312 380,356 360,428 L456,428 Z")
        Kit.solid(&context, rock, stops: Kit.stops(0x2F5F50, 0x163A38), light: 0.16, shade: 0.2, rim: 2)
        let facets = Art.svg("M430,232 L438,268 M416,262 L428,300 M404,300 L418,340 M440,290 L446,330")
        Art.clipped(&context, to: rock) { g in
            Art.stroke(&g, facets, Art.color(0x7FB08A, 0.25), width: 1.2)
        }

        let tufts: [(CGFloat, CGFloat)] = [(438, 212), (422, 232), (410, 262), (402, 292)]
        var blades = Path()
        var glints = Path()
        for tuft in tufts {
            let x: CGFloat = tuft.0
            let y: CGFloat = tuft.1
            blades.move(to: pt(x, y))
            blades.addQuadCurve(to: pt(x - 9, y - 9), control: pt(x - 2, y - 8))
            blades.move(to: pt(x + 1, y))
            blades.addQuadCurve(to: pt(x - 3, y - 14), control: pt(x + 1, y - 8))
            blades.move(to: pt(x + 2, y))
            blades.addQuadCurve(to: pt(x + 5, y - 11), control: pt(x + 5, y - 5))
            glints.move(to: pt(x - 0.6, y - 2))
            glints.addQuadCurve(to: pt(x - 3.6, y - 13), control: pt(x - 0.4, y - 8))
        }
        Art.stroke(&context, blades, Art.color(0x1E4A40), width: ArtStyle.detailLine)
        Art.stroke(&context, glints, Art.color(0xDDF2A4, 0.4), width: 0.7)
    }

    // MARK: Finish

    static func machuFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x1F4A44, from: 300, alpha: 0.9)
        tooth(&context, seed: 521, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
