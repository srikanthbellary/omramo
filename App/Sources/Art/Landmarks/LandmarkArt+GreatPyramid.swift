import SwiftUI
import OmramoCore

// The Great Pyramid of Giza by day, as it stands today: our own drawing (no photograph,
// nothing traced). The great pyramid is seen from a corner, its left face in the sun and its
// right face in soft indigo shade, its courses of stone drawn as fine lines and its edges
// stepped and weathered. Two more pyramids stand smaller and hazier behind it to the right;
// the middle one keeps a smooth cap of casing stones near its top. Tiny people and a camel
// rider at its foot give the scale. Card background #5A3A1C.

extension LandmarkArt {
    /// great-pyramid-giza: the pale stone pyramid under a hot clear sky, two more pyramids
    /// behind it, desert sand and low rock in front, and tiny people at its foot, by day.
    static func paintGreatPyramid(_ context: inout GraphicsContext) {
        pyramidSky(&context)
        pyramidFarPlane(&context)
        pyramidGround(&context)
        pyramidCastShadow(&context)
        pyramidBody(&context)
        pyramidStonework(&context)
        pyramidFoot(&context)
        // Warm light lying on the sunlit face, from the upper left.
        Art.glow(&context, 140, 170, 130, Art.color(0xFFE9B8), alpha: 0.16)
        pyramidRocks(&context)
        pyramidPeople(&context)
        pyramidCamelRider(&context)
        pyramidNearPlane(&context)
        pyramidFinish(&context)
    }

    // MARK: Geometry

    /// The top of the great pyramid.
    static func pyramidApex() -> CGPoint { CGPoint(x: 212, y: 70) }
    /// The far left corner of its base.
    static func pyramidLeftCorner() -> CGPoint { CGPoint(x: 62, y: 286) }
    /// The corner of its base that points at the viewer.
    static func pyramidFrontCorner() -> CGPoint { CGPoint(x: 236, y: 296) }
    /// The far right corner of its base.
    static func pyramidRightCorner() -> CGPoint { CGPoint(x: 352, y: 284) }

    /// The point `t` of the way from `a` to `b`.
    static func pyramidLerp(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        let x: CGFloat = a.x + (b.x - a.x) * t
        let y: CGFloat = a.y + (b.y - a.y) * t
        return CGPoint(x: x, y: y)
    }

