import SwiftUI
import OmramoCore

// Bremen Town Hall and Roland: the market square by day. The stone knight Roland stands in the
// middle under his tall pointed canopy, with sword and shield, on a stepped base; behind him
// runs the town hall (brick, with its sandstone front: a row of round arches, tall windows, a
// steep green copper roof with decorated gables). Our own drawing; the modern bronze statue of
// the four animals is deliberately NOT shown. Card background #3A2A4F.

extension LandmarkArt {
    /// Roland's centre line: the middle of the picture.
    private static let bremenX: CGFloat = 216
    /// The hall runs from here off the right edge of the picture.
    private static let bremenHallLeft: CGFloat = 96
    private static let bremenHallWidth: CGFloat = 374
    /// Where the hall meets the square.
    private static let bremenGround: CGFloat = 262
    /// The first arch (and window) of the hall front, and the step between them.
    private static let bremenBayStart: CGFloat = 113
    private static let bremenBayStep: CGFloat = 26
    private static let bremenStone: UInt32 = 0xE9D6B4
    private static let bremenStatueStone: UInt32 = 0xEFE6D2

    /// bremen-town-hall-roland: the stone knight in front of the town hall, by day.
    static func paintBremenRoland(_ context: inout GraphicsContext) {
        bremenSky(&context)
        bremenFarHouses(&context)
        bremenSquare(&context)
        bremenHallRoof(&context)
        bremenGable(&context, x: 165, scale: 0.55)
        bremenGable(&context, x: 427, scale: 0.55)
        bremenGable(&context, x: 296, scale: 1)
        bremenHallWall(&context)
        bremenHallArcade(&context)
        // A thin veil of air over the hall, so the knight stands clear in front of it.
        haze(&context, top: 90, bottom: 264, hex: 0xFBE3C4, alpha: 0.14)
        bremenFolk(&context)
        bremenRolandBase(&context)
        bremenRolandCanopy(&context)
        bremenRolandBody(&context)
        bremenRolandArms(&context)
        bremenRolandHead(&context)
        // The near plane: a dark bough of a lime tree in the top-right corner.
        cornerSpray(&context, seed: 77, dark: Art.color(0x2E3A4A, 0.94), lit: Art.color(0xFFE0A8, 0.35))
        bremenFinish(&context)
    }

    // MARK: Sky, far houses, square

    private static func bremenSky(_ context: inout GraphicsContext) {
        let sky: Kit.Stops = [
            (Art.color(0x5FA8DC), 0),
            (Art.color(0x9CCDEA), 0.3),
            (Art.color(0xDCEBE6), 0.52),
            (Art.color(0xFBE3C4), 0.65),
            (Art.color(0xFBE3C4), 1),
        ]
        backdrop(&context, sky)
        horizon(&context, y: bremenGround, rise: 80, hex: 0xFFD9A8, alpha: 0.35)
        Art.glow(&context, 10, 30, 220, Art.color(0xFFF1D0), alpha: 0.3)
        Kit.cloud(&context, 150, 70, scale: 0.5, color: Art.color(0xFFFFFF, 0.85))
        Kit.cloud(&context, 318, 52, scale: 0.42, color: Art.color(0xFFFFFF, 0.8))
        Kit.birds(&context, 118, 118, scale: 0.55, color: Art.color(0x4A5A8A, 0.55))
    }

