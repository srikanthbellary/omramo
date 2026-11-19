import SwiftUI
import OmramoCore

// The Hall of Supreme Harmony in the Forbidden City, Beijing, by day: our own drawing (no
// photograph, nothing traced). A long hall of red columns and walls under a double-eaved roof of
// golden glazed tiles with upturned corners, raised on a three-tiered white marble terrace with
// balustrades and a central stair, and a wide stone courtyard in front under a pale sky. A few
// tiny visitors give the scale; a dark bronze water vat stands at the near right edge.
// Card background #5A1E1A.

extension LandmarkArt {
    /// forbidden-city: the Hall of Supreme Harmony on its white marble terrace across the stone
    /// courtyard, golden roofs in a warm light from the upper left, by day.
    static func paintForbiddenCity(_ context: inout GraphicsContext) {
        forbiddenSky(&context)
        forbiddenFarHalls(&context)
        forbiddenCourtyard(&context)
        forbiddenHallBody(&context)
        forbiddenRoofs(&context)
        forbiddenTerrace(&context)
        forbiddenStairs(&context)
        // Warm light lying on the golden roofs and the marble, from the upper left.
        Art.glow(&context, 150, 120, 170, Art.color(0xFFE0B0), alpha: 0.16)
        forbiddenVisitors(&context)
        forbiddenVat(&context)
        forbiddenFinish(&context)
    }

    // MARK: Materials

