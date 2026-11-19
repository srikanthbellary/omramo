import SwiftUI
import OmramoCore

// The Great Mosque of Djenné by day: our own drawing (no photograph, nothing traced).
// The great mud-brick building on its raised platform, seen from the market square: its
// front with three tall square towers, each crowned with cones and an egg-shaped finial,
// rows of buttress pillars between them and the short palm-wood poles that jut from the
// smooth brown plaster. Far mud houses and palms in the heat haze; a few tiny figures and
// market shades on the square give the scale. Card background #5A3218.

extension LandmarkArt {
    /// great-mosque-djenne: the mud-brick front with its three crowned towers on the raised
    /// platform, warm light on the plaster, a market on the square below, by day.
    static func paintDjenne(_ context: inout GraphicsContext) {
        djenneSky(&context)
        djenneTown(&context)
        djenneGround(&context)
        djenneWall(&context)
        djenneTowers(&context)
        // The platform after the walls, so its top and pinnacles stand in front of their feet.
        djennePlatform(&context)
        djenneStairs(&context)
        // Warm light lying on the plaster, from the upper left.
        Art.glow(&context, 168, 150, 160, Art.color(0xFFE6B8), alpha: 0.18)
        djenneMarket(&context)
        djenneNear(&context)
        djenneFinish(&context)
    }

    // MARK: Plaster