    /// The far plane: gabled merchants' houses on the far side of the square, pale and veiled.
    private static func bremenFarHouses(_ context: inout GraphicsContext) {
        // x, width, eaves, gable height, colour.
        let houses: [(CGFloat, CGFloat, CGFloat, CGFloat, UInt32)] = [
            (-14, 30, 214, 22, 0xE8C9A8),
            (16, 26, 206, 26, 0xD9A690),
            (42, 28, 218, 20, 0xEAD7B4),
            (70, 30, 200, 28, 0xD4B0A0),
        ]
        var windows = Path()
        for house in houses {
            let x: CGFloat = house.0
            let w: CGFloat = house.1
            let eaves: CGFloat = house.2
            let top: CGFloat = eaves - house.3
            let front = Art.polygon([pt(x, 264), pt(x, eaves), pt(x + w / 2, top), pt(x + w, eaves), pt(x + w, 264)])
            Kit.solid(&context, front, Art.color(house.4), light: 0.12, shade: 0.14)
            var row: CGFloat = eaves + 5
            while row < 252 {
                windows.addRect(CGRect(x: x + w * 0.2, y: row, width: 3.4, height: 6))
                windows.addRect(CGRect(x: x + w * 0.5 - 1.7, y: row, width: 3.4, height: 6))
                windows.addRect(CGRect(x: x + w * 0.8 - 3.4, y: row, width: 3.4, height: 6))
                row += 13
            }
        }
        Art.fill(&context, windows, Art.color(0x6A5A84, 0.5))
        haze(&context, top: 168, bottom: 264, hex: 0xFBE3C4, alpha: 0.42)
    }