    /// Golden glazed tiles in the one light: bright on the left, deeper amber to the right.
    static func forbiddenGold(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [(Art.color(0xFFD97A), 0), (Art.color(0xF0B440), 0.45), (Art.color(0xC98A2E), 1)]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// White marble across the whole terrace: warm white on the left, cool to the right.
    static func forbiddenMarble(_ context: inout GraphicsContext, _ path: Path) {
        let stops: [(Color, CGFloat)] = [(Art.color(0xFFFBF2), 0), (Art.color(0xEDE6DA), 0.5), (Art.color(0xD2CACE), 1)]
        fillHorizontal(&context, path, stops, from: 56, to: 376)
    }

    /// The red of the columns and walls, lit on the left.
    static func forbiddenRedStops() -> [(Color, CGFloat)] {
        [(Art.color(0xD8503C), 0), (Art.color(0xB8362C), 0.5), (Art.color(0x8E2A2C), 1)]
    }

    // MARK: Sky and far plane

    static func forbiddenSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0xA9CBE0), 0),
            (Art.color(0xCFE2EA), 0.25),
            (Art.color(0xF2EDE0), 0.5),
            (Art.color(0xF8E8CC), 0.65),
            (Art.color(0xF8E8CC), 1),
        ]
        backdrop(&context, sky)
        // Two long, thin clouds high on the right; the top left stays quiet.
        let cloudA = cloudBand(250, 44, width: 130, height: 12)
        let cloudB = cloudBand(316, 62, width: 96, height: 8)
        Art.fill(&context, cloudA, Art.color(0xFFFFFF, 0.5))
        Art.fill(&context, cloudB, Art.color(0xFFFFFF, 0.38))
        // The faint hills to the north and the trees of the far gardens, veiled by the sky.
        let hills = Art.svg("M-24,214 C30,200 70,206 120,196 C170,188 230,194 280,186 C330,180 380,192 456,184 L456,262 L-24,262 Z")
        Art.fill(&context, hills, Art.color(0xA8B8B0))
        let trees = canopy(from: -24, to: 456, baseY: 224, height: 18, bump: 22, depth: 40, seed: 211)
        Art.fill(&context, trees, Art.color(0x8EA49A))
        haze(&context, top: 170, bottom: 262, hex: 0xF2EDE0, alpha: 0.55)
    }

    /// The long side galleries of the courtyard and a pavilion behind each, far and hazed.
    static func forbiddenFarHalls(_ context: inout GraphicsContext) {
        var walls = Path()
        walls.addRect(CGRect(x: 4, y: 206, width: 52, height: 16))
        walls.addRect(CGRect(x: 376, y: 206, width: 52, height: 16))
        walls.addRect(CGRect(x: -24, y: 234, width: 104, height: 28))
        walls.addRect(CGRect(x: 352, y: 234, width: 104, height: 28))
        Art.fill(&context, walls, Art.color(0xB04C40))
        var bays = Path()
        for index in 0..<9 {
            let leftX: CGFloat = -16 + CGFloat(index) * 11
            let rightX: CGFloat = 360 + CGFloat(index) * 11
            bays.move(to: pt(leftX, 238))
            bays.addLine(to: pt(leftX, 262))
            bays.move(to: pt(rightX, 238))
            bays.addLine(to: pt(rightX, 262))
        }
        Art.stroke(&context, bays, Art.color(0x7E2E34, 0.5), width: 1.2, cap: .butt)
        Art.fill(&context, Art.rect(-24, 234, 104, 5), ArtStyle.coolShade.opacity(0.2))
        Art.fill(&context, Art.rect(352, 234, 104, 5), ArtStyle.coolShade.opacity(0.2))

        let roofs = Art.svg("M-6,208 Q4,212 16,212 L44,212 Q56,212 66,208 C58,204 52,198 48,192 L12,192 C8,198 2,204 -6,208 Z M366,208 Q376,212 388,212 L416,212 Q428,212 438,208 C430,204 424,198 420,192 L384,192 C380,198 374,204 366,208 Z M-24,238 L80,238 Q86,238 90,234 C82,230 76,226 70,222 L-24,222 Z M456,238 L352,238 Q346,238 342,234 C350,230 356,226 362,222 L456,222 Z")
        let farGold: [(Color, CGFloat)] = [(Art.color(0xF2CC74), 0), (Art.color(0xD8A452), 1)]
        fillHorizontal(&context, roofs, farGold, from: -24, to: 456)
        let ridges = Art.svg("M12,192 L48,192 M384,192 L420,192 M-24,222 L70,222 M456,222 L362,222")
        Art.stroke(&context, ridges, Art.color(0xB8843A, 0.8), width: 1.4)
        haze(&context, top: 186, bottom: 262, hex: 0xF2EDE0, alpha: 0.4)
    }

    // MARK: Courtyard

    static func forbiddenCourtyard(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 262, unitWidth + 48, unitHeight - 262 + 24)
        let stone: [(Color, CGFloat)] = [
            (Art.color(0xEEE4D2), 0),
            (Art.color(0xDCCDB6), 0.35),
            (Art.color(0xA87866), 0.75),
            (Art.color(0x5A1E1A), 1),
        ]
        fillVertical(&context, ground, stone, from: 262, to: unitHeight)
        horizon(&context, y: 262, rise: 36, hex: 0xFFE2B4, alpha: 0.28)

        // The paving: courses that widen toward us, and joints that run back to the hall.
        var courses = Path()
        let rows: [CGFloat] = [267, 274, 284, 297, 314, 336, 364]
        for rowY in rows {
            courses.move(to: pt(-24, rowY))
            courses.addLine(to: pt(456, rowY))
        }
        var joints = Path()
        for index in 0..<17 {
            let spread: CGFloat = CGFloat(index - 8)
            let topX: CGFloat = 216 + spread * 22
            let bottomX: CGFloat = 216 + spread * 64
            joints.move(to: pt(topX, 262))
            joints.addLine(to: pt(bottomX, 404))
        }
        Art.clipped(&context, to: ground) { g in
            Art.stroke(&g, courses, Art.color(0xA89480, 0.3), width: 0.7, cap: .butt)
            Art.stroke(&g, joints, Art.color(0xA89480, 0.22), width: 0.6, cap: .butt)
        }

        // The raised imperial way running straight to the stair.
        let way = Art.polygon([pt(196, 262), pt(236, 262), pt(268, 404), pt(164, 404)])
        let wayStops: [(Color, CGFloat)] = [(Art.color(0xFAF2E2, 0.85), 0), (Art.color(0xE6D6C0, 0.5), 0.6), (Art.color(0xE6D6C0, 0), 1)]
        fillVertical(&context, way, wayStops, from: 262, to: 404)
        // The patch of sun lying across the stones.
        let patch = Art.polygon([pt(40, 264), pt(300, 264), pt(250, 330), pt(-10, 330)])
        let sun: [(Color, CGFloat)] = [(Art.color(0xFFEBC6, 0.32), 0), (Art.color(0xFFEBC6, 0), 1)]
        fillVertical(&context, patch, sun, from: 264, to: 330)
        ArtStyle.contactShadow(&context, 222, 264, 170, 5, alpha: 0.26)
    }

    // MARK: The hall

    /// A band of painted bracket sets under an eave: blue-green with gold.
    static func forbiddenBrackets(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, height: CGFloat) {
        let width: CGFloat = x1 - x0
        let band = Art.rect(x0, y, width, height)
        let teal: [(Color, CGFloat)] = [(Art.color(0x3E7E78), 0), (Art.color(0x24545C), 1)]
        fillVertical(&context, band, teal, from: y, to: y + height)
        var blocks = Path()
        var dots = Path()
        var blockX: CGFloat = x0 + 3
        while blockX < x1 - 3 {
            blocks.addRect(CGRect(x: blockX - 1.8, y: y + 1, width: 3.6, height: height - 2))
            dots.addEllipse(in: CGRect(x: blockX - 0.7, y: y + 1.4, width: 1.4, height: 1.4))
            blockX += 6
        }
        Art.fill(&context, blocks, Art.color(0x5EA898, 0.55))
        Art.fill(&context, dots, Art.color(0xF2C860, 0.85))
        Art.fill(&context, Art.rect(x0, y + height - 1.4, width, 1.4), Art.color(0xF2C860, 0.5))
        Art.fill(&context, band, ArtStyle.coolShade.opacity(0.22))
    }

    static func forbiddenHallBody(_ context: inout GraphicsContext) {
        let red: [(Color, CGFloat)] = forbiddenRedStops()
        // The short red wall of the upper storey, between the two roofs.
        let clerestory = Art.rect(134, 120, 164, 20)
        fillHorizontal(&context, clerestory, red, from: 134, to: 298)
        forbiddenBrackets(&context, x0: 134, x1: 298, y: 121, height: 8)

        // The main hall: a red wall, eleven bays of lattice doors between red columns.
        let wall = Art.rect(112, 160, 208, 34)
        fillHorizontal(&context, wall, red, from: 112, to: 320)
        let step: CGFloat = 200 / 11
        var doors = Path()
        for index in 0..<11 {
            let left: CGFloat = 116 + CGFloat(index) * step
            doors.addRect(CGRect(x: left + 3.6, y: 166, width: step - 7.2, height: 28))
        }
        let doorStops: [(Color, CGFloat)] = [(Art.color(0xA83A2E), 0), (Art.color(0x8A2A28), 0.6), (Art.color(0x6E2230), 1)]
        fillHorizontal(&context, doors, doorStops, from: 112, to: 320)
        let doorBox = CGRect(x: 112, y: 166, width: 208, height: 28)
        let rising = diagonals(in: doorBox, spacing: 3.2, rising: true)
        let falling = diagonals(in: doorBox, spacing: 3.2, rising: false)
        Art.clipped(&context, to: doors) { g in
            Art.stroke(&g, rising, Art.color(0xE0A868, 0.3), width: 0.5, cap: .butt)
            Art.stroke(&g, falling, Art.color(0xE0A868, 0.3), width: 0.5, cap: .butt)
        }
        var rails = Art.line(112, 174, 320, 174)
        rails.move(to: pt(112, 186))
        rails.addLine(to: pt(320, 186))
        Art.stroke(&context, rails, Art.color(0xC8784A, 0.45), width: 0.8, cap: .butt)

        var columns = Path()
        var columnLights = Path()
        for index in 0...11 {
            let cx: CGFloat = 116 + CGFloat(index) * step
            columns.addRect(CGRect(x: cx - 2.6, y: 160, width: 5.2, height: 34))
            columnLights.addRect(CGRect(x: cx - 2.6, y: 160, width: 1.6, height: 34))
        }
        fillHorizontal(&context, columns, red, from: 112, to: 320)
        Art.fill(&context, columnLights, Art.color(0xFFB890, 0.4))
        model(&context, wall, light: 0.1, shade: 0.24)

        // The deep shade under the wide eaves.
        let eaveShade: [(Color, CGFloat)] = [(ArtStyle.coolShade.opacity(0.42), 0), (ArtStyle.coolShade.opacity(0), 1)]
        fillVertical(&context, Art.rect(112, 160, 208, 18), eaveShade, from: 160, to: 178)
        fillVertical(&context, Art.rect(134, 129, 164, 8), eaveShade, from: 129, to: 137)
        forbiddenBrackets(&context, x0: 106, x1: 326, y: 152, height: 8)
    }

    // MARK: The double-eaved roof

    /// Fills one roof with golden tiles: the rows of tiles running down the slope, modelled.
    static func forbiddenRoofTiles(_ context: inout GraphicsContext, _ roof: Path, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat) {
        forbiddenGold(&context, roof, from: x0, to: x1)
        var tiles = Path()
        var tileX: CGFloat = x0
        while tileX < x1 {
            tiles.move(to: pt(tileX, top))
            tiles.addLine(to: pt(tileX, bottom))
            tileX += 3.6
        }
        Art.clipped(&context, to: roof) { g in
            Art.stroke(&g, tiles, Art.color(0xA86E26, 0.3), width: 0.9, cap: .butt)
        }
        model(&context, roof, light: 0.26, shade: 0.22, rim: 0.5)
    }

    /// The round tile ends along the straight middle of an eave.
    static func forbiddenEaveEnds(_ context: inout GraphicsContext, from x0: CGFloat, to x1: CGFloat, y: CGFloat) {
        var ends = Path()
        var endX: CGFloat = x0
        while endX < x1 {
            ends.addEllipse(in: CGRect(x: endX - 1.1, y: y - 1.1, width: 2.2, height: 2.2))
            endX += 3.6
        }
        Art.fill(&context, ends, Art.color(0xFFE596, 0.8))
    }

    static func forbiddenRoofs(_ context: inout GraphicsContext) {
        let hipColor: Color = Art.color(0xA86E26, 0.85)
        // The lower eave, its corners sweeping up.
        let lower = Art.svg("M86,144 Q102,154 128,154 L304,154 Q330,154 346,144 C332,142 318,138 304,134 L128,134 C114,138 100,142 86,144 Z")
        forbiddenRoofTiles(&context, lower, x0: 86, x1: 346, top: 130, bottom: 156)
        let lowerHips = Art.svg("M128,134 C114,138 100,142 86,144 M304,134 C318,138 332,142 346,144")
        Art.stroke(&context, lowerHips, hipColor, width: ArtStyle.detailLine)
        Art.fill(&context, Art.rect(128, 132.4, 176, 2.6), Art.color(0xC8922E))
        forbiddenEaveEnds(&context, from: 130, to: 304, y: 152.6)
        let lowerEdge = Art.svg("M86,144 Q102,154.8 128,154.8 L304,154.8 Q330,154.8 346,144")
        Art.stroke(&context, lowerEdge, ArtStyle.coolShade.opacity(0.35), width: 1)

        // The upper roof, hipped, with its ridge and the two curled ornaments at its ends.
        let upper = Art.svg("M104,112 Q116,122 140,122 L292,122 Q316,122 328,112 C308,104 292,92 282,76 L150,76 C140,92 124,104 104,112 Z")
        forbiddenRoofTiles(&context, upper, x0: 104, x1: 328, top: 72, bottom: 124)
        let upperHips = Art.svg("M150,77 C140,92 124,104 104,112 M282,77 C292,92 308,104 328,112")
        Art.stroke(&context, upperHips, hipColor, width: ArtStyle.detailLine)
        forbiddenEaveEnds(&context, from: 142, to: 292, y: 120.6)
        let upperEdge = Art.svg("M104,112 Q116,122.8 140,122.8 L292,122.8 Q316,122.8 328,112")
        Art.stroke(&context, upperEdge, ArtStyle.coolShade.opacity(0.35), width: 1)

        let ridge = Art.rect(146, 71, 140, 7)
        forbiddenGold(&context, ridge, from: 146, to: 286)
        Art.stroke(&context, Art.line(146, 71.4, 286, 71.4), Art.color(0xFFEAA8, 0.8), width: 0.9, cap: .butt)
        Art.fill(&context, Art.rect(146, 76, 140, 2), ArtStyle.coolShade.opacity(0.18))
        let ornaments = Art.svg("M141,79 L151,79 L151,68 C149,63 146,61 142,60 C144,64 143,67 140,69 Z M291,79 L281,79 L281,68 C283,63 286,61 290,60 C288,64 289,67 292,69 Z")
        forbiddenGold(&context, ornaments, from: 140, to: 292)
        model(&context, ornaments, light: 0.2, shade: 0.24)

        // The little row of figures that walks down each corner ridge.
        let beasts: [(CGFloat, CGFloat)] = [
            (110, 109.4), (115, 107.4), (120, 105), (125, 102.2),
            (322, 109.4), (317, 107.4), (312, 105), (307, 102.2),
            (92, 142.6), (97, 141.4), (102, 140.2),
            (340, 142.6), (335, 141.4), (330, 140.2),
        ]
        var figures = Path()
        for beast in beasts {
            figures.addEllipse(in: CGRect(x: beast.0 - 1.2, y: beast.1 - 2.6, width: 2.4, height: 2.8))
        }
        Art.fill(&context, figures, Art.color(0xB87C2C))
    }

    // MARK: The marble terrace

    /// One tier of the terrace: a plain face with mouldings and drain spouts, and the
    /// balustrade of posts and panels standing on its edge.
    static func forbiddenTier(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, railTop: CGFloat, faceTop: CGFloat, faceBottom: CGFloat) {
        let width: CGFloat = x1 - x0
        let faceHeight: CGFloat = faceBottom - faceTop
        let face = Art.rect(x0, faceTop, width, faceHeight)
        forbiddenMarble(&context, face)
        model(&context, face, light: 0.14, shade: 0.16)
        var mouldings = Path()
        mouldings.addRect(CGRect(x: x0 - 2, y: faceTop, width: width + 4, height: 2.6))
        mouldings.addRect(CGRect(x: x0 - 3, y: faceBottom - 3, width: width + 6, height: 3))
        forbiddenMarble(&context, mouldings)
        let waistY: CGFloat = faceTop + faceHeight * 0.55
        var creases = Art.line(x0 - 2, faceTop + 2.8, x1 + 2, faceTop + 2.8)
        creases.move(to: pt(x0, waistY))
        creases.addLine(to: pt(x1, waistY))
        Art.stroke(&context, creases, Art.color(0xB0A6B4, 0.45), width: 0.6, cap: .butt)

        // The drain spouts under the edge.
        var spouts = Path()
        var spoutX: CGFloat = x0 + 7
        while spoutX < x1 - 4 {
            spouts.addEllipse(in: CGRect(x: spoutX - 1.4, y: faceTop + 3.4, width: 2.8, height: 2))
            spoutX += 14
        }
        Art.fill(&context, spouts, ArtStyle.coolShade.opacity(0.3))

        // The balustrade: a solid lower panel, a handrail, a small support in each bay, posts.
        let barY: CGFloat = faceTop - 2.4
        let panelTop: CGFloat = railTop + (faceTop - railTop) * 0.45
        let count: Int = max(1, Int(width / 9))
        let step: CGFloat = width / CGFloat(count)
        var rail = Path()
        rail.addRect(CGRect(x: x0, y: panelTop, width: width, height: faceTop - panelTop))
        rail.addRect(CGRect(x: x0, y: railTop + 1.2, width: width, height: 1.6))
        var recesses = Path()
        var posts = Path()
        var postShades = Path()
        for index in 0...count {
            let x: CGFloat = x0 + CGFloat(index) * step
            posts.addRect(CGRect(x: x - 1.1, y: railTop, width: 2.2, height: faceTop - railTop))
            posts.addEllipse(in: CGRect(x: x - 1.5, y: railTop - 2.6, width: 3, height: 3))
            postShades.addRect(CGRect(x: x + 0.3, y: railTop, width: 0.8, height: faceTop - railTop))
            if index < count {
                let middle: CGFloat = x + step / 2
                rail.addRect(CGRect(x: middle - 0.6, y: railTop + 2.8, width: 1.2, height: panelTop - railTop - 2.8))
                recesses.addRect(CGRect(x: x + 2.2, y: panelTop + 0.8, width: step - 4.4, height: max(0.5, barY - panelTop - 0.8)))
            }
        }
        forbiddenMarble(&context, rail)
        Art.fill(&context, recesses, ArtStyle.coolShade.opacity(0.12))
        forbiddenMarble(&context, posts)
        Art.fill(&context, postShades, ArtStyle.coolShade.opacity(0.16))
        Art.stroke(&context, Art.line(x0, railTop + 1.3, x1, railTop + 1.3), Art.color(0xFFFFFF, 0.7), width: 0.6, cap: .butt)
        Art.fill(&context, Art.rect(x0, faceTop + 2.6, width, 1.6), ArtStyle.coolShade.opacity(0.12))
    }

    static func forbiddenTerrace(_ context: inout GraphicsContext) {
        // The three tiers, the highest first; each lower tier stands nearer and wider.
        let tiers: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)] = [(96, 336, 186, 194, 210), (78, 354, 210, 218, 234), (58, 374, 234, 242, 262)]
        for tier in tiers {
            forbiddenTier(&context, x0: tier.0, x1: tier.1, railTop: tier.2, faceTop: tier.3, faceBottom: tier.4)
        }
    }

    /// The central stair: three flights of white steps, a carved ramp up the middle and a
    /// low balustrade down each side.
    static func forbiddenStairs(_ context: inout GraphicsContext) {
        let stair = Art.polygon([pt(198, 186), pt(234, 186), pt(246, 262), pt(186, 262)])
        forbiddenMarble(&context, stair)
        model(&context, stair, light: 0.16, shade: 0.18)
        var treads = Path()
        var treadY: CGFloat = 189
        while treadY < 261 {
            treads.move(to: pt(186, treadY))
            treads.addLine(to: pt(246, treadY))
            treadY += 3.2
        }
        var landings = Path()
        landings.addRect(CGRect(x: 180, y: 210, width: 72, height: 3))
        landings.addRect(CGRect(x: 180, y: 234, width: 72, height: 3))
        Art.clipped(&context, to: stair) { g in
            Art.stroke(&g, treads, Art.color(0xB8AEB8, 0.5), width: 0.6, cap: .butt)
            Art.fill(&g, landings, Art.color(0xFFFFFF, 0.6))
        }

        // The carved stone ramp up the middle, with its swirling clouds drawn softly.
        let ramp = Art.polygon([pt(209, 186), pt(223, 186), pt(228, 262), pt(204, 262)])
        let rampStops: [(Color, CGFloat)] = [(Art.color(0xF6F0E4), 0), (Art.color(0xD8CFC8), 1)]
        fillHorizontal(&context, ramp, rampStops, from: 204, to: 228)
        let carving = Art.svg("M210,196 C214,192 218,200 222,196 M209,208 C213,204 219,212 223,207 M208,221 C213,216 219,225 224,219 M207,234 C212,229 220,238 225,232 M206,247 C212,242 220,251 226,245")
        Art.stroke(&context, carving, Art.color(0xA89CAE, 0.55), width: 0.8)

        // The low balustrades down both sides of the stair.
        let sides = Art.svg("M198,182 L186,258 M234,182 L246,258")
        Art.stroke(&context, sides, Art.color(0xFFFBF2), width: 2.2)
        Art.stroke(&context, Art.svg("M235.4,184 L247.4,260"), ArtStyle.coolShade.opacity(0.2), width: 0.9)
        var sidePosts = Path()
        for index in 0..<8 {
            let t: CGFloat = CGFloat(index) / 7
            let leftX: CGFloat = 198 - 12 * t
            let rightX: CGFloat = 234 + 12 * t
            let postY: CGFloat = 180 + 76 * t
            sidePosts.addEllipse(in: CGRect(x: leftX - 1.5, y: postY - 1.5, width: 3, height: 3))
            sidePosts.addEllipse(in: CGRect(x: rightX - 1.5, y: postY - 1.5, width: 3, height: 3))
        }
        Art.fill(&context, sidePosts, Art.color(0xFFFCF4))
        Art.stroke(&context, sidePosts, Art.color(0xB8AEB8, 0.5), width: 0.5)
        ArtStyle.contactShadow(&context, 218, 262.5, 34, 2.5, alpha: 0.24)
    }

    // MARK: Visitors and the near plane

    /// A few tiny visitors crossing the courtyard, about three heads tall.
    static func forbiddenVisitors(_ context: inout GraphicsContext) {
        let people: [(CGFloat, CGFloat, CGFloat, UInt32)] = [
            (132, 288, 0.8, 0x3E5A8A),
            (140, 289, 0.75, 0xE8DCC8),
            (262, 276, 0.6, 0x5A4A7A),
            (292, 292, 0.85, 0x8A4A3A),
            (318, 300, 0.95, 0x4E7A6A),
            (98, 312, 1.1, 0xC88A3A),
        ]
        var heads = Path()
        var legs = Path()
        var lights = Path()
        for person in people {
            let x: CGFloat = person.0
            let y: CGFloat = person.1
            let s: CGFloat = person.2
            ArtStyle.contactShadow(&context, x + 1.5 * s, y + 0.3, 4 * s, 1.1 * s, alpha: 0.3)
            let shoulderY: CGFloat = y - 7.2 * s
            let hemY: CGFloat = y - 2.6 * s
            let narrow: CGFloat = 1.7 * s
            let wide: CGFloat = 2.1 * s
            let corners: [CGPoint] = [pt(x - narrow, shoulderY), pt(x + narrow, shoulderY), pt(x + wide, hemY), pt(x - wide, hemY)]
            let body = Art.polygon(corners)
            Art.fill(&context, body, Art.color(person.3))
            lights.addRect(CGRect(x: x - 1.8 * s, y: shoulderY, width: 0.8 * s, height: 4.6 * s))
            legs.addRect(CGRect(x: x - 1.3 * s, y: hemY, width: s, height: 2.6 * s))
            legs.addRect(CGRect(x: x + 0.3 * s, y: hemY, width: s, height: 2.6 * s))
            heads.addEllipse(in: CGRect(x: x - 1.5 * s, y: shoulderY - 3.2 * s, width: 3 * s, height: 3 * s))
        }
        Art.fill(&context, legs, Art.color(0x4A3448))
        Art.fill(&context, heads, Art.color(0xC89478))
        Art.fill(&context, lights, Art.color(0xFFE6C4, 0.35))
    }

    /// A great bronze water vat at the near right edge, cropped by the frame.
    static func forbiddenVat(_ context: inout GraphicsContext) {
        let body = Art.svg("M374,340 L452,340 L452,346 C456,362 454,386 444,410 L384,410 C374,386 370,362 374,346 Z")
        Kit.solid(&context, body, stops: Kit.stops(0x6A4A36, 0x2E1E2C), light: 0.12, shade: 0.24, rim: 2.5)
        let lip = Art.rect(368, 333, 90, 7, radius: 2)
        Kit.solid(&context, lip, stops: Kit.stops(0x7E5A40, 0x3A2632), light: 0.16, shade: 0.2)
        let bands = Art.svg("M373,352 C396,356 430,356 456,352 M372,380 C396,384 430,384 456,380")
        Art.clipped(&context, to: body) { g in
            Art.stroke(&g, bands, Art.color(0x8E6A48, 0.5), width: 1.4)
        }
        // A ring handle hanging on the lit side.
        Art.stroke(&context, Art.circle(380, 364, 5.5), Art.color(0x5A3E32), width: 2)
        Art.stroke(&context, Art.svg("M375,361 C376,358 378,357 380,357"), Art.color(0xC89A68, 0.6), width: 0.9)
        Art.stroke(&context, Art.line(369, 333.6, 420, 333.6), Art.color(0xE0B080, 0.5), width: 0.9)
    }

    // MARK: Finish

    static func forbiddenFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x5A1E1A, from: 300, alpha: 0.9)
        tooth(&context, seed: 727, light: 0.05, dark: 0.04)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