    /// Smooth mud plaster in the one light: pale and warm on the left, deeper brown to the right.
    static func djenneMud(_ context: inout GraphicsContext, _ path: Path, from x0: CGFloat, to x1: CGFloat) {
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xEDBE86), 0),
            (Art.color(0xD49A62), 0.45),
            (Art.color(0xAE7046), 1),
        ]
        fillHorizontal(&context, path, stops, from: x0, to: x1)
    }

    /// The short palm-wood poles that jut out of the plaster: each a dark stub with a pale sawn
    /// end, throwing a small shadow down and to the right.
    static func djennePoles(_ context: inout GraphicsContext, _ points: [CGPoint]) {
        var sticks = Path()
        var shadows = Path()
        var ends = Path()
        for point in points {
            sticks.move(to: pt(point.x + 0.6, point.y))
            sticks.addLine(to: pt(point.x - 3.4, point.y + 1.4))
            shadows.move(to: pt(point.x + 1, point.y + 1.8))
            shadows.addLine(to: pt(point.x + 3.8, point.y + 3.8))
            ends.addEllipse(in: CGRect(x: point.x - 4.3, y: point.y + 0.5, width: 1.7, height: 1.7))
        }
        Art.stroke(&context, shadows, ArtStyle.coolShade.opacity(0.22), width: 1.4)
        Art.stroke(&context, sticks, Art.color(0x6E4426), width: 1.6)
        Art.fill(&context, ends, Art.color(0xD8AA76))
    }

    // MARK: Sky and the far town

    static func djenneSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0xC4DCE6), 0),
            (Art.color(0xE8E6D6), 0.22),
            (Art.color(0xFBE8C6), 0.55),
            (Art.color(0xF6DDB4), 1),
        ]
        backdrop(&context, sky)
        // The hot, pale sun-glare high on the left, and two thin veils of dusty cloud.
        Art.glow(&context, 130, 64, 170, Art.color(0xFFF6DE), alpha: 0.45)
        let veilHigh = cloudBand(252, 72, width: 150, height: 13)
        Art.fill(&context, veilHigh, Art.color(0xFFFFFF, 0.32))
        let veilLow = cloudBand(150, 128, width: 96, height: 8)
        Art.fill(&context, veilLow, Art.color(0xFFFFFF, 0.24))
    }

    /// The far plane: low flat-roofed mud houses and a few palms, veiled in the heat haze.
    static func djenneTown(_ context: inout GraphicsContext) {
        // x, width, height of each house; they all stand on the same far line.
        let houses: [(CGFloat, CGFloat, CGFloat)] = [
            (-24, 40, 30), (14, 34, 42), (46, 30, 34), (72, 26, 26),
            (338, 28, 30), (364, 36, 44), (398, 30, 34), (426, 32, 38),
        ]
        let base: CGFloat = 264
        var blocks = Path()
        var lit = Path()
        var doors = Path()
        for house in houses {
            let top: CGFloat = base - house.2
            let postX: CGFloat = house.0 + house.1 - 5
            let litW: CGFloat = house.1 * 0.3
            let doorX: CGFloat = house.0 + house.1 * 0.5
            blocks.addRect(CGRect(x: house.0, y: top, width: house.1, height: house.2))
            blocks.addRect(CGRect(x: house.0 + 2, y: top - 4, width: 3, height: 4))
            blocks.addRect(CGRect(x: postX, y: top - 4, width: 3, height: 4))
            lit.addRect(CGRect(x: house.0, y: top, width: litW, height: house.2))
            doors.addRect(CGRect(x: doorX, y: base - 12, width: 5, height: 12))
        }
        Art.fill(&context, blocks, Art.color(0xC9966A))
        Art.fill(&context, lit, Art.color(0xF2C894, 0.4))
        Art.fill(&context, doors, Art.color(0x8A5A3E, 0.7))

        // Date palms: a gently bent trunk and a crown of fronds.
        let palms: [(CGFloat, CGFloat, CGFloat)] = [(28, 264, 72), (60, 264, 54), (394, 264, 66)]
        var trunks = Path()
        var fronds = Path()
        for palm in palms {
            let topY: CGFloat = palm.1 - palm.2
            let topX: CGFloat = palm.0 + 4
            let bendY: CGFloat = palm.1 - palm.2 * 0.5
            trunks.move(to: pt(palm.0, palm.1))
            trunks.addQuadCurve(to: pt(topX, topY), control: pt(palm.0 - 3, bendY))
            for index in 0..<7 {
                let angle: CGFloat = -0.3 - CGFloat(index) * 0.42
                fronds.addPath(leaf(topX, topY, length: 20, width: 3.6, angle: angle))
            }
            fronds.addPath(leaf(topX, topY, length: 17, width: 3.2, angle: 0.45))
            fronds.addPath(leaf(topX, topY, length: 17, width: 3.2, angle: 2.7))
        }
        Art.stroke(&context, trunks, Art.color(0x8A6A4A), width: 2.2)
        Art.fill(&context, fronds, Art.color(0x6F7A4A))
        haze(&context, top: 180, bottom: 266, hex: 0xF6DDB4, alpha: 0.45)
    }

    // MARK: Ground and platform

    static func djenneGround(_ context: inout GraphicsContext) {
        let ground = Art.rect(-24, 262, unitWidth + 48, unitHeight - 262 + 24)
        let sand: [(Color, CGFloat)] = [
            (Art.color(0xF0D2A2), 0),
            (Art.color(0xDDB07C), 0.3),
            (Art.color(0x9C6438), 0.75),
            (Art.color(0x5A3218), 1),
        ]
        fillVertical(&context, ground, sand, from: 262, to: unitHeight)
        horizon(&context, y: 264, rise: 40, hex: 0xFFE2B0, alpha: 0.3)
        Kit.rippleMarks(&context, x0: 40, x1: 390, y0: 296, y1: 350, count: 18, seed: 71, color: Art.color(0xB07A4A), alpha: 0.28)
    }

    /// The raised mud platform the mosque stands on, with small pinnacles along its edge.
    static func djennePlatform(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 222, 287, 168, 6, alpha: 0.26)
        let topFace = Art.polygon([pt(72, 250), pt(360, 250), pt(368, 258), pt(64, 258)])
        Art.fill(&context, topFace, Art.color(0xF2CC98))
        let front = Art.rect(64, 258, 304, 28)
        djenneMud(&context, front, from: 64, to: 368)
        model(&context, front, light: 0.12, shade: 0.2)
        Art.stroke(&context, Art.line(64, 258.4, 368, 258.4), Art.color(0xFFE6BE, 0.8), width: 1, cap: .butt)
        // A soft line of shade just under the lip of the platform.
        Art.fill(&context, Art.rect(64, 259, 304, 3), ArtStyle.coolShade.opacity(0.14))

        // Small rounded pinnacles standing on the platform's front edge (none over the stairs).
        var posts = Path()
        var x: CGFloat = 72
        while x < 364 {
            if x < 182 || x > 250 {
                posts.move(to: pt(x - 2.4, 258))
                posts.addLine(to: pt(x - 2.4, 253))
                posts.addQuadCurve(to: pt(x, 248), control: pt(x - 2.4, 249))
                posts.addQuadCurve(to: pt(x + 2.4, 253), control: pt(x + 2.4, 249))
                posts.addLine(to: pt(x + 2.4, 258))
                posts.closeSubpath()
            }
            x += 22
        }
        djenneMud(&context, posts, from: 64, to: 368)
        Art.fill(&context, posts, Art.color(0xFFE6BE, 0.18))
    }

    // MARK: The front wall

    /// The long front wall between the towers: smooth plaster, a row of buttress pillars
    /// rising above the parapet into rounded points, and rows of palm-wood poles.
    static func djenneWall(_ context: inout GraphicsContext) {
        let wall = Art.svg("M92,252 L92,154 Q93,150 97,150 L335,150 Q339,150 340,154 L340,252 Z")
        djenneMud(&context, wall, from: 92, to: 340)
        model(&context, wall, light: 0.14, shade: 0.16)
        // Rain has run down the plaster in soft streaks.
        let streaks = Art.svg("M104,156 C103,190 106,220 104,250 M152,156 C151,180 153,200 152,226 M180,158 C181,190 179,214 180,246 M252,156 C251,184 254,204 252,236 M280,158 C281,180 279,210 281,248 M330,156 C329,190 331,214 330,250")
        Art.clipped(&context, to: wall) { g in
            Art.stroke(&g, streaks, Art.color(0xFFE2B8, 0.22), width: 2)
        }

        let xs: [CGFloat] = [98, 146, 156, 166, 176, 186, 246, 256, 266, 276, 286, 334]
        var piers = Path()
        var pierLit = Path()
        var pierCast = Path()
        for x in xs {
            piers.addRect(CGRect(x: x - 3, y: 144, width: 6, height: 108))
            piers.move(to: pt(x - 3, 144))
            piers.addQuadCurve(to: pt(x, 132), control: pt(x - 3, 136))
            piers.addQuadCurve(to: pt(x + 3, 144), control: pt(x + 3, 136))
            piers.closeSubpath()
            pierLit.addRect(CGRect(x: x - 3, y: 142, width: 1.8, height: 110))
            pierCast.addRect(CGRect(x: x + 3, y: 151, width: 3, height: 101))
        }
        Art.fill(&context, pierCast, ArtStyle.coolShade.opacity(0.16))
        djenneMud(&context, piers, from: 92, to: 340)
        Art.fill(&context, pierLit, Art.color(0xFFE6BE, 0.4))
        // The parapet's lit top edge between the pillars.
        Art.stroke(&context, Art.line(96, 150.5, 336, 150.5), Art.color(0xFFE6BE, 0.6), width: 1, cap: .butt)

        // Three rows of poles in the bays between the pillars.
        let bayXs: [CGFloat] = [151, 161, 171, 181, 251, 261, 271, 281]
        let rowYs: [CGFloat] = [172, 198, 224]
        var stubs: [CGPoint] = []
        for rowY in rowYs {
            for bayX in bayXs {
                stubs.append(pt(bayX, rowY))
            }
        }
        djennePoles(&context, stubs)

        // A few low dark doorways at the foot of the wall.
        var doors = Path()
        doors.addPath(pointedArch(161, 252, width: 8, height: 16))
        doors.addPath(pointedArch(271, 252, width: 8, height: 16))
        Art.fill(&context, doors, Art.color(0x5E321E))
    }

    // MARK: Towers

    static func djenneTowers(_ context: inout GraphicsContext) {
        djenneTower(&context, cx: 120, top: 104, half: 17, spire: 18)
        djenneTower(&context, cx: 312, top: 104, half: 17, spire: 18)
        djenneTower(&context, cx: 216, top: 86, half: 22, spire: 24)
    }

    /// One square tower, wider at its foot, crowned with two corner pinnacles, a tall middle
    /// cone and the egg-shaped finial on top; poles jut from its face in rows.
    static func djenneTower(_ context: inout GraphicsContext, cx: CGFloat, top: CGFloat, half: CGFloat, spire: CGFloat) {
        let base: CGFloat = 252
        let neck: CGFloat = half * 0.74
        let footL: CGFloat = cx - half
        let footR: CGFloat = cx + half
        let leftX: CGFloat = cx - neck
        let rightX: CGFloat = cx + neck
        // The tower throws a little shade onto the wall on its right.
        let castCorners: [CGPoint] = [
            pt(footR, base), pt(rightX, top + 4), pt(rightX + 9, top + 12), pt(footR + 9, base),
        ]
        Art.fill(&context, Art.polygon(castCorners), ArtStyle.coolShade.opacity(0.16))

        let shaft: [CGPoint] = [pt(footL, base), pt(leftX, top), pt(rightX, top), pt(footR, base)]
        var body = Art.polygon(shaft)
        // The two corner pinnacles.
        let pin: CGFloat = half * 0.22
        let pinTop: CGFloat = top - half * 0.6
        let pinMid: CGFloat = top - half * 0.36
        body.move(to: pt(leftX, top + 1))
        body.addQuadCurve(to: pt(leftX + pin, pinTop), control: pt(leftX, pinMid))
        body.addQuadCurve(to: pt(leftX + pin * 2, top + 1), control: pt(leftX + pin * 2, pinMid))
        body.closeSubpath()
        body.move(to: pt(rightX - pin * 2, top + 1))
        body.addQuadCurve(to: pt(rightX - pin, pinTop), control: pt(rightX - pin * 2, pinMid))
        body.addQuadCurve(to: pt(rightX, top + 1), control: pt(rightX, pinMid))
        body.closeSubpath()
        // The tall middle cone.
        let coneHalf: CGFloat = half * 0.42
        let coneMid: CGFloat = top - spire * 0.55
        let coneTop: CGFloat = top - spire
        body.move(to: pt(cx - coneHalf, top + 1))
        body.addQuadCurve(to: pt(cx, coneTop), control: pt(cx - half * 0.36, coneMid))
        body.addQuadCurve(to: pt(cx + coneHalf, top + 1), control: pt(cx + half * 0.36, coneMid))
        body.closeSubpath()
        djenneMud(&context, body, from: footL, to: footR)
        model(&context, body, light: 0.2, shade: 0.2, rim: 0.5)
        djenneTowerFace(&context, cx: cx, top: top, half: half, spire: spire)
    }

    /// The faces, window, finial and poles of one tower (see `djenneTower`).
    static func djenneTowerFace(_ context: inout GraphicsContext, cx: CGFloat, top: CGFloat, half: CGFloat, spire: CGFloat) {
        let base: CGFloat = 252
        let neck: CGFloat = half * 0.74
        let coneTop: CGFloat = top - spire
        // The lit left face and the shaded right face of the square shaft.
        let litCorners: [CGPoint] = [
            pt(cx - half, base), pt(cx - neck, top), pt(cx - neck * 0.7, top), pt(cx - half * 0.7, base),
        ]
        Art.fill(&context, Art.polygon(litCorners), Art.color(0xFFE6BE, 0.3))
        let shadeCorners: [CGPoint] = [
            pt(cx + half * 0.35, base), pt(cx + neck * 0.35, top), pt(cx + neck, top), pt(cx + half, base),
        ]
        Art.fill(&context, Art.polygon(shadeCorners), ArtStyle.coolShade.opacity(0.14))
        let ribFoot: CGFloat = half * 0.33
        let ribTop: CGFloat = neck * 0.33
        var ribs = Art.line(cx - ribFoot, base, cx - ribTop, top)
        ribs.move(to: pt(cx + ribFoot, base))
        ribs.addLine(to: pt(cx + ribTop, top))
        Art.stroke(&context, ribs, Art.color(0xA8683E, 0.35), width: 1)
        let parapet = Art.line(cx - neck, top + 0.5, cx + neck, top + 0.5)
        Art.stroke(&context, parapet, Art.color(0xFFE6BE, 0.6), width: 0.9, cap: .butt)

        // A small dark window high on the shaft.
        let windowW: CGFloat = half * 0.24
        let window = Art.rect(cx - windowW / 2, top + 12, windowW, half * 0.5)
        Art.fill(&context, window, Art.color(0x6E3E24))

        // The finial: a short stick and a pale egg on the cone's point.
        let eggR: CGFloat = half * 0.17
        let eggY: CGFloat = coneTop - eggR * 1.3
        Art.fill(&context, Art.rect(cx - 0.5, coneTop - 2, 1, 2.4), Art.color(0x8A5A3E))
        let egg = Art.ellipse(cx, eggY, eggR * 0.8, eggR * 1.15)
        Art.fill(&context, egg, Art.color(0xF4EAD8))
        model(&context, egg, light: 0.2, shade: 0.24)
        Art.fill(&context, Art.ellipse(cx - eggR * 0.3, eggY - eggR * 0.4, eggR * 0.22, eggR * 0.32), Art.color(0xFFFFFF, 0.7))

        // Rows of poles up the face.
        var stubs: [CGPoint] = []
        var y: CGFloat = top + 26
        while y < base - 8 {
            let t: CGFloat = (y - top) / (base - top)
            let w: CGFloat = neck + (half - neck) * t
            stubs.append(pt(cx - w * 0.6, y))
            stubs.append(pt(cx + w * 0.05, y))
            stubs.append(pt(cx + w * 0.66, y))
            y += 22
        }
        djennePoles(&context, stubs)
    }

    /// The broad mud stairs up the middle of the platform.
    static func djenneStairs(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 218, 293, 36, 3, alpha: 0.26)
        let stairs = Art.polygon([pt(190, 256), pt(242, 256), pt(250, 292), pt(182, 292)])
        djenneMud(&context, stairs, from: 182, to: 250)
        model(&context, stairs, light: 0.16, shade: 0.18)
        var treads = Path()
        var risers = Path()
        let steps: [CGFloat] = [263, 270, 277, 284]
        for stepY in steps {
            let inset: CGFloat = (292 - stepY) * 0.22
            treads.move(to: pt(182 + inset, stepY))
            treads.addLine(to: pt(250 - inset, stepY))
            risers.move(to: pt(182 + inset, stepY + 1.4))
            risers.addLine(to: pt(250 - inset, stepY + 1.4))
        }
        Art.stroke(&context, risers, ArtStyle.coolShade.opacity(0.2), width: 1.6, cap: .butt)
        Art.stroke(&context, treads, Art.color(0xFFE6BE, 0.7), width: 0.9, cap: .butt)
    }

    // MARK: The market

    /// Three cloth sunshades on poles with heaps of goods under them, and a few tiny people
    /// in bright robes crossing the square.
    static func djenneMarket(_ context: inout GraphicsContext) {
        let stalls: [(CGFloat, CGFloat, UInt32, UInt32)] = [
            (82, 318, 0xEDE0C4, 0xE58A3A),
            (300, 326, 0xDCC9A8, 0x7E9A44),
            (352, 308, 0xE8D4B2, 0xE8B83A),
        ]
        for stall in stalls {
            let x: CGFloat = stall.0
            let y: CGFloat = stall.1
            ArtStyle.contactShadow(&context, x + 15, y + 1, 19, 2.4, alpha: 0.26)
            var poles = Art.line(x, y, x, y - 17)
            poles.move(to: pt(x + 26, y))
            poles.addLine(to: pt(x + 26, y - 14))
            Art.stroke(&context, poles, Art.color(0x6E4426), width: 1.2)
            let clothCorners: [CGPoint] = [pt(x - 4, y - 18), pt(x + 30, y - 15), pt(x + 31, y - 12), pt(x - 3, y - 15)]
            Art.fill(&context, Art.polygon(clothCorners), Art.color(stall.2))
            let foldCorners: [CGPoint] = [pt(x + 14, y - 16.4), pt(x + 30, y - 15), pt(x + 31, y - 12), pt(x + 14, y - 13.4)]
            Art.fill(&context, Art.polygon(foldCorners), ArtStyle.coolShade.opacity(0.16))
            // The shade the cloth throws on the ground, and the heap of goods.
            let groundCorners: [CGPoint] = [pt(x, y - 2), pt(x + 30, y - 2), pt(x + 34, y + 2), pt(x + 4, y + 2)]
            Art.fill(&context, Art.polygon(groundCorners), ArtStyle.coolShade.opacity(0.14))
            var heap = Path()
            heap.move(to: pt(x + 4, y))
            heap.addQuadCurve(to: pt(x + 22, y), control: pt(x + 13, y - 10))
            heap.closeSubpath()
            Art.fill(&context, heap, Art.color(stall.3))
            model(&context, heap, light: 0.22, shade: 0.24)
        }

        let people: [(CGFloat, CGFloat, UInt32, CGFloat)] = [
            (60, 332, 0x3E5AA8, 1), (128, 304, 0xE07A2E, 0.85), (170, 318, 0xEFC24A, 0.95),
            (208, 302, 0xF2EEE2, 0.8), (262, 312, 0x2E8A62, 0.9), (284, 338, 0xC8463A, 1.05),
            (370, 336, 0x6A4AA0, 1),
        ]
        for person in people {
            djenneFigure(&context, x: person.0, y: person.1, robe: person.2, scale: person.3)
        }
    }

    /// One tiny person in a long robe and head wrap, about three heads tall.
    static func djenneFigure(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, robe: UInt32, scale: CGFloat) {
        let s: CGFloat = scale
        ArtStyle.contactShadow(&context, x + 1.5 * s, y + 0.4, 4.4 * s, 1.2 * s, alpha: 0.3)
        let hem: CGFloat = 2.8 * s
        let shoulder: CGFloat = 1.6 * s
        let neckY: CGFloat = y - 8.4 * s
        let gownCorners: [CGPoint] = [pt(x - hem, y), pt(x - shoulder, neckY), pt(x + shoulder, neckY), pt(x + hem, y)]
        Art.fill(&context, Art.polygon(gownCorners), Art.color(robe))
        let litW: CGFloat = 1.1 * s
        let litTop: CGFloat = x - shoulder + litW
        let litFoot: CGFloat = x - hem + litW
        let litCorners: [CGPoint] = [pt(x - hem, y), pt(x - shoulder, neckY), pt(litTop, neckY), pt(litFoot, y)]
        Art.fill(&context, Art.polygon(litCorners), Art.color(0xFFF2DC, 0.35))
        let shadeFoot: CGFloat = x + hem * 0.3
        let shadeTop: CGFloat = x + shoulder * 0.3
        let shadeCorners: [CGPoint] = [pt(shadeFoot, y), pt(shadeTop, neckY), pt(x + shoulder, neckY), pt(x + hem, y)]
        Art.fill(&context, Art.polygon(shadeCorners), ArtStyle.coolShade.opacity(0.22))
        let headR: CGFloat = 1.5 * s
        let headY: CGFloat = neckY - headR
        Art.fill(&context, Art.circle(x, headY, headR), Art.color(0x6E4230))
        let wrap = Art.ellipse(x, headY - headR * 0.6, headR * 1.05, headR * 0.6)
        Art.fill(&context, wrap, Art.color(robe))
        Art.fill(&context, wrap, Art.color(0xFFF2DC, 0.2))
    }

    // MARK: The near plane

    /// A corner of a dark mud wall in the lower left, its own poles catching a sliver of light,
    /// and a neem branch hanging into the top-right corner.
    static func djenneNear(_ context: inout GraphicsContext) {
        let wall = Art.svg("M-24,428 L-24,316 C-4,312 16,318 30,328 Q40,334 44,344 L50,428 Z")
        Kit.solid(&context, wall, stops: Kit.stops(0x7A4626, 0x40220F), light: 0.08, shade: 0.2, rim: 2)
        var near: [CGPoint] = []
        let nearRows: [(CGFloat, CGFloat)] = [(6, 340), (26, 350), (12, 368), (34, 374)]
        for row in nearRows {
            near.append(pt(row.0, row.1))
        }
        djennePoles(&context, near)
        cornerSpray(&context, seed: 59, dark: Art.color(0x3E3A20), lit: Art.color(0xA6A862, 0.55))
    }

    // MARK: Finish

    static func djenneFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x5A3218, from: 300, alpha: 0.9)
        tooth(&context, seed: 709, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