    private static func bremenSquare(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 260, unitWidth + 48, unitHeight - 260 + 24)
        let stops: Kit.Stops = [
            (Art.color(0xE6D0B8), 0),
            (Art.color(0xC4A4A2), 0.3),
            (Art.color(0x7A5C7C), 0.7),
            (Art.color(0x3A2A4F), 1),
        ]
        fillVertical(&context, ground, stops, from: 260, to: unitHeight)
        // Courses of cobbles, finer far away.
        let far = CGRect(x: 0, y: 266, width: unitWidth, height: 16)
        let near = CGRect(x: 0, y: 280, width: unitWidth, height: 40)
        ripples(&context, in: far, count: 40, seed: 14, color: Art.color(0x8A6A80, 0.22), width: 0.5, length: 6...16)
        ripples(&context, in: near, count: 30, seed: 23, color: Art.color(0x6A4E70, 0.2), width: 0.7, length: 10...26)
        ripples(&context, in: near, count: 14, seed: 37, color: Art.color(0xFFF1DC, 0.2), width: 0.7, length: 8...20)
        // The hall's shadow at its foot.
        ArtStyle.contactShadow(&context, 300, 264, 210, 5, alpha: 0.22)
    }

    // MARK: The town hall

    private static func bremenHallRoof(_ context: inout GraphicsContext) {
        let roof = Art.polygon([pt(90, 154), pt(110, 98), pt(470, 98), pt(470, 154)])
        Kit.solid(&context, roof, stops: Kit.stops(0x93D2B8, 0x5AA68E), light: 0.2, shade: 0.16)
        var courses = Path()
        var y: CGFloat = 105
        while y < 152 {
            courses.move(to: pt(88, y))
            courses.addLine(to: pt(470, y))
            y += 7
        }
        var seams = Path()
        var x: CGFloat = 104
        while x < 470 {
            seams.move(to: pt(x + 6, 98))
            seams.addLine(to: pt(x, 154))
            x += 14
        }
        Art.clipped(&context, to: roof) { g in
            Art.stroke(&g, courses, Art.color(0x3F8572, 0.34), width: 0.6, cap: .butt)
            Art.stroke(&g, seams, Art.color(0x3F8572, 0.16), width: 0.5, cap: .butt)
        }
        // The ridge and the lit left hip.
        Art.stroke(&context, Art.line(110, 98, 470, 98), Art.color(0xD6F0E2), width: 1.6)
        Art.stroke(&context, Art.line(90.6, 153, 110, 98.6), ArtStyle.warmLight.opacity(0.7), width: 1.1)
    }

    /// One decorated gable standing on the cornice at `x`: stepped, with scrolls and finials.
    private static func bremenGable(_ context: inout GraphicsContext, x: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: 154, scale: scale) { g in
            let outline: [CGPoint] = [
                pt(-35, 0), pt(-35, -24), pt(-27, -24), pt(-27, -44), pt(-17, -44), pt(-17, -62), pt(-8, -62),
                pt(0, -78), pt(8, -62), pt(17, -62), pt(17, -44), pt(27, -44), pt(27, -24), pt(35, -24), pt(35, 0),
            ]
            let shape = Art.polygon(outline)
            // Finials and scrolls first, so the gable's own wall overlaps their feet.
            var finials = Path()
            let spikes: [(CGFloat, CGFloat)] = [(-33, -24), (33, -24), (-25, -44), (25, -44), (0, -76)]
            for spike in spikes {
                finials.move(to: pt(spike.0 - 1.8, spike.1))
                finials.addLine(to: pt(spike.0, spike.1 - 11))
                finials.addLine(to: pt(spike.0 + 1.8, spike.1))
                finials.closeSubpath()
            }
            Art.fill(&g, finials, Art.color(0xD9C29C))
            Kit.solid(&g, shape, Art.color(bremenStone), light: 0.2, shade: 0.2)
            var scrolls = Path()
            let curls: [(CGFloat, CGFloat, CGFloat)] = [
                (-31, -27, 4), (31, -27, 4), (-22, -47, 4), (22, -47, 4), (-12.5, -64.5, 3.4), (12.5, -64.5, 3.4),
            ]
            for curl in curls {
                scrolls.addEllipse(in: CGRect(x: curl.0 - curl.2, y: curl.1 - curl.2, width: curl.2 * 2, height: curl.2 * 2))
            }
            Art.fill(&g, scrolls, Art.color(0xF6E8CC))
            Art.stroke(&g, scrolls, Art.color(0xB89A80, 0.5), width: 0.6)
            var panes = Path()
            let lowRow: [CGFloat] = [-24, -12, 0, 12, 24]
            for column in lowRow {
                panes.addRect(CGRect(x: column - 3, y: -20, width: 6, height: 13))
            }
            let midRow: [CGFloat] = [-18, -6, 6, 18]
            for column in midRow {
                panes.addRect(CGRect(x: column - 2.5, y: -40, width: 5, height: 10))
            }
            panes.addRect(CGRect(x: -8, y: -58, width: 4, height: 8))
            panes.addRect(CGRect(x: 4, y: -58, width: 4, height: 8))
            Art.fill(&g, panes, Art.color(0x5A4A6E, 0.75))
            var strings = Path()
            strings.move(to: pt(-35, -24))
            strings.addLine(to: pt(35, -24))
            strings.move(to: pt(-27, -44))
            strings.addLine(to: pt(27, -44))
            strings.move(to: pt(-17, -62))
            strings.addLine(to: pt(17, -62))
            Art.stroke(&g, strings, Art.color(0xB89A80, 0.6), width: 0.8, cap: .butt)
        }
    }

    /// The upper storey: brick, with tall stone-framed windows under a stone cornice.
    private static func bremenHallWall(_ context: inout GraphicsContext) {
        let left: CGFloat = bremenHallLeft
        let wide: CGFloat = bremenHallWidth
        let wall = Art.rect(left, 160, wide, 56)
        Kit.solid(&context, wall, stops: Kit.stops(0xCB765C, 0xB05E4E), light: 0.16, shade: 0.18)
        var bricks = Path()
        var y: CGFloat = 164
        while y < 215 {
            bricks.move(to: pt(left, y))
            bricks.addLine(to: pt(left + wide, y))
            y += 4
        }
        Art.stroke(&context, bricks, Art.color(0x8A4038, 0.2), width: 0.5, cap: .butt)

        var frames = Path()
        var glass = Path()
        var glints = Path()
        var bars = Path()
        for index in 0..<14 {
            let x: CGFloat = bremenBayStart + CGFloat(index) * bremenBayStep
            frames.addRect(CGRect(x: x - 7.5, y: 168, width: 15, height: 42))
            frames.move(to: pt(x - 9.5, 168))
            frames.addLine(to: pt(x, 161.5))
            frames.addLine(to: pt(x + 9.5, 168))
            frames.closeSubpath()
            glass.addRect(CGRect(x: x - 5, y: 171, width: 10, height: 37))
            glints.addRect(CGRect(x: x - 5, y: 171, width: 3.4, height: 37))
            bars.move(to: pt(x, 171))
            bars.addLine(to: pt(x, 208))
            bars.move(to: pt(x - 5, 184))
            bars.addLine(to: pt(x + 5, 184))
            bars.move(to: pt(x - 5, 196))
            bars.addLine(to: pt(x + 5, 196))
        }
        // The pilasters of the middle bay, under the great gable.
        frames.addRect(CGRect(x: 259, y: 160, width: 4, height: 56))
        frames.addRect(CGRect(x: 329, y: 160, width: 4, height: 56))
        Art.fill(&context, frames, Art.color(bremenStone))
        Art.fill(&context, glass, Art.color(0x4E4870))
        Art.fill(&context, glints, Art.color(0xBFD8F0, 0.3))
        Art.stroke(&context, bars, Art.color(0xF2E4C8, 0.7), width: 0.6, cap: .butt)

        // The cornice under the roof, and its shade on the brick.
        let cornice = Art.rect(left - 4, 153, wide + 8, 7)
        Kit.solid(&context, cornice, Art.color(0xF2E0BE), light: 0.2, shade: 0.16)
        Art.fill(&context, Art.rect(left, 160, wide, 2.6), ArtStyle.coolShade.opacity(0.18))
        Art.stroke(&context, Art.line(left + 0.5, 160, left + 0.5, 216), ArtStyle.warmLight.opacity(0.6), width: 1, cap: .butt)
    }

    /// A round-headed arch standing on `baseY`.
    private static func bremenRoundArch(_ cx: CGFloat, _ baseY: CGFloat, width: CGFloat, height: CGFloat) -> Path {
        let r: CGFloat = width / 2
        let spring: CGFloat = baseY - height + r
        let k: CGFloat = r * 0.5523
        var path = Path()
        path.move(to: pt(cx - r, baseY))
        path.addLine(to: pt(cx - r, spring))
        path.addCurve(to: pt(cx, spring - r), control1: pt(cx - r, spring - k), control2: pt(cx - k, spring - r))
        path.addCurve(to: pt(cx + r, spring), control1: pt(cx + k, spring - r), control2: pt(cx + r, spring - k))
        path.addLine(to: pt(cx + r, baseY))
        path.closeSubpath()
        return path
    }

    /// The ground floor: the arcade of round arches under a stone balustrade.
    private static func bremenHallArcade(_ context: inout GraphicsContext) {
        let left: CGFloat = bremenHallLeft
        let wide: CGFloat = bremenHallWidth
        let front = Art.rect(left, 223, wide, 39)
        Kit.solid(&context, front, Art.color(bremenStone), light: 0.18, shade: 0.2)

        var openings = Path()
        var jambs = Path()
        var medallions = Path()
        for index in 0..<14 {
            let x: CGFloat = bremenBayStart + CGFloat(index) * bremenBayStep
            openings.addPath(bremenRoundArch(x, bremenGround, width: 18, height: 32))
            jambs.addRect(CGRect(x: x - 9, y: 241, width: 2.6, height: 21))
            medallions.addEllipse(in: CGRect(x: x + 10.8, y: 231.8, width: 4.4, height: 4.4))
        }
        let dark: Kit.Stops = [(Art.color(0x7C6A94), 0), (Art.color(0x443860), 1)]
        fillVertical(&context, openings, dark, from: 230, to: 262)
        // Daylight on the left jamb of every arch, and a thin lit edge round each opening.
        Art.fill(&context, jambs, Art.color(0xFFE9C8, 0.22))
        Art.stroke(&context, openings, Art.color(0xFFF3DC, 0.7), width: 0.8)
        Art.fill(&context, medallions, Art.color(0xC9A88A, 0.7))

        // The balustrade over the arcade.
        let rail = Art.rect(left - 4, 214, wide + 8, 9)
        Kit.solid(&context, rail, Art.color(0xF2E0BE), light: 0.2, shade: 0.16)
        var balusters = Path()
        var x: CGFloat = left
        while x < left + wide {
            balusters.move(to: pt(x, 216.4))
            balusters.addLine(to: pt(x, 221))
            x += 4
        }
        Art.stroke(&context, balusters, Art.color(0xA88A78, 0.5), width: 0.7, cap: .butt)
        Art.fill(&context, Art.rect(left, 223, wide, 2.2), ArtStyle.coolShade.opacity(0.2))
    }

    /// A few tiny far people by the arcade, for scale. No faces.
    private static func bremenFolk(_ context: inout GraphicsContext) {
        let people: [(CGFloat, CGFloat, CGFloat, UInt32)] = [
            (138, 265, 11, 0x5A5488), (147, 266, 10, 0x9A4E5A), (350, 266, 11, 0x3F6E7A), (386, 267, 12, 0x6A4A7A),
        ]
        for person in people {
            let x: CGFloat = person.0
            let y: CGFloat = person.1
            let h: CGFloat = person.2
            var figure = Art.rect(x - 1.8, y - h * 0.74, 3.6, h * 0.74, radius: 1.6)
            figure.addEllipse(in: CGRect(x: x - h * 0.14, y: y - h, width: h * 0.28, height: h * 0.28))
            ArtStyle.contactShadow(&context, x + 2, y, 5, 1.2, alpha: 0.25)
            Art.fill(&context, figure, Art.color(person.3, 0.85))
        }
    }

    // MARK: Roland

    private static func bremenRolandBase(_ context: inout GraphicsContext) {
        let cx: CGFloat = bremenX
        // The monument's shadow lies on the cobbles to the right, away from the light.
        let cast = Art.polygon([pt(cx + 20, 288), pt(cx + 40, 291), pt(cx + 108, 280), pt(cx + 92, 276)])
        Art.fill(&context, cast, ArtStyle.coolShade.opacity(0.14))
        ArtStyle.contactShadow(&context, cx + 6, 291, 52, 5, alpha: 0.3)

        let lowStep = Art.rect(cx - 40, 283, 80, 8)
        let highStep = Art.rect(cx - 32, 276, 64, 7)
        let plinth = Art.rect(cx - 22, 250, 44, 26)
        let cap = Art.rect(cx - 25, 247, 50, 4)
        Kit.solid(&context, lowStep, Art.color(0xD6C8B6), light: 0.2, shade: 0.24)
        Kit.solid(&context, highStep, Art.color(0xDDD0BC), light: 0.2, shade: 0.24)
        Kit.solid(&context, plinth, Art.color(0xE6DAC6), light: 0.22, shade: 0.24)
        Kit.solid(&context, cap, Art.color(bremenStatueStone), light: 0.2, shade: 0.2)
        var edges = Path()
        edges.addRect(CGRect(x: cx - 40, y: 283, width: 80, height: 1.2))
        edges.addRect(CGRect(x: cx - 32, y: 276, width: 64, height: 1.2))
        edges.addRect(CGRect(x: cx - 25, y: 247, width: 50, height: 1.1))
        Art.fill(&context, edges, Art.color(0xFFF8E8, 0.7))
        let panel = Art.rect(cx - 17, 254.5, 34, 17)
        Art.stroke(&context, panel, Art.color(0x9A8C98, 0.5), width: 0.7, cap: .butt, join: .miter)
        Art.fill(&context, Art.rect(cx - 22, 251, 44, 2), ArtStyle.coolShade.opacity(0.14))
    }

    /// The pillar at Roland's back and the pointed Gothic canopy it carries over his head.
    private static func bremenRolandCanopy(_ context: inout GraphicsContext) {
        let cx: CGFloat = bremenX
        let stone = Art.color(bremenStatueStone)
        let pillar = Art.rect(cx - 12, 112, 24, 138)
        Kit.solid(&context, pillar, Art.color(0xBDB2B6), light: 0.14, shade: 0.24)

        // The spire, with crockets up both edges and a finial.
        let spire = Art.polygon([pt(cx - 9, 101), pt(cx, 60), pt(cx + 9, 101)])
        var crockets = Path()
        for index in 1..<6 {
            let t: CGFloat = CGFloat(index) / 6
            let y: CGFloat = 101 - 41 * t
            let reach: CGFloat = 9 * (1 - t) + 0.6
            crockets.addEllipse(in: CGRect(x: cx - reach - 1.5, y: y - 1.5, width: 3, height: 3))
            crockets.addEllipse(in: CGRect(x: cx + reach - 1.5, y: y - 1.5, width: 3, height: 3))
        }
        Art.fill(&context, crockets, Art.color(0xD6CAB8))
        Kit.solid(&context, spire, stone, light: 0.24, shade: 0.26, rim: 1.2)
        Art.stroke(&context, Art.line(cx, 61, cx, 55), Art.color(0xD9CDB8), width: 1.2)
        Art.fill(&context, Art.circle(cx, 58, 2.3), Art.color(0xE8C46A))

        // Corner pinnacles, then the canopy box with its three little gables.
        var pinnacles = Path()
        let corners: [CGFloat] = [-19, 19]
        for corner in corners {
            pinnacles.addRect(CGRect(x: cx + corner - 1.6, y: 96, width: 3.2, height: 28))
            pinnacles.move(to: pt(cx + corner - 2.2, 96))
            pinnacles.addLine(to: pt(cx + corner, 86))
            pinnacles.addLine(to: pt(cx + corner + 2.2, 96))
            pinnacles.closeSubpath()
        }
        Art.fill(&context, pinnacles, Art.color(0xDDD2BE))
        let box = Art.polygon([pt(cx - 20, 124), pt(cx - 18, 104), pt(cx + 18, 104), pt(cx + 20, 124)])
        Kit.solid(&context, box, stone, light: 0.22, shade: 0.24)
        var gablets = Path()
        var niches = Path()
        let bays: [(CGFloat, CGFloat)] = [(-12, 93), (0, 90), (12, 93)]
        for bay in bays {
            gablets.move(to: pt(cx + bay.0 - 6, 104.5))
            gablets.addLine(to: pt(cx + bay.0, bay.1))
            gablets.addLine(to: pt(cx + bay.0 + 6, 104.5))
            gablets.closeSubpath()
            niches.addPath(pointedArch(cx + bay.0, 124, width: 9, height: 14))
        }
        Kit.solid(&context, gablets, stone, light: 0.2, shade: 0.2)
        Art.fill(&context, niches, Art.color(0x7A6E90, 0.72))
        Art.stroke(&context, niches, Art.color(0xFFF8E8, 0.6), width: 0.6)
        Art.fill(&context, Art.rect(cx - 12, 124, 24, 5), ArtStyle.coolShade.opacity(0.22))
    }

    private static func bremenLimb(_ data: String, width: CGFloat) -> Path {
        Art.svg(data).strokedPath(StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    /// The knight's cloak, legs and belted tunic.
    private static func bremenRolandBody(_ context: inout GraphicsContext) {
        let stone = Art.color(bremenStatueStone)
        let cloak = Art.svg("M199,152 C194,180 193,214 195,244 L237,244 C239,214 238,180 233,152 Z")
        Kit.solid(&context, cloak, Art.color(0xC6BAB2), light: 0.16, shade: 0.26)

        var legs = Art.rect(204.5, 208, 9.5, 38, radius: 3)
        legs.addPath(Art.rect(218, 208, 9.5, 38, radius: 3))
        Kit.solid(&context, legs, Art.color(0xE4D9C4), light: 0.2, shade: 0.24)
        var feet = Path()
        feet.addEllipse(in: CGRect(x: 201.5, y: 243.6, width: 13, height: 6))
        feet.addEllipse(in: CGRect(x: 217.5, y: 243.6, width: 13, height: 6))
        Art.fill(&context, feet, Art.color(0xD9CDB8))
        var knees = Path()
        knees.addEllipse(in: CGRect(x: 205.5, y: 219, width: 7.5, height: 6))
        knees.addEllipse(in: CGRect(x: 219, y: 219, width: 7.5, height: 6))
        Art.fill(&context, knees, Art.color(0xF8F1E0, 0.8))

        let tunic = Art.svg("M198,154 C198,149 207,147 216,147 C225,147 234,149 234,154 L232,186 C233,196 235,206 236,214 L196,214 C197,206 199,196 200,186 Z")
        Kit.solid(&context, tunic, stone, light: 0.24, shade: 0.24, rim: 1.2)
        let folds = Art.svg("M206,200 L205,212 M213,200 L212.5,212 M220,200 L220.5,212 M227,200 L228,212 M204,170 C211,174 221,174 228,170")
        Art.stroke(&context, folds, Art.color(0xA89C98, 0.55), width: 0.8)
        Art.stroke(&context, Art.line(196.5, 214, 235.5, 214), Art.color(0x9A8C98, 0.6), width: 1)
        // The low knight's belt, gilded as on the statue.
        let belt = Art.rect(199.4, 193.5, 33.2, 4.2, radius: 1.4)
        Kit.solid(&context, belt, Art.color(0xDDAE50), light: 0.2, shade: 0.2)
        Art.fill(&context, Art.circle(216, 195.6, 2.6), Art.color(0xF4D27A))
    }

    /// Arms, the upright sword in his right hand and the shield on his left side.
    private static func bremenRolandArms(_ context: inout GraphicsContext) {
        let stone = Art.color(bremenStatueStone)
        let shieldArm = bremenLimb("M231,156 C236,164 236,172 233,180", width: 7)
        Kit.solid(&context, shieldArm, Art.color(0xDDD2BE), light: 0.16, shade: 0.24)
        let swordArm = bremenLimb("M201,156 C196,164 195,172 197,183", width: 7)
        Kit.solid(&context, swordArm, stone, light: 0.24, shade: 0.2)

        // The sword: blade up along the shoulder, gilded hilt in the hand.
        let blade = Art.polygon([pt(195.2, 180), pt(194.2, 137), pt(195.7, 131), pt(197.4, 137), pt(198.4, 180)])
        Art.fill(&context, blade, Art.color(0xF6F2E8))
        Art.stroke(&context, Art.line(196.6, 134, 197.2, 179), Art.color(0x8E86A0, 0.6), width: 0.7, cap: .butt)
        Art.stroke(&context, Art.line(190.6, 181, 203, 181), Art.color(0xDDAE50), width: 2)
        Art.fill(&context, Art.circle(197, 184.5, 3.4), stone)
        Art.fill(&context, Art.circle(197, 190, 1.9), Art.color(0xDDAE50))

        // The shield: gold, with a small dark eagle. No lettering.
        let shield = Art.svg("M221,160 L239,160 C239,172 236,181 230,187 C224,181 221,172 221,160 Z")
        Kit.solid(&context, shield, Art.color(0xEBBC52), light: 0.26, shade: 0.24)
        Art.stroke(&context, shield, Art.color(0xB8862E, 0.8), width: 0.9)
        let eagleInk = Art.color(0x4A3A4E)
        Art.fill(&context, Art.svg("M230,168 L224.6,165 L225.6,172.5 Z"), eagleInk)
        Art.fill(&context, Art.svg("M230,168 L235.4,165 L234.4,172.5 Z"), eagleInk)
        Art.fill(&context, Art.ellipse(230, 171, 1.7, 5), eagleInk)
    }

    /// Head and long hair; the face is only hinted, and friendly.
    private static func bremenRolandHead(_ context: inout GraphicsContext) {
        let stone = Art.color(bremenStatueStone)
        Art.fill(&context, Art.rect(212.5, 142, 7, 7), Art.color(0xD9CDB8))
        let hair = Art.svg("M206,138 C205,127 211,125 216,125 C221,125 227,127 226,138 C227.5,144 227,149 225,153 L207,153 C205,149 204.5,144 206,138 Z")
        Kit.solid(&context, hair, Art.color(0xD9B878), light: 0.2, shade: 0.24)
        let face = Art.ellipse(216, 138, 6.6, 7.8)
        Kit.solid(&context, face, stone, light: 0.24, shade: 0.2)
        let waves = Art.svg("M208,140 C207,144 207.5,148 208.5,151 M224,140 C225,144 224.5,148 223.5,151")
        Art.stroke(&context, waves, Art.color(0xA8864E, 0.6), width: 0.7)
        ArtStyle.eye(&context, 213.4, 137.6, 0.9, iris: Art.color(0x6A5A66), showsWhite: false)
        ArtStyle.eye(&context, 218.6, 137.6, 0.9, iris: Art.color(0x6A5A66), showsWhite: false)
        ArtStyle.smile(&context, 216, 141.6, width: 4, curve: 0.7, color: Art.color(0x9A8478), lineWidth: 0.8)
    }

    // MARK: Finish

    private static func bremenFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x3A2A4F, from: 300, alpha: 0.9)
        tooth(&context, seed: 521, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