    /// One face of a pyramid whose outer edge (from `base` up to `apex`) is a worn stair of
    /// stone courses; the edge from `apex` down to `corner` is straight.
    static func pyramidSteppedFace(base: CGPoint, apex: CGPoint, corner: CGPoint, steps: Int, seed: UInt32) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        path.move(to: corner)
        path.addLine(to: base)
        var x: CGFloat = base.x
        let count: Int = max(1, steps)
        for index in 1...count {
            let t: CGFloat = CGFloat(index) / CGFloat(count)
            let p: CGPoint = pyramidLerp(base, apex, t)
            let wobble: CGFloat = random.next(in: -0.7...0.7)
            path.addLine(to: pt(x, p.y))
            x = p.x + wobble
            path.addLine(to: pt(x, p.y))
        }
        path.addLine(to: apex)
        path.closeSubpath()
        return path
    }

    /// The course lines of one face: `count` lines parallel to the base, moved down by `drop`.
    static func pyramidCourses(base: CGPoint, apex: CGPoint, corner: CGPoint, count: Int, drop: CGFloat) -> Path {
        var path = Path()
        let rows: Int = max(2, count)
        for index in 1..<rows {
            let t: CGFloat = CGFloat(index) / CGFloat(rows)
            let a: CGPoint = pyramidLerp(base, apex, t)
            let b: CGPoint = pyramidLerp(corner, apex, t)
            path.move(to: pt(a.x - 4, a.y + drop))
            path.addLine(to: pt(b.x, b.y + drop))
        }
        return path
    }

    /// Short upright joints between the blocks of one face, scattered over its courses.
    static func pyramidJoints(base: CGPoint, apex: CGPoint, corner: CGPoint, courses: Int, count: Int, seed: UInt32) -> Path {
        var random = ArtRandom(seed)
        var path = Path()
        let rows: CGFloat = CGFloat(max(2, courses))
        for _ in 0..<max(0, count) {
            let pick: CGFloat = random.next(in: 0...0.9)
            let row: CGFloat = (pick * rows).rounded(.down)
            let t0: CGFloat = row / rows
            let t1: CGFloat = (row + 1) / rows
            let s: CGFloat = random.next(in: 0.04...0.96)
            let low: CGPoint = pyramidLerp(pyramidLerp(base, apex, t0), pyramidLerp(corner, apex, t0), s)
            let high: CGPoint = pyramidLerp(pyramidLerp(base, apex, t1), pyramidLerp(corner, apex, t1), s)
            path.move(to: low)
            path.addLine(to: pt(low.x, high.y))
        }
        return path
    }

    // MARK: Sky

    static func pyramidSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x5FA6DA), 0),
            (Art.color(0x9CCBE6), 0.3),
            (Art.color(0xDDEBE0), 0.55),
            (Art.color(0xFFEBC2), 0.7),
            (Art.color(0xFFEBC2), 1),
        ]
        backdrop(&context, sky)
        // The heat of the day: the sky whitens toward the sun, off the picture's upper left.
        Art.glow(&context, 40, 150, 230, Art.color(0xFFF6DC), alpha: 0.3)

        // Thin high wisps, kept away from the top-left corner.
        var wisps = Path()
        wisps.addPath(cloudBand(262, 50, width: 150, height: 7))
        wisps.addPath(cloudBand(318, 104, width: 130, height: 6))
        wisps.addPath(cloudBand(-10, 132, width: 120, height: 6))
        Art.fill(&context, wisps, Art.color(0xFFFFFF, 0.3))

        // Three far birds.
        let birds = Art.svg("M322,62 q3,-3 5,0 q2,-3 5,0 M340,72 q2.4,-2.4 4,0 q1.6,-2.4 4,0 M308,76 q2,-2 3.4,0 q1.4,-2 3.4,0")
        Art.stroke(&context, birds, Art.color(0x6A5A78, 0.55), width: 0.8)
    }

    // MARK: The far plane

    /// The low desert plateau on the skyline and the two farther pyramids, veiled with the
    /// sky's own colour.
    static func pyramidFarPlane(_ context: inout GraphicsContext) {
        let plateau = Art.svg("M-24,290 L-24,270 C30,264 80,272 140,268 C200,264 260,273 330,268 C380,264 420,270 456,266 L456,290 Z")
        let dust: [(Color, CGFloat)] = [
            (Art.color(0xE8CC9C), 0),
            (Art.color(0xDDB884), 1),
        ]
        fillVertical(&context, plateau, dust, from: 264, to: 290)
        let ridges = Art.svg("M-24,276 C40,271 90,278 150,274 M250,277 C300,272 370,279 456,273")
        Art.stroke(&context, ridges, Art.color(0xFFEBC2, 0.5), width: 1)

        // The third pyramid, the smallest and farthest.
        pyramidFar(&context, apex: pt(408, 214), left: pt(378, 283), front: pt(414, 286), right: pt(448, 282), courses: 9)
        haze(&context, top: 200, bottom: 290, hex: 0xFFEBC2, alpha: 0.22)
        // The middle pyramid, with its cap of smooth casing stones.
        let apex = pt(350, 138)
        let left = pt(284, 283)
        let front = pt(362, 288)
        let right = pt(426, 282)
        pyramidFar(&context, apex: apex, left: left, front: front, right: right, courses: 20)
        pyramidCasingCap(&context, apex: apex, left: left, front: front, right: right)
        haze(&context, top: 120, bottom: 290, hex: 0xFFEBC2, alpha: 0.36)
    }

    /// A farther pyramid: a lit left face, a shaded right face, faint courses, straight edges.
    static func pyramidFar(_ context: inout GraphicsContext, apex: CGPoint, left: CGPoint, front: CGPoint, right: CGPoint, courses: Int) {
        let litFace = Art.polygon([apex, left, front])
        let shadeFace = Art.polygon([apex, front, right])
        let lit: [(Color, CGFloat)] = [
            (Art.color(0xF8E2B4), 0),
            (Art.color(0xE6C48C), 1),
        ]
        let shade: [(Color, CGFloat)] = [
            (Art.color(0xBCA8B8), 0),
            (Art.color(0xA48EA6), 1),
        ]
        fillVertical(&context, litFace, lit, from: apex.y, to: front.y)
        fillVertical(&context, shadeFace, shade, from: apex.y, to: front.y)
        let litLines = pyramidCourses(base: left, apex: apex, corner: front, count: courses, drop: 0)
        let shadeLines = pyramidCourses(base: right, apex: apex, corner: front, count: courses, drop: 0)
        Art.clipped(&context, to: litFace) { g in
            Art.stroke(&g, litLines, Art.color(0xB88C58, 0.32), width: 0.5, cap: .butt)
        }
        Art.clipped(&context, to: shadeFace) { g in
            Art.stroke(&g, shadeLines, Art.color(0x5E4E84, 0.3), width: 0.5, cap: .butt)
        }
        Art.stroke(&context, Art.line(apex.x, apex.y, front.x, front.y), Art.color(0xFFF2D0, 0.6), width: 0.7)
    }

    /// The smooth casing stones that still cover the top of the middle pyramid: paler than the
    /// stepped core below, standing a little proud of it, with a ragged lower edge.
    static func pyramidCasingCap(_ context: inout GraphicsContext, apex: CGPoint, left: CGPoint, front: CGPoint, right: CGPoint) {
        let t: CGFloat = 0.75
        let l: CGPoint = pyramidLerp(left, apex, t)
        let f: CGPoint = pyramidLerp(front, apex, t)
        let r: CGPoint = pyramidLerp(right, apex, t)
        let capLeft = pt(l.x - 1.4, l.y)
        let capFront = pt(f.x, f.y + 1.2)
        let capRight = pt(r.x + 1.4, r.y)
        let m1: CGPoint = pyramidLerp(capLeft, capFront, 0.35)
        let m2: CGPoint = pyramidLerp(capLeft, capFront, 0.7)
        let n1: CGPoint = pyramidLerp(capFront, capRight, 0.5)
        let litCap = Art.polygon([apex, capLeft, pt(m1.x, m1.y + 2.4), pt(m2.x, m2.y - 1.6), capFront])
        let shadeCap = Art.polygon([apex, capFront, pt(n1.x, n1.y + 2.2), capRight])
        // The shade the cap throws on the core just under its edge.
        let under = Art.polygon([capLeft, pt(m1.x, m1.y + 2.4), pt(m2.x, m2.y - 1.6), capFront, pt(n1.x, n1.y + 2.2), capRight], closed: false)
        Art.group(&context, y: 1.6) { g in
            Art.stroke(&g, under, ArtStyle.coolShade.opacity(0.22), width: 1.6)
        }
        let lit: [(Color, CGFloat)] = [
            (Art.color(0xFFF6DC), 0),
            (Art.color(0xF6E2B8), 1),
        ]
        let shade: [(Color, CGFloat)] = [
            (Art.color(0xCDBDC8), 0),
            (Art.color(0xB6A2B4), 1),
        ]
        fillVertical(&context, litCap, lit, from: apex.y, to: capFront.y)
        fillVertical(&context, shadeCap, shade, from: apex.y, to: capFront.y)
        Art.stroke(&context, Art.line(apex.x, apex.y, capFront.x, capFront.y), Art.color(0xFFFFFF, 0.6), width: 0.7)
    }

    // MARK: Ground

    static func pyramidGround(_ context: inout GraphicsContext) {
        let ground = Art.svg("M-24,284 C80,279 180,286 260,283 C340,280 400,286 456,282 L456,428 L-24,428 Z")
        let sand: [(Color, CGFloat)] = [
            (Art.color(0xF8E0AC), 0),
            (Art.color(0xEAC288), 0.3),
            (Art.color(0xA87444), 0.75),
            (Art.color(0x5A3A1C), 1),
        ]
        fillVertical(&context, ground, sand, from: 280, to: unitHeight)
        horizon(&context, y: 282, rise: 40, hex: 0xFFEBC2, alpha: 0.28)

        // Low swells of sand: a pale sunlit crest and the shade behind it.
        let crests = Art.svg("M-24,316 C50,304 130,310 200,320 C262,328 340,314 456,324 L456,330 C340,322 262,336 200,328 C130,318 50,312 -24,324 Z M-24,352 C70,340 160,350 240,358 C320,364 390,350 456,356 L456,362 C390,356 320,370 240,364 C160,356 70,346 -24,358 Z")
        Art.fill(&context, crests, Art.color(0xFFF0C8, 0.32))
        let lees = Art.svg("M-24,324 C50,312 130,318 200,328 C262,336 340,322 456,330 L456,338 C340,330 262,343 200,336 C130,327 50,321 -24,333 Z")
        Art.fill(&context, lees, ArtStyle.coolShade.opacity(0.08))
        let marks = CGRect(x: 0, y: 300, width: unitWidth, height: 70)
        ripples(&context, in: marks, count: 46, seed: 211, color: Art.color(0xB8864E, 0.3), width: 0.8, length: 8...26)
        ripples(&context, in: marks, count: 24, seed: 223, color: Art.color(0xFFF2CC, 0.35), width: 0.7, length: 6...18)
    }

    /// The long shadow the great pyramid throws on the sand, away from the light.
    static func pyramidCastShadow(_ context: inout GraphicsContext) {
        let front = pyramidFrontCorner()
        let right = pyramidRightCorner()
        let shadow = Art.polygon([front, right, pt(456, 290), pt(456, 304), pt(318, 308)])
        let stops: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.3), 0),
            (ArtStyle.coolShade.opacity(0.14), 1),
        ]
        fillHorizontal(&context, shadow, stops, from: 240, to: 456)
    }

    // MARK: The great pyramid

    /// The two faces: pale gold in the sun on the left, soft indigo shade on the right.
    static func pyramidBody(_ context: inout GraphicsContext) {
        let apex = pyramidApex()
        let left = pyramidLeftCorner()
        let front = pyramidFrontCorner()
        let right = pyramidRightCorner()
        let litFace = pyramidSteppedFace(base: left, apex: apex, corner: front, steps: 36, seed: 71)
        let shadeFace = pyramidSteppedFace(base: right, apex: apex, corner: front, steps: 36, seed: 83)

        let lit: [(Color, CGFloat)] = [
            (Art.color(0xFFEDBE), 0),
            (Art.color(0xF4D292), 0.5),
            (Art.color(0xE2B272), 1),
        ]
        fillVertical(&context, litFace, lit, from: 70, to: 296)
        model(&context, litFace, light: 0.2, shade: 0.06)

        let shade: [(Color, CGFloat)] = [
            (Art.color(0xB29CB0), 0),
            (Art.color(0x9480A6), 0.5),
            (Art.color(0x86709A), 1),
        ]
        fillVertical(&context, shadeFace, shade, from: 70, to: 296)
        // Warm light thrown back up from the sand onto the foot of the shaded face.
        let bounce: [(Color, CGFloat)] = [
            (Art.color(0xF0BC84, 0), 0),
            (Art.color(0xF0BC84, 0.3), 1),
        ]
        Art.clipped(&context, to: shadeFace) { g in
            fillVertical(&g, Art.rect(200, 226, 180, 74), bounce, from: 226, to: 296)
        }
        // The edge between the two faces catches the light.
        Art.stroke(&context, Art.line(apex.x, apex.y, front.x, front.y), Art.color(0xFFF6D8, 0.7), width: 1)
    }

    /// The courses of stone on both faces, the joints between blocks, and worn patches.
    static func pyramidStonework(_ context: inout GraphicsContext) {
        let apex = pyramidApex()
        let left = pyramidLeftCorner()
        let front = pyramidFrontCorner()
        let right = pyramidRightCorner()
        let litFace = Art.polygon([apex, pt(left.x - 6, left.y), front])
        let shadeFace = Art.polygon([apex, front, pt(right.x + 6, right.y)])

        let litLines = pyramidCourses(base: left, apex: apex, corner: front, count: 36, drop: 0)
        let litGlints = pyramidCourses(base: left, apex: apex, corner: front, count: 36, drop: -0.9)
        let litJoints = pyramidJoints(base: left, apex: apex, corner: front, courses: 36, count: 90, seed: 131)
        let worn = Art.svg("M120,236 C136,226 160,232 170,244 C160,254 132,252 120,236 Z M176,150 C186,142 200,146 204,158 C196,168 180,164 176,150 Z M186,262 C200,254 220,260 224,272 C210,280 192,276 186,262 Z M98,268 C108,262 120,266 122,274 C112,280 102,276 98,268 Z")
        Art.clipped(&context, to: litFace) { g in
            Art.fill(&g, worn, Art.color(0xB8844C, 0.14))
            Art.stroke(&g, litLines, Art.color(0xB07E46, 0.42), width: 0.6, cap: .butt)
            Art.stroke(&g, litGlints, Art.color(0xFFF8DC, 0.4), width: 0.5, cap: .butt)
            Art.stroke(&g, litJoints, Art.color(0xB07E46, 0.3), width: 0.5, cap: .butt)
        }

        let shadeLines = pyramidCourses(base: right, apex: apex, corner: front, count: 36, drop: 0)
        let shadeJoints = pyramidJoints(base: right, apex: apex, corner: front, courses: 36, count: 60, seed: 149)
        let gouges = Art.svg("M262,220 C272,212 286,218 288,230 C278,238 266,232 262,220 Z M236,150 C244,144 252,150 252,160 C244,164 238,158 236,150 Z")
        Art.clipped(&context, to: shadeFace) { g in
            Art.fill(&g, gouges, ArtStyle.coolShade.opacity(0.12))
            Art.stroke(&g, shadeLines, Art.color(0x54447E, 0.4), width: 0.6, cap: .butt)
            Art.stroke(&g, shadeJoints, Art.color(0x54447E, 0.28), width: 0.5, cap: .butt)
        }
    }

    /// Fallen blocks and rubble along the foot of both faces.
    static func pyramidFoot(_ context: inout GraphicsContext) {
        let left = pyramidLeftCorner()
        let front = pyramidFrontCorner()
        let right = pyramidRightCorner()
        var random = ArtRandom(167)
        var litBlocks = Path()
        var shadeBlocks = Path()
        var tops = Path()
        for index in 0..<40 {
            let s: CGFloat = random.next(in: 0.02...0.98)
            let w: CGFloat = random.next(in: 2.4...6)
            let h: CGFloat = random.next(in: 1.6...3.4)
            let sink: CGFloat = random.next(in: 0.4...2.6)
            if index % 5 < 3 {
                let p: CGPoint = pyramidLerp(left, front, s)
                let block = CGRect(x: p.x - w / 2, y: p.y - h + sink, width: w, height: h)
                litBlocks.addRect(block)
                tops.addRect(CGRect(x: block.minX, y: block.minY, width: w, height: 0.7))
            } else {
                let p: CGPoint = pyramidLerp(front, right, s)
                shadeBlocks.addRect(CGRect(x: p.x - w / 2, y: p.y - h + sink, width: w, height: h))
            }
        }
        Art.fill(&context, litBlocks, Art.color(0xEECB90))
        Art.fill(&context, tops, Art.color(0xFFF4D2, 0.8))
        Art.fill(&context, shadeBlocks, Art.color(0x8E789C))
        // Where the stone meets the sand.
        let seam = Art.polygon([left, front, right], closed: false)
        Art.group(&context, y: 1.4) { g in
            Art.stroke(&g, seam, ArtStyle.coolShade.opacity(0.16), width: 1.6)
        }
    }

    // MARK: Rock, people, camel

    /// Low limestone rock lying in the sand in front of the pyramid.
    static func pyramidRocks(_ context: inout GraphicsContext) {
        let stone: [(Color, CGFloat)] = [
            (Art.color(0xF2D6A2), 0),
            (Art.color(0xC89A62), 1),
        ]
        let leftRock = Art.svg("M34,336 C38,326 50,320 64,322 C76,317 94,320 104,327 C114,328 120,332 122,337 Z")
        ArtStyle.contactShadow(&context, 86, 337, 50, 3.4, alpha: 0.24)
        fillVertical(&context, leftRock, stone, from: 318, to: 338)
        model(&context, leftRock, light: 0.22, shade: 0.22)
        let rightRock = Art.svg("M286,334 C290,326 300,322 312,324 C324,320 338,324 344,330 C350,331 353,333 354,335 Z")
        ArtStyle.contactShadow(&context, 326, 335, 38, 3, alpha: 0.24)
        fillVertical(&context, rightRock, stone, from: 320, to: 336)
        model(&context, rightRock, light: 0.2, shade: 0.24)
        let cracks = Art.svg("M62,323 C66,328 62,332 66,336 M92,321 C90,327 96,331 94,336 M312,325 C314,329 310,331 314,334")
        Art.stroke(&context, cracks, Art.color(0x9A6C3E, 0.45), width: 0.8)
        let pebbles: [(CGFloat, CGFloat, CGFloat)] = [(140, 338, 2.4), (150, 341, 1.6), (262, 340, 2), (366, 338, 2.2), (20, 344, 2)]
        var small = Path()
        for pebble in pebbles {
            small.addEllipse(in: CGRect(x: pebble.0 - pebble.2, y: pebble.1 - pebble.2 * 0.6, width: pebble.2 * 2, height: pebble.2 * 1.2))
        }
        Art.fill(&context, small, Art.color(0xC89A62))
    }

    /// One tiny person in a long robe: a shadow, a robe lit on the left, a head.
    static func pyramidPerson(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, height: CGFloat, robe: UInt32) {
        let w: CGFloat = height * 0.2
        let headR: CGFloat = height * 0.15
        let top: CGFloat = y - height + headR * 2
        ArtStyle.contactShadow(&context, x + height * 0.3, y + 0.2, height * 0.5, height * 0.12, alpha: 0.3)
        let body = Art.polygon([pt(x - w * 0.6, top), pt(x + w * 0.6, top), pt(x + w, y), pt(x - w, y)])
        Art.fill(&context, body, Art.color(robe))
        let side = Art.polygon([pt(x, top), pt(x + w * 0.6, top), pt(x + w, y), pt(x, y)])
        Art.fill(&context, side, ArtStyle.coolShade.opacity(0.24))
        Art.fill(&context, Art.circle(x, top - headR * 0.8, headR), Art.color(0x6A4028))
    }

    /// A few tiny people at the foot of the pyramid, for scale.
    static func pyramidPeople(_ context: inout GraphicsContext) {
        let people: [(CGFloat, CGFloat, CGFloat, UInt32)] = [
            (146, 297, 4.6, 0xFFF6E0),
            (151, 297.6, 4.2, 0x3E6E9A),
            (178, 299.4, 4.8, 0xB8503A),
            (207, 301.4, 4.8, 0xFFF6E0),
            (212, 302, 3.6, 0x2E8A86),
            (296, 299, 4.6, 0xE8D8C0),
            (246, 316, 6.4, 0xFFF6E0),
            (254, 317, 6, 0x3E6E9A),
        ]
        for person in people {
            pyramidPerson(&context, person.0, person.1, height: person.2, robe: person.3)
        }
    }

    /// A tiny rider on a camel, walking toward the pyramid.
    static func pyramidCamelRider(_ context: inout GraphicsContext) {
        let camel = Art.svg("M-7,-6 C-6,-9 -3,-9 -1,-11 C1,-12.5 3,-10 4,-7.5 C5.5,-7.5 6.5,-10 7,-13 L9.4,-13.6 L9.8,-12.4 L8.2,-12 C7.8,-9 7,-5.6 4.6,-5 L4.4,0 L3.4,0 L3,-4.6 L-4,-4.6 L-4.4,0 L-5.4,0 L-5.6,-5 C-6.6,-5.2 -7.2,-5.6 -7,-6 Z M1.4,-4.6 L1.8,0 L0.9,0 L0.4,-4.6 Z M-2.2,-4.6 L-1.8,0 L-2.8,0 L-3.2,-4.6 Z")
        let saddle = Art.rect(-3.4, -11.4, 5.4, 2.6, radius: 0.8)
        let robe = Art.polygon([pt(-2.2, -15.6), pt(0, -15.6), pt(1, -10.6), pt(-3, -10.6)])
        let head = Art.circle(-1.1, -16.6, 1.1)
        Art.group(&context, x: 124, y: 312, scale: 0.95) { g in
            ArtStyle.contactShadow(&g, 3, 0.4, 10, 1.6, alpha: 0.3)
            Art.fill(&g, camel, Art.color(0x8A5C34))
            Art.fill(&g, saddle, Art.color(0xB8503A))
            Art.fill(&g, robe, Art.color(0xFFF6E0))
            Art.fill(&g, head, Art.color(0x6A4028))
        }
    }

    // MARK: The near plane

    /// Dark rock at the two bottom corners, cropped by the frame.
    static func pyramidNearPlane(_ context: inout GraphicsContext) {
        let dark: [(Color, CGFloat)] = [
            (Art.color(0x7E5632), 0),
            (Art.color(0x3E2612), 1),
        ]
        let left = Art.svg("M-24,428 L-24,340 C-8,332 10,336 24,344 C40,340 56,350 66,364 C80,368 92,382 98,428 Z")
        fillVertical(&context, left, dark, from: 334, to: unitHeight)
        model(&context, left, light: 0.14, shade: 0.2, rim: 0.4)
        let right = Art.svg("M456,428 L456,348 C440,342 424,348 410,358 C394,358 380,370 372,386 C362,394 356,410 354,428 Z")
        fillVertical(&context, right, dark, from: 342, to: unitHeight)
        model(&context, right, light: 0.1, shade: 0.24)
        let clefts = Art.svg("M24,344 C28,360 22,376 30,396 M66,364 C64,378 72,392 70,410 M410,358 C406,374 414,388 410,406")
        Art.stroke(&context, clefts, Art.color(0x2E1A0C, 0.4), width: 1.2)
    }

    // MARK: Finish

    static func pyramidFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x5A3A1C, from: 300, alpha: 0.9)
        tooth(&context, seed: 617, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
